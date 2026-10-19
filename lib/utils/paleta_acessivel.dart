import 'package:flutter/material.dart';

/// Paletas de cor usadas pelo "Modo daltonismo".
///
/// A paleta segura é baseada nas paletas Okabe-Ito e IBM Color Blind
/// Safe Palette, escolhidas para ficarem distinguíveis entre si tanto
/// para quem tem visão normal quanto para protanopia, deuteranopia e
/// tritanopia (os tipos mais comuns de daltonismo).
class PaletaAcessivel {
  PaletaAcessivel._();

  /// Cores das 5 categorias fixas do app quando o modo daltonismo está
  /// DESLIGADO (as cores originais, sempre usadas por padrão).
  static const Map<String, Color> categoriasFixasPadrao = {
    'Ações': Colors.orange,
    'Pessoas': Colors.blue,
    'Objetos': Colors.teal,
    'Emoções': Colors.lightGreen,
    'Negação': Colors.red,
  };

  /// Cores das 5 categorias fixas quando o modo daltonismo está LIGADO.
  static const Map<String, Color> categoriasFixasDaltonismo = {
    'Ações': Color(0xFFE69F00), // laranja
    'Pessoas': Color(0xFF0072B2), // azul
    'Objetos': Color(0xFF009E73), // verde-azulado
    'Emoções': Color(0xFFF0E442), // amarelo
    'Negação': Color(0xFFCC79A7), // roxo-avermelhado
  };

  /// Paleta oferecida nos seletores de cor (nova categoria, novo
  /// perfil) quando o modo daltonismo está LIGADO.
  static const List<Color> seletorDaltonismo = [
    Color(0xFFE69F00), // laranja
    Color(0xFF0072B2), // azul
    Color(0xFF009E73), // verde-azulado
    Color(0xFFF0E442), // amarelo
    Color(0xFFCC79A7), // roxo-avermelhado
    Color(0xFF56B4E9), // azul-céu
    Color(0xFFD55E00), // vermelho-alaranjado
    Color(0xFF785EF0), // roxo
    Color(0xFFDC267F), // magenta
    Color(0xFF000000), // preto
  ];
}
