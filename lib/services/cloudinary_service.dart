import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Serviço de upload de imagens para o Cloudinary.
///
/// Usa upload "unsigned" (sem precisar de API secret no app), igual ao
/// esquema usado no site da Elicar Multimarcas.
///
/// CONFIGURAÇÃO NECESSÁRIA (painel do Cloudinary > Settings > Upload):
/// 1. Crie/copie o "Cloud name" (aparece no topo do dashboard).
/// 2. Crie um "Upload preset" do tipo "Unsigned" (Settings > Upload >
///    Upload presets > Add upload preset > Signing Mode: Unsigned).
/// 3. Preencha as duas constantes abaixo com esses valores.
class CloudinaryService {
  // TODO: preencher com os dados reais do Cloudinary (não são secretos,
  // são o cloud name e o nome do preset, ambos de uso público no cliente).
  static const String cloudName = 'dkqsqloj';
  static const String uploadPreset = 'falatea';

  static bool get configurado =>
      cloudName != 'SEU_CLOUD_NAME_AQUI' &&
      uploadPreset != 'SEU_UPLOAD_PRESET_AQUI' &&
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty;

  /// Envia uma imagem para o Cloudinary e retorna a URL segura (https).
  ///
  /// [pasta] organiza os uploads dentro do Cloudinary (ex: 'perfis', 'botoes').
  static Future<String> enviarImagem(File arquivo, {String? pasta}) async {
    if (!configurado) {
      throw Exception(
        'Cloudinary não configurado. Preencha cloudName e uploadPreset em '
        'lib/services/cloudinary_service.dart',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    if (pasta != null && pasta.isNotEmpty) {
      request.fields['folder'] = pasta;
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', arquivo.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      debugPrint(
        'Erro Cloudinary (${response.statusCode}): ${response.body}',
      );
      throw Exception('Falha ao enviar imagem para o Cloudinary.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null) {
      throw Exception('Resposta inesperada do Cloudinary (sem secure_url).');
    }

    return secureUrl;
  }
}
