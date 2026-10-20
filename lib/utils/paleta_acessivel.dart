import 'package:flutter/material.dart';

/// Paletas de cor do modo daltonismo (baseadas na Okabe-Ito)
class PaletaAcessivel {
  PaletaAcessivel._();

  /// Cores padrão das categorias fixas
  static const Map<String, Color> categoriasFixasPadrao = {
    'Ações': Colors.orange,
    'Pessoas': Colors.blue,
    'Objetos': Colors.teal,
    'Emoções': Colors.lightGreen,
    'Negação': Colors.red,
  };

  /// Cores das categorias fixas no modo daltonismo
  static const Map<String, Color> categoriasFixasDaltonismo = {
    'Ações': Color(0xFFE69F00), // laranja
    'Pessoas': Color(0xFF0072B2), // azul
    'Objetos': Color(0xFF009E73), // verde-azulado
    'Emoções': Color(0xFFF0E442), // amarelo
    'Negação': Color(0xFFCC79A7), // roxo-avermelhado
  };

  /// Cores dos seletores no modo daltonismo
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
