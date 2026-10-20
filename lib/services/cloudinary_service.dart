import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Upload de imagens para o Cloudinary
class CloudinaryService {
  static const String cloudName = 'dkqsqloj';
  static const String uploadPreset = 'falatea';

  static bool get configurado =>
      cloudName != 'SEU_CLOUD_NAME_AQUI' &&
      uploadPreset != 'SEU_UPLOAD_PRESET_AQUI' &&
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty;

  /// Envia uma imagem e retorna a URL
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

    request.files.add(await http.MultipartFile.fromPath('file', arquivo.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      debugPrint('Erro Cloudinary (${response.statusCode}): ${response.body}');
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
