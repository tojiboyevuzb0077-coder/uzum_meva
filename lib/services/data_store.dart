import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage abstraction. Providers only depend on this interface, so to move
/// to Firebase / a REST API, write a new class implementing [DataStore]
/// (e.g. `FirebaseDataStore`, `RestDataStore`) and pass it in main.dart.
abstract class DataStore {
  Future<dynamic> read(String key);
  Future<void> write(String key, Object value);
  Future<void> remove(String key);
}

/// Local implementation: JSON strings in SharedPreferences.
class LocalDataStore implements DataStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<dynamic> read(String key) async {
    final raw = (await _p).getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null; // corrupted data -> treated as empty
    }
  }

  @override
  Future<void> write(String key, Object value) async =>
      (await _p).setString(key, jsonEncode(value));

  @override
  Future<void> remove(String key) async => (await _p).remove(key);
}
