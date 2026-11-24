class ApiConfig {
  /// Backend produksi (Vercel).
  /// Untuk memakai backend lokal: flutter run --dart-define=API_URL=http://localhost:5050
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://jelajah-topeng-backend.vercel.app',
  );

  static String get api => '$baseUrl/api';
}
