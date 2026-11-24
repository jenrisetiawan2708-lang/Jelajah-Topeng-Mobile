import 'api_client.dart';

class PaymentOrder {
  const PaymentOrder({
    required this.orderId,
    required this.itemName,
    required this.amount,
    required this.status,
    this.snapToken = '',
    this.redirectUrl = '',
    this.createdAt = '',
  });

  final String orderId;
  final String itemName;
  final int amount;

  /// "pending" | "paid" | "failed" | "expired" | "refunded"
  final String status;
  final String snapToken;
  final String redirectUrl;
  final String createdAt;

  bool get isPaid => status == 'paid';
  bool get isFinalFailure => status == 'failed' || status == 'expired';

  factory PaymentOrder.fromJson(Map<String, dynamic> j) {
    final a = j['amount'];
    return PaymentOrder(
      orderId: (j['orderId'] ?? j['id'] ?? '').toString(),
      itemName: (j['itemName'] ?? '').toString(),
      amount: a is num ? a.toInt() : int.tryParse('$a') ?? 0,
      status: (j['status'] ?? 'pending').toString(),
      snapToken: (j['snapToken'] ?? '').toString(),
      redirectUrl: (j['redirectUrl'] ?? '').toString(),
      createdAt: (j['createdAt'] ?? '').toString(),
    );
  }
}

/// Pembayaran Midtrans (mode SANDBOX). Wajib login.
class PaymentService {
  static const minAmount = 1000;
  static const maxAmount = 100000000;

  /// Buat transaksi. Nama dan email pembeli diambil BE dari akun yang login.
  static Future<PaymentOrder> checkout({
    required int amount,
    required String itemName,
  }) async {
    if (amount < minAmount || amount > maxAmount) {
      throw ApiException('Nominal harus antara Rp1.000 dan Rp100.000.000.');
    }
    if (itemName.trim().length < 3) {
      throw ApiException('Nama item minimal 3 karakter.');
    }
    final data = await ApiClient.instance.post(
      '/payments/checkout',
      body: {'amount': amount, 'itemName': itemName.trim()},
    );
    return PaymentOrder.fromJson(data as Map<String, dynamic>);
  }

  /// Status terbaru: pending | paid | failed | expired | refunded.
  static Future<String> status(String orderId) async {
    final data = await ApiClient.instance.get('/payments/$orderId/status');
    if (data is Map<String, dynamic>) {
      return (data['status'] ?? 'pending').toString();
    }
    return 'pending';
  }

  /// Riwayat transaksi milik user yang login.
  static Future<List<PaymentOrder>> mine() async {
    final data = await ApiClient.instance.get('/payments/mine');
    if (data is! List) return const [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>) PaymentOrder.fromJson(e),
    ];
  }
}
