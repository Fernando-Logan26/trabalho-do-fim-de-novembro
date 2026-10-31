import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/occurrence.dart';
import '../services/app_store.dart';
import '../widgets/common.dart';

class ReportScreen extends StatefulWidget {
  final AppStore store;
  const ReportScreen({required this.store, super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final form = GlobalKey<FormState>();
  final address = TextEditingController(),
      description = TextEditingController();
  String type = 'Calçada danificada';
  XFile? photo;
  bool saving = false;
  @override
  void dispose() {
    address.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> choosePhoto(ImageSource source) async {
    try {
      final result = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (mounted && result != null) setState(() => photo = result);
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Não foi possível acessar a foto. Verifique as permissões.',
        );
      }
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    String? savedPath;
    try {
      final now = DateTime.now();
      if (photo != null) {
        final root = await getApplicationDocumentsDirectory();
        final directory = await Directory(
          '${root.path}/photos',
        ).create(recursive: true);
        savedPath = '${directory.path}/${now.microsecondsSinceEpoch}.jpg';
        await File(photo!.path).copy(savedPath);
      }
      await widget.store.add(
        Occurrence(
          id: now.microsecondsSinceEpoch.toString(),
          type: type,
          address: address.text.trim(),
          description: description.text.trim(),
          createdAt: now,
          photoPath: savedPath,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (savedPath != null) {
        try {
          await File(savedPath).delete();
        } catch (_) {}
      }
      if (mounted) {
        message(context, 'Não foi possível salvar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registrar ocorrência')),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const PageHeading(
              'Um caminho melhor começa aqui',
              'Conte o que encontrou',
              subtitle: 'Descreva a barreira e indique onde ela está.',
            ),
            DropdownButtonFormField<String>(
              initialValue: type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tipo de barreira'),
              items: [
                'Calçada danificada',
                'Obstáculo na passagem',
                'Rampa ausente',
                'Piso tátil danificado',
                'Outro',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: saving ? null : (s) => setState(() => type = s!),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: address,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Rua e ponto de referência',
                hintText: 'Ex.: Av. Carlos Gomes, próximo ao nº 100',
              ),
              validator: (s) => (s?.trim().length ?? 0) < 5
                  ? 'Informe a rua e um ponto de referência.'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: description,
              enabled: !saving,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'O que aconteceu?',
                alignLabelWithHint: true,
              ),
              validator: (s) => (s?.trim().length ?? 0) < 10
                  ? 'Descreva a situação com pelo menos 10 caracteres.'
                  : null,
            ),
            if (photo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(photo!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              TextButton(
                onPressed: saving ? null : () => setState(() => photo = null),
                child: const Text('Remover foto'),
              ),
            ],
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () => choosePhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
                OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () => choosePhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const NoteBox(
              'Os registros ficam somente neste celular. Este protótipo não envia solicitações à Prefeitura.',
            ),
            const SizedBox(height: 20),
            ActionButton(
              saving ? 'Salvando…' : 'Salvar ocorrência',
              saving ? null : save,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    ),
  );
}
