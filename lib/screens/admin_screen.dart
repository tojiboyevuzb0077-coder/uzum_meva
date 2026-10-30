import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/json_utils.dart';
import '../models/product.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/fruit_art.dart';
import '../widgets/glass_card.dart';
import '../widgets/order_tile.dart';

/// Admin dashboard: product CRUD + order status management.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Orders'),
          ]),
          Expanded(child: TabBarView(children: [_ProductsTab(), _OrdersTab()])),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().all;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _ProductDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          for (final p in products)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FruitArt(product: p),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${p.category} • ${money(p.price)} / ${p.unit} • Stock: ${p.stock}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDialog(
                        context: context, builder: (_) => _ProductDialog(existing: p)),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      final provider = context.read<ProductProvider>();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete product?'),
                          content: Text('"${p.name}" will be removed from the catalog.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) provider.delete(p.id);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    if (orders.isEmpty) return const Center(child: Text('No orders yet'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [for (final o in orders) OrderTile(order: o, editable: true)],
    );
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({this.existing});
  final Product? existing;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _category = TextEditingController(text: widget.existing?.category ?? 'Berries');
  late final _price = TextEditingController(
      text: widget.existing == null ? '' : widget.existing!.price.round().toString());
  late final _emoji = TextEditingController(text: widget.existing?.emoji ?? '🍎');
  late final _unit = TextEditingController(text: widget.existing?.unit ?? 'kg');
  late final _stock = TextEditingController(
      text: widget.existing == null ? '50' : widget.existing!.stock.toString());
  late final _image = TextEditingController(text: widget.existing?.imageUrl);
  late final _desc = TextEditingController(text: widget.existing?.description);

  @override
  void dispose() {
    for (final c in [_name, _category, _price, _emoji, _unit, _stock, _image, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v ?? '').trim().isEmpty ? 'Required' : null;

  void _save() {
    if (!_form.currentState!.validate()) return;
    final old = widget.existing;
    final product = Product(
      id: old?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      price: asDouble(_price.text),
      emoji: _emoji.text.trim(),
      unit: _unit.text.trim(),
      stock: asInt(_stock.text, 50),
      imageUrl: _image.text.trim(),
      description: _desc.text.trim(),
      isFavorite: old?.isFavorite ?? false,
    );
    context.read<ProductProvider>().upsert(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String label,
        {String? Function(String?)? validator, TextInputType? type}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: c,
            keyboardType: type,
            validator: validator,
            decoration: InputDecoration(labelText: label),
          ),
        );

    return AlertDialog(
      title: Text(widget.existing == null ? 'Add product' : 'Edit product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(_name, 'Name', validator: _required),
                field(_category, 'Category (e.g. Berries, Citrus)', validator: _required),
                field(_price, 'Price (UZS)', type: TextInputType.number, validator: (v) {
                  final n = asDouble(v);
                  return n <= 0 ? 'Enter a price above 0' : null;
                }),
                field(_emoji, 'Emoji', validator: _required),
                field(_unit, 'Unit (kg, pc, box)', validator: _required),
                field(_stock, 'Stock quantity', type: TextInputType.number, validator: _required),
                field(_image, 'Image URL (optional)'),
                field(_desc, 'Description (optional)'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
