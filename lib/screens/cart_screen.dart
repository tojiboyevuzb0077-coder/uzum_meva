import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/json_utils.dart';
import '../providers/cart_provider.dart';
import '../widgets/fruit_art.dart';
import '../widgets/glass_card.dart';
import '../widgets/routes.dart';
import '../widgets/surprise_banner.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promo = TextEditingController();
  String? _msg;
  bool _ok = false;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  Widget _row(String l, String r, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w800 : null, fontSize: bold ? 18 : 14)),
        const Spacer(),
        Text(r,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : null,
                fontSize: bold ? 18 : 14,
                color: color)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SurprisePromoBanner(),
          const SizedBox(height: 60),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket_outlined, size: 72, color: Colors.white54),
                SizedBox(height: 12),
                Text('Your cart is empty', style: TextStyle(fontSize: 18)),
                Text('Add some fresh fruit from the Shop 🍓', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SurprisePromoBanner(),
            for (final it in items)
              GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FruitArt(product: it.product),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          Text('${money(it.product.price)} / ${it.product.unit}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => cart.decrement(it.product.id),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text('${it.quantity}',
                                    key: ValueKey(it.quantity),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => cart.add(it.product),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              const Spacer(),
                              Text(money(it.total),
                                  style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => cart.remove(it.product.id),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            // Promo code
            GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: cart.promo != null
                  ? Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.amberAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        '${cart.promo} applied (-${(cart.discountRate * 100).round()}%)'),
                  ),
                  TextButton(onPressed: cart.removePromo, child: const Text('Remove')),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promo,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Promo code (try MEVA20)',
                            prefixIcon: Icon(Icons.local_offer_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final ok = cart.applyPromo(_promo.text);
                          setState(() {
                            _ok = ok;
                            _msg = ok ? null : 'Invalid promo code';
                          });
                          if (ok) _promo.clear();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  if (_msg != null && !_ok)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_msg!, style: const TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
            ),
            // Summary
            GlassCard(
              child: Column(
                children: [
                  _row('Subtotal', money(cart.subtotal)),
                  if (cart.discount > 0)
                    _row('Discount', '-${money(cart.discount)}', color: Colors.lightGreenAccent),
                  _row('Shipping', cart.shipping == 0 ? 'Free' : money(cart.shipping)),
                  if (cart.shipping > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Free shipping over ${money(CartProvider.freeShippingThreshold)}',
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ),
                  const Divider(height: 24),
                  _row('Total', money(cart.total), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).push(fadeRoute(const CheckoutScreen())),
              icon: const Icon(Icons.lock_outline),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
