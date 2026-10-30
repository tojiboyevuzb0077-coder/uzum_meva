import 'package:flutter/foundation.dart';
import '../models/json_utils.dart';
import '../models/product.dart';
import '../services/data_store.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._store);

  static const _key = 'products_v2';
  final DataStore _store;

  List<Product> _all = [];
  String _query = '';
  String _category = 'All';

  List<Product> get all => List.unmodifiable(_all);
  String get category => _category;

  List<String> get categories =>
      ['All', ...{for (final p in _all) p.category}];

  /// Products after applying the search query and category filter.
  List<Product> get items => _all.where((p) {
    final okCat = _category == 'All' || p.category == _category;
    final q = _query.trim().toLowerCase();
    final okQ = q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q);
    return okCat && okQ;
  }).toList();

  Future<void> load() async {
    final list = asList(await _store.read(_key));
    _all = list.isEmpty
        ? _seed()
        : list.map((e) => Product.fromJson(asMap(e))).toList();
    notifyListeners();
  }

  Future<void> _save() =>
      _store.write(_key, _all.map((p) => p.toJson()).toList());

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final i = _all.indexWhere((p) => p.id == id);
    if (i < 0) return;
    _all[i] = _all[i].copyWith(isFavorite: !_all[i].isFavorite);
    notifyListeners();
    await _save();
  }

  /// Add (new id) or update (existing id).
  Future<void> upsert(Product p) async {
    final i = _all.indexWhere((e) => e.id == p.id);
    i < 0 ? _all.add(p) : _all[i] = p;
    if (!categories.contains(_category)) _category = 'All';
    notifyListeners();
    await _save();
  }

  Future<void> delete(String id) async {
    _all.removeWhere((p) => p.id == id);
    if (!categories.contains(_category)) _category = 'All';
    notifyListeners();
    await _save();
  }

  List<Product> _seed() => const [
    Product(id: 'p1', name: 'Strawberry', category: 'Berries', price: 48000, emoji: '🍓', description: 'Sweet, juicy and picked this morning.', stock: 35),
    Product(id: 'p2', name: 'Blueberry', category: 'Berries', price: 85000, emoji: '🫐', unit: 'box', stock: 20),
    Product(id: 'p3', name: 'Cherry', category: 'Berries', price: 70000, emoji: '🍒', stock: 40),
    Product(id: 'p4', name: 'Orange', category: 'Citrus', price: 22000, emoji: '🍊', stock: 80),
    Product(id: 'p5', name: 'Lemon', category: 'Citrus', price: 26000, emoji: '🍋', stock: 50),
    Product(id: 'p6', name: 'Banana', category: 'Tropical', price: 24000, emoji: '🍌', stock: 100),
    Product(id: 'p7', name: 'Pineapple', category: 'Tropical', price: 38000, emoji: '🍍', unit: 'pc', stock: 15),
    Product(id: 'p8', name: 'Mango', category: 'Tropical', price: 65000, emoji: '🥭', stock: 25),
    Product(id: 'p9', name: 'Kiwi', category: 'Tropical', price: 52000, emoji: '🥝', stock: 45),
    Product(id: 'p10', name: 'Apple', category: 'Orchard', price: 15000, emoji: '🍎', stock: 120),
    Product(id: 'p11', name: 'Pear', category: 'Orchard', price: 18000, emoji: '🍐', stock: 60),
    Product(id: 'p12', name: 'Peach', category: 'Orchard', price: 30000, emoji: '🍑', stock: 50),
    Product(id: 'p13', name: 'Grape', category: 'Orchard', price: 32000, emoji: '🍇', stock: 70),
    Product(id: 'p14', name: 'Watermelon', category: 'Melons', price: 9000, emoji: '🍉', unit: 'dona', stock: 30),
    Product(id: 'p15', name: 'Melon', category: 'Melons', price: 12000, emoji: '🍈', unit: 'dona', stock: 25),
  ];
}
