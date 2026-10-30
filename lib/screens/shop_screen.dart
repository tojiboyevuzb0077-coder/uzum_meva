import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/surprise_banner.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductProvider>();
    final items = p.items;

    return Column(
      children: [
        const SurprisePromoBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            onChanged: p.setQuery,
            decoration: const InputDecoration(
              hintText: 'Search fruits...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final c in p.categories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: p.category == c,
                    onSelected: (_) => p.setCategory(c),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No products found 🍃'))
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.74,
            ),
            itemCount: items.length,
            itemBuilder: (c, i) => ProductCard(key: ValueKey(items[i].id), product: items[i]),
          ),
        ),
      ],
    );
  }
}
