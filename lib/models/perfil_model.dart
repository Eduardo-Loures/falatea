import 'package:flutter/material.dart';

/// Modelo de dados para Perfil de Aluno
class Perfil {
  final String id;              // ID único do perfil
  final String nome;            // Nome do aluno (ex: "Pedro", "Lucas")
  final String? foto;           // Caminho da foto do aluno (opcional)
  final Color cor;              // Cor temática do perfil
  final IconData icone;         // Ícone representativo
  final DateTime dataCriacao;   // Quando foi criado

  Perfil({
    required this.id,
    required this.nome,
    this.foto,
    required this.cor,
    required this.icone,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  /// Converte perfil para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'foto': foto,
      'corValue': cor.value,
      'iconeCodePoint': icone.codePoint,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  /// Cria perfil a partir de JSON
  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'] as String,
      nome: json['nome'] as String,
      foto: json['foto'] as String?,
      cor: Color(json['corValue'] as int),
      icone: IconData(
        json['iconeCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
    );
  }

  /// Cria cópia modificada
  Perfil copyWith({
    String? id,
    String? nome,
    String? foto,
    Color? cor,
    IconData? icone,
    DateTime? dataCriacao,
  }) {
    return Perfil(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      foto: foto ?? this.foto,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  String toString() => 'Perfil(id: $id, nome: $nome)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Perfil && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}