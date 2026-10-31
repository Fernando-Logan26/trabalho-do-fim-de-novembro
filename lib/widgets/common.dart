import 'package:flutter/material.dart';

const brand = Color(0xFF65558F);
const ink = Color(0xFF20283B);
const muted = Color(0xFF657185);
const soft = Color(0xFFF0EBF8);

class PageHeading extends StatelessWidget {
  final String eyebrow, title;
  final String? subtitle;
  const PageHeading(this.eyebrow, this.title, {this.subtitle, super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w800,
          color: brand,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: -.8,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 12),
        Text(subtitle!, style: const TextStyle(color: muted, height: 1.5)),
      ],
      const SizedBox(height: 22),
    ],
  );
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  const ActionButton(this.text, this.onPressed, {this.icon, super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 21), const SizedBox(width: 9)],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

class NoteBox extends StatelessWidget {
  final String text;
  final bool warning;
  const NoteBox(this.text, {this.warning = false, super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFFFF3DE) : soft,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.45,
        color: warning ? const Color(0xFF805318) : const Color(0xFF514367),
      ),
    ),
  );
}

class Tag extends StatelessWidget {
  final String label;
  final Color color;
  const Tag(this.label, {this.color = brand, super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
    ),
  );
}

void message(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Ilustração vetorial introdutória. Os mapas navegáveis usam flutter_map.
class CityIllustration extends StatelessWidget {
  const CityIllustration({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: const SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(painter: _CityPainter()),
    ),
  );
}

class _CityPainter extends CustomPainter {
  const _CityPainter();
  @override
  void paint(Canvas c, Size s) {
    final p = Paint();
    c.drawRect(Offset.zero & s, p..color = const Color(0xFFE8EDE4));
    for (int x = 1; x < 5; x++) {
      for (int y = 0; y < 2; y++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * s.width / 5 - 22, y * 82 + 14, 46, 54),
            const Radius.circular(6),
          ),
          p..color = const Color(0xFFD7DFD0),
        );
      }
    }
    p
      ..color = Colors.white
      ..strokeWidth = 13;
    c.drawLine(Offset(0, s.height / 2), Offset(s.width, s.height / 2), p);
    for (int x = 1; x < 5; x++) {
      c.drawLine(
        Offset(x * s.width / 5 + 32, 0),
        Offset(x * s.width / 5 + 32, s.height),
        p,
      );
    }
    final river = Path()
      ..moveTo(0, 0)
      ..lineTo(27, 0)
      ..quadraticBezierTo(9, 80, 25, 150)
      ..lineTo(0, 150)
      ..close();
    c.drawPath(
      river,
      p
        ..color = const Color(0xFFA8D5EF)
        ..style = PaintingStyle.fill,
    );
    final route = Path()
      ..moveTo(s.width * .3, 127)
      ..lineTo(s.width * .3, 75)
      ..lineTo(s.width * .78, 75)
      ..lineTo(s.width * .78, 28);
    c.drawPath(
      route,
      p
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    p.style = PaintingStyle.fill;
    c.drawCircle(Offset(s.width * .3, 127), 9, p..color = Colors.white);
    c.drawCircle(
      Offset(s.width * .3, 127),
      6,
      p..color = const Color(0xFF4285F4),
    );
    c.drawCircle(Offset(s.width * .78, 28), 9, p..color = Colors.white);
    c.drawCircle(
      Offset(s.width * .78, 28),
      6,
      p..color = const Color(0xFF20875D),
    );
  }

  @override
  bool shouldRepaint(covariant _CityPainter oldDelegate) => false;
}
