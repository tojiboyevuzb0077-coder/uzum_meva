import 'json_utils.dart';
import 'product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() =>
      {'product': product.toJson(), 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    product: Product.fromJson(asMap(j['product'])),
    quantity: asInt(j['quantity'], 1).clamp(1, 999),
  );
}
