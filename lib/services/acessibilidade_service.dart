import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de acessibilidade (modo daltonismo)
class AcessibilidadeService extends ChangeNotifier {
  static const _chaveModoDaltonismo = 'modo_daltonismo';

  bool _modoDaltonismo = false;
  bool _carregado = false;

  bool get modoDaltonismo => _modoDaltonismo;

  AcessibilidadeService() {
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _modoDaltonismo = prefs.getBool(_chaveModoDaltonismo) ?? false;
    } catch (e) {
      debugPrint('Erro ao carregar preferências de acessibilidade: $e');
    } finally {
      _carregado = true;
      notifyListeners();
    }
  }

  bool get carregado => _carregado;

  Future<void> definirModoDaltonismo(bool ativo) async {
    _modoDaltonismo = ativo;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chaveModoDaltonismo, ativo);
    } catch (e) {
      debugPrint('Erro ao salvar preferências de acessibilidade: $e');
    }
  }
}
