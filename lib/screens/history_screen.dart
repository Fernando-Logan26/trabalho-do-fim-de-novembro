import 'dart:io';
import 'package:flutter/material.dart';
import '../models/occurrence.dart';
import '../services/app_store.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatelessWidget {
  final AppStore store;
  const HistoryScreen({required this.store, super.key});
  String date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  Future<void> details(BuildContext context, Occurrence item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tag('SALVO NESTE CELULAR · ${date(item.createdAt)}'),
              const SizedBox(height: 16),
              Text(item.type, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                item.address,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(item.description),
              if (item.photoPath != null) ...[
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(item.photoPath!),
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Text('Foto indisponível.'),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const NoteBox(
                'Registro pessoal de demonstração. Não existe protocolo municipal ou acompanhamento por um órgão público.',
              ),
              if (store.signedIn) TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir registro'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: ctx,
                    builder: (dialog) => AlertDialog(
                      title: const Text('Excluir ocorrência?'),
                      content: const Text(
                        'O registro e sua foto serão removidos deste celular.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await store.remove(item);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (_) {
                      if (ctx.mounted) {
                        message(ctx, 'Não foi possível excluir.');
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Minhas ocorrências')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => store.reports.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fact_check_outlined, size: 56, color: brand),
                      SizedBox(height: 16),
                      Text(
                        'Você ainda não tem registros.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Use “Registrar uma barreira” na tela inicial.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const NoteBox('Histórico local · não enviado à Prefeitura'),
                  const SizedBox(height: 12),
                  for (final item in store.reports)
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.report_outlined,
                          color: brand,
                        ),
                        title: Text(item.type),
                        subtitle: Text(
                          '${item.address}\n${date(item.createdAt)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => details(context, item),
                      ),
                    ),
                ],
              ),
      ),
    ),
  );
}
