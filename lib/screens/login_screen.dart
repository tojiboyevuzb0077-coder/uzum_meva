import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/routes.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _pass = TextEditingController();
  bool _admin = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final err = await auth.login(_name.text, asAdmin: _admin, password: _pass.text);
    if (err != null) {
      if (mounted) setState(() => _error = err);
      return;
    }
    nav.pushReplacement(fadeRoute(const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🍓', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text('Welcome to Meva Market',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  const Text('Fresh fruits & organic produce',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Customer'), icon: Icon(Icons.shopping_basket_outlined)),
                      ButtonSegment(value: true, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings_outlined)),
                    ],
                    selected: {_admin},
                    onSelectionChanged: (s) => setState(() {
                      _admin = s.first;
                      _error = null;
                    }),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: _admin
                        ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _pass,
                        obscureText: true,
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Admin password',
                          helperText: 'Demo password: admin123',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                    )
                        : const SizedBox(width: double.infinity),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Enter the market'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
