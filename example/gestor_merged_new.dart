import 'dart:convert';
import 'package:intl/intl.dart';

DateTime? _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    final cleanDate = dateString.trim();
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(cleanDate)) {
      return null;
    }
    return DateFormat('dd/MM/yyyy').parse(cleanDate);
  } catch (e) {
    return null;
  }
}

class Gestor {
  Gestor(
      {this.id,
      required this.nome,
      this.createdDate,
      this.updatedDate,
      this.assignedTo,
      this.tags});
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
      id: (json['id'] ?? '') as int?, nome: (json['nome'] ?? '') as String);
  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};
}

enum TaskTypeTaylson { personal, work, urgent }

extension GestorRecord on Gestor {
  ({int? id, String nome}) get destructure => (id: id, nome: nome);
}

int soma(int a, int b) {
  return a + b;
}
