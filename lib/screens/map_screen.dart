import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/city_map.dart';
import '../widgets/common.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback onReport;
  const MapScreen({required this.onReport, super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = MapController();
  String filter = 'Todos';
  DemoPoint selected = demoPoints.first;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final region = await showModalBottomSheet<LatLng>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Buscar uma região',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                subtitle: Text('Selecione uma das regiões de Porto Velho.'),
              ),
              for (final r in [
                ('Centro / Av. Carlos Gomes', portoVelho),
                ('Av. Jorge Teixeira', const LatLng(-8.761, -63.881)),
                ('Rua Duque de Caxias', const LatLng(-8.7652, -63.902)),
              ])
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(r.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, r.$2),
                ),
            ],
          ),
        ),
      ),
    );
    if (region != null && mounted) controller.move(region, 16);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      children: [
        Positioned.fill(
          child: CityMap(
            controller: controller,
            filter: filter,
            onPoint: (p) => setState(() => selected = p),
          ),
        ),
        Positioned(
          top: 18,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: search,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: muted),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Buscar rua ou destino',
                            style: TextStyle(color: muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in ['Todos', 'Barreiras', 'Rampas'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          backgroundColor: Colors.white,
                          label: Text(f),
                          selected: filter == f,
                          onSelected: (_) => setState(() => filter = f),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 158,
          child: Column(
            children: [
              _mapControl(
                Icons.add,
                'Aproximar',
                () => controller.move(
                  controller.camera.center,
                  (controller.camera.zoom + 1).clamp(3, 19),
                ),
              ),
              const SizedBox(height: 6),
              _mapControl(
                Icons.remove,
                'Afastar',
                () => controller.move(
                  controller.camera.center,
                  (controller.camera.zoom - 1).clamp(3, 19),
                ),
              ),
              const SizedBox(height: 6),
              _mapControl(
                Icons.center_focus_strong,
                'Centralizar em Porto Velho',
                () => controller.move(portoVelho, 16),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .48),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 35,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tag(
                      'PONTO DEMONSTRATIVO',
                      color: selected.ramp
                          ? const Color(0xFF237849)
                          : const Color(0xFFAD4F26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selected.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(selected.street, style: const TextStyle(color: muted)),
                    const SizedBox(height: 14),
                    ActionButton(
                      'Ver detalhes',
                      () => showPoint(context, selected),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: widget.onReport,
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar outro problema'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _mapControl(IconData icon, String label, VoidCallback onTap) =>
      Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        child: IconButton(
          tooltip: label,
          onPressed: onTap,
          icon: Icon(icon, color: brand),
        ),
      );
}
