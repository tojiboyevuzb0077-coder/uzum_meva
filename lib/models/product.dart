import 'json_utils.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.emoji = '🍎',
    this.unit = 'kg',
    this.description = '',
    this.imageUrl = '',
    this.isFavorite = false,
    this.stock = 50,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String emoji;
  final String unit;
  final String description;
  final String imageUrl;
  final bool isFavorite;
  final int stock;

  Product copyWith({
    String? name,
    String? category,
    double? price,
    String? emoji,
    String? unit,
    String? description,
    String? imageUrl,
    bool? isFavorite,
    int? stock,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        price: price ?? this.price,
        emoji: emoji ?? this.emoji,
        unit: unit ?? this.unit,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        isFavorite: isFavorite ?? this.isFavorite,
        stock: stock ?? this.stock,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'emoji': emoji,
    'unit': unit,
    'description': description,
    'imageUrl': imageUrl,
    'isFavorite': isFavorite,
    'stock': stock,
  };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: asString(j['id'], DateTime.now().microsecondsSinceEpoch.toString()),
    name: asString(j['name'], 'Unnamed'),
    category: asString(j['category'], 'Other'),
    price: asDouble(j['price']),
    emoji: asString(j['emoji'], '🍎'),
    unit: asString(j['unit'], 'kg'),
    description: asString(j['description']),
    imageUrl: asString(j['imageUrl']),
    isFavorite: asBool(j['isFavorite']),
    stock: asInt(j['stock'], 50),
  );
}
