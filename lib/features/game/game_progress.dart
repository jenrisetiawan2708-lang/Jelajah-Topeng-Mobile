import 'package:flutter/foundation.dart';

/// Menyimpan jumlah level yang sudah selesai (0-5).
class GameProgress {
  static final ValueNotifier<int> completed = ValueNotifier<int>(0);

  static void completeLevel(int level) {
    if (level > completed.value) completed.value = level;
  }
}