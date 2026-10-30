import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/json_utils.dart';
import '../models/product.dart';
import '../services/data_store.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._store) {
    _initSurpriseTimer();
  }

  static const _key = 'cart';
  static const freeShippingThreshold = 120000.0; // free shipping above this
  static const shippingFee = 15000.0;
  
  static final Map<String, double> promoCodes = {
    'MEVA20': 0.20,
    'FRESH10': 0.10,
    'SURPRISE25': 0.25,
    'SUPER30': 0.30,
    'VITAMIN35': 0.35,
    'MEVABOSS40': 0.40,
    'FRESH50': 0.50,
  };

  static final Map<String, double> surprisePool = {
    'SURPRISE25': 0.25,
    'SUPER30': 0.30,
    'VITAMIN35': 0.35,
    'MEVABOSS40': 0.40,
    'FRESH50': 0.50,
    'MEVAFUN60': 0.60,
  };

  final DataStore _store;
  final Map<String, CartItem> _items = {};
  String? _promo;

  Timer? _surpriseTimer;
  String? _activeSurpriseCode;
  double _activeSurpriseRate = 0;
  String? _surpriseNotification;

  List<CartItem> get items => _items.values.toList();
  String? get promo => _promo;
  int get count => _items.values.fold(0, (s, e) => s + e.quantity);
  int quantityOf(String id) => _items[id]?.quantity ?? 0;

  double get subtotal => _items.values.fold(0.0, (s, e) => s + e.total);
  double get discountRate => promoCodes[_promo] ?? 0;
  double get discount => subtotal * discountRate;
  double get shipping =>
      _items.isEmpty || subtotal > freeShippingThreshold ? 0 : shippingFee;
  double get total => subtotal - discount + shipping;

  String? get activeSurpriseCode => _activeSurpriseCode;
  double get activeSurpriseRate => _activeSurpriseRate;
  String? get surpriseNotification => _surpriseNotification;

  void _initSurpriseTimer() {
    _generateSurprise();
    _surpriseTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _generateSurprise();
    });
  }

  void _generateSurprise() {
    final entries = surprisePool.entries.toList();
    entries.shuffle();
    final chosen = entries.first;
    _activeSurpriseCode = chosen.key;
    _activeSurpriseRate = chosen.value;
    promoCodes[chosen.key] = chosen.value;
    _surpriseNotification = '🎁 Surpriz Promo-kod: ${chosen.key} (${(chosen.value * 100).round()}% chegirma)!';
    notifyListeners();
  }

  @override
  void dispose() {
    _surpriseTimer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final m = asMap(await _store.read(_key));
    _items.clear();
    for (final e in asList(m['items'])) {
      final item = CartItem.fromJson(asMap(e));
      _items[item.product.id] = item;
    }
    final p = asString(m['promo']);
    _promo = promoCodes.containsKey(p) ? p : null;
    notifyListeners();
  }

  Future<void> _save() => _store.write(_key, {
    'items': _items.values.map((e) => e.toJson()).toList(),
    'promo': _promo,
  });

  void _changed() {
    notifyListeners();
    _save();
  }

  void add(Product p) {
    final cur = _items[p.id];
    _items[p.id] = cur == null
        ? CartItem(product: p, quantity: 1)
        : cur.copyWith(quantity: cur.quantity + 1);
    _changed();
  }

  void decrement(String id) {
    final cur = _items[id];
    if (cur == null) return;
    cur.quantity <= 1
        ? _items.remove(id)
        : _items[id] = cur.copyWith(quantity: cur.quantity - 1);
    _changed();
  }

  void remove(String id) {
    _items.remove(id);
    _changed();
  }

  void clear() {
    _items.clear();
    _promo = null;
    _changed();
  }

  /// Returns true when the code is valid.
  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    if (!promoCodes.containsKey(c)) return false;
    _promo = c;
    _changed();
    return true;
  }

  void removePromo() {
    _promo = null;
    _changed();
  }
}
