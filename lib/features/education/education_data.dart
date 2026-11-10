class Reading {
  const Reading({
    required this.menuTitle,
    required this.label,
    required this.title,
    required this.body,
    required this.quote,
  });

  final String menuTitle; // judul di daftar bacaan
  final String label; // teks merah kecil di atas judul
  final String title; // judul besar
  final String body;
  final String quote;
}

class Materi {
  const Materi({
    required this.number,
    required this.title,
    required this.description,
    required this.readings,
  });

  final int number;
  final String title;
  final String description;
  final List<Reading> readings;

  String get author => 'Ki Sujono';
}

const _quoteReni = 'Warisan terjaga saat kita ikut merawatnya.';
const _quoteWindu =
    'Sumur Windu merupakan salah satu situs yang menjadi bagian dari kekayaan budaya Kampung Budaya Polowijen.';
const _quotePurwa =
    'Polowijen memiliki sejumlah situs dan tradisi yang berkaitan dengan sejarah kawasan serta kehidupan masyarakat pada masa lalu';
const _quoteLolo =
    'Situs Joko Lolo merupakan salah satu dari beberapa situs yang menjadi bagian dari kawasan budaya Polowijen.';

const materiList = <Materi>[
  // ───────────── MATERI 1 ─────────────
  Materi(
    number: 1,
    title: 'Makam Mbah Reni',
    description:
        'Kenali Makam Mbah Reni melalui kisah budaya Polowijen. Yuk, baca dan temukan makna merawat warisan bersama!',
    readings: [
      Reading(
        menuTitle: 'Mengenal Makam Mbah Reni',
        label: 'Mengenal Lebih Jauh',
        title: 'Mbah Reni',
        body:
            'Mbah Reni merupakan salah satu tokoh penting dalam sejarah seni budaya Polowijen, khususnya dalam perkembangan Topeng Malangan. Nama Mbah Reni juga dikenal dengan nama Ki Tjondro Suwono. Sosoknya dikenang sebagai seorang seniman dan pengrajin topeng yang memiliki peran besar dalam perkembangan kesenian topeng di Polowijen.\n\n'
            'Polowijen bahkan pernah dikenal dengan sebutan Desa Reni karena kuatnya keterkaitan wilayah tersebut dengan keberadaan Mbah Reni dan kesenian topengnya. Pada masa lalu, Polowijen dikenal sebagai salah satu wilayah yang memiliki kehidupan seni pertunjukan yang kuat.',
        quote: _quoteReni,
      ),
      Reading(
        menuTitle: 'Warisan Seni Topeng',
        label: 'Warisan Seni',
        title: 'Topeng',
        body:
            'Topeng bukan hanya sebuah benda yang digunakan sebagai hiasan. Dalam kesenian Topeng Malangan, topeng digunakan sebagai bagian dari pertunjukan untuk menggambarkan karakter dan tokoh dalam sebuah cerita.\n\n'
            'Kesenian topeng diwariskan melalui proses belajar, latihan, dan praktik secara langsung. Pengetahuan mengenai cara membuat topeng, mengenali karakter, hingga memahami cerita di balik pertunjukan menjadi bagian dari warisan budaya yang diteruskan dari satu generasi ke generasi berikutnya.Mbah Reni menjadi salah satu tokoh yang dikenang dalam perjalanan kesenian topeng di Polowijen.',
        quote: _quoteReni,
      ),
      Reading(
        menuTitle: 'Nilai dan Pelestarian Budaya',
        label: 'Nilai dan Pelestarian',
        title: 'Budaya',
        body:
            'Makam Mbah Reni menjadi salah satu tempat yang memiliki nilai sejarah dan budaya bagi masyarakat Polowijen. Keberadaannya menjadi pengingat terhadap sosok yang dikaitkan dengan perkembangan kesenian topeng di kawasan tersebut.\n'
            'Warisan budaya tidak hanya berupa bangunan, benda, atau tempat bersejarah. Cerita, keterampilan, kesenian, dan pengetahuan yang diwariskan oleh masyarakat juga merupakan bagian dari warisan budaya.\n\n'
            'Generasi muda dapat ikutmenghargai para pelaku budaya, mempelajari keseniannya, serta memperkenalkan budaya lokal kepada orang lain.',
        quote: _quoteReni,
      ),
    ],
  ),

  // ───────────── MATERI 2 ─────────────
  Materi(
    number: 2,
    title: 'Situs Sumur Windu',
    description:
        'Mengenal Situs Sumur Windu dan cerita masyarakat yang menghubungkannya dengan Ken Dedes. Jelajahi kisah dan nilai budaya yang hidup di tengah masyarakat Polowijen.',
    readings: [
      Reading(
        menuTitle: 'Mengenal Sumur Windu',
        label: 'Mengenal Lebih Jauh',
        title: 'Sumur Windu',
        body:
            'Situs Sumur Windu merupakan salah satu situs budaya yang berada di kawasan Polowijen. Situs ini menjadi bagian dari kekayaan sejarah dan cerita budaya yang berkembang di masyarakat. Sumur Windu juga dikenal dalam cerita masyarakat sebagai salah satu tempat yang memiliki hubungan dengan Ken Dedes. Di kawasan situs terdapat tinggalan fisik yang menjadi bagian dari pembahasan mengenai sejarah kawasan Polowijen.\n'
            'Keberadaan Sumur Windu menunjukkan bahwa sebuah tempat dapat memiliki nilai yang lebih dari sekadar bentuk fisiknya. Di dalamnya terdapat cerita dan ingatan masyarakat yang diwariskan dari generasi ke generasi.',
        quote: _quoteWindu,
      ),
      Reading(
        menuTitle: 'Ken Dedes Dan Cerita Masyarakat',
        label: 'Ken Dedes dan Cerita',
        title: 'Masyarakat',
        body:
            'Polowijen memiliki hubungan yang kuat dengan cerita mengenai Ken Dedes. Dalam berbagai sumber dan cerita masyarakat, kawasan Polowijen dikaitkan dengan Panawijen dan kisah kehidupan Ken Dedes.\n'
            'Salah satu cerita yang berkembang juga menghubungkan Sumur Windu dengan Joko Lolo. Dalam salah satu versi cerita, Joko Lolo merupakan seorang pemuda dari Dinoyo yang ingin mempersunting Ken Dedes.\n'
            'Cerita mengenai Joko Lolo dan Ken Dedes kemudian berkembang menjadi bagian dari legenda masyarakat Polowijen. Cerita tersebut diwariskan secara turun-temurun dan menjadi bagian dari identitas budaya masyarakat.\n'
            'Perlu dipahami bahwa kisah tersebut merupakan bagian dari cerita rakyat dan tradisi tutur masyarakat. Karena memiliki beberapa versi, cerita tersebut tidak selalu dapat diperlakukan sebagai fakta sejarah yang telah terbukti.',
        quote: _quoteWindu,
      ),
      Reading(
        menuTitle: 'Menjaga Situs Budaya',
        label: 'Menjaga',
        title: 'Situs Budaya',
        body:
            'Sumur Windu menunjukkan bahwa sebuah situs dapat memiliki banyak lapisan cerita. Selain tinggalan fisik, terdapat pula cerita masyarakat yang memberikan makna terhadap keberadaan tempat tersebut.\n\n'
            'Situs budaya perlu dijaga agar generasi berikutnya tetap dapat mengenal dan mempelajari sejarah serta budaya daerahnya. Ketika mengunjungi situs budaya, kita dapat ikut menjaga dengan tidak merusak benda atau lingkungan, menjaga kebersihan, mengikuti aturan yang berlaku, dan menghormati masyarakat sekitar.',
        quote: _quoteWindu,
      ),
    ],
  ),

  // ───────────── MATERI 3 ─────────────
  Materi(
    number: 3,
    title: 'Mandala Empu Purwa',
    description:
        'Mengenal Mandala Empu Purwa sebagai salah satu jejak sejarah dan budaya di Polowijen. Pelajari kisah Empu Purwa serta warisan budaya yang terdapat di kawasan ini.',
    readings: [
      Reading(
        menuTitle: 'Mengenal Makam Empu Purwa',
        label: 'Mengenal Lebih Jauh',
        title: 'Empu Purwa',
        body:
            'Empu Purwa merupakan salah satu tokoh yang muncul dalam sejarah dan tradisi yang berkaitan dengan Polowijen dan Ken Dedes.\n\n'
            'Dalam cerita yang berkembang, Empu Purwa memiliki hubungan dengan Ken Dedes. Kisah mengenai tokoh tersebut kemudian menjadi bagian dari cerita budaya yang dikenal oleh masyarakat Polowijen.\n\n'
            'Kawasan yang dikaitkan dengan Empu Purwa dikenal sebagai Mandala Empu Purwa. Keberadaannya menjadi salah satu bagian dari jejak sejarah dan budaya yang terdapat di Polowijen.',
        quote: _quotePurwa,
      ),
      Reading(
        menuTitle: 'Mandala dan Tinggalan Budaya',
        label: 'Mandala dan Tinggalan',
        title: 'Budaya',
        body:
            'Dalam konteks sejarah Jawa, istilah mandala dapat digunakan untuk menggambarkan suatu lingkungan yang berkaitan dengan kehidupan keagamaan dan pendidikan.Mandala Empu Purwa di Polowijen dipahami sebagai salah satu tinggalan budaya yang menunjukkan bahwa kawasan tersebut memiliki sejarah yang panjang. Di kawasan yang dikaitkan dengan situs ini terdapat tinggalan fisik seperti struktur atau susunan bata merah. Tinggalan tersebut menjadi bagian dari pembahasan mengenai kehidupan masyarakat pada masa lalu.\n'
            'Dalam mempelajari situs budaya, penting untuk membedakan antara tinggalan fisik yang dapat diamati, ataupun tidak dapat diamati',
        quote: _quotePurwa,
      ),
      Reading(
        menuTitle: 'Polowljen Sebagai Tempat Bersejarah',
        label: 'Polowljen Sebagai Tempat',
        title: 'Bersejarah',
        body:
            'Mandala Empu Purwa merupakan salah satu bagian dari rangkaian situs budaya yang terdapat di Polowijen. Bersama Makam Mbah Reni, Sumur Windu, dan Situs Joko Lolo, keberadaan situs tersebut memperkuat identitas Polowijen sebagai kawasan yang memiliki kekayaan sejarah dan budaya.Sejarah sebuah wilayah tidak hanya dapat ditemukan melalui buku. Lingkungan sekitar, situs, tradisi, kesenian, dan cerita masyarakat juga dapat membantu kita memahami perjalanan sebuah wilayah.\n'
            'Dengan mempelajari situs seperti Mandala Empu Purwa, generasi muda dapat mengenal bahwa lingkungan tempat tinggal mereka memiliki cerita dan nilai sejarah yang penting untuk dijaga.',
        quote: _quotePurwa,
      ),
    ],
  ),

  // ───────────── MATERI 4 ─────────────
  Materi(
    number: 4,
    title: 'Situs Joko Lolo',
    description:
        'Mengenal Situs Joko Lolo dan legenda Joko Lolo yang berkembang di masyarakat Polowijen. Temukan nilai budaya dan tradisi yang membuat situs ini tetap dikenang.',
    readings: [
      Reading(
        menuTitle: 'Mengenal Situs Joko Lolo',
        label: 'Mengenal Lebih Jauh',
        title: 'Situs Joko Lolo',
        body:
            'Situs Joko Lolo merupakan salah satu situs budaya yang berada di kawasan Polowijen. Situs ini memiliki hubungan erat dengan cerita masyarakat mengenai Joko Lolo dan Ken Dedes. Salah satu ciri yang dikenal dari kawasan tersebut adalah keberadaan pohon beringin besar. Keberadaan tempat tersebut kemudian menjadi bagian dari cerita dan ingatan budaya masyarakat Polowijen.\n\n'
            'Situs Joko Lolo menunjukkan bagaimana sebuah tempat dapat memiliki hubungan dengan cerita rakyat yang terus diwariskan dari generasi ke generasi.',
        quote: _quoteLolo,
      ),
      Reading(
        menuTitle: 'Kisah Ken Dedes Dan Joko Lolo',
        label: 'Kisah Ken Dedes dan',
        title: 'Joko Lolo',
        body:
            'Dalam salah satu versi cerita yang berkembang di masyarakat, Joko Lolo merupakan seorang pemuda dari Dinoyo yang ingin mempersunting Ken Dedes.Cerita tersebut kemudian dikaitkan dengan pembuatan Sumur Windu. Dalam cerita masyarakat, Joko Lolo juga dikaitkan dengan kisah menghilang atau moksa.\n'
            'Terdapat beberapa versi mengenai kisah Joko Lolo dan Ken Dedes. Perbedaan tersebut merupakan hal yang umum dalam cerita rakyat karena cerita dapat berkembang melalui tradisi lisan dari satu generasi ke generasi berikutnya. Oleh karena itu, kisah Joko Lolo lebih tepat dipahami sebagai bagian dari legenda dan tradisi tutur masyarakat Polowijen.',
        quote: _quoteLolo,
      ),
      Reading(
        menuTitle: 'Tradisi dan Nilai Budaya',
        label: 'Tradisi dan',
        title: 'Nilai Budaya',
        body:
            'Situs Joko Lolo menunjukkan bahwa sebuah tempat dapat menyimpan cerita yang terus hidup selama masyarakat masih mengingat dan menceritakannya.Situs budaya juga tidak hanya berkaitan dengan masa lalu. Keberadaannya dapat menjadi bagian dari kehidupan sosial dan budaya masyarakat saat ini.Ketika mengunjungi situs budaya, kita perlu menjaga kebersihan, tidak merusak lingkungan, berbicara dengan sopan, mengikuti aturan setempat, dan menghormati kegiatan masyarakat.Generasi muda memiliki peran penting dalam menjaga keberadaan cerita dan tradisi tersebut. Mengenal budaya merupakan langkah awal untuk menghargai dan melestarikannya.',
        quote: _quoteLolo,
      ),
    ],
  ),
];