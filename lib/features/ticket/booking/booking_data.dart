const monthsId = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const monthsShortId = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];
const monthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const daysEn = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
];
const daysId = [
  'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
];

/// 50000 -> "Rp50.000" (prefix bisa diganti, mis. "Rp.")
String rupiah(int v, {String prefix = 'Rp'}) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$prefix$b';
}

String dateId(DateTime d) => '${d.day} ${monthsId[d.month - 1]} ${d.year}';

/// "Sabtu, 24 Okt 2026"
String dateShortId(DateTime d) =>
    '${daysId[d.weekday % 7]}, ${d.day} ${monthsShortId[d.month - 1]} ${d.year}';

/// Satu paket kunjungan.
class TicketPackage {
  const TicketPackage({
    required this.name,
    required this.info,
    required this.chips,
    required this.price,
    required this.priceLabel,
    required this.minPeople,
    required this.maxPeople,
    this.tags = const [],
    this.saturdayOnly = false,
    this.time = '10.00',
    this.flatTotal,
  });

  final String name;
  final String info;
  final List<String> chips;
  final int price; // harga per orang
  final String priceLabel;
  final int minPeople;
  final int maxPeople;
  final List<String> tags;
  final bool saturdayOnly;
  final String time;
  final int? flatTotal; // kalau paket berharga tetap

  bool fits(int people) => people >= minPeople && people <= maxPeople;

  int totalFor(int people) => flatTotal ?? people * price;

  /// Tanggal terdekat yang boleh dipilih (mulai besok).
  DateTime firstDate() {
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day + 1);
    while (saturdayOnly && d.weekday != DateTime.saturday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}

// Data paket. Ubah di sini kalau harga atau aturan berubah.
const kPackages = [
  TicketPackage(
    name: 'Paket Medayoh',
    info: 'Sabtu 13.00–17.00 · kelompok 3–10 orang',
    chips: ['Sabtu', '3–10 orang', 'Bebas dokumentasi'],
    price: 30000,
    priceLabel: 'Rp30 rb / orang',
    minPeople: 3,
    maxPeople: 10,
    saturdayOnly: true,
    time: '13.00–17.00',
  ),
  TicketPackage(
    name: 'Paket Sobo Pawon',
    info: 'Kunjungan harian · kelompok kecil',
    chips: ['Harian', '2–4 orang'],
    price: 25000,
    priceLabel: 'Rp25 rb / orang',
    minPeople: 2,
    maxPeople: 4,
  ),
  TicketPackage(
    name: 'Paket Sumbang Kampung',
    info: 'Minimal 30 orang · rombongan sekolah',
    chips: ['Rombongan', 'min. 30 orang'],
    price: 30000,
    priceLabel: 'Rp30 rb / orang',
    minPeople: 30,
    maxPeople: 100,
    tags: ['Pelajar'],
  ),
  TicketPackage(
    name: 'Paket Selametan/Metri',
    info: '1 jt untuk 20 orang · mentri weton',
    chips: ['Weton / ulang tahun', '20 orang'],
    price: 50000,
    priceLabel: 'Rp1 jt / 20 orang',
    minPeople: 1,
    maxPeople: 20,
    flatTotal: 1000000,
  ),
  TicketPackage(
    name: 'Paket Hasta Karya',
    info: 'Memahat, membatik, melukis topeng',
    chips: ['Workshop', 'Per kegiatan'],
    price: 25000,
    priceLabel: 'mulai Rp25 rb / orang',
    minPeople: 1,
    maxPeople: 30,
  ),
];

/// Data pesanan yang dibawa dari halaman ke halaman.
class BookingData {
  BookingData({TicketPackage? package})
      : package = package ?? kPackages[0],
        date = DateTime(2026, 10, 15);

  TicketPackage package;
  DateTime date;
  int tickets = 2;
  String name = '';
  String phone = '';

  String? _time;
  String get time => _time ?? package.time;
  set time(String v) => _time = v;

  // Dipertahankan agar kode lama tetap jalan.
  static const price = 25000;

  int get unitPrice => package.price;
  int get total => package.totalFor(tickets);
}