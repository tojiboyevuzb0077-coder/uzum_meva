import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/json_utils.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'fruit_art.dart';
import 'glass_card.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false; // web/desktop hover effect

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final inCart = context.select<CartProvider, int>((c) => c.quantityOf(p.id));

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1,
        duration: const Duration(milliseconds: 180),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FruitArt(product: p),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filledTonal(
                        onPressed: () =>
                            context.read<ProductProvider>().toggleFavorite(p.id),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            p.isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(p.isFavorite),
                            color: p.isFavorite ? Colors.redAccent : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('${p.category} • per ${p.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    Text('Stock: ${p.stock} ${p.unit}',
                        style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(money(p.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFFC5E1A5))),
                        ),
                        IconButton.filled(
                          onPressed: () {
                            context.read<CartProvider>().add(p);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                duration: const Duration(milliseconds: 900),
                                content: Text('${p.name} added to cart'),
                              ));
                          },
                          icon: Badge(
                            isLabelVisible: inCart > 0,
                            label: Text('$inCart'),
                            child: const Icon(Icons.add_shopping_cart),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
