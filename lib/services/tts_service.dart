import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service para gerenciar configurações de Text-to-Speech
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _vozFeminina = true;        // true = feminina, false = masculina
  double _velocidadeFala = 0.5;    // 0.3 a 1.0
  double _tomVoz = 1.0;            // 0.5 a 2.0
  double _volume = 1.0;            // 0.0 a 1.0

  bool get vozFeminina => _vozFeminina;
  double get velocidadeFala => _velocidadeFala;
  double get tomVoz => _tomVoz;
  double get volume => _volume;

  FlutterTts get tts => _tts;

  TtsService() {
    _inicializar();
  }

  /// Inicializa TTS e carrega configurações salvas
  Future<void> _inicializar() async {
    await _tts.setLanguage('pt-BR');
    await _carregarConfiguracoes();
    await _aplicarConfiguracoes();
  }

  /// Carrega configurações salvas
  Future<void> _carregarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _vozFeminina = prefs.getBool('tts_voz_feminina') ?? true;
      _velocidadeFala = prefs.getDouble('tts_velocidade') ?? 0.5;
      _tomVoz = prefs.getDouble('tts_tom') ?? 1.0;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;

      print('Configurações TTS carregadas');
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar configurações TTS: $e');
    }
  }

  /// Salva configurações
  Future<void> _salvarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tts_voz_feminina', _vozFeminina);
      await prefs.setDouble('tts_velocidade', _velocidadeFala);
      await prefs.setDouble('tts_tom', _tomVoz);
      await prefs.setDouble('tts_volume', _volume);

      print('Configurações TTS salvas');
    } catch (e) {
      print('Erro ao salvar configurações TTS: $e');
    }
  }

  /// Aplica as configurações ao TTS
  Future<void> _aplicarConfiguracoes() async {
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(_velocidadeFala);
      await _tts.setPitch(_tomVoz);
      await _tts.setVolume(_volume);

      // Tenta configurar voz específica (funcionalidade limitada no Flutter TTS)
      // No Android/iOS, a voz masculina/feminina depende das vozes instaladas
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android geralmente tem vozes diferentes instaladas
        // Exemplo: pt-br-x-ptd-local (masculina) ou pt-br-x-ptd-network (feminina)
        // A disponibilidade depende do dispositivo
      }

      print('Configurações TTS aplicadas');
    } catch (e) {
      print('Erro ao aplicar configurações TTS: $e');
    }
  }

  /// Alterna entre voz feminina e masculina
  Future<void> alternarVoz() async {
    _vozFeminina = !_vozFeminina;
    await _aplicarConfiguracoes();
    await _salvarConfiguracoes();
    notifyListeners();
  }

  /// Define velocidade da fala
  Future<void> setVelocidade(double velocidade) async {
    _velocidadeFala = velocidade.clamp(0.3, 1.0);
    await _tts.setSpeechRate(_velocidadeFala);
    await _salvarConfiguracoes();
    notifyListeners();
  }

  /// Define tom de voz
  Future<void> setTom(double tom) async {
    _tomVoz = tom.clamp(0.5, 2.0);
    await _tts.setPitch(_tomVoz);
    await _salvarConfiguracoes();
    notifyListeners();
  }

  /// Define volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
    await _salvarConfiguracoes();
    notifyListeners();
  }

  /// Fala um texto
  Future<void> falar(String texto) async {
    try {
      await _tts.speak(texto);
    } catch (e) {
      print('Erro ao falar: $e');
    }
  }

  /// Para a fala atual
  Future<void> parar() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Erro ao parar TTS: $e');
    }
  }

  /// Testa a voz com uma frase
  Future<void> testarVoz() async {
    String textoTeste = _vozFeminina
        ? "Olá! Eu sou a voz feminina do FalaTEA."
        : "Olá! Eu sou a voz masculina do FalaTEA.";
    await falar(textoTeste);
  }

  /// Reseta configurações para padrão
  Future<void> resetarConfiguracoes() async {
    _vozFeminina = true;
    _velocidadeFala = 0.5;
    _tomVoz = 1.0;
    _volume = 1.0;

    await _aplicarConfiguracoes();
    await _salvarConfiguracoes();
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}