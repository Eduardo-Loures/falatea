import 'package:flutter/material.dart';

/// Classe que representa um botão de comunicação AAC com serialização
///
/// Esta classe armazena as informações de cada botão de comunicação,
/// incluindo texto, ícone/imagem, cor e se é fixo (não pode ser excluído)
class BotaoAAC {
  final String label;           // Texto do botão (ex: "água", "mamãe")
  final IconData? icon;         // Ícone do Material Icons (opcional)
  final String? imagePath;      // Caminho da imagem (assets ou arquivo local)
  final Color color;            // Cor de fundo do botão
  final bool isFixo;            // Se true, não pode ser excluído

  BotaoAAC(
      this.label,
      this.icon,
      this.color, {
        this.imagePath,
        this.isFixo = false,
      });

  /// Converte o botão para JSON para salvar no SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'iconCodePoint': icon?.codePoint,
      'imagePath': imagePath,
      'colorValue': color.value,
      'isFixo': isFixo,
    };
  }

  /// Cria um botão a partir de JSON carregado do SharedPreferences
  factory BotaoAAC.fromJson(Map<String, dynamic> json) {
    return BotaoAAC(
      json['label'] as String,
      json['iconCodePoint'] != null
          ? IconData(
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      )
          : null,
      Color(json['colorValue'] as int),
      imagePath: json['imagePath'] as String?,
      isFixo: json['isFixo'] as bool? ?? false,
    );
  }

  /// Cria uma cópia do botão com alguns campos modificados
  BotaoAAC copyWith({
    String? label,
    IconData? icon,
    String? imagePath,
    Color? color,
    bool? isFixo,
  }) {
    return BotaoAAC(
      label ?? this.label,
      icon ?? this.icon,
      color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      isFixo: isFixo ?? this.isFixo,
    );
  }

  @override
  String toString() {
    return 'BotaoAAC(label: $label, isFixo: $isFixo, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BotaoAAC &&
        other.label == label &&
        other.icon == icon &&
        other.imagePath == imagePath &&
        other.color == color &&
        other.isFixo == isFixo;
  }

  @override
  int get hashCode {
    return label.hashCode ^
    icon.hashCode ^
    imagePath.hashCode ^
    color.hashCode ^
    isFixo.hashCode;
  }
}