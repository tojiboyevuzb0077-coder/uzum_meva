import 'package:flutter/foundation.dart';
import '../models/json_utils.dart';
import '../services/data_store.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._store);

  static const _key = 'auth';
  static const adminPassword = 'admin123'; // demo only: replace with real auth

  final DataStore _store;
  String _name = '';
  bool _isAdmin = false;

  String get name => _name;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _name.isNotEmpty;

  Future<void> load() async {
    final m = asMap(await _store.read(_key));
    _name = asString(m['name']);
    _isAdmin = asBool(m['isAdmin']);
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> login(String name, {bool asAdmin = false, String password = ''}) async {
    if (name.trim().isEmpty) return 'Please enter your name';
    if (asAdmin && password != adminPassword) return 'Wrong admin password';
    _name = name.trim();
    _isAdmin = asAdmin;
    await _store.write(_key, {'name': _name, 'isAdmin': _isAdmin});
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _name = '';
    _isAdmin = false;
    await _store.remove(_key);
    notifyListeners();
  }
}
