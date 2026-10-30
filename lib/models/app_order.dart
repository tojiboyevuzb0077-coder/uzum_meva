import 'cart_item.dart';
import 'json_utils.dart';

enum OrderStatus {
  pending,
  shipping,
  delivered;

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.shipping => 'Shipping',
    OrderStatus.delivered => 'Delivered',
  };
}

enum PaymentMethod {
  cash,
  payme,
  click;

  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.payme => 'Payme',
    PaymentMethod.click => 'Click',
  };
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.customer,
    required this.address,
    required this.phone,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String customer;
  final String address;
  final String phone;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final PaymentMethod method;
  final OrderStatus status;
  final DateTime createdAt;

  AppOrder withStatus(OrderStatus s) => AppOrder(
    id: id,
    customer: customer,
    address: address,
    phone: phone,
    items: items,
    subtotal: subtotal,
    discount: discount,
    shipping: shipping,
    total: total,
    method: method,
    status: s,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer,
    'address': address,
    'phone': phone,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'shipping': shipping,
    'total': total,
    'method': method.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppOrder.fromJson(Map<String, dynamic> j) => AppOrder(
    id: asString(j['id']),
    customer: asString(j['customer']),
    address: asString(j['address']),
    phone: asString(j['phone']),
    items: asList(j['items'])
        .map((e) => CartItem.fromJson(asMap(e)))
        .toList(),
    subtotal: asDouble(j['subtotal']),
    discount: asDouble(j['discount']),
    shipping: asDouble(j['shipping']),
    total: asDouble(j['total']),
    method: enumByName(PaymentMethod.values, j['method'], PaymentMethod.cash),
    status: enumByName(OrderStatus.values, j['status'], OrderStatus.pending),
    createdAt: DateTime.tryParse(asString(j['createdAt'])) ?? DateTime.now(),
  );
}
