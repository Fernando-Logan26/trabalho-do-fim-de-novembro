import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_store.dart';
import '../widgets/city_map.dart';
import '../widgets/common.dart';

class RoutesScreen extends StatefulWidget {
  final AppStore store;
  final VoidCallback onMap, onSettings;
  const RoutesScreen({
    required this.store,
    required this.onMap,
    required this.onSettings,
    super.key,
  });
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final destination = TextEditingController(
    text: 'Praça das Três Caixas d’Água, Porto Velho',
  );
  @override
  void dispose() {
    destination.dispose();
    super.dispose();
  }

  Future<void> directions() async {
    if (destination.text.trim().isEmpty) {
      message(context, 'Informe o destino.');
      return;
    }
    try {
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': destination.text.trim(),
        'travelmode': 'walking',
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        message(context, 'Não foi possível abrir o aplicativo de mapas.');
      }
    } catch (_) {
      if (mounted) message(context, 'Não foi possível abrir as direções.');
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const PageHeading(
        'Mobilidade com autonomia',
        'Planeje seu caminho',
        subtitle:
            'Explore o destino e abra as direções no aplicativo de mapas.',
      ),
      TextField(
        controller: destination,
        decoration: const InputDecoration(
          labelText: 'Destino',
          prefixIcon: Icon(Icons.place_outlined),
        ),
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seu perfil de mobilidade',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(widget.store.mobility),
              TextButton(
                onPressed: widget.onSettings,
                child: const Text('Ajustar preferências →'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 220,
          child: CityMap(
            interactive: false,
            onPoint: (p) => showPoint(context, p),
          ),
        ),
      ),
      const SizedBox(height: 18),
      const NoteBox(
        'Esta versão ainda não calcula rotas acessíveis. Confirme rampas, obstáculos e condições locais antes de sair.',
        warning: true,
      ),
      const SizedBox(height: 18),
      ActionButton(
        'Abrir direções no Google Maps',
        directions,
        icon: Icons.directions_walk,
      ),
      const SizedBox(height: 6),
      TextButton(
        onPressed: widget.onMap,
        child: const Text('Explorar barreiras no mapa'),
      ),
    ],
  );
}
