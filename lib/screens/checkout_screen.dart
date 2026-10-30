import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_order.dart';
import '../models/json_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/glass_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  bool _busy = false;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    if (!_form.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    final order = await orders.place(
      cart: cart,
      customer: auth.name,
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      method: _method,
    );
    cart.clear();
    nav.pop();
    messenger.showSnackBar(SnackBar(
      content: Text('Order #${order.id} placed! Total ${money(order.total)}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(
                          labelText: 'Delivery address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) =>
                        (v ?? '').trim().length < 5 ? 'Enter a valid address' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) =>
                        (v ?? '').replaceAll(RegExp(r'\D'), '').length < 9
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                    ],
                  ),
                ),
                GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RadioGroup<PaymentMethod>(
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v ?? _method),
                    child: Column(
                      children: [
                        for (final m in PaymentMethod.values)
                          RadioListTile<PaymentMethod>(
                            value: m,
                            title: Text(m.label),
                            secondary: Icon(switch (m) {
                              PaymentMethod.cash => Icons.payments_outlined,
                              PaymentMethod.payme => Icons.account_balance_wallet_outlined,
                              PaymentMethod.click => Icons.touch_app_outlined,
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
                GlassCard(
                  child: Row(
                    children: [
                      const Text('Total to pay',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(money(cart.total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy || cart.items.isEmpty ? null : _place,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Place order'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
