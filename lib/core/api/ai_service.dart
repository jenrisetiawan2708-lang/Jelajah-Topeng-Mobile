import 'api_client.dart';

class AiAnswer {
  const AiAnswer({
    required this.id,
    required this.question,
    required this.answer,
    this.references = const [],
    this.confidence = 'sedang',
    this.createdAt = '',
  });

  final String id;
  final String question;
  final String answer;
  final List<String> references;

  /// "tinggi" | "sedang" | "rendah"
  final String confidence;
  final String createdAt;

  factory AiAnswer.fromJson(Map<String, dynamic> j) {
    final refs = j['references'];
    return AiAnswer(
      id: (j['id'] ?? '').toString(),
      question: (j['question'] ?? '').toString(),
      answer: (j['answer'] ?? '').toString(),
      references: refs is List
          ? [for (final r in refs) r.toString()]
          : const [],
      confidence: (j['confidence'] ?? 'sedang').toString(),
      createdAt: (j['createdAt'] ?? '').toString(),
    );
  }
}

/// Tanya AI lewat backend (wajib login).
class AiService {
  /// Jawaban butuh 2-30 detik, jadi batas waktunya 45 detik.
  static const _timeout = Duration(seconds: 45);

  static Future<AiAnswer> ask(String question) async {
    final q = question.trim();
    if (q.length < 3) {
      throw ApiException('Pertanyaan minimal 3 karakter.');
    }
    if (q.length > 500) {
      throw ApiException('Pertanyaan maksimal 500 karakter.');
    }
    final data = await ApiClient.instance.post(
      '/ai/ask',
      body: {'question': q},
      timeout: _timeout,
    );
    return AiAnswer.fromJson(data as Map<String, dynamic>);
  }

  /// 20 pertanyaan terakhir milik user yang login.
  static Future<List<AiAnswer>> history() async {
    final data = await ApiClient.instance.get('/ai/history');
    if (data is! List) return const [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>) AiAnswer.fromJson(e),
    ];
  }
}
