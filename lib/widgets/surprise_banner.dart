import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'glass_card.dart';

class SurprisePromoBanner extends StatelessWidget {
  const SurprisePromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final code = cart.activeSurpriseCode;
    final notif = cart.surpriseNotification;
    if (code == null) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Surpriz Promo-kod (Har 5 daqiqada yangilanadi!)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.greenAccent)),
                const SizedBox(height: 2),
                Text(
                  notif ?? 'Kod: $code (${(cart.activeSurpriseRate * 100).round()}% chegirma)',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              cart.applyPromo(code);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Surpriz promo-kod "$code" muvaffaqiyatli qo\'shildi!')),
              );
            },
            child: const Text('Qo\'llash'),
          ),
        ],
      ),
    );
  }
}
