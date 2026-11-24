import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/token_storage.dart';
import 'api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors = const {}});

  final String message;
  final int? statusCode;

  /// Pesan error per kolom, mis. {'email': 'Email sudah terdaftar'}.
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Nilainya bertambah setiap kali token ditolak BE (401). app.dart
  /// mendengarkan ini lalu mengembalikan user ke layar Login.
  static final ValueNotifier<int> sessionExpired = ValueNotifier<int>(0);

  static const _timeout = Duration(seconds: 15);

  Future<dynamic> get(String path, {Duration? timeout}) =>
      _send('GET', path, timeout: timeout);
  Future<dynamic> post(String path, {Object? body, Duration? timeout}) =>
      _send('POST', path, body: body, timeout: timeout);
  Future<dynamic> patch(String path, {Object? body, Duration? timeout}) =>
      _send('PATCH', path, body: body, timeout: timeout);
  Future<dynamic> delete(String path, {Duration? timeout}) =>
      _send('DELETE', path, timeout: timeout);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('${ApiConfig.api}$path');
    final token = await TokenStorage.read();
    final req = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) req.body = jsonEncode(body);

    http.Response res;
    try {
      final streamed = await req.send().timeout(timeout ?? _timeout);
      res = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('Server tidak merespons. Coba lagi.');
    } on SocketException {
      throw ApiException('Tidak bisa terhubung ke server. Periksa koneksi.');
    } on http.ClientException {
      throw ApiException('Tidak bisa terhubung ke server. Periksa koneksi.');
    }

    dynamic json;
    try {
      json = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      json = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json is Map ? json['data'] : null;
    }

    // Token ditolak: hapus dan kabari aplikasi (hanya jika memang sedang login).
    if (res.statusCode == 401 && token != null) {
      await TokenStorage.clear();
      sessionExpired.value++;
    }

    final message = json is Map && json['message'] != null
        ? json['message'].toString()
        : 'Terjadi kesalahan (${res.statusCode}).';
    throw ApiException(
      message,
      statusCode: res.statusCode,
      fieldErrors: json is Map ? _fieldErrors(json['errors']) : const {},
    );
  }

  /// BE bisa mengirim errors sebagai Map atau List; dua-duanya ditangani.
  static Map<String, String> _fieldErrors(dynamic e) {
    final out = <String, String>{};
    if (e is Map) {
      e.forEach((k, v) {
        out[k.toString()] = v is List ? v.join(', ') : v.toString();
      });
    } else if (e is List) {
      for (final it in e) {
        if (it is Map) {
          final field = (it['field'] ?? it['path'] ?? '').toString();
          final msg = (it['message'] ?? '').toString();
          if (field.isNotEmpty) out[field.split('.').last] = msg;
        }
      }
    }
    return out;
  }
}
