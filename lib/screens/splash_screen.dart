import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/routes.dart';
import 'home_shell.dart';
import 'login_screen.dart';

double _cl(double v, [double lo = 0, double hi = 1]) =>
    v < lo ? lo : (v > hi ? hi : v);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _title = 'MEVA MARKET';
  static const _fruits = ['🍓', '🍊', '🍍', '🍎', '🥝', '🍉', '🍇', '🍋', '🍑', '🥭'];

  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _next();
    })
    ..forward();

  void _next() {
    if (!mounted) return;
    final loggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.of(context).pushReplacement(
      fadeRoute(loggedIn ? const HomeShell() : const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Staggered "dropping" letter.
  Widget _letter(int i) {
    final start = _cl(i * 0.045, 0, 0.7);
    final end = start + 0.3;
    final p = _cl((_c.value - start) / (end - start));
    final drop = Curves.bounceOut.transform(p);
    return Opacity(
      opacity: _cl((_c.value - start) / 0.1),
      child: Transform.translate(
        offset: Offset(0, -180 * (1 - drop)),
        child: Text(
          _title[i] == ' ' ? '\u00A0\u00A0' : _title[i],
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final size = MediaQuery.sizeOf(context);
          return Stack(
            children: [
              // Floating fruit particles with sine-wave motion.
              for (var i = 0; i < _fruits.length; i++)
                Positioned(
                  left: size.width * ((0.05 + i * 0.37) % 0.9),
                  top: size.height * (0.08 + (i * 0.23) % 0.8) +
                      sin(_c.value * 4 * pi + i) * 20,
                  child: Opacity(
                    opacity: 0.55,
                    child: Text(_fruits[i],
                        style: TextStyle(fontSize: 26.0 + (i % 3) * 10)),
                  ),
                ),
              Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [for (var i = 0; i < _title.length; i++) _letter(i)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 70,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _cl((_c.value - 0.6) / 0.3),
                  child: const Text(
                    'Fresh from the orchard to your door',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
