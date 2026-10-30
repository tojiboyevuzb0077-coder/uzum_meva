import 'dart:math';
import 'package:flutter/material.dart';

/// Living "Lush Green Forest" background. Wrap the whole app with it.
/// After login ([authenticated]) the palette gains warm fruit-colored orbs.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child, required this.authenticated});

  final Widget child;
  final bool authenticated;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 24))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      RepaintBoundary(
        child: CustomPaint(
          painter: AmbientBackgroundPainter(_c, widget.authenticated),
        ),
      ),
      widget.child,
    ],
  );
}

class AmbientBackgroundPainter extends CustomPainter {
  AmbientBackgroundPainter(this.t, this.authenticated) : super(repaint: t);

  final Animation<double> t;
  final bool authenticated;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = authenticated
        ? const [Color(0xFF04210F), Color(0xFF0B3D1E), Color(0xFF14532D)]
        : const [Color(0xFF021A0B), Color(0xFF053B1C), Color(0xFF0A2E1A)];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ).createShader(rect),
    );

    final orbs = authenticated
        ? const [
      Color(0xFF66BB6A), Color(0xFFC0CA33), Color(0xFFFFA726),
      Color(0xFF26A69A), Color(0xFFEF5350), Color(0xFF9CCC65),
    ]
        : const [
      Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFF1B5E20),
      Color(0xFF00897B), Color(0xFF7CB342), Color(0xFF33691E),
    ];

    final a = t.value * 2 * pi;
    for (var i = 0; i < orbs.length; i++) {
      final center = Offset(
        size.width * (0.5 + 0.42 * sin(a * (1 + i % 3) + i * 1.3)),
        size.height * (0.5 + 0.42 * cos(a * (1 + (i + 1) % 2) + i * 2.1)),
      );
      final radius = size.shortestSide * (0.28 + 0.06 * (i % 3));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [
            orbs[i].withValues(alpha: authenticated ? 0.34 : 0.28),
            orbs[i].withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(AmbientBackgroundPainter old) =>
      old.authenticated != authenticated;
}
