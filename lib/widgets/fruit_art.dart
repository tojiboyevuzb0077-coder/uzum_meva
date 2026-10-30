import 'package:flutter/material.dart';
import '../models/product.dart';

/// Always-pretty product visual: an emoji on a themed gradient. If the product
/// has an imageUrl it is layered on top; when the network image fails
/// (offline / CORS on web) nothing is drawn and the artwork stays visible.
class FruitArt extends StatelessWidget {
  const FruitArt({super.key, required this.product});

  final Product product;

  static const _palettes = {
    'Berries': [Color(0xFFC62828), Color(0xFF6A1B9A)],
    'Citrus': [Color(0xFFFBC02D), Color(0xFFEF6C00)],
    'Tropical': [Color(0xFF00ACC1), Color(0xFF7CB342)],
    'Orchard': [Color(0xFFD84315), Color(0xFF558B2F)],
    'Melons': [Color(0xFF2E7D32), Color(0xFFEC407A)],
  };

  @override
  Widget build(BuildContext context) {
    final colors =
        _palettes[product.category] ?? const [Color(0xFF2E7D32), Color(0xFF1B5E20)];
    final art = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(product.emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),
      ),
    );
    if (product.imageUrl.isEmpty) return SizedBox.expand(child: art);
    return Stack(
      fit: StackFit.expand,
      children: [
        art,
        Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
