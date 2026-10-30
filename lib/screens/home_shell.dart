import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/routes.dart';
import 'admin_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'shop_screen.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.page, {this.badge = 0});
  final String label;
  final IconData icon;
  final Widget page;
  final int badge;

  Widget iconWidget() => Badge(
    isLabelVisible: badge > 0,
    label: Text('$badge'),
    child: Icon(icon),
  );
}

/// Responsive shell: web-style header on wide screens, bottom navigation on mobile.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    nav.pushAndRemoveUntil(fadeRoute(const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cartCount = context.select<CartProvider, int>((c) => c.count);

    final tabs = auth.isAdmin
        ? <_Tab>[
            const _Tab('Orders', Icons.receipt_long_outlined, OrdersScreen()),
            const _Tab('Admin', Icons.admin_panel_settings_outlined, AdminScreen()),
          ]
        : <_Tab>[
            const _Tab('Shop', Icons.storefront_outlined, ShopScreen()),
            _Tab('Cart', Icons.shopping_cart_outlined, const CartScreen(), badge: cartCount),
            const _Tab('Orders', Icons.receipt_long_outlined, OrdersScreen()),
          ];

    if (_index >= tabs.length) _index = 0;

    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(_index), child: tabs[_index].page),
        ),
      ),
    );

    final wide = MediaQuery.sizeOf(context).width >= 800;

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          titleSpacing: 28,
          title: Row(
            children: [
              const Text('🍓 Meva Market',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
              const SizedBox(width: 48),
              for (var i = 0; i < tabs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor:
                      i == _index ? Colors.white.withValues(alpha: 0.14) : null,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _index = i),
                    icon: tabs[i].iconWidget(),
                    label: Text(tabs[i].label),
                  ),
                ),
            ],
          ),
          actions: [
            Chip(
              avatar: Icon(auth.isAdmin ? Icons.shield_outlined : Icons.person_outline, size: 18),
              label: Text(auth.name),
            ),
            IconButton(onPressed: _logout, tooltip: 'Log out', icon: const Icon(Icons.logout)),
            const SizedBox(width: 16),
          ],
        ),
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍓 Meva Market', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _logout, tooltip: 'Log out', icon: const Icon(Icons.logout)),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs)
            NavigationDestination(icon: t.iconWidget(), label: t.label),
        ],
      ),
    );
  }
}
