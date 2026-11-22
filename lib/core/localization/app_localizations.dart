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

  // ==========================================
  // 🎓 JLPT N5 SIMULATION SCREEN STRINGS
  // ==========================================

  static String simOfficialStandardBadge([String? langCode]) => tr(
        'OFFICIAL JLPT N5 STANDARD',
        'OFFICIAL JLPT N5 STANDARD',
        langCode,
      );

  static String simHistoryLabel([String? langCode]) => tr(
        'History',
        'Riwayat',
        langCode,
      );

  static String simHistorySemantics([String? langCode]) => tr(
        'Exam history',
        'Riwayat ujian',
        langCode,
      );

  static String simTitle([String? langCode]) => tr(
        'JLPT N5 Mock Exam',
        'Simulasi Ujian JLPT N5',
        langCode,
      );

  static String simHeroDescription([String? langCode]) => tr(
        'Measure your Japanese in real exam conditions.',
        'Ukur kemampuan bahasa Jepangmu dalam kondisi ujian nyata.',
        langCode,
      );

  static String simBestScoreTitle([String? langCode]) => tr(
        'Your Best Score',
        'Skor Terbaikmu',
        langCode,
      );

  static String simPassTargetBadge([String? langCode]) => tr(
        'Pass Target: 80',
        'Target Lulus: 80',
        langCode,
      );

  static String simPassedBadge([String? langCode]) => tr(
        'PASSED N5',
        'LULUS N5',
        langCode,
      );

  static String simBestScoreSemantics([String? langCode]) => tr(
        'Best simulation score progress',
        'Progres skor terbaik simulasi',
        langCode,
      );

  static String simExamRoomUnlockedTitle([String? langCode]) => tr(
        'Exam Room Unlocked',
        'Ruang Ujian Terbuka',
        langCode,
      );

  static String simUnlockSimulationTitle([String? langCode]) => tr(
        'Unlock JLPT N5 Simulation',
        'Buka Simulasi JLPT N5',
        langCode,
      );

  static String simUnlockRequirementInfo([String? langCode]) => tr(
        'Collect 1,500 XP from daily lessons to unlock.',
        'Kumpulkan 1.500 XP dari latihan harian untuk membuka.',
        langCode,
      );

  static String simXpReadinessLabel([String? langCode]) => tr(
        'XP Readiness',
        'Kesiapan XP',
        langCode,
      );

  static String simUnlockProgressSemantics([String? langCode]) => tr(
        'XP unlock progress',
        'Progres XP pembuka',
        langCode,
      );

  static String simStartButton([String? langCode]) => tr(
        'START SIMULATION',
        'MULAI SIMULASI',
        langCode,
      );

  static String simUnlockButton([String? langCode]) => tr(
        'UNLOCK SIMULATION',
        'BUKA SIMULASI',
        langCode,
      );

  static String simMinXpWarning([String? langCode]) => tr(
        'You need at least 100 XP to start a simulation session.',
        'Kamu membutuhkan minimal 100 XP untuk memulai sesi simulasi.',
        langCode,
      );

  static String simNotEnoughXpToUnlock([String? langCode]) => tr(
        'Not enough XP to unlock the simulation.',
        'XP tidak cukup untuk membuka simulasi.',
        langCode,
      );

  static String simNotEnoughXpToStart([String? langCode]) => tr(
        'Not enough XP to start the exam.',
        'XP tidak cukup untuk memulai ujian.',
        langCode,
      );

  static String simUnlockedSuccessMessage([String? langCode]) => tr(
        'Simulation unlocked! Now you can start the exam for 100 XP.',
        'Simulasi terbuka! Sekarang kamu bisa memulai ujian seharga 100 XP.',
        langCode,
      );

  static String simErrorMessage(Object error, [String? langCode]) => tr(
        'Error: $error',
        'Kesalahan: $error',
        langCode,
      );

  static String simBriefingBadge([String? langCode]) => tr(
        'OFFICIAL EXAM BRIEFING',
        'BRIEFING RESMI UJIAN',
        langCode,
      );

  static String simReadyToStartTitle([String? langCode]) => tr(
        'Ready to Start?',
        'Siap untuk Mulai?',
        langCode,
      );

  static String simReadyToStartSubtitle([String? langCode]) => tr(
        'Check the rules before you start.',
        'Cek aturan sebelum mulai.',
        langCode,
      );

  static String simRuleDurationTitle([String? langCode]) => tr(
        '50 Minutes Continuous',
        '50 Menit Nonstop',
        langCode,
      );

  static String simRuleDurationSubtitle([String? langCode]) => tr(
        'The timer never pauses.',
        'Timer berjalan tanpa jeda.',
        langCode,
      );

  static String simRulePassScoreTitle([String? langCode]) => tr(
        'Pass Score: 80 / 180',
        'Batas Lulus: 80 / 180',
        langCode,
      );

  static String simRulePassScoreSubtitle([String? langCode]) => tr(
        'Language 60 + Reading 120.',
        'Bahasa 60 + Membaca 120.',
        langCode,
      );

  static String simRuleTicketTitle([String? langCode]) => tr(
        'Entry Ticket: 100 XP',
        'Tiket Masuk: 100 XP',
        langCode,
      );

  static String simRuleTicketSubtitle([String? langCode]) => tr(
        'Deducted when the exam starts.',
        'Dipotong saat ujian dimulai.',
        langCode,
      );

  static String simStartExamAction([String? langCode]) => tr(
        'START',
        'MULAI',
        langCode,
      );

  static String simModulesSectionTitle([String? langCode]) => tr(
        'Test Modules & Structure',
        'Modul & Struktur Ujian',
        langCode,
      );

  static String simModule1Title([String? langCode]) => tr(
        'Language Knowledge',
        'Pengetahuan Bahasa',
        langCode,
      );

  static String simModule1Points([String? langCode]) => tr(
        '60 Points',
        '60 Poin',
        langCode,
      );

  static String simModuleDuration25([String? langCode]) => tr(
        '25 Mins',
        '25 Menit',
        langCode,
      );

  static String simModule1Description([String? langCode]) => tr(
        'Tests Kanji readings, vocabulary usage in context, sentence grammar particles, and word order.',
        'Menguji cara baca Kanji, penggunaan kosakata sesuai konteks, partikel tata bahasa, dan susunan kalimat.',
        langCode,
      );

  static String simModule2Title([String? langCode]) => tr(
        'Reading Comprehension',
        'Pemahaman Membaca',
        langCode,
      );

  static String simModule2Points([String? langCode]) => tr(
        '120 Points',
        '120 Poin',
        langCode,
      );

  static String simModule2Description([String? langCode]) => tr(
        'Tests comprehension of short passages, daily notices, emails, and finding key information.',
        'Menguji pemahaman wacana pendek, pengumuman harian, pesan email, dan pencarian informasi utama.',
        langCode,
      );

  static String simGradingSystemTitle([String? langCode]) => tr(
        'Grading System',
        'Sistem Penilaian',
        langCode,
      );

  static String simMaxScoreLabel([String? langCode]) => tr(
        'MAX SCORE',
        'SKOR MAKS',
        langCode,
      );

  static String simPassingGradeLabel([String? langCode]) => tr(
        'PASSING GRADE',
        'BATAS LULUS',
        langCode,
      );

  static String simPassCriteriaNote([String? langCode]) => tr(
        'Pass criteria: Total score ≥ 80/180 AND non-zero score in both Language and Reading sections.',
        'Kriteria lulus: Skor total ≥ 80/180 DAN tidak boleh mendapat nilai 0 pada sesi Bahasa maupun Membaca.',
        langCode,
      );

  static String simStrictRulesTitle([String? langCode]) => tr(
        'Strict Exam Conditions',
        'Aturan Ujian Resmi',
        langCode,
      );

  static String simStrictRulesDescription([String? langCode]) => tr(
        'Continuous 50-minute timer. No pausing. Exiting early forfeits current attempt.',
        'Timer 50 menit berjalan terus tanpa jeda. Keluar sebelum selesai membatalkan sesi ujian.',
        langCode,
      );

  // ==========================================
  // 📊 SIMULATION HISTORY SCREEN STRINGS
  // ==========================================

  static String simHistoryAppBarTitle([String? langCode]) => tr(
        'EXAM HISTORY',
        'RIWAYAT UJIAN',
        langCode,
      );

  static String simHistoryBackSemantics([String? langCode]) => tr(
        'Back to simulation',
        'Kembali ke simulasi',
        langCode,
      );

  static String simHistorySummaryHeader([String? langCode]) => tr(
        'PERFORMANCE SUMMARY',
        'RINGKASAN PERFORMA',
        langCode,
      );

  static String simHistoryBestScoreLabel([String? langCode]) => tr(
        'BEST SCORE',
        'SKOR TERBAIK',
        langCode,
      );

  static String simHistoryTargetMarkerLabel([String? langCode]) => tr(
        'Pass Target 80',
        'Target Lulus 80',
        langCode,
      );

  static String simHistoryGapToPass(int points, [String? langCode]) => tr(
        'Need $points more pts',
        'Butuh $points poin lagi',
        langCode,
      );

  static String simHistoryTargetReached([String? langCode]) => tr(
        'Target 80 Reached',
        'Target 80 Tercapai',
        langCode,
      );

  static String simHistoryStatDone([String? langCode]) => tr(
        'Done',
        'Selesai',
        langCode,
      );

  static String simHistoryLevelMastery([String? langCode]) => tr(
        'Mastery',
        'Sangat Mahir',
        langCode,
      );

  static String simHistoryLevelReady([String? langCode]) => tr(
        'Exam Ready',
        'Siap Ujian',
        langCode,
      );

  static String simHistoryLevelPassed([String? langCode]) => tr(
        'Pass Standard',
        'Lulus Standar',
        langCode,
      );

  static String simHistoryLevelAlmost([String? langCode]) => tr(
        'Almost There',
        'Hampir Lulus',
        langCode,
      );

  static String simHistoryLevelPractice([String? langCode]) => tr(
        'Needs Practice',
        'Perlu Latihan',
        langCode,
      );

  static String simHistoryMotivationPassed([String? langCode]) => tr(
        'Great job, you passed! Keep sharpening your skills.',
        'Hebat, kamu sudah lulus! Terus pertahankan performamu.',
        langCode,
      );

  static String simHistoryMotivationAlmost(int gap, [String? langCode]) => tr(
        'Almost there! Just $gap pts away from passing 80.',
        'Selangkah lagi! Butuh $gap poin lagi menuju target 80.',
        langCode,
      );

  static String simHistoryMotivationPractice(int gap, [String? langCode]) => tr(
        'Keep going! Your target is 80 pts ($gap pts to go).',
        'Tetap semangat! Targetmu 80 poin (butuh $gap poin lagi).',
        langCode,
      );

  static String simHistoryStartSimulationCta([String? langCode]) => tr(
        'START SIMULATION',
        'MULAI SIMULASI',
        langCode,
      );

  static String simHistoryEmptyTitle([String? langCode]) => tr(
        'No Exam History Yet',
        'Belum Ada Riwayat Ujian',
        langCode,
      );

  static String simHistoryEmptySubtitle([String? langCode]) => tr(
        'Take a JLPT N5 mock exam to track your score progress here.',
        'Mulai simulasi JLPT N5 untuk memantau perkembangan skormu di sini.',
        langCode,
      );

  static String simHistoryGroupToday([String? langCode]) => tr(
        'Today',
        'Hari Ini',
        langCode,
      );

  static String simHistoryGroupYesterday([String? langCode]) => tr(
        'Yesterday',
        'Kemarin',
        langCode,
      );

  static String simHistoryGroupThisWeek([String? langCode]) => tr(
        'This Week',
        'Minggu Ini',
        langCode,
      );

  static String simHistoryGroupEarlier([String? langCode]) => tr(
        'Earlier',
        'Sebelumnya',
        langCode,
      );

  static String simHistoryStatusPassed([String? langCode]) => tr(
        'PASSED',
        'LULUS',
        langCode,
      );

  static String simHistoryStatusNotPassed([String? langCode]) => tr(
        'NOT PASSED',
        'BELUM LULUS',
        langCode,
      );

  static String simHistoryBestSessionBadge([String? langCode]) => tr(
        'Best',
        'Terbaik',
        langCode,
      );

  static String simHistoryLangBarLabel(int points, [String? langCode]) => tr(
        'Lang $points/60',
        'Bhs $points/60',
        langCode,
      );

  static String simHistoryReadBarLabel(int points, [String? langCode]) => tr(
        'Read $points/120',
        'Baca $points/120',
        langCode,
      );

  static String simHistoryTileSemantics(
    int score,
    String status,
    String dateText, [
    String? langCode,
  ]) =>
      tr(
        'Exam result: $score out of 180, $status, on $dateText. Tap for details.',
        'Hasil ujian: $score dari 180, $status, pada $dateText. Ketuk untuk detail.',
        langCode,
      );

  // ==========================================
  // 🏅 SIMULATION RESULT / EXAM REPORT STRINGS
  // ==========================================

  static String simResultAppBarTitle([String? langCode]) => tr(
        'EXAM REPORT',
        'RAPOR HASIL UJIAN',
        langCode,
      );

  static String simResultAppBarSubtitle([String? langCode]) => tr(
        'JLPT N5 SIMULATION',
        'SIMULASI JLPT N5',
        langCode,
      );

  static String simResultCloseSemantics([String? langCode]) => tr(
        'Close exam report',
        'Tutup rapor ujian',
        langCode,
      );

  static String simResultStatusPassedBadge([String? langCode]) => tr(
        'Passed • 合格',
        'Lulus • 合格',
        langCode,
      );

  static String simResultStatusNotPassedBadge([String? langCode]) => tr(
        'Not Passed • 不合格',
        'Belum Lulus • 不合格',
        langCode,
      );

  static String simResultGradeBadge(String grade, [String? langCode]) => tr(
        'Grade $grade',
        'Predikat $grade',
        langCode,
      );

  static String simResultGapToPass(int points, [String? langCode]) => tr(
        '$points points to pass',
        'Butuh $points poin lagi untuk lulus',
        langCode,
      );

  static String simResultPassedAboveTarget(int surplus, [String? langCode]) =>
      tr(
        'Passed target by +$surplus pts',
        'Melampaui batas lulus (+$surplus poin)',
        langCode,
      );

  static String simResultPassMarkPill(
    int passTarget,
    int maxScore, [
    String? langCode,
  ]) =>
      tr(
        'Pass mark: $passTarget/$maxScore',
        'Batas lulus: $passTarget/$maxScore',
        langCode,
      );

  static String simResultMotivationTitlePassed([String? langCode]) => tr(
        'Omedetou Gozaimasu!',
        'Omedetou Gozaimasu!',
        langCode,
      );

  static String simResultMotivationTitleNotPassed([String? langCode]) => tr(
        'Ganbatte Kudasai!',
        'Ganbatte Kudasai!',
        langCode,
      );

  static String simResultMotivationBodyPassed([String? langCode]) => tr(
        'Great milestone! Review your answers to master every JLPT N5 topic.',
        'Pencapaian hebat! Tinjau jawabanmu untuk menguasai seluruh materi N5.',
        langCode,
      );

  static String simResultMotivationBodyNotPassed([String? langCode]) => tr(
        'You are getting closer! Review your mistakes and try again.',
        'Semakin dekat ke target! Tinjau pembahasan soal dan coba lagi.',
        langCode,
      );

  static String simResultRingSemantics(
    int score,
    int maxScore,
    String targetStatus, [
    String? langCode,
  ]) =>
      tr(
        'Score $score out of $maxScore, $targetStatus',
        'Skor $score dari $maxScore, $targetStatus',
        langCode,
      );

  static String simResultBreakdownTitle([String? langCode]) => tr(
        'Sectional Score Breakdown',
        'Rincian Skor Per Bagian',
        langCode,
      );

  static String simResultTagStrongest([String? langCode]) => tr(
        'Strongest',
        'Terkuat',
        langCode,
      );

  static String simResultTagNeedsPractice([String? langCode]) => tr(
        'Needs practice',
        'Perlu latihan',
        langCode,
      );

  static String simResultTagBalanced([String? langCode]) => tr(
        'On track',
        'Stabil',
        langCode,
      );

  static String simResultCorrectCount(
    int correct,
    int total, [
    String? langCode,
  ]) =>
      tr(
        '$correct/$total correct',
        '$correct/$total benar',
        langCode,
      );

  static String simResultAccuracyLabel([String? langCode]) => tr(
        'Accuracy',
        'Akurasi',
        langCode,
      );

  static String simResultDurationLabel([String? langCode]) => tr(
        'Time',
        'Durasi',
        langCode,
      );

  static String simResultDurationSubtitle([String? langCode]) => tr(
        'Of 50m limit',
        'Dari batas 50m',
        langCode,
      );

  static String simResultReviewAnswersCta([String? langCode]) => tr(
        'REVIEW ANSWERS',
        'TINJAU JAWABAN',
        langCode,
      );

  // ===========================================================================
  // SIMULATION EXAM & REVIEW SCREENS
  // ===========================================================================

  static String simExamSectionLanguage([String? langCode]) => tr(
        'LANGUAGE KNOWLEDGE',
        'PENGETAHUAN BAHASA',
        langCode,
      );

  static String simExamSectionReading([String? langCode]) => tr(
        'READING',
        'MEMBACA',
        langCode,
      );

  static String simTestAppBarTitle([String? langCode]) => tr(
        'EXAM',
        'SIMULASI UJIAN',
        langCode,
      );

  static String simTestExitSemantics([String? langCode]) => tr(
        'Exit exam',
        'Keluar ujian',
        langCode,
      );

  static String simTestTimerSemantics(
    String formattedTime, [
    String? langCode,
  ]) =>
      tr(
        'Remaining time $formattedTime',
        'Sisa waktu $formattedTime',
        langCode,
      );

  static String simTestProgressSemantics([String? langCode]) => tr(
        'Exam progress',
        'Progres ujian',
        langCode,
      );

  static String simTestChipActiveSemantics(int number, [String? langCode]) =>
      tr(
        'Question $number, current',
        'Soal $number, aktif',
        langCode,
      );

  static String simTestChipAnsweredSemantics(int number, [String? langCode]) =>
      tr(
        'Question $number, answered',
        'Soal $number, sudah dijawab',
        langCode,
      );

  static String simTestChipUnansweredSemantics(
    int number, [
    String? langCode,
  ]) =>
      tr(
        'Question $number, unanswered',
        'Soal $number, belum dijawab',
        langCode,
      );

  static String simTestOptionSemantics(
    String letter,
    String text,
    bool selected, [
    String? langCode,
  ]) =>
      tr(
        'Option $letter: $text${selected ? ', selected' : ''}',
        'Pilihan $letter: $text${selected ? ', terpilih' : ''}',
        langCode,
      );

  static String simTestNextCta([String? langCode]) => tr(
        'NEXT',
        'LANJUT',
        langCode,
      );

  static String simTestFinishCta([String? langCode]) => tr(
        'FINISH',
        'SELESAI',
        langCode,
      );

  static String simTestFinishDialogTitle([String? langCode]) => tr(
        'Finish Exam?',
        'Selesaikan Ujian?',
        langCode,
      );

  static String simTestFinishDialogBodyAllAnswered([String? langCode]) => tr(
        'All questions have been answered. Submit your answers and view your exam report?',
        'Semua soal sudah terjawab. Kirim jawaban dan lihat rapor hasil ujianmu?',
        langCode,
      );

  static String simTestFinishDialogBodyUnanswered(
    int count, [
    String? langCode,
  ]) =>
      tr(
        'There are still $count unanswered questions. Submit your answers now?',
        'Masih ada $count soal yang belum terjawab. Kirim jawaban sekarang?',
        langCode,
      );

  static String simTestExitDialogTitle([String? langCode]) => tr(
        'Exit Exam?',
        'Keluar dari Ujian?',
        langCode,
      );

  static String simTestExitDialogBody([String? langCode]) => tr(
        'Are you sure you want to exit? All simulation progress in this session will be lost.',
        'Yakin ingin keluar? Semua progres simulasi di sesi ini akan hilang.',
        langCode,
      );

  static String simTestCancelCta([String? langCode]) => tr(
        'CANCEL',
        'BATAL',
        langCode,
      );

  static String simTestExitCta([String? langCode]) => tr(
        'EXIT',
        'KELUAR',
        langCode,
      );

  static String simReviewAppBarTitle([String? langCode]) => tr(
        'EXAM REVIEW',
        'PEMBAHASAN UJIAN',
        langCode,
      );

  static String simReviewBackSemantics([String? langCode]) => tr(
        'Back',
        'Kembali',
        langCode,
      );

  static String simReviewFilterAll(int count, [String? langCode]) => tr(
        'All ($count)',
        'Semua ($count)',
        langCode,
      );

  static String simReviewFilterWrong(int count, [String? langCode]) => tr(
        'Wrong ($count)',
        'Salah ($count)',
        langCode,
      );

  static String simReviewFilterCorrect(int count, [String? langCode]) => tr(
        'Correct ($count)',
        'Benar ($count)',
        langCode,
      );

  static String simReviewProgressSemantics([String? langCode]) => tr(
        'Review progress',
        'Progres pembahasan',
        langCode,
      );

  static String simReviewPreviousCta([String? langCode]) => tr(
        'PREVIOUS',
        'SEBELUMNYA',
        langCode,
      );

  static String simReviewNextCta([String? langCode]) => tr(
        'NEXT',
        'SELANJUTNYA',
        langCode,
      );

  static String simReviewDoneCta([String? langCode]) => tr(
        'DONE',
        'SELESAI',
        langCode,
      );

  static String simReviewEmptyFilterTitle([String? langCode]) => tr(
        'No questions in this filter',
        'Tidak ada soal pada filter ini',
        langCode,
      );

  static String simReviewShowAllCta([String? langCode]) => tr(
        'SHOW ALL QUESTIONS',
        'TAMPILKAN SEMUA SOAL',
        langCode,
      );

  static String simReviewStatusCorrect([String? langCode]) => tr(
        'CORRECT',
        'BENAR',
        langCode,
      );

  static String simReviewStatusWrong([String? langCode]) => tr(
        'WRONG',
        'SALAH',
        langCode,
      );

  static String simReviewTagYourAnswer([String? langCode]) => tr(
        'YOUR ANSWER',
        'JAWABANMU',
        langCode,
      );

  static String simReviewTagCorrectAnswer([String? langCode]) => tr(
        'CORRECT ANSWER',
        'KUNCI JAWABAN',
        langCode,
      );

  static String simReviewTagYourChoice([String? langCode]) => tr(
        'YOUR CHOICE',
        'PILIHANMU',
        langCode,
      );

  static String simReviewExplanationHeader([String? langCode]) => tr(
        'STUDY NOTE & EXPLANATION',
        'CATATAN & PEMBAHASAN',
        langCode,
      );
}
