import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _vozFeminina = true;
  double _velocidadeFala = 0.5;
  double _tomVoz = 1.0;
  double _volume = 1.0;
  bool _isInitialized = false;

  bool get vozFeminina => _vozFeminina;
  double get velocidadeFala => _velocidadeFala;
  double get tomVoz => _tomVoz;
  double get volume => _volume;

  FlutterTts get tts => _tts;

  TtsService() {
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      debugPrint('🔊 Inicializando TTS...');

      if (Platform.isAndroid) {
        await _tts.setSharedInstance(true);
        await _tts.awaitSpeakCompletion(true);
      }

      // Verifica se pt-BR está disponível
      final isAvailable = await _tts.isLanguageAvailable('pt-BR');

      if (isAvailable) {
        await _tts.setLanguage('pt-BR');
        debugPrint('✅ pt-BR disponível');
      } else {
        debugPrint('⚠️ pt-BR não disponível');
        await _tts.setLanguage('pt-BR'); // Tenta configurar mesmo assim
      }

      await _carregarConfiguracoes();
      await _aplicarConfiguracoes();

      _tts.setStartHandler(() {
        debugPrint('🔊 Iniciando fala');
      });

      _tts.setCompletionHandler(() {
        debugPrint('✅ Fala concluída');
      });

      _tts.setErrorHandler((msg) {
        debugPrint('❌ Erro TTS: $msg');
      });

      _isInitialized = true;
      debugPrint('✅ TTS inicializado');

    } catch (e) {
      debugPrint('❌ Erro ao inicializar TTS: $e');
      _isInitialized = false;
    }
  }

  Future<void> _carregarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _vozFeminina = prefs.getBool('tts_voz_feminina') ?? true;
      _velocidadeFala = prefs.getDouble('tts_velocidade') ?? 0.5;
      _tomVoz = prefs.getDouble('tts_tom') ?? 1.0;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar config: $e');
    }
  }

  Future<void> _salvarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tts_voz_feminina', _vozFeminina);
      await prefs.setDouble('tts_velocidade', _velocidadeFala);
      await prefs.setDouble('tts_tom', _tomVoz);
      await prefs.setDouble('tts_volume', _volume);
      debugPrint('✅ Configurações salvas');
    } catch (e) {
      debugPrint('❌ Erro ao salvar config: $e');
    }
  }

  Future<void> _aplicarConfiguracoes() async {
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(_velocidadeFala);
      await _tts.setVolume(_volume);

      // Define o pitch (tom) baseado no gênero
      double pitchAjustado = _vozFeminina ? _tomVoz * 1.2 : _tomVoz * 0.9;
      await _tts.setPitch(pitchAjustado);

      // ESTRATÉGIA: Tenta usar vozes de alta qualidade, se não conseguir usa offline
      bool vozDefinida = false;

      try {
        // TENTA PRIMEIRO: Vozes de alta qualidade (network)
        if (_vozFeminina) {
          await _tts.setVoice({
            "name": "pt-br-x-pte-network",
            "locale": "pt-BR",
          });
          debugPrint('✅ Voz feminina de alta qualidade definida');
          vozDefinida = true;
        } else {
          await _tts.setVoice({
            "name": "pt-br-x-ptd-network",
            "locale": "pt-BR",
          });
          debugPrint('✅ Voz masculina de alta qualidade definida');
          vozDefinida = true;
        }
      } catch (e) {
        debugPrint('⚠️ Vozes de alta qualidade não disponíveis: $e');
        vozDefinida = false;
      }

      // FALLBACK: Se não conseguiu definir vozes network, usa vozes offline
      if (!vozDefinida) {
        try {
          final voices = await _tts.getVoices;
          if (voices != null && voices.isNotEmpty) {
            debugPrint('📋 Procurando vozes offline...');

            // Procura vozes PT (qualquer uma disponível)
            final ptVoices = voices.where((v) {
              final locale = v['locale']?.toString().toLowerCase() ?? '';
              return locale.startsWith('pt');
            }).toList();

            if (ptVoices.isNotEmpty) {
              debugPrint('✅ ${ptVoices.length} vozes PT encontradas');

              // Tenta filtrar por gênero
              final filteredVoices = ptVoices.where((v) {
                final name = v['name']?.toString().toLowerCase() ?? '';
                if (_vozFeminina) {
                  return name.contains('female') || name.contains('pte') || name.contains('f0');
                } else {
                  return name.contains('male') || name.contains('ptd') || name.contains('m0');
                }
              }).toList();

              if (filteredVoices.isNotEmpty) {
                await _tts.setVoice({
                  'name': filteredVoices.first['name'],
                  'locale': filteredVoices.first['locale']
                });
                debugPrint('✅ Voz ${_vozFeminina ? "feminina" : "masculina"} offline: ${filteredVoices.first['name']}');
              } else {
                // Usa primeira voz PT disponível
                await _tts.setVoice({
                  'name': ptVoices.first['name'],
                  'locale': ptVoices.first['locale']
                });
                debugPrint('✅ Voz PT padrão: ${ptVoices.first['name']}');
              }
            } else {
              debugPrint('⚠️ Nenhuma voz PT, usando padrão do sistema');
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao buscar vozes offline: $e');
        }
      }

      debugPrint('✅ Config aplicadas → Voz: ${_vozFeminina ? "Feminina" : "Masculina"}');
    } catch (e) {
      debugPrint('❌ Erro ao aplicar config: $e');
    }
  }

  Future<void> alternarVoz() async {
    _vozFeminina = !_vozFeminina;
    await _aplicarConfiguracoes();
    await _salvarConfiguracoes();
    notifyListeners();
  }

  Future<void> setVelocidade(double velocidade) async {
    _velocidadeFala = velocidade.clamp(0.3, 1.0);
    await _tts.setSpeechRate(_velocidadeFala);
    await _salvarConfiguracoes();
    notifyListeners();
  }

  Future<void> setTom(double tom) async {
    _tomVoz = tom.clamp(0.5, 2.0);
    await _aplicarConfiguracoes();
    await _salvarConfiguracoes();
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
    await _salvarConfiguracoes();
    notifyListeners();
  }

  Future<void> falar(String texto) async {
    if (texto.trim().isEmpty) {
      debugPrint('⚠️ Texto vazio');
      return;
    }

    try {
      if (!_isInitialized) {
        debugPrint('⚠️ Reinicializando TTS...');
        await _inicializar();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await _tts.stop();
      debugPrint('🔊 Falando: "$texto"');

      final result = await _tts.speak(texto);

      if (result == 1) {
        debugPrint('✅ Fala iniciada');
      } else {
        debugPrint('⚠️ Código: $result');
      }
    } catch (e) {
      debugPrint('❌ Erro ao falar: $e');
      _isInitialized = false;
      await _inicializar();
    }
  }

  Future<void> parar() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('❌ Erro ao parar: $e');
    }
  }

  Future<void> testarVoz() async {
    String textoTeste = _vozFeminina
        ? "Olá! Esta é a voz feminina do FalaTEA."
        : "Olá! Esta é a voz masculina do FalaTEA.";
    await _aplicarConfiguracoes();
    await falar(textoTeste);
  }

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