import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../widgets/common.dart';
import 'history_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppStore store;
  const SettingsScreen({required this.store, super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const PageHeading(
          'Do seu jeito',
          'Suas preferências',
          subtitle: 'Ajuste a leitura e informe seu perfil de mobilidade.',
        ),
        DropdownButtonFormField<String>(
          initialValue: store.mobility,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Perfil de mobilidade'),
          items:
              [
                    'Pessoa com mobilidade reduzida',
                    'Pessoa cadeirante',
                    'Pessoa com deficiência visual',
                    'Pedestre',
                  ]
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: (s) => store.setAccessibility(profile: s),
        ),
        const SizedBox(height: 18),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Textos maiores'),
          subtitle: const Text('Aumenta o tamanho da leitura'),
          value: store.largeText,
          onChanged: (v) => store.setAccessibility(large: v),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Alto contraste'),
          subtitle: const Text('Reforça o contraste dos controles'),
          value: store.highContrast,
          onChanged: (v) => store.setAccessibility(contrast: v),
        ),
        const Divider(height: 32),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.fact_check_outlined),
          title: const Text('Minhas ocorrências'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => HistoryScreen(store: store),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: const Text('Como o app funciona'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (ctx) =>
                  WelcomeScreen(onStart: () => Navigator.pop(ctx)),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const NoteBox(
          'Mobilidade PVH · protótipo acadêmico\nFlutter e Dart · IFRO\n\nMapas: © OpenStreetMap contributors. Notícias e marcadores são exemplos. Fotos, preferências e registros ficam no aparelho; desinstalar o aplicativo apaga esses dados.',
        ),
      ],
    ),
  );
}
