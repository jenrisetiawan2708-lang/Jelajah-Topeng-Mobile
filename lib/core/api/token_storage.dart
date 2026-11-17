import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan token login dan data user ringkas di penyimpanan aman.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  static Future<String?> read() => _storage.read(key: _kToken);

  static Future<void> save(String token) =>
      _storage.write(key: _kToken, value: token);

  static Future<String?> readUser() => _storage.read(key: _kUser);

  static Future<void> saveUser(String json) =>
      _storage.write(key: _kUser, value: json);

  static Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUser);
  }
}
