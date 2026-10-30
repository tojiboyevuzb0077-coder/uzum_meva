import 'package:flutter/foundation.dart';
import '../models/app_order.dart';
import '../models/json_utils.dart';
import '../services/data_store.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._store);

  static const _key = 'orders';
  final DataStore _store;
  List<AppOrder> _orders = [];

  List<AppOrder> get orders => List.unmodifiable(_orders);

  Future<void> load() async {
    _orders = asList(await _store.read(_key))
        .map((e) => AppOrder.fromJson(asMap(e)))
        .toList();
    notifyListeners();
  }

  Future<void> _save() =>
      _store.write(_key, _orders.map((o) => o.toJson()).toList());

  /// Creates an order from the current cart. The caller clears the cart.
  Future<AppOrder> place({
    required CartProvider cart,
    required String customer,
    required String phone,
    required String address,
    required PaymentMethod method,
  }) async {
    final order = AppOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
      customer: customer,
      phone: phone,
      address: address,
      items: cart.items,
      subtotal: cart.subtotal,
      discount: cart.discount,
      shipping: cart.shipping,
      total: cart.total,
      method: method,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    notifyListeners();
    await _save();
    return order;
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    _orders[i] = _orders[i].withStatus(status);
    notifyListeners();
    await _save();
  }
}
