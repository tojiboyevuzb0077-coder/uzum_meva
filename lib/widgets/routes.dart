import 'package:flutter/material.dart';

/// Smooth fade + slight slide transition.
Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 600),
  pageBuilder: (c, a, s) => page,
  transitionsBuilder: (c, a, s, child) => FadeTransition(
    opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
      child: child,
    ),
  ),
);
