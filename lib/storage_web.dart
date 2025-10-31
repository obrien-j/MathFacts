import 'package:web/web.dart' as web;
import 'storage_interface.dart';

/// Web implementation using localStorage with package:web
class WebStorage implements StorageInterface {
  web.Storage get _localStorage => web.window.localStorage;

  @override
  Future<void> setString(String key, String value) async {
    _localStorage.setItem(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _localStorage.getItem(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    _localStorage.setItem(key, value.toString());
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _localStorage.getItem(key);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _localStorage.setItem(key, value.toString());
  }

  @override
  Future<bool> getBool(String key) async {
    final value = _localStorage.getItem(key);
    return value == 'true';
  }

  @override
  Future<void> remove(String key) async {
    _localStorage.removeItem(key);
  }
}

StorageInterface getStorage() => WebStorage();
