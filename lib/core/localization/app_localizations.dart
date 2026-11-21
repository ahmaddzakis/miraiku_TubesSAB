import '../game_manager.dart';

/// Centralized localization strings for MIRAIku quizzes and UI.
///
/// Decouples translated strings from widgets in accordance with GEMINI.md.
/// Reacts to [globalLanguage] ('id' or 'en').
class AppLocalizations {
  AppLocalizations._();

  static bool get isId => globalLanguage.value == 'id';

  static String tr(String en, String id, [String? langCode]) {
    final code = langCode ?? globalLanguage.value;
    return code == 'id' ? id : en;
  }

  // ==========================================
  // 📝 QUIZ & EXERCISE LOCALIZED STRINGS
  // ==========================================

  /// Standardized prompt for word meaning questions ("arti kata").
  static String wordMeaningQuestion([String? langCode]) => tr(
        'What does this word mean?',
        'Apa arti dari kata ini?',
        langCode,
      );

  /// Standardized prompt for word meaning questions with a hint.
  static String wordMeaningWithHintQuestion(
    String hintEn,
    String hintId, [
    String? langCode,
  ]) =>
      tr(
        'What does this word mean? (Hint: $hintEn)',
        'Apa arti dari kata ini? (Petunjuk: $hintId)',
        langCode,
      );

  /// Standardized prompt for character reading / romaji questions.
  static String characterReadingQuestion([String? langCode]) => tr(
        'What is the reading of this character?',
        'Bagaimana cara baca karakter ini?',
        langCode,
      );

  /// Standardized prompt for choosing the matching character.
  static String chooseCorrectCharacterQuestion([String? langCode]) => tr(
        'Choose the correct character:',
        'Pilih karakter yang tepat:',
        langCode,
      );

  /// Standardized prompt for expression meaning questions.
  static String expressionMeaningQuestion([String? langCode]) => tr(
        'What does this expression mean?',
        'Apa arti dari ungkapan ini?',
        langCode,
      );

  /// Standardized prompt for number meaning questions.
  static String numberMeaningQuestion([String? langCode]) => tr(
        'What does this number mean?',
        'Apa arti dari angka ini?',
        langCode,
      );

  /// Standardized prompt for verb meaning questions.
  static String verbMeaningQuestion([String? langCode]) => tr(
        'What does this verb mean?',
        'Apa arti dari kata kerja ini?',
        langCode,
      );

  /// Standardized prompt for adjective meaning questions.
  static String adjectiveMeaningQuestion([String? langCode]) => tr(
        'What does this adjective mean?',
        'Apa arti dari kata sifat ini?',
        langCode,
      );

  /// Standardized prompt for single Kanji meaning questions.
  static String kanjiMeaningQuestion([String? langCode]) => tr(
        'What does this Kanji character mean?',
        'Apa arti dari karakter Kanji ini?',
        langCode,
      );

  /// Standardized prompt for compound Kanji (Jukugo) meaning questions.
  static String compoundMeaningQuestion([String? langCode]) => tr(
        'What does this compound word mean?',
        'Apa arti dari kata gabungan (Jukugo) ini?',
        langCode,
      );

  /// Standardized prompt for particle function questions.
  static String particleFunctionQuestion([String? langCode]) => tr(
        'What is the function of this particle in a sentence?',
        'Apa fungsi dari partikel ini dalam kalimat?',
        langCode,
      );

  /// Standardized prompt for particle meaning questions.
  static String particleMeaningQuestion([String? langCode]) => tr(
        'What does this particle mean?',
        'Apa arti dari partikel ini?',
        langCode,
      );

  /// Placeholder for the single-choice answer slot in word meaning quizzes.
  static String answerSlotPlaceholder([String? langCode]) => tr(
        'Tap an option below to answer',
        'Ketuk pilihan di bawah untuk mengisi',
        langCode,
      );

  static String checkAnswer([String? langCode]) => tr(
        'CHECK ANSWER',
        'CEK JAWABAN',
        langCode,
      );

  static String continueLabel([String? langCode]) => tr(
        'CONTINUE',
        'LANJUTKAN',
        langCode,
      );

  static String finishLabel([String? langCode]) => tr(
        'FINISH',
        'SELESAI',
        langCode,
      );

  static String excellentLabel([String? langCode]) => tr(
        'Excellent!',
        'Luar Biasa!',
        langCode,
      );

  static String correctAnswerLabel([String? langCode]) => tr(
        'Correct Answer:',
        'Jawaban yang Benar:',
        langCode,
      );

  // ==========================================
  // 🛡️ EXERCISE DIALOG & ACCESSIBILITY STRINGS
  // ==========================================

  static String outOfHearts([String? langCode]) => tr(
        'Out of Hearts!',
        'Nyawa Habis!',
        langCode,
      );

  static String timesUp([String? langCode]) => tr(
        "Time's Up!",
        'Waktu Habis!',
        langCode,
      );

  static String holdOn([String? langCode]) => tr(
        'Hold on!',
        'Tunggu Dulu!',
        langCode,
      );

  static String exitConfirmMessage([String? langCode]) => tr(
        'Are you sure you want to exit? Your progress in this session will be lost!',
        'Yakin ingin keluar? Progres dan jawaban benarmu di sesi ini akan hangus loh!',
        langCode,
      );

  static String cancelLabel([String? langCode]) => tr(
        'CANCEL',
        'BATAL',
        langCode,
      );

  static String exitLabel([String? langCode]) => tr(
        'EXIT',
        'KELUAR',
        langCode,
      );

  static String failureIsNormal([String? langCode]) => tr(
        'Failure is normal!',
        'Gagal Itu Wajar!',
        langCode,
      );

  static String timesUpMessage([String? langCode]) => tr(
        'Your exam time has run out! Restore your hearts and try to finish faster.',
        'Waktu ujianmu telah habis! Ayo pulihkan nyawamu lalu coba selesaikan lebih cepat.',
        langCode,
      );

  static String outOfHeartsMessage([String? langCode]) => tr(
        "Don't give up! Every mistake is a step towards success. Come on, restore your lives and try again!",
        'Jangan menyerah! Setiap kesalahan adalah langkah menuju kesuksesan. Yuk, pulihkan nyawa dan coba lagi!',
        langCode,
      );

  static String needsXpForHeart([String? langCode]) => tr(
        'Needs 150 XP for 1 Heart',
        'Butuh 150 XP untuk 1 Nyawa',
        langCode,
      );

  static String buyHeartLabel([String? langCode]) => tr(
        'BUY HEART (150 XP)',
        'BELI NYAWA (150 XP)',
        langCode,
      );

  static String notEnoughXp([String? langCode]) => tr(
        'Not enough XP!',
        'XP tidak cukup!',
        langCode,
      );

  static String backToMenuLabel([String? langCode]) => tr(
        'BACK TO MENU',
        'KEMBALI KE MENU',
        langCode,
      );

  static String unitTestPassed([String? langCode]) => tr(
        '🏆 Unit Test Passed!',
        '🏆 Unit Test Lulus!',
        langCode,
      );

  static String exerciseFinished([String? langCode]) => tr(
        '🎉 Exercise Finished!',
        '🎉 Latihan Selesai!',
        langCode,
      );

  static String scoreLabel([String? langCode]) => tr(
        'Score',
        'Skor',
        langCode,
      );

  static String exitExerciseSemantics([String? langCode]) => tr(
        'Exit exercise',
        'Keluar latihan',
        langCode,
      );

  static String quizProgressSemantics([String? langCode]) => tr(
        'Quiz progress',
        'Progres kuis',
        langCode,
      );

  static String playAudioSemantics([String? langCode]) => tr(
        'Play pronunciation audio',
        'Putar audio pelafalan',
        langCode,
      );
}
