import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/splash_screen.dart';
import 'services/data_store.dart';
import 'widgets/ambient_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Swap LocalDataStore for a Firebase/REST implementation later.
  final DataStore store = LocalDataStore();
  runApp(MevaApp(store: store));
}

class MevaApp extends StatelessWidget {
  const MevaApp({super.key, required this.store});

  final DataStore store;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => ProductProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => CartProvider(store)..load()),
        ChangeNotifierProvider(create: (_) => OrderProvider(store)..load()),
      ],
      child: MaterialApp(
        title: 'Meva Market',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF43A047),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent, // ambient shows through
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
          ),
        ),
        // One persistent animated background behind every route.
        builder: (context, child) => AmbientBackground(
          authenticated: context.watch<AuthProvider>().isLoggedIn,
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
