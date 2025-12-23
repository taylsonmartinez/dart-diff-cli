import 'dart:convert';
import 'package:intl/intl.dart';

/// Faz o parse de uma string de data no formato dd/MM/yyyy
DateTime? _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;

  try {
    // Remove espaços em branco
    final cleanDate = dateString.trim();

    // Verifica se a string está no formato correto usando regex
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(cleanDate)) {
      return null;
    }

    // Faz o parse usando o DateFormat
    return DateFormat('dd/MM/yyyy').parse(cleanDate);
  } catch (e) {
    // Se houver erro no parse, retorna null
    return null;
  }
}

int soma(int a, int b){ 
  return a+b;
}

class Gestor {
  Gestor({
    this.id,
    required this.nome,
    this.createdDate,
    this.updatedDate,
    this.assignedTo,
    this.tags,
  });

  int? id;
  String nome;
  String? createdDate;
  String? updatedDate;
  String? assignedTo;
  List<String>? tags;

  @override
    bool operator ==(Object other) =>
    identical(this, other) || other is Gestor && id == other.id;

  factory Gestor.fromRawJson(String str) => Gestor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Gestor.fromJson(Map<String, dynamic> json) => Gestor(
    id: (json['id'] ?? '') as int?,
            nome: (json['nome'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
        'nome': nome,
        
  };

}

enum TaskTypeTaylson {
  personal,
  work,
  urgent
}

extension GestorRecord on Gestor {
  ({
   int? id,
      String nome,
  })
  get destructure => (
    id: id,
      nome: nome,
  );
}
