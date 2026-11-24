import 'api_client.dart';

/// Satu item konten dari web admin.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.name,
    this.description = '',
    this.location = '',
    this.date = '',
    this.amount = '',
    this.status = '',
    this.imageUrl,
    this.eventDate,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String location;
  final String date;
  final String amount;
  final String status;
  final String? imageUrl;
  final String? eventDate;
  final String? updatedAt;

  /// Angka dari field amount (mis. "Rp25.000" -> 25000), null kalau bukan angka.
  int? get amountInt {
    final digits = amount.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  factory ContentItem.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => v == null ? '' : v.toString();
    String? n(dynamic v) {
      final t = s(v).trim();
      return t.isEmpty ? null : t;
    }

    return ContentItem(
      id: s(j['id']),
      name: s(j['name']),
      description: s(j['description']),
      location: s(j['location']),
      date: s(j['date']),
      amount: s(j['amount']),
      status: s(j['status']),
      imageUrl: n(j['imageUrl']),
      eventDate: n(j['eventDate']),
      updatedAt: n(j['updatedAt']),
    );
  }
}

class ContentBundle {
  const ContentBundle({
    this.exploration = const [],
    this.panji = const [],
    this.materi = const [],
    this.ticketing = const [],
    this.faq = const [],
    this.notification = const [],
  });

  final List<ContentItem> exploration;
  final List<ContentItem> panji;
  final List<ContentItem> materi;
  final List<ContentItem> ticketing;
  final List<ContentItem> faq;
  final List<ContentItem> notification;
}

/// Konten dari web admin (wajib login, hanya baca).
class ContentService {
  static ContentBundle? _cache;

  static List<ContentItem> _list(dynamic v) {
    if (v is! List) return const [];
    return [
      for (final e in v)
        if (e is Map<String, dynamic>) ContentItem.fromJson(e),
    ];
  }

  /// Ambil semua jenis sekaligus. Hasilnya disimpan selama app berjalan;
  /// pakai [force] untuk memuat ulang (mis. tarik-untuk-refresh).
  static Future<ContentBundle> load({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    final data = await ApiClient.instance.get('/content');
    final m = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    return _cache = ContentBundle(
      exploration: _list(m['exploration']),
      panji: _list(m['panji']),
      materi: _list(m['materi']),
      ticketing: _list(m['ticketing']),
      faq: _list(m['faq']),
      notification: _list(m['notification']),
    );
  }

  /// Ambil satu jenis: exploration | panji | materi | ticketing | faq | notification.
  static Future<List<ContentItem>> kind(String kind) async {
    final data = await ApiClient.instance.get('/content/$kind');
    return _list(data);
  }

  /// Item dari BE hanya TAMBAHAN: yang namanya sama dengan data bawaan
  /// aplikasi dilewati.
  static List<ContentItem> extras(
    List<ContentItem> fromApi,
    Iterable<String> localNames,
  ) {
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    final local = {for (final n in localNames) norm(n)};
    return [
      for (final i in fromApi)
        if (!local.contains(norm(i.name))) i,
    ];
  }

  /// Cek jawaban game panji baru. Jawaban benar dan clue ada di server.
  static Future<({bool correct, String? clue})> checkPanjiAnswer(
    String id,
    String answer,
  ) async {
    final data = await ApiClient.instance.post(
      '/content/panji/$id/answer',
      body: {'answer': answer.trim()},
    );
    final m = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    return (correct: m['correct'] == true, clue: m['clue']?.toString());
  }

  static void clearCache() => _cache = null;
}
