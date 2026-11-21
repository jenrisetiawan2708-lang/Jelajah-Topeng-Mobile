/// Satu bacaan (sub bab) di dalam materi.
class Reading {
  const Reading({
    required this.title,
    required this.eyebrow,
    required this.heading,
    required this.paragraphs,
    required this.quote,
  });
  final String title; // judul di daftar "Pelajari Materi"
  final String eyebrow; // teks merah kecil di kartu baca
  final String heading; // judul besar di kartu baca
  final List<String> paragraphs;
  final String quote; // kutipan di kotak krem
}

class Materi {
  const Materi({
    required this.number,
    required this.title,
    required this.author,
    required this.about,
    required this.readings,
  });
  final int number;
  final String title;
  final String author;
  final String about;
  final List<Reading> readings;
}

/// Status baca disimpan di memori (belum ke backend).
/// 0 = belum dimulai, 1 = sedang dibaca, 2 = selesai
class EducationProgress {
  static final Map<String, int> _status = {};

  static int of(int materi, int reading) => _status['$materi-$reading'] ?? 0;

  static void set(int materi, int reading, int value) {
    _status['$materi-$reading'] = value;
  }

  static int doneCount(Materi m) {
    var n = 0;
    for (var i = 0; i < m.readings.length; i++) {
      if (of(m.number, i) == 2) n++;
    }
    return n;
  }

  /// Jumlah bacaan yang sedang dibaca (belum selesai).
  static int readingCount(Materi m) {
    var n = 0;
    for (var i = 0; i < m.readings.length; i++) {
      if (of(m.number, i) == 1) n++;
    }
    return n;
  }
}

// ---------------------------------------------------------------------------
// Kutipan di kotak krem (sama untuk semua bacaan dalam satu materi)
// ---------------------------------------------------------------------------
const _quoteM1 = 'Warisan terjaga saat kita ikut merawatnya.';
const _quoteM2 =
    'Sumur Windu merupakan salah satu situs yang menjadi bagian dari kekayaan budaya Kampung Budaya Polowijen.';
const _quoteM3 =
    'Polowijen memiliki sejumlah situs dan tradisi yang berkaitan dengan sejarah kawasan serta kehidupan masyarakat pada masa lalu';
const _quoteM4 =
    'Situs Joko Lolo merupakan salah satu dari beberapa situs yang menjadi bagian dari kawasan budaya Polowijen.';

// ---------------------------------------------------------------------------
// Isi materi (disalin dari wireframe high-fi)
// ---------------------------------------------------------------------------
const List<Materi> materiList = [
  // ------------------------------------------------------------- MATERI 1
  Materi(
    number: 1,
    title: 'Makam Mbah Reni',
    author: 'Ki Sujono',
    about: 'Kenali Makam Mbah Reni melalui kisah budaya Polowijen. Yuk, baca dan temukan makna merawat warisan bersama!',
    readings: [
      Reading(
        title: 'Mengenal Makam Mbah Reni',
        eyebrow: 'Mengenal Lebih Jauh',
        heading: 'Mbah Reni',
        quote: _quoteM1,
        paragraphs: [
          'Mbah Reni merupakan salah satu tokoh penting dalam sejarah seni budaya Polowijen, khususnya dalam perkembangan Topeng Malangan. Nama Mbah Reni juga dikenal dengan nama Ki Tjondro Suwono. Sosoknya dikenang sebagai seorang seniman dan pengrajin topeng yang memiliki peran besar dalam perkembangan kesenian topeng di Polowijen.',
          'Polowijen bahkan pernah dikenal dengan sebutan Desa Reni karena kuatnya keterkaitan wilayah tersebut dengan keberadaan Mbah Reni dan kesenian topengnya. Pada masa lalu, Polowijen dikenal sebagai salah satu wilayah yang memiliki kehidupan seni pertunjukan yang kuat.',
        ],
      ),
      Reading(
        title: 'Warisan Seni Topeng',
        eyebrow: 'Warisan Seni',
        heading: 'Topeng',
        quote: _quoteM1,
        paragraphs: [
          'Topeng bukan hanya sebuah benda yang digunakan sebagai hiasan. Dalam kesenian Topeng Malangan, topeng digunakan sebagai bagian dari pertunjukan untuk menggambarkan karakter dan tokoh dalam sebuah cerita.',
          'Kesenian topeng diwariskan melalui proses belajar, latihan, dan praktik secara langsung. Pengetahuan mengenai cara membuat topeng, mengenali karakter, hingga memahami cerita di balik pertunjukan menjadi bagian dari warisan budaya yang diteruskan dari satu generasi ke generasi berikutnya. Mbah Reni menjadi salah satu tokoh yang dikenang dalam perjalanan kesenian topeng di Polowijen.',
        ],
      ),
      Reading(
        title: 'Nilai dan Pelestarian Budaya',
        eyebrow: 'Nilai dan Pelestarian',
        heading: 'Budaya',
        quote: _quoteM1,
        paragraphs: [
          'Makam Mbah Reni menjadi salah satu tempat yang memiliki nilai sejarah dan budaya bagi masyarakat Polowijen. Keberadaannya menjadi pengingat terhadap sosok yang dikaitkan dengan perkembangan kesenian topeng di kawasan tersebut.',
          'Warisan budaya tidak hanya berupa bangunan, benda, atau tempat bersejarah. Cerita, keterampilan, kesenian, dan pengetahuan yang diwariskan oleh masyarakat juga merupakan bagian dari warisan budaya.',
          'Generasi muda dapat ikut menghargai para pelaku budaya, mempelajari keseniannya, serta memperkenalkan budaya lokal kepada orang lain.',
        ],
      ),
    ],
  ),

  // ------------------------------------------------------------- MATERI 2
  Materi(
    number: 2,
    title: 'Situs Sumur Windu',
    author: 'Ki Sujono',
    about: 'Mengenal Situs Sumur Windu dan cerita masyarakat yang menghubungkannya dengan Ken Dedes. Jelajahi kisah dan nilai budaya yang hidup di tengah masyarakat Polowijen.',
    readings: [
      Reading(
        title: 'Mengenal Sumur Windu',
        eyebrow: 'Mengenal Lebih Jauh',
        heading: 'Sumur Windu',
        quote: _quoteM2,
        paragraphs: [
          'Situs Sumur Windu merupakan salah satu situs budaya yang berada di kawasan Polowijen. Situs ini menjadi bagian dari kekayaan sejarah dan cerita budaya yang berkembang di masyarakat. Sumur Windu juga dikenal dalam cerita masyarakat sebagai salah satu tempat yang memiliki hubungan dengan Ken Dedes. Di kawasan situs terdapat tinggalan fisik yang menjadi bagian dari pembahasan mengenai sejarah kawasan Polowijen.',
          'Keberadaan Sumur Windu menunjukkan bahwa sebuah tempat dapat memiliki nilai yang lebih dari sekadar bentuk fisiknya. Di dalamnya terdapat cerita dan ingatan masyarakat yang diwariskan dari generasi ke generasi.',
        ],
      ),
      Reading(
        title: 'Ken Dedes Dan Cerita Masyarakat',
        eyebrow: 'Ken Dedes dan Cerita',
        heading: 'Masyarakat',
        quote: _quoteM2,
        paragraphs: [
          'Polowijen memiliki hubungan yang kuat dengan cerita mengenai Ken Dedes. Dalam berbagai sumber dan cerita masyarakat, kawasan Polowijen dikaitkan dengan Panawijen dan kisah kehidupan Ken Dedes.',
          'Salah satu cerita yang berkembang juga menghubungkan Sumur Windu dengan Joko Lolo. Dalam salah satu versi cerita, Joko Lolo merupakan seorang pemuda dari Dinoyo yang ingin mempersunting Ken Dedes.',
          'Cerita mengenai Joko Lolo dan Ken Dedes kemudian berkembang menjadi bagian dari legenda masyarakat Polowijen. Cerita tersebut diwariskan secara turun-temurun dan menjadi bagian dari identitas budaya masyarakat.',
          'Perlu dipahami bahwa kisah tersebut merupakan bagian dari cerita rakyat dan tradisi tutur masyarakat. Karena memiliki beberapa versi, cerita tersebut tidak selalu dapat diperlakukan sebagai fakta sejarah yang telah terbukti.',
        ],
      ),
      Reading(
        title: 'Menjaga Situs Budaya',
        eyebrow: 'Menjaga',
        heading: 'Situs Budaya',
        quote: _quoteM2,
        paragraphs: [
          'Sumur Windu menunjukkan bahwa sebuah situs dapat memiliki banyak lapisan cerita. Selain tinggalan fisik, terdapat pula cerita masyarakat yang memberikan makna terhadap keberadaan tempat tersebut.',
          'Situs budaya perlu dijaga agar generasi berikutnya tetap dapat mengenal dan mempelajari sejarah serta budaya daerahnya. Ketika mengunjungi situs budaya, kita dapat ikut menjaga dengan tidak merusak benda atau lingkungan, menjaga kebersihan, mengikuti aturan yang berlaku, dan menghormati masyarakat sekitar.',
        ],
      ),
    ],
  ),

  // ------------------------------------------------------------- MATERI 3
  Materi(
    number: 3,
    title: 'Mandala Empu Purwa',
    author: 'Ki Sujono',
    about: 'Mengenal Mandala Empu Purwa sebagai salah satu jejak sejarah dan budaya di Polowijen. Pelajari kisah Empu Purwa serta warisan budaya yang terdapat di kawasan ini.',
    readings: [
      Reading(
        title: 'Mengenal Makam Empu Purwa',
        eyebrow: 'Mengenal Lebih Jauh',
        heading: 'Empu Purwa',
        quote: _quoteM3,
        paragraphs: [
          'Empu Purwa merupakan salah satu tokoh yang muncul dalam sejarah dan tradisi yang berkaitan dengan Polowijen dan Ken Dedes.',
          'Dalam cerita yang berkembang, Empu Purwa memiliki hubungan dengan Ken Dedes. Kisah mengenai tokoh tersebut kemudian menjadi bagian dari cerita budaya yang dikenal oleh masyarakat Polowijen.',
          'Kawasan yang dikaitkan dengan Empu Purwa dikenal sebagai Mandala Empu Purwa. Keberadaannya menjadi salah satu bagian dari jejak sejarah dan budaya yang terdapat di Polowijen.',
        ],
      ),
      Reading(
        title: 'Mandala dan Tinggalan Budaya',
        eyebrow: 'Mandala dan Tinggalan',
        heading: 'Budaya',
        quote: _quoteM3,
        paragraphs: [
          'Dalam konteks sejarah Jawa, istilah mandala dapat digunakan untuk menggambarkan suatu lingkungan yang berkaitan dengan kehidupan keagamaan dan pendidikan. Mandala Empu Purwa di Polowijen dipahami sebagai salah satu tinggalan budaya yang menunjukkan bahwa kawasan tersebut memiliki sejarah yang panjang. Di kawasan yang dikaitkan dengan situs ini terdapat tinggalan fisik seperti struktur atau susunan bata merah. Tinggalan tersebut menjadi bagian dari pembahasan mengenai kehidupan masyarakat pada masa lalu.',
          'Dalam mempelajari situs budaya, penting untuk membedakan antara tinggalan fisik yang dapat diamati, ataupun tidak dapat diamati.',
        ],
      ),
      Reading(
        title: 'Polowijen Sebagai Tempat Bersejarah',
        eyebrow: 'Polowijen Sebagai Tempat',
        heading: 'Bersejarah',
        quote: _quoteM3,
        paragraphs: [
          'Mandala Empu Purwa merupakan salah satu bagian dari rangkaian situs budaya yang terdapat di Polowijen. Bersama Makam Mbah Reni, Sumur Windu, dan Situs Joko Lolo, keberadaan situs tersebut memperkuat identitas Polowijen sebagai kawasan yang memiliki kekayaan sejarah dan budaya. Sejarah sebuah wilayah tidak hanya dapat ditemukan melalui buku. Lingkungan sekitar, situs, tradisi, kesenian, dan cerita masyarakat juga dapat membantu kita memahami perjalanan sebuah wilayah.',
          'Dengan mempelajari situs seperti Mandala Empu Purwa, generasi muda dapat mengenal bahwa lingkungan tempat tinggal mereka memiliki cerita dan nilai sejarah yang penting untuk dijaga.',
        ],
      ),
    ],
  ),

  // ------------------------------------------------------------- MATERI 4
  Materi(
    number: 4,
    title: 'Situs Joko Lolo',
    author: 'Ki Sujono',
    about: 'Mengenal Situs Joko Lolo dan legenda Joko Lolo yang berkembang di masyarakat Polowijen. Temukan nilai budaya dan tradisi yang membuat situs ini tetap dikenang.',
    readings: [
      Reading(
        title: 'Mengenal Situs Joko Lolo',
        eyebrow: 'Mengenal Lebih Jauh',
        heading: 'Situs Joko Lolo',
        quote: _quoteM4,
        paragraphs: [
          'Situs Joko Lolo merupakan salah satu situs budaya yang berada di kawasan Polowijen. Situs ini memiliki hubungan erat dengan cerita masyarakat mengenai Joko Lolo dan Ken Dedes. Salah satu ciri yang dikenal dari kawasan tersebut adalah keberadaan pohon beringin besar. Keberadaan tempat tersebut kemudian menjadi bagian dari cerita dan ingatan budaya masyarakat Polowijen.',
          'Situs Joko Lolo menunjukkan bagaimana sebuah tempat dapat memiliki hubungan dengan cerita rakyat yang terus diwariskan dari generasi ke generasi.',
        ],
      ),
      Reading(
        title: 'Kisah Ken Dedes Dan Joko Lolo',
        eyebrow: 'Kisah Ken Dedes dan',
        heading: 'Joko Lolo',
        quote: _quoteM4,
        paragraphs: [
          'Dalam salah satu versi cerita yang berkembang di masyarakat, Joko Lolo merupakan seorang pemuda dari Dinoyo yang ingin mempersunting Ken Dedes. Cerita tersebut kemudian dikaitkan dengan pembuatan Sumur Windu. Dalam cerita masyarakat, Joko Lolo juga dikaitkan dengan kisah menghilang atau moksa.',
          'Terdapat beberapa versi mengenai kisah Joko Lolo dan Ken Dedes. Perbedaan tersebut merupakan hal yang umum dalam cerita rakyat karena cerita dapat berkembang melalui tradisi lisan dari satu generasi ke generasi berikutnya. Oleh karena itu, kisah Joko Lolo lebih tepat dipahami sebagai bagian dari legenda dan tradisi tutur masyarakat Polowijen.',
        ],
      ),
      Reading(
        title: 'Tradisi dan Nilai Budaya',
        eyebrow: 'Tradisi dan',
        heading: 'Nilai Budaya',
        quote: _quoteM4,
        paragraphs: [
          'Situs Joko Lolo menunjukkan bahwa sebuah tempat dapat menyimpan cerita yang terus hidup selama masyarakat masih mengingat dan menceritakannya. Situs budaya juga tidak hanya berkaitan dengan masa lalu. Keberadaannya dapat menjadi bagian dari kehidupan sosial dan budaya masyarakat saat ini. Ketika mengunjungi situs budaya, kita perlu menjaga kebersihan, tidak merusak lingkungan, berbicara dengan sopan, mengikuti aturan setempat, dan menghormati kegiatan masyarakat. Generasi muda memiliki peran penting dalam menjaga keberadaan cerita dan tradisi tersebut. Mengenal budaya merupakan langkah awal untuk menghargai dan melestarikannya.',
        ],
      ),
    ],
  ),
];
