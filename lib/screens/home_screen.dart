import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../services/app_store.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppStore store;
  final VoidCallback onMap, onReport;
  const HomeScreen({required this.store, required this.onMap, required this.onReport, super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = 'Destaques';
  final news = const [
    (
      'Acessibilidade',
      'ATENÇÃO NO TRAJETO',
      'Av. Carlos Gomes: barreira na calçada',
      'Exemplo de alerta da comunidade sobre um obstáculo na faixa de passagem.',
      Color(0xFFAD4F26),
    ),
    (
      'Obras',
      'OBRAS E MANUTENÇÃO',
      'Av. Jorge Teixeira: intervenções no percurso',
      'Exemplo de notícia sobre adequação de rampas e possíveis desvios.',
      Color(0xFF876417),
    ),
    (
      'Acessibilidade',
      'ACESSIBILIDADE',
      'Duque de Caxias: melhorias na calçada',
      'Exemplo de atualização sobre recuperação de um trecho de calçada.',
      Color(0xFF237849),
    ),
  ];
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
    children: [
      const PageHeading('Mobilidade PVH', 'Meu painel',
          subtitle: 'Suas ocorrências neste aparelho.'),
      Card(child: Column(children: [
        ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: Text('Ocorrências registradas: ${widget.store.reports.length}'),
          subtitle: Text('Com foto: ${widget.store.reports.where((r) => r.photoPath != null).length}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(
            builder: (_) => HistoryScreen(store: widget.store))),
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(widget.store.signedIn ? 'Meu cadastro' : 'Entrar ou criar cadastro'),
          subtitle: Text(widget.store.profile['name'] ?? 'Você está como visitante'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            if (!widget.store.signedIn) {
              await requestLogin(context, widget.store);
            } else {
              await Navigator.push(context, MaterialPageRoute<void>(
                builder: (_) => ProfileScreen(store: widget.store)));
            }
          },
        ),
        if (widget.store.signedIn)
          ListTile(leading: const Icon(Icons.logout), title: const Text('Sair da conta'),
              onTap: widget.store.signOut),
      ])),
      const SizedBox(height: 20),
      const PageHeading(
        'Porto Velho · atualizações',
        'O que acontece\nnas suas ruas',
        subtitle: 'Informações para planejar melhor seu caminho.',
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in ['Destaques', 'Obras', 'Acessibilidade'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item),
                  selected: filter == item,
                  onSelected: (_) => setState(() => filter = item),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'NOTÍCIAS ILUSTRATIVAS DO PROTÓTIPO',
        style: TextStyle(
          fontSize: 10,
          color: muted,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
      for (final item in news.where(
        (n) => filter == 'Destaques' || filter == n.$1,
      ))
        Card(
          margin: const EdgeInsets.only(top: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tag(item.$2, color: item.$5),
                const SizedBox(height: 12),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (item == news.first) ...[
                  const SizedBox(height: 16),
                  const CityIllustration(),
                ],
                const SizedBox(height: 12),
                Text(
                  item.$4,
                  style: const TextStyle(color: muted, height: 1.5),
                ),
                TextButton.icon(
                  onPressed: widget.onMap,
                  label: const Text('Explorar no mapa'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 22),
      ActionButton('Registrar uma barreira', widget.onReport, icon: Icons.add),
    ],
  );
}
