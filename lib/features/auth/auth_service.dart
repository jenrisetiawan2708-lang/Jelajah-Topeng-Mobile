import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/auth/token_storage.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    email: (j['email'] ?? '').toString(),
    role: (j['role'] ?? 'user').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

class AuthService {
  /// User yang sedang login (null jika belum).
  static AppUser? current;

  /// Dipanggil saat splash: true jika token dan data user masih tersimpan.
  /// Jika token ternyata sudah kedaluwarsa, request berikutnya akan dibalas
  /// 401 dan ApiClient.sessionExpired mengembalikan user ke Login.
  static Future<bool> restore() async {
    final token = await TokenStorage.read();
    if (token == null || token.isEmpty) return false;
    try {
      final raw = await TokenStorage.readUser();
      if (raw != null) {
        current = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      current = null;
    }
    return true;
  }

  /// PENTING: cocokkan nama kolom dengan validator BE
  /// (repo BE: src/validators atau src/schemas, cari kata "login").
  static Future<void> login(String email, String password) async {
    final data = await ApiClient.instance.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;
    final token = (data['token'] ?? data['accessToken'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException('Balasan login dari server tidak berisi token.');
    }
    await TokenStorage.save(token);
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      current = AppUser.fromJson(userJson);
      await TokenStorage.saveUser(jsonEncode(current!.toJson()));
    }
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await ApiClient.instance.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  static Future<void> logout() async {
    current = null;
    await TokenStorage.clear();
  }
}
