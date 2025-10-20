import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projeto/models/botao_aac_model.dart';
import 'package:projeto/models/perfil_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service para gerenciar perfis e seus botões personalizados
class PerfilService extends ChangeNotifier {
  List<Perfil> _perfis = [];
  Perfil? _perfilAtivo;

  // Armazena botões personalizados por perfil
  // Estrutura: {perfilId: {categoria: [BotaoAAC]}}
  Map<String, Map<String, List<BotaoAAC>>> _botoesPersonalizadosPorPerfil = {};

  List<Perfil> get perfis => _perfis;
  Perfil? get perfilAtivo => _perfilAtivo;

  PerfilService() {
    carregarPerfis();
  }

  /// Carrega todos os perfis salvos
  Future<void> carregarPerfis() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega lista de perfis
      String? perfisJson = prefs.getString('perfis');
      if (perfisJson != null && perfisJson.isNotEmpty) {
        List<dynamic> perfisList = json.decode(perfisJson);
        _perfis = perfisList.map((p) => Perfil.fromJson(p)).toList();
      }

      // Carrega perfil ativo
      String? perfilAtivoId = prefs.getString('perfil_ativo_id');
      if (perfilAtivoId != null && _perfis.isNotEmpty) {
        try {
          _perfilAtivo = _perfis.firstWhere((p) => p.id == perfilAtivoId);
        } catch (e) {
          _perfilAtivo = _perfis.first;
        }
      } else if (_perfis.isNotEmpty) {
        _perfilAtivo = _perfis.first;
      }

      // Carrega botões personalizados de todos os perfis
      await _carregarTodosBotoesPersonalizados();

      notifyListeners();
      print('Perfis carregados: ${_perfis.length}');
    } catch (e) {
      print('Erro ao carregar perfis: $e');
    }
  }

  /// Salva todos os perfis
  Future<void> _salvarPerfis() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String perfisJson = json.encode(_perfis.map((p) => p.toJson()).toList());
      await prefs.setString('perfis', perfisJson);
      print('Perfis salvos com sucesso!');
    } catch (e) {
      print('Erro ao salvar perfis: $e');
    }
  }

  /// Cria um novo perfil
  Future<void> criarPerfil(Perfil perfil) async {
    _perfis.add(perfil);
    await _salvarPerfis();

    // Inicializa estrutura vazia de botões para este perfil
    _botoesPersonalizadosPorPerfil[perfil.id] = {};

    notifyListeners();
  }

  /// Atualiza um perfil existente
  Future<void> atualizarPerfil(Perfil perfilAtualizado) async {
    int index = _perfis.indexWhere((p) => p.id == perfilAtualizado.id);
    if (index != -1) {
      _perfis[index] = perfilAtualizado;
      await _salvarPerfis();

      if (_perfilAtivo?.id == perfilAtualizado.id) {
        _perfilAtivo = perfilAtualizado;
      }

      notifyListeners();
    }
  }

  /// Exclui um perfil
  Future<void> excluirPerfil(String perfilId) async {
    _perfis.removeWhere((p) => p.id == perfilId);
    await _salvarPerfis();

    // Remove botões personalizados deste perfil
    _botoesPersonalizadosPorPerfil.remove(perfilId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('botoes_personalizados_$perfilId');

    // Se era o perfil ativo, seleciona outro
    if (_perfilAtivo?.id == perfilId) {
      _perfilAtivo = _perfis.isNotEmpty ? _perfis.first : null;
      if (_perfilAtivo != null) {
        await selecionarPerfil(_perfilAtivo!.id);
      }
    }

    notifyListeners();
  }

  /// Seleciona um perfil como ativo
  Future<void> selecionarPerfil(String perfilId) async {
    _perfilAtivo = _perfis.firstWhere((p) => p.id == perfilId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_ativo_id', perfilId);

    notifyListeners();
    print('Perfil ativo: ${_perfilAtivo?.nome}');
  }

  /// Carrega botões personalizados de todos os perfis
  Future<void> _carregarTodosBotoesPersonalizados() async {
    final prefs = await SharedPreferences.getInstance();

    for (var perfil in _perfis) {
      String? botoesJson = prefs.getString('botoes_personalizados_${perfil.id}');

      if (botoesJson != null && botoesJson.isNotEmpty) {
        Map<String, dynamic> dadosSalvos = json.decode(botoesJson);
        Map<String, List<BotaoAAC>> botoesCategorizados = {};

        dadosSalvos.forEach((categoria, botoesList) {
          botoesCategorizados[categoria] = (botoesList as List)
              .map((b) => BotaoAAC.fromJson(b))
              .toList();
        });

        _botoesPersonalizadosPorPerfil[perfil.id] = botoesCategorizados;
      } else {
        _botoesPersonalizadosPorPerfil[perfil.id] = {};
      }
    }
  }

  /// Retorna botões personalizados do perfil ativo
  Map<String, List<BotaoAAC>> getBotoesPerfilAtivo() {
    if (_perfilAtivo == null) return {};
    return _botoesPersonalizadosPorPerfil[_perfilAtivo!.id] ?? {};
  }

  /// Salva botões personalizados do perfil ativo
  Future<void> salvarBotoesPerfilAtivo(Map<String, List<BotaoAAC>> categorias) async {
    if (_perfilAtivo == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Filtra apenas botões não fixos
      Map<String, List<Map<String, dynamic>>> botoesPersonalizados = {};

      categorias.forEach((categoria, botoes) {
        List<BotaoAAC> botoesNaoFixos = botoes.where((b) => !b.isFixo).toList();
        if (botoesNaoFixos.isNotEmpty) {
          botoesPersonalizados[categoria] = botoesNaoFixos.map((b) => b.toJson()).toList();
        }
      });

      String jsonString = json.encode(botoesPersonalizados);
      await prefs.setString('botoes_personalizados_${_perfilAtivo!.id}', jsonString);

      // Atualiza cache em memória
      _botoesPersonalizadosPorPerfil[_perfilAtivo!.id] = categorias;

      print('Botões do perfil ${_perfilAtivo!.nome} salvos!');
    } catch (e) {
      print('Erro ao salvar botões: $e');
    }
  }

  /// Verifica se há algum perfil criado
  bool get temPerfis => _perfis.isNotEmpty;

  /// Retorna quantidade de perfis
  int get quantidadePerfis => _perfis.length;
}