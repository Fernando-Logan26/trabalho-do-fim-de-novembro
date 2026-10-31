import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common.dart';

const portoVelho = LatLng(-8.7615, -63.9035);

class DemoPoint {
  final String title, street;
  final LatLng position;
  final bool ramp;
  const DemoPoint(this.title, this.street, this.position, {this.ramp = false});
}

const demoPoints = [
  DemoPoint(
    'Obstáculo na calçada',
    'Av. Carlos Gomes · Centro',
    LatLng(-8.7617, -63.9027),
  ),
  DemoPoint(
    'Rampa mapeada',
    'Região central · Porto Velho',
    LatLng(-8.7585, -63.9062),
    ramp: true,
  ),
];

class CityMap extends StatefulWidget {
  final ValueChanged<DemoPoint>? onPoint;
  final MapController? controller;
  final String filter;
  final bool interactive;
  const CityMap({
    this.onPoint,
    this.controller,
    this.filter = 'Todos',
    this.interactive = true,
    super.key,
  });
  @override
  State<CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<CityMap> {
  bool failed = false;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      FlutterMap(
        mapController: widget.controller,
        options: MapOptions(
          initialCenter: portoVelho,
          initialZoom: 16,
          minZoom: 3,
          maxZoom: 19,
          interactionOptions: InteractionOptions(
            flags: widget.interactive
                ? InteractiveFlag.all
                : InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'br.edu.ifro.mobilidade_flutter',
            maxZoom: 19,
            errorTileCallback: (_, __, ___) {
              if (!failed && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => failed = true);
                });
              }
            },
          ),
          MarkerLayer(
            markers: [
              for (final p in demoPoints.where(
                (p) =>
                    widget.filter == 'Todos' ||
                    (widget.filter == 'Rampas' ? p.ramp : !p.ramp),
              ))
                Marker(
                  point: p.position,
                  width: 48,
                  height: 52,
                  child: Semantics(
                    label: '${p.title}, ponto demonstrativo',
                    button: true,
                    child: GestureDetector(
                      onTap: () => widget.onPoint?.call(p),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: p.ramp
                            ? const Color(0xFF20875D)
                            : const Color(0xFFE15D36),
                        size: 46,
                        shadows: const [
                          Shadow(color: Colors.white, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
      if (failed)
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Não foi possível carregar o mapa. Verifique a internet.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar aviso',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => failed = false),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

void showPoint(BuildContext context, DemoPoint p) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Tag('PONTO DEMONSTRATIVO'),
          const SizedBox(height: 14),
          Text(
            p.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(p.street),
          const SizedBox(height: 20),
          const NoteBox(
            'Este marcador é fictício e demonstra a interface. Não informa a condição real da calçada.',
            warning: true,
          ),
          const SizedBox(height: 16),
          ActionButton('Entendi', () => Navigator.pop(context)),
        ],
      ),
    ),
  ),
);
