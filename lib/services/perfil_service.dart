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
    print('🔍 DEBUG: Iniciando carregarDadosUsuario');
    print('🔍 DEBUG: _userUid = $_userUid');

    if (_userUid == null) {
      print('Nenhum usuário autenticado');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega perfis do usuário específico
      final key = 'perfis_user_$_userUid';
      print('DEBUG: Chave para carregar = $key');

      final jsonString = prefs.getString(key);
      print('DEBUG: Dados carregados: ${jsonString != null ? "SIM" : "NÃO"}');

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> perfisJson = jsonDecode(jsonString);
        print('DEBUG: Quantidade de perfis no JSON = ${perfisJson.length}');

        _perfis = perfisJson.map((json) => Perfil.fromJson(json)).toList();
        print('DEBUG: Perfis carregados na memória = ${_perfis.length}');

        // Carrega perfil ativo
        final perfilAtivoId = prefs.getString('perfil_ativo_user_$_userUid');
        print('DEBUG: Perfil ativo ID = $perfilAtivoId');

        if (perfilAtivoId != null) {
          try {
            _perfilAtivo = _perfis.firstWhere((p) => p.id == perfilAtivoId);
            print('DEBUG: Perfil ativo encontrado: ${_perfilAtivo!.nome}');
          } catch (e) {
            // Se não encontrar, usa o primeiro
            _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
            print('DEBUG: Perfil ativo não encontrado, usando primeiro');
          }
        } else if (_perfis.isNotEmpty) {
          _perfilAtivo = _perfis.first;
          print('DEBUG: Nenhum perfil ativo salvo, usando primeiro');
        }

        print('${_perfis.length} perfis carregados para usuário $_userUid');
      } else {
        print('DEBUG: Nenhum dado encontrado no SharedPreferences');
        _perfis = [];
        _perfilAtivo = null;
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
    if (_perfilAtivo == null) {
      print('Nenhum perfil ativo');
      return;
    }

    if (_userUid == null) {
      print('Nenhum usuário autenticado');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // CHAVE AGORA INCLUI O UID DO USUÁRIO
      final key = 'botoes_perfil_${_perfilAtivo!.id}_user_$_userUid';

      // Filtra apenas botões NÃO-FIXOS para salvar
      final Map<String, dynamic> botoesJson = {};

      botoes.forEach((categoria, listaBotoes) {
        final botoesNaoFixos = listaBotoes
            .where((botao) => !botao.isFixo)
            .map((botao) => botao.toJson())
            .toList();

        if (botoesNaoFixos.isNotEmpty) {
          botoesJson[categoria] = botoesNaoFixos;
        }
      });

      await prefs.setString(key, jsonEncode(botoesJson));
      print('Botões salvos para perfil ${_perfilAtivo!.nome} (usuário $_userUid)');
    } catch (e) {
      print('Erro ao salvar botões: $e');
    }
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
    if (_perfilAtivo == null) {
      print('Nenhum perfil ativo');
      return {};
    }

    if (_userUid == null) {
      print('Nenhum usuário autenticado');
      return {};
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // CHAVE AGORA INCLUI O UID DO USUÁRIO
      final key = 'botoes_perfil_${_perfilAtivo!.id}_user_$_userUid';
      final jsonString = prefs.getString(key);

      if (jsonString == null) {
        print('Nenhum botão salvo para este perfil e usuário');
        return {};
      }

      final Map<String, dynamic> botoesJson = jsonDecode(jsonString);
      final Map<String, List<BotaoAAC>> botoes = {};

      botoesJson.forEach((categoria, listaBotoesJson) {
        botoes[categoria] = (listaBotoesJson as List)
            .map((json) => BotaoAAC.fromJson(json))
            .toList();
      });

      print('${botoes.length} categorias com botões carregadas para perfil ${_perfilAtivo!.nome}');
      return botoes;
    } catch (e) {
      print('Erro ao carregar botões: $e');
      return {};
    }
  }
}