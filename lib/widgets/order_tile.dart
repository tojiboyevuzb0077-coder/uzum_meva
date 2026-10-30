import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_order.dart';
import '../models/json_utils.dart';
import '../providers/order_provider.dart';
import 'glass_card.dart';

Color statusColor(OrderStatus s) => switch (s) {
  OrderStatus.pending => Colors.orangeAccent,
  OrderStatus.shipping => Colors.lightBlueAccent,
  OrderStatus.delivered => Colors.lightGreenAccent,
};

String _fmt(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Order summary. With [editable] (admin) the status can be changed.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, this.editable = false});

  final AppOrder order;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Buyurtma #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              if (editable)
                DropdownButton<OrderStatus>(
                  value: order.status,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final s in OrderStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (s) {
                    if (s != null) {
                      context.read<OrderProvider>().updateStatus(order.id, s);
                    }
                  },
                )
              else
                Chip(
                  label: Text(order.status.label),
                  side: BorderSide(color: color),
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
            ],
          ),
          Text('${_fmt(order.createdAt)} • Xaridor: ${order.customer}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yetkazib berish (Dastafka) ma\'lumotlari:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.greenAccent)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Manzil: ${order.address}', style: const TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Tel: ${order.phone}', style: const TextStyle(fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Dastafka: ${order.shipping == 0 ? 'Bepul' : money(order.shipping)}', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          for (final i in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(i.product.emoji),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${i.quantity} × ${i.product.name}')),
                  Text(money(i.total)),
                ],
              ),
            ),
          const Divider(height: 20),
          Row(
            children: [
              Text('To\'lov usuli: ${order.method.label}',
                  style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(money(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
