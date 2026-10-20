import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:projeto/models/perfil_model.dart';
import 'package:projeto/models/botao_aac_model.dart';

/// Gerencia Perfis, Categorias e Botões do usuário (Firestore)
class PerfilService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Perfil> _perfis = [];
  Perfil? _perfilAtivo;

  List<Perfil> get perfis => _perfis;

  Perfil? get perfilAtivo => _perfilAtivo;

  bool get temPerfis => _perfis.isNotEmpty;

  int get quantidadePerfis => _perfis.length;

  // Armazena categorias e botões carregados do perfil ativo
  Map<String, Color> _categoriasSalvas = {};
  Map<String, List<BotaoAAC>> _botoesSalvos = {};

  Map<String, Color> get categoriasSalvas => _categoriasSalvas;

  Map<String, List<BotaoAAC>> get botoesSalvos => _botoesSalvos;

  // Pega o UID do usuário atual
  String? get _userUid => _auth.currentUser?.uid;

  // Referências Firestore do usuário atual
  DocumentReference<Map<String, dynamic>> get _usuarioDoc =>
      _db.collection('usuarios').doc(_userUid);

  CollectionReference<Map<String, dynamic>> get _perfisCol =>
      _usuarioDoc.collection('perfis');

  CollectionReference<Map<String, dynamic>> _categoriasCol(String perfilId) =>
      _perfisCol.doc(perfilId).collection('categorias');

  PerfilService() {
    _inicializar();

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Usuário logou, carrega dados
        debugPrint('AuthStateChanged: Usuário logou, carregando dados');
        carregarDadosUsuario();
      } else {
        // Usuário deslogou, limpa memória
        debugPrint('AuthStateChanged: Usuário deslogou, limpando memória');
        limparDadosMemoria();
      }
    });
  }

  Future<void> _inicializar() async {
    // Aguarda autenticação estar pronta
    await Future.delayed(const Duration(milliseconds: 100));
    await carregarDadosUsuario();
  }

  // CARREGAR DADOS DO USUÁRIO AO FAZER LOGIN
  Future<void> carregarDadosUsuario() async {
    if (_userUid == null) {
      debugPrint('Nenhum usuário autenticado');
      return;
    }

    try {
      await _migrarDadosLocaisSeNecessario();

      // Carrega perfis do Firestore
      final perfisSnap = await _perfisCol.orderBy('dataCriacao').get();
      _perfis =
          perfisSnap.docs.map((doc) => Perfil.fromJson(doc.data())).toList();

      final usuarioSnap = await _usuarioDoc.get();
      final perfilAtivoId = usuarioSnap.data()?['perfilAtivoId'] as String?;

      if (perfilAtivoId != null) {
        try {
          _perfilAtivo = _perfis.firstWhere((p) => p.id == perfilAtivoId);
        } catch (e) {
          _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
        }
      } else {
        _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
      }

      // Só carregue categorias/botões SE existir perfil ativo
      if (_perfilAtivo != null) {
        _categoriasSalvas = await carregarCategoriasPerfilAtivo();
        _botoesSalvos = await getBotoesPerfilAtivoAsync();
      } else {
        _categoriasSalvas = {};
        _botoesSalvos = {};
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
  }

  // MIGRAÇÃO ÚNICA DOS DADOS LOCAIS (SharedPreferences) PARA O FIRESTORE
  Future<void> _migrarDadosLocaisSeNecessario() async {
    if (_userUid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final flagKey = 'migrado_firestore_user_$_userUid';

    if (prefs.getBool(flagKey) == true) return; // já migrado antes

    try {
      final key = 'perfis_user_$_userUid';
      final jsonString = prefs.getString(key);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> perfisJson = jsonDecode(jsonString);
        final perfisLocais =
            perfisJson.map((json) => Perfil.fromJson(json)).toList();

        debugPrint(
          'Migrando ${perfisLocais.length} perfil(is) local(is) para o Firestore...',
        );

        for (final perfil in perfisLocais) {
          final existente = await _perfisCol.doc(perfil.id).get();
          if (existente.exists) continue; // não sobrescreve o que já há

          await _perfisCol.doc(perfil.id).set(perfil.toJson());

          // Migra categorias (cores) desse perfil
          final categoriasJson = prefs.getString('categorias_${perfil.id}');
          final Map<String, Color> categoriasLocais = {};
          if (categoriasJson != null) {
            final decoded = jsonDecode(categoriasJson) as Map<String, dynamic>;
            decoded.forEach((nome, corValue) {
              categoriasLocais[nome] = Color(corValue as int);
            });
          }

          // Migra botões personalizados desse perfil
          final botoesJson = prefs.getString(
            'botoes_perfil_${perfil.id}_user_$_userUid',
          );
          final Map<String, List<BotaoAAC>> botoesLocais = {};
          if (botoesJson != null) {
            final Map<String, dynamic> decoded = jsonDecode(botoesJson);
            decoded.forEach((categoria, listaJson) {
              botoesLocais[categoria] =
                  (listaJson as List).map((j) => BotaoAAC.fromJson(j)).toList();
            });
          }

          final nomesCategorias = {
            ...categoriasLocais.keys,
            ...botoesLocais.keys,
          };

          final batch = _db.batch();
          for (final nome in nomesCategorias) {
            final docRef = _categoriasCol(perfil.id).doc(nome);
            batch.set(docRef, {
              if (categoriasLocais.containsKey(nome))
                'cor': categoriasLocais[nome]!.toARGB32(),
              'botoes':
                  (botoesLocais[nome] ?? []).map((b) => b.toJson()).toList(),
            }, SetOptions(merge: true));
          }
          await batch.commit();
        }

        // Migra o perfil ativo
        final perfilAtivoId = prefs.getString('perfil_ativo_user_$_userUid');
        if (perfilAtivoId != null) {
          await _usuarioDoc.set({
            'perfilAtivoId': perfilAtivoId,
          }, SetOptions(merge: true));
        }

        debugPrint('Migração para o Firestore concluída.');
      }

      await prefs.setBool(flagKey, true);
    } catch (e) {
      debugPrint('Erro ao migrar dados locais para o Firestore: $e');
      // Não marca a flag, para tentar migrar novamente na próxima vez
    }
  }

  // LIMPAR DADOS DA MEMÓRIA AO FAZER LOGOUT (NÃO DELETA DO FIRESTORE)
  void limparDadosMemoria() {
    _perfis = [];
    _perfilAtivo = null;
    _categoriasSalvas = {};
    _botoesSalvos = {};
    notifyListeners();
    debugPrint('Dados limpos da memória (mantidos no Firestore)');
  }

  // DELETAR TODOS OS DADOS DO USUÁRIO (USE COM CUIDADO!)
  Future<void> deletarTodosDadosUsuario() async {
    if (_userUid == null) return;

    try {
      for (final perfil in _perfis) {
        await _excluirPerfilDoFirestore(perfil.id);
      }

      await _usuarioDoc.delete();

      _perfis = [];
      _perfilAtivo = null;
      _categoriasSalvas = {};
      _botoesSalvos = {};
      notifyListeners();

      debugPrint(
        'Todos os dados do usuário $_userUid deletados permanentemente',
      );
    } catch (e) {
      debugPrint('Erro ao deletar dados: $e');
    }
  }

  // CRIAR PERFIL
  Future<void> criarPerfil(Perfil perfil) async {
    if (_userUid == null) return;

    await _perfisCol.doc(perfil.id).set(perfil.toJson());
    _perfis.add(perfil);

    // Se for o primeiro perfil, define como ativo
    if (_perfis.length == 1) {
      _perfilAtivo = perfil;
      await _usuarioDoc.set({
        'perfilAtivoId': perfil.id,
      }, SetOptions(merge: true));
    }

    notifyListeners();
  }

  // ATUALIZAR PERFIL
  Future<void> atualizarPerfil(Perfil perfil) async {
    if (_userUid == null) return;

    final index = _perfis.indexWhere((p) => p.id == perfil.id);
    if (index != -1) {
      await _perfisCol.doc(perfil.id).set(perfil.toJson());

      _perfis[index] = perfil;

      if (_perfilAtivo?.id == perfil.id) {
        _perfilAtivo = perfil;
      }

      notifyListeners();
    }
  }

  // EXCLUIR PERFIL
  Future<void> excluirPerfil(String perfilId) async {
    if (_userUid == null) return;

    await _excluirPerfilDoFirestore(perfilId);

    _perfis.removeWhere((p) => p.id == perfilId);

    if (_perfilAtivo?.id == perfilId) {
      _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
      await _usuarioDoc.set({
        'perfilAtivoId': _perfilAtivo?.id,
      }, SetOptions(merge: true));

      if (_perfilAtivo != null) {
        _categoriasSalvas = await carregarCategoriasPerfilAtivo();
        _botoesSalvos = await getBotoesPerfilAtivoAsync();
      } else {
        _categoriasSalvas = {};
        _botoesSalvos = {};
      }
    }

    notifyListeners();
  }

  Future<void> _excluirPerfilDoFirestore(String perfilId) async {
    // Apaga as categorias manualmente (Firestore não apaga subcoleções)
    final categoriasSnap = await _categoriasCol(perfilId).get();
    final batch = _db.batch();
    for (final doc in categoriasSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_perfisCol.doc(perfilId));
    await batch.commit();
  }

  // SELECIONAR PERFIL
  Future<void> selecionarPerfil(String perfilId) async {
    if (_userUid == null) return;

    final perfil = _perfis.firstWhere(
      (p) => p.id == perfilId,
      orElse: () => throw Exception('Perfil não encontrado'),
    );

    _perfilAtivo = perfil;
    await _usuarioDoc.set({'perfilAtivoId': perfilId}, SetOptions(merge: true));

    _categoriasSalvas = await carregarCategoriasPerfilAtivo();
    _botoesSalvos = await getBotoesPerfilAtivoAsync();

    notifyListeners();
  }

  // SALVAR BOTÕES PERSONALIZADOS
  Future<void> salvarBotoesPerfilAtivo(
    Map<String, List<BotaoAAC>> botoes,
  ) async {
    if (_perfilAtivo == null || _userUid == null) return;

    // Zera os botões das categorias que não vieram no mapa
    final categoriasExistentes = await _categoriasCol(_perfilAtivo!.id).get();
    final nomesExistentes = categoriasExistentes.docs.map((d) => d.id).toSet();
    final nomes = {...nomesExistentes, ...botoes.keys};

    final batch = _db.batch();
    for (final nome in nomes) {
      final docRef = _categoriasCol(_perfilAtivo!.id).doc(nome);
      final lista = botoes[nome] ?? [];
      batch.set(docRef, {
        'botoes': lista.map((b) => b.toJson()).toList(),
      }, SetOptions(merge: true));
    }
    await batch.commit();

    // Atualiza memória interna
    _botoesSalvos = Map.from(botoes);

    notifyListeners();
  }

  // CARREGAR BOTÕES PERSONALIZADOS DO PERFIL ATIVO
  Future<Map<String, List<BotaoAAC>>> getBotoesPerfilAtivoAsync() async {
    if (_perfilAtivo == null || _userUid == null) return {};

    try {
      final snap = await _categoriasCol(_perfilAtivo!.id).get();
      final Map<String, List<BotaoAAC>> botoes = {};

      for (final doc in snap.docs) {
        final lista = doc.data()['botoes'] as List<dynamic>?;
        if (lista == null || lista.isEmpty) continue;
        botoes[doc.id] =
            lista
                .map((json) => BotaoAAC.fromJson(json as Map<String, dynamic>))
                .toList();
      }

      return botoes;
    } catch (e) {
      debugPrint('Erro ao carregar botões: $e');
      return {};
    }
  }

  // SALVAR CORES DAS CATEGORIAS DO PERFIL ATIVO
  Future<void> salvarCategoriasPerfilAtivo(
    Map<String, Color> categorias,
  ) async {
    if (_perfilAtivo == null) return;

    final batch = _db.batch();
    categorias.forEach((nome, cor) {
      final docRef = _categoriasCol(_perfilAtivo!.id).doc(nome);
      batch.set(docRef, {'cor': cor.toARGB32()}, SetOptions(merge: true));
    });
    await batch.commit();

    // Atualiza memória interna
    _categoriasSalvas = Map.from(categorias);

    notifyListeners();
  }

  Future<Map<String, Color>> carregarCategoriasPerfilAtivo() async {
    if (_perfilAtivo == null) return {};

    final snap = await _categoriasCol(_perfilAtivo!.id).get();
    final Map<String, Color> map = {};

    for (final doc in snap.docs) {
      final corValue = doc.data()['cor'] as int?;
      if (corValue != null) {
        map[doc.id] = Color(corValue);
      }
    }

    return map;
  }

  Future<void> excluirCategoria(String categoria) async {
    if (_perfilAtivo == null) return;

    // Remove o documento inteiro da categoria (cor + botões)
    await _categoriasCol(_perfilAtivo!.id).doc(categoria).delete();

    _categoriasSalvas.remove(categoria);
    _botoesSalvos.remove(categoria);

    notifyListeners();
  }
}
