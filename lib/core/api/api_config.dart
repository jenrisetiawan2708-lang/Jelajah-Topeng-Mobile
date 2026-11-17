class ApiConfig {
  /// Alamat BE. iOS Simulator memakai localhost untuk menjangkau laptop.
  /// Android emulator: ganti ke http://10.0.2.2:5050
  /// Atau jalankan: flutter run --dart-define=API_URL=http://192.168.x.x:5050
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5050',
  );

  static String get api => '$baseUrl/api';
}
