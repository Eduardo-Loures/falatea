import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:projeto/models/perfil_model.dart';
import 'package:projeto/models/botao_aac_model.dart';

class PerfilService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Perfil> _perfis = [];
  Perfil? _perfilAtivo;

  List<Perfil> get perfis => _perfis;
  Perfil? get perfilAtivo => _perfilAtivo;
  bool get temPerfis => _perfis.isNotEmpty;
  int get quantidadePerfis => _perfis.length;

  // Armazena categorias e botões carregados do perfil ativo
  Map<String, Color> _categorias = {};
  Map<String, List<BotaoAAC>> _botoesPersonalizados = {};

  // Armazena categorias e botões carregados do perfil ativo
  Map<String, Color> _categoriasSalvas = {};
  Map<String, List<BotaoAAC>> _botoesSalvos = {};

  Map<String, Color> get categoriasSalvas => _categoriasSalvas;
  Map<String, List<BotaoAAC>> get botoesSalvos => _botoesSalvos;

  // Pega o UID do usuário atual
  String? get _userUid => _auth.currentUser?.uid;

  PerfilService() {
    _inicializar();

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Usuário logou, carrega dados
        print('AuthStateChanged: Usuário logou, carregando dados');
        carregarDadosUsuario();
      } else {
        // Usuário deslogou, limpa memória
        print('AuthStateChanged: Usuário deslogou, limpando memória');
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
    print(' DEBUG: Iniciando carregarDadosUsuario');
    print(' DEBUG: _userUid = $_userUid');

    if (_userUid == null) {
      print('Nenhum usuário autenticado');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Carregar perfis primeiro
      final key = 'perfis_user_$_userUid';
      final jsonString = prefs.getString(key);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> perfisJson = jsonDecode(jsonString);
        _perfis = perfisJson.map((json) => Perfil.fromJson(json)).toList();

        final perfilAtivoId = prefs.getString('perfil_ativo_user_$_userUid');

        if (perfilAtivoId != null) {
          try {
            _perfilAtivo = _perfis.firstWhere((p) => p.id == perfilAtivoId);
          } catch (e) {
            _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
          }
        } else {
          _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
        }
      } else {
        _perfis = [];
        _perfilAtivo = null;
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
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  // LIMPAR DADOS DA MEMÓRIA AO FAZER LOGOUT (NÃO DELETA DO STORAGE)
  void limparDadosMemoria() {
    // Limpa apenas da memória, NÃO deleta do SharedPreferences
    _perfis = [];
    _perfilAtivo = null;
    notifyListeners();
    print('Dados limpos da memória (mantidos no storage)');
  }


  // DELETAR TODOS OS DADOS DO USUÁRIO (USE COM CUIDADO!)
  Future<void> deletarTodosDadosUsuario() async {
    if (_userUid == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove todas as chaves relacionadas ao usuário atual
      final keys = prefs.getKeys();
      final keysParaRemover = keys.where((key) =>
          key.contains('user_$_userUid')
      ).toList();

      for (var key in keysParaRemover) {
        await prefs.remove(key);
      }

      // Limpa dados na memória
      _perfis = [];
      _perfilAtivo = null;
      notifyListeners();

      print('Todos os dados do usuário $_userUid deletados permanentemente');
    } catch (e) {
      print('Erro ao deletar dados: $e');
    }
  }


  // SALVAR PERFIS (COM UID DO USUÁRIO)

  Future<void> _salvarPerfis() async {
    print('DEBUG: Iniciando _salvarPerfis');
    print('DEBUG: _userUid = $_userUid');
    print('DEBUG: _perfis.length = ${_perfis.length}');
    print('DEBUG: _perfilAtivo = ${_perfilAtivo?.nome}');

    if (_userUid == null) {
      print('Nenhum usuário autenticado - dados não salvos');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Chave específica do usuário
      final key = 'perfis_user_$_userUid';
      print('DEBUG: Chave para salvar = $key');

      final perfisJson = _perfis.map((p) => p.toJson()).toList();
      print('DEBUG: Perfis JSON = $perfisJson');

      await prefs.setString(key, jsonEncode(perfisJson));
      print('DEBUG: Dados gravados no SharedPreferences');

      // Salva perfil ativo
      if (_perfilAtivo != null) {
        await prefs.setString('perfil_ativo_user_$_userUid', _perfilAtivo!.id);
        print('DEBUG: Perfil ativo salvo: ${_perfilAtivo!.id}');
      }

      // VERIFICA SE REALMENTE SALVOU
      final verificacao = prefs.getString(key);
      print('DEBUG: Verificação - dados salvos: ${verificacao != null ? "SIM" : "NÃO"}');

      print('Perfis salvos para usuário $_userUid');
    } catch (e) {
      print('Erro ao salvar perfis: $e');
    }
  }

  // CRIAR PERFIL
  Future<void> criarPerfil(Perfil perfil) async {
    _perfis.add(perfil);

    // Se for o primeiro perfil, define como ativo
    if (_perfis.length == 1) {
      _perfilAtivo = perfil;
    }

    await _salvarPerfis();
    notifyListeners();
  }

  // ATUALIZAR PERFIL
  Future<void> atualizarPerfil(Perfil perfil) async {
    final index = _perfis.indexWhere((p) => p.id == perfil.id);
    if (index != -1) {
      _perfis[index] = perfil;

      // Atualiza o perfil ativo se for o mesmo
      if (_perfilAtivo?.id == perfil.id) {
        _perfilAtivo = perfil;
      }

      await _salvarPerfis();
      notifyListeners();
    }
  }

  // EXCLUIR PERFIL
  Future<void> excluirPerfil(String perfilId) async {
    // Remove perfil da lista
    _perfis.removeWhere((p) => p.id == perfilId);

    // Se era o perfil ativo, seleciona outro
    if (_perfilAtivo?.id == perfilId) {
      _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
    }

    // Remove botões personalizados desse perfil
    if (_userUid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('botoes_perfil_${perfilId}_user_$_userUid');
    }

    await _salvarPerfis();
    notifyListeners();
  }

  // SELECIONAR PERFIL
  Future<void> selecionarPerfil(String perfilId) async {
    final perfil = _perfis.firstWhere(
          (p) => p.id == perfilId,
      orElse: () => throw Exception('Perfil não encontrado'),
    );

    _perfilAtivo = perfil;
    await _salvarPerfis();
    notifyListeners();
  }

  // SALVAR BOTÕES PERSONALIZADOS (COM UID)
  Future<void> salvarBotoesPerfilAtivo(Map<String, List<BotaoAAC>> botoes) async {
    if (_perfilAtivo == null || _userUid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'botoes_perfil_${_perfilAtivo!.id}_user_$_userUid';

    final jsonData = {};

    botoes.forEach((categoria, lista) {
      jsonData[categoria] = lista.map((b) => b.toJson()).toList();
    });

    await prefs.setString(key, jsonEncode(jsonData));

    // Atualiza memória interna
    _botoesSalvos = Map.from(botoes);

    notifyListeners();
  }


  // CARREGAR BOTÕES PERSONALIZADOS (COM UID)
  Map<String, List<BotaoAAC>> getBotoesPerfilAtivo() {
    if (_perfilAtivo == null) {
      print('Nenhum perfil ativo');
      return {};
    }

    if (_userUid == null) {
      print('Nenhum usuário autenticado');
      return {};
    }

    try {
      SharedPreferences.getInstance().then((prefs) {
        // CHAVE AGORA INCLUI O UID DO USUÁRIO
        final key = 'botoes_perfil_${_perfilAtivo!.id}_user_$_userUid';
        final jsonString = prefs.getString(key);

        if (jsonString != null) {
          print('Botões carregados para perfil ${_perfilAtivo!.nome} (usuário $_userUid)');
        } else {
          print('Nenhum botão salvo para este perfil e usuário');
        }
      });

      // Retorna vazio por enquanto (sincrono)
      // Os botões serão carregados de forma assíncrona na HomePage
      return {};
    } catch (e) {
      print('Erro ao carregar botões: $e');
      return {};
    }
  }

  // VERSÃO ASSÍNCRONA PARA CARREGAR BOTÕES
  Future<Map<String, List<BotaoAAC>>> getBotoesPerfilAtivoAsync() async {
    if (_perfilAtivo == null) return {};
    if (_userUid == null) return {};

    try {
      final prefs = await SharedPreferences.getInstance();

      final key = 'botoes_perfil_${_perfilAtivo!.id}_user_$_userUid';
      final jsonString = prefs.getString(key);

      if (jsonString == null) return {};

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final Map<String, List<BotaoAAC>> botoes = {};

      data.forEach((categoria, listaJson) {
        botoes[categoria] = (listaJson as List)
            .map((json) => BotaoAAC.fromJson(json))
            .toList();
      });

      return botoes;
    } catch (e) {
      print('Erro ao carregar botões: $e');
      return {};
    }
  }

  Future<void> salvarCategoriasPerfilAtivo(Map<String, Color> categorias) async {
    final prefs = await SharedPreferences.getInstance();

    final converted = categorias.map((k, v) => MapEntry(k, v.value));

    await prefs.setString('categorias_${perfilAtivo!.id}', jsonEncode(converted));
    // Atualiza memória interna
    _categoriasSalvas = Map.from(categorias);

    notifyListeners();
  }



  Future<Map<String, Color>> carregarCategoriasPerfilAtivo() async {
    if (_perfilAtivo == null) return {};

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('categorias_${_perfilAtivo!.id}');

    if (jsonString == null) return {};

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final map = decoded.map((nome, corValue) => MapEntry(nome, Color(corValue)));

    return map;
  }

  Future<void> excluirCategoria(String categoria) async {
    // Remove categoria salva (cor + botões)
    _categoriasSalvas.remove(categoria);
    _botoesSalvos.remove(categoria);

    await salvarCategoriasPerfilAtivo(_categoriasSalvas);
    await salvarBotoesPerfilAtivo(_botoesSalvos);

    // Notifica quem usa PerfilService
    notifyListeners();
  }


}