import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

/// Service para gerenciar configurações de Text-to-Speech (TTS)
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _vozFeminina = true;        // true = feminina, false = masculina
  double _velocidadeFala = 0.5;    // 0.3 a 1.0
  double _tomVoz = 1.0;            // 0.5 a 2.0
  double _volume = 1.0;            // 0.0 a 1.0
  bool _isInitialized = false;

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
    try {
      debugPrint('🔊 Inicializando TTS...');

      // Configurações específicas para Android
      if (Platform.isAndroid) {
        await _tts.setSharedInstance(true);
      }

      // IMPORTANTE: Verifica se pt-BR está disponível
      final isLanguageAvailable = await _tts.isLanguageAvailable('pt-BR');

      if (isLanguageAvailable) {
        await _tts.setLanguage('pt-BR');
        debugPrint('✅ Idioma pt-BR configurado');
      } else {
        debugPrint('⚠️ pt-BR não disponível, usando configuração padrão');
        // Tenta configurar mesmo assim (alguns dispositivos funcionam)
        await _tts.setLanguage('pt-BR');
      }

      // Carrega e aplica configurações
      await _carregarConfiguracoes();
      await _aplicarConfiguracoes();

      // Configura handlers para debug
      _tts.setStartHandler(() {
        debugPrint('🔊 TTS: Iniciando fala');
      });

      _tts.setCompletionHandler(() {
        debugPrint('✅ TTS: Fala concluída');
      });

      _tts.setErrorHandler((msg) {
        debugPrint('❌ TTS Erro: $msg');
      });

      _isInitialized = true;
      debugPrint('✅ TTS inicializado com sucesso');

    } catch (e) {
      debugPrint('❌ Erro ao inicializar TTS: $e');
    }
  }

  /// Carrega configurações salvas
  Future<void> _carregarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _vozFeminina = prefs.getBool('tts_voz_feminina') ?? true;
      _velocidadeFala = prefs.getDouble('tts_velocidade') ?? 0.5;
      _tomVoz = prefs.getDouble('tts_tom') ?? 1.0;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      notifyListeners();
      debugPrint('✅ Configurações TTS carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações TTS: $e');
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
    } catch (e) {
      debugPrint('❌ Erro ao salvar configurações TTS: $e');
    }
  }

  /// Aplica as configurações ao TTS
  Future<void> _aplicarConfiguracoes() async {
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(_velocidadeFala);
      await _tts.setVolume(_volume);

      // Define o pitch (tom)
      double pitchAjustado = _vozFeminina ? _tomVoz * 1.2 : _tomVoz * 0.9;
      await _tts.setPitch(pitchAjustado);

      // Tenta definir voz específica (funciona em alguns dispositivos)
      try {
        if (_vozFeminina) {
          await _tts.setVoice({
            "name": "pt-br-x-pte-network",
            "locale": "pt-BR",
          });
        } else {
          await _tts.setVoice({
            "name": "pt-br-x-ptd-network",
            "locale": "pt-BR",
          });
        }
        debugPrint('✅ Voz específica definida: ${_vozFeminina ? "Feminina" : "Masculina"}');
      } catch (e) {
        // Se falhar ao definir voz específica, usa apenas o pitch
        debugPrint('⚠️ Voz específica não disponível, usando apenas pitch');
      }

      debugPrint('✅ Configurações aplicadas → Voz: ${_vozFeminina ? "Feminina" : "Masculina"}');
    } catch (e) {
      debugPrint('❌ Erro ao aplicar configurações TTS: $e');
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
    await _aplicarConfiguracoes();
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
    if (texto.trim().isEmpty) {
      debugPrint('⚠️ Texto vazio, não há nada para falar');
      return;
    }

    try {
      // Garante que está inicializado
      if (!_isInitialized) {
        debugPrint('⚠️ TTS não inicializado, inicializando...');
        await _inicializar();
      }

      // Para qualquer fala anterior
      await _tts.stop();

      debugPrint('🔊 Falando: "$texto"');

      // Fala o texto
      final result = await _tts.speak(texto);

      if (result == 1) {
        debugPrint('✅ Fala iniciada com sucesso');
      } else {
        debugPrint('⚠️ TTS retornou código: $result');
      }
    } catch (e) {
      debugPrint('❌ Erro ao falar: $e');
      // Tenta reinicializar em caso de erro
      _isInitialized = false;
      await _inicializar();
    }
  }

  /// Para a fala atual
  Future<void> parar() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('❌ Erro ao parar TTS: $e');
    }
  }

  /// Testa a voz com uma frase
  Future<void> testarVoz() async {
    String textoTeste = _vozFeminina
        ? "Olá! Esta é a voz feminina do FalaTEA."
        : "Olá! Esta é a voz masculina do FalaTEA.";
    await _aplicarConfiguracoes();
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