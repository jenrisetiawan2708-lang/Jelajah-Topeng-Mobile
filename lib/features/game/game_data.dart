/// Data tantangan game Jejak Sang Panji.
/// Baru tantangan 1 yang ada di desain. Isi sisanya kalau materinya sudah ada.
class GameChallenge {
  const GameChallenge({
    required this.title,
    required this.audioAsset,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.clue,
    required this.clueImage,
  });

  final String title;

  /// Path di dalam folder assets, tanpa awalan "assets/".
  final String audioAsset;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  /// Teks yang tampil di pop-up setelah jawaban benar.
  final String clue;
  final String clueImage;
}

const gameChallenges = <GameChallenge>[
  GameChallenge(
    title: 'Makam Mbah Reni',
    audioAsset: 'audio/kisah_mbah_reni.mp3',
    question: 'Siapa yang dipercaya menjaga topeng sakti di kisah ini?',
    options: ['Mbah Reni', 'Ki Sujono', 'Dewi Sekartaji'],
    correctIndex: 0,
    hint: 'dengarkan lagi nama tokoh yang disebut di menit pertama.',
    clue: 'AKU MENYEMBUNYIKAN WAJAH, NAMUN MENGUNGKAPKAN KARAKTER',
    clueImage: 'assets/images/maks_clue.png',
  ),
  
  GameChallenge(
    title: 'Lokasi 2',
    audioAsset: 'audio/kisah_mbah_reni.mp3',
    question: 'Soal tantangan 2',
    options: ['Pilihan A', 'Pilihan B', 'Pilihan C'],
    correctIndex: 0,
    hint: 'dengarkan lagi audionya.',
    clue: 'CLUE TANTANGAN 2',
    clueImage: 'assets/images/maks_clue.png',
  ),
  GameChallenge(
    title: 'Lokasi 3',
    audioAsset: 'audio/kisah_mbah_reni.mp3',
    question: 'Soal tantangan 3',
    options: ['Pilihan A', 'Pilihan B', 'Pilihan C'],
    correctIndex: 0,
    hint: 'dengarkan lagi audionya.',
    clue: 'CLUE TANTANGAN 3',
    clueImage: 'assets/images/maks_clue.png',
  ),
  GameChallenge(
    title: 'Lokasi 4',
    audioAsset: 'audio/kisah_mbah_reni.mp3',
    question: 'Soal tantangan 4',
    options: ['Pilihan A', 'Pilihan B', 'Pilihan C'],
    correctIndex: 0,
    hint: 'dengarkan lagi audionya.',
    clue: 'CLUE TANTANGAN 4',
    clueImage: 'assets/images/maks_clue.png',
  ),
  GameChallenge(
    title: 'Lokasi 5',
    audioAsset: 'audio/kisah_mbah_reni.mp3',
    question: 'Soal tantangan 5',
    options: ['Pilihan A', 'Pilihan B', 'Pilihan C'],
    correctIndex: 0,
    hint: 'dengarkan lagi audionya.',
    clue: 'CLUE TANTANGAN 5',
    clueImage: 'assets/images/maks_clue.png',
  ),
];
