import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../model/gestor.dart';
import '../store/gestor_store.dart';
import '../../../shared/widgets/date_picker_field.dart';
import 'package:file_selector/file_selector.dart';

class GestorFormPage extends StatefulWidget {
  final Gestor gestor;
  const GestorFormPage({super.key, required this.gestor});
  @override
  State<GestorFormPage> createState() => _GestorFormPageState();
}

class _GestorFormPageState extends State<GestorFormPage> {
  late final TextEditingController _nomeController;
  late final GestorStore _store;
  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.gestor.nome);
    _store = Modular.get<GestorStore>();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('nome é obrigatório')));
      return;
    }
    if (widget.gestor.id == null) {
      final newRecord = Gestor(nome: _nomeController.text.trim());
      await _store.createGestor(newRecord);
    } else {
      final updatedRecord = Gestor(
          id: widget.gestor.id,
          nome: _nomeController.text.trim(),
          createdDate: widget.gestor.createdDate,
          updatedDate: DateTime.now().toIso8601String());
      await _store.updateGestor(updatedRecord);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.gestor.id == null ? 'Novo(a) Gestor' : 'Editar Gestor')),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(children: [
              Card(
                  elevation: 2,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Informações Principais',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700)),
                            const SizedBox(height: 16),
                            TextField(
                                controller: _nomeController,
                                key: ValueKey('main'),
                                decoration: InputDecoration(
                                    labelText: 'Nome',
                                    hintText: 'Nome...',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.edit))),
                            TextField(
                                controller: _nomeController,
                                key: ValueKey('main'),
                                decoration: InputDecoration(
                                    labelText: 'Cidade',
                                    hintText: 'Cidade...',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.edit))),
                            const SizedBox(height: 16)
                          ]))),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Salvar Gestor',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))))
            ])));
  }
}
