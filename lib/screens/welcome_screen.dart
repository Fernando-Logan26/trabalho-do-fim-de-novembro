import 'package:flutter/material.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  const WelcomeScreen({required this.onStart, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mobilidade PVH',
                style: TextStyle(
                  color: brand,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const PageHeading(
            'Porto Velho mais acessível',
            'Mais autonomia.\nMenos barreiras.',
            subtitle:
                'Conheça o app que conecta pessoas para tornar as calçadas da cidade mais acessíveis.',
          ),
          const CityIllustration(),
          const SizedBox(height: 22),
          _feature(
            Icons.route_rounded,
            'Explore seus caminhos',
            'Veja o mapa das ruas e pontos de acessibilidade.',
          ),
          _feature(
            Icons.add_a_photo_outlined,
            'Ajude a mapear a cidade',
            'Registre uma barreira com descrição, endereço e foto.',
          ),
          _feature(
            Icons.notifications_active_outlined,
            'Acompanhe o que muda',
            'Consulte seus registros e atualizações das principais ruas.',
          ),
          const SizedBox(height: 14),
          ActionButton(
            'Começar a usar',
            onStart,
            icon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 20),
          const Text(
            'Protótipo acadêmico • IFRO • TCC 2026',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    ),
  );
  Widget _feature(IconData icon, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  color: muted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
