class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars) {
    // ==========================================
    // 🗂️ LOGIKA ROUTING SOAL (BERDASARKAN ID LEVEL & BINTANG)
    // ==========================================

    // ================= UNIT 1 =================
    if (unit == 1) {
      if (difficulty == 'hiragana_1') {
        switch (currentStars) { case 0: return _h1Star1; case 1: return _h1Star2; case 2: return _h1Star3; default: return _h1Star1; }
      }
      if (difficulty == 'hiragana_2') {
        switch (currentStars) { case 0: return _h2Star1; case 1: return _h2Star2; case 2: return _h2Star3; default: return _h2Star1; }
      }
      if (difficulty == 'hiragana_3') {
        switch (currentStars) { case 0: return _h3Star1; case 1: return _h3Star2; case 2: return _h3Star3; default: return _h3Star1; }
      }
      if (difficulty == 'hiragana_4') {
        switch (currentStars) { case 0: return _h4Star1; case 1: return _h4Star2; case 2: return _h4Star3; default: return _h4Star1; }
      }
      if (difficulty == 'greetings') {
        switch (currentStars) { case 0: return _greetStar1; case 1: return _greetStar2; case 2: return _greetStar3; default: return _greetStar1; }
      }
      if (difficulty == 'numbers') {
        switch (currentStars) { case 0: return _numStar1; case 1: return _numStar2; case 2: return _numStar3; default: return _numStar1; }
      }
      if (difficulty == 'verbs') {
        switch (currentStars) { case 0: return _verbStar1; case 1: return _verbStar2; case 2: return _verbStar3; default: return _verbStar1; }
      }
      if (difficulty == 'test') return _u1UnitTest;
    }

    // ================= UNIT 2 (KATAKANA) =================
    if (unit == 2) {
      if (difficulty == 'katakana_1') {
        switch (currentStars) { case 0: return _k1Star1; case 1: return _k1Star2; case 2: return _k1Star3; default: return _k1Star1; }
      }
      if (difficulty == 'katakana_2') {
        switch (currentStars) { case 0: return _k2Star1; case 1: return _k2Star2; case 2: return _k2Star3; default: return _k2Star1; }
      }
      if (difficulty == 'katakana_3') {
        switch (currentStars) { case 0: return _k3Star1; case 1: return _k3Star2; case 2: return _k3Star3; default: return _k3Star1; }
      }
      if (difficulty == 'katakana_4') {
        switch (currentStars) { case 0: return _k4Star1; case 1: return _k4Star2; case 2: return _k4Star3; default: return _k4Star1; }
      }
      if (difficulty == 'katakana_words') {
        switch (currentStars) { case 0: return _kataWordStar1; case 1: return _kataWordStar2; case 2: return _kataWordStar3; default: return _kataWordStar1; }
      }
      if (difficulty == 'loanwords') {
        switch (currentStars) { case 0: return _loanStar1; case 1: return _loanStar2; case 2: return _loanStar3; default: return _loanStar1; }
      }
      if (difficulty == 'test') return _u2UnitTest;
    }

    return _h1Star1; // Fallback
  }

  // =========================================================================
  // 📚 UNIT 1: HIRAGANA (Data Tetap Sama Seperti Sebelumnya)
  // =========================================================================
  static final List<Map<String, dynamic>> _h1Star1 = [
    { 'type': 'multiple_choice', 'question': 'Pilihlah romaji yang tepat:', 'japanese': 'あ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'a', 'romaji': 'a'}, {'code': 'B', 'text': 'i', 'romaji': 'i'}, {'code': 'C', 'text': 'u', 'romaji': 'u'}, {'code': 'D', 'text': 'e', 'romaji': 'e'}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'い', 'answer': 'i' },
  ];
  static final List<Map<String, dynamic>> _h1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilihlah romaji yang tepat:', 'japanese': 'か', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'sa', 'romaji': 'sa'}, {'code': 'B', 'text': 'ka', 'romaji': 'ka'}, {'code': 'C', 'text': 'ta', 'romaji': 'ta'}, {'code': 'D', 'text': 'na', 'romaji': 'na'}] },
  ];
  static final List<Map<String, dynamic>> _h1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pengecualian! Karakter ini dibaca...', 'japanese': 'し', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'si', 'romaji': 'si'}, {'code': 'B', 'text': 'su', 'romaji': 'su'}, {'code': 'C', 'text': 'shi', 'romaji': 'shi'}, {'code': 'D', 'text': 'se', 'romaji': 'se'}] },
  ];
  static final List<Map<String, dynamic>> _h2Star1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari pengecualian ini:', 'japanese': 'つ', 'answer': 'tsu' }, ];
  static final List<Map<String, dynamic>> _h2Star2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'に', 'answer': 'ni' }, ];
  static final List<Map<String, dynamic>> _h2Star3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'は', 'answer': 'ha' }, ];
  static final List<Map<String, dynamic>> _h3Star1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'め', 'answer': 'me' }, ];
  static final List<Map<String, dynamic>> _h3Star2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'る', 'answer': 'ru' }, ];
  static final List<Map<String, dynamic>> _h3Star3 = [ { 'type': 'essay', 'question': 'Satu-satunya huruf konsonan mati dalam Jepang adalah:', 'japanese': 'ん', 'answer': 'n' }, ];
  static final List<Map<String, dynamic>> _h4Star1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari kata "Mizu" (Air):', 'japanese': 'みず', 'answer': 'mizu' }, ];
  static final List<Map<String, dynamic>> _h4Star2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'ぴ', 'answer': 'pi' }, ];
  static final List<Map<String, dynamic>> _h4Star3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji dari karakter berikut:', 'japanese': 'きゃ', 'answer': 'kya' }, ];

  static final List<Map<String, dynamic>> _greetStar1 = [ { 'type': 'essay', 'question': 'Ketik romaji untuk "Selamat Pagi":', 'japanese': 'おはよう', 'answer': 'ohayou' } ];
  static final List<Map<String, dynamic>> _greetStar2 = [ { 'type': 'essay', 'question': 'Ketik romaji untuk "Selamat Siang":', 'japanese': 'こんにちは', 'answer': 'konnichiwa' } ];
  static final List<Map<String, dynamic>> _greetStar3 = [ { 'type': 'essay', 'question': 'Ketik romaji untuk "Sampai Jumpa":', 'japanese': 'さようなら', 'answer': 'sayounara' } ];

  static final List<Map<String, dynamic>> _numStar1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk angka 7:', 'japanese': 'なな', 'answer': 'nana' } ];
  static final List<Map<String, dynamic>> _numStar2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk 100:', 'japanese': 'ひゃく', 'answer': 'hyaku' } ];
  static final List<Map<String, dynamic>> _numStar3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jam 3 Lewat Setengah:', 'japanese': 'さんじはん', 'answer': 'sanjihan' } ];

  static final List<Map<String, dynamic>> _verbStar1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Makan":', 'japanese': 'たべる', 'answer': 'taberu' } ];
  static final List<Map<String, dynamic>> _verbStar2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Minum":', 'japanese': 'のむ', 'answer': 'nomu' } ];
  static final List<Map<String, dynamic>> _verbStar3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Melihat":', 'japanese': 'みる', 'answer': 'miru' } ];

  // =========================================================================
  // 🔥 UNIT TESTS 1 (30 SOAL CAMPURAN - BERPACU DENGAN WAKTU 20 MENIT)
  // =========================================================================
  static final List<Map<String, dynamic>> _u1UnitTest = [
    // --- Bagian 1: Hiragana Acak ---
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'む', 'answer': 'mu' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'け', 'answer': 'ke' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'ち', 'answer': 'chi' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'ぬ', 'answer': 'nu' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'ふ', 'answer': 'fu' },
    { 'type': 'multiple_choice', 'question': 'Karakter "Ya" yang benar adalah...', 'japanese': 'や', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'yu', 'romaji': ''}, {'code': 'C', 'text': 'yo', 'romaji': ''}, {'code': 'D', 'text': 'wa', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'が', 'answer': 'ga' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'ぽ', 'answer': 'po' },
    { 'type': 'essay', 'question': 'Tuliskan romaji karakter ini:', 'japanese': 'じゃ', 'answer': 'ja' },

    // --- Bagian 2: Kosakata & Salam ---
    { 'type': 'essay', 'question': 'Ubah ke romaji: Sepatu', 'japanese': 'くつ', 'answer': 'kutsu' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Guru', 'japanese': 'せんせい', 'answer': 'sensei' },
    { 'type': 'multiple_choice', 'question': 'Pilih ucapan "Selamat Malam" yang tepat:', 'japanese': 'こんばんは', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Konnichiwa', 'romaji': ''}, {'code': 'B', 'text': 'Ohayou', 'romaji': ''}, {'code': 'C', 'text': 'Konbanwa', 'romaji': ''}, {'code': 'D', 'text': 'Sayounara', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Tas', 'japanese': 'かばん', 'answer': 'kaban' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Telepon', 'japanese': 'でんわ', 'answer': 'denwa' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Selamat Tidur', 'japanese': 'おやすみなさい', 'answer': 'oyasuminasai' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Terima Kasih', 'japanese': 'ありがとう', 'answer': 'arigatou' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Maaf', 'japanese': 'ごめんなさい', 'answer': 'gomennasai' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Rumah', 'japanese': 'いえ', 'answer': 'ie' },
    { 'type': 'essay', 'question': 'Ubah ke romaji: Air', 'japanese': 'みず', 'answer': 'mizu' },

    // --- Bagian 3: Angka & Waktu ---
    { 'type': 'essay', 'question': 'Tuliskan romaji angka 100:', 'japanese': 'ひゃく', 'answer': 'hyaku' },
    { 'type': 'essay', 'question': 'Tuliskan romaji angka 7:', 'japanese': 'なな', 'answer': 'nana' },
    { 'type': 'multiple_choice', 'question': 'Jam 4 dibaca...', 'japanese': 'よじ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Yon ji', 'romaji': ''}, {'code': 'B', 'text': 'Yo ji', 'romaji': ''}, {'code': 'C', 'text': 'Shi ji', 'romaji': ''}, {'code': 'D', 'text': 'Go ji', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji Jam 9 (Pengecualian):', 'japanese': 'くじ', 'answer': 'kuji' },
    { 'type': 'essay', 'question': 'Tuliskan romaji angka 10.000:', 'japanese': 'いちまん', 'answer': 'ichiman' },

    // --- Bagian 4: Kata Kerja ---
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Makan":', 'japanese': 'たべる', 'answer': 'taberu' },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Minum":', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'multiple_choice', 'question': 'Kata kerja "Melihat" adalah...', 'japanese': 'みる', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Kiku', 'romaji': ''}, {'code': 'B', 'text': 'Hanasu', 'romaji': ''}, {'code': 'C', 'text': 'Kaku', 'romaji': ''}, {'code': 'D', 'text': 'Miru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Mendengar":', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Tidur":', 'japanese': 'ねる', 'answer': 'neru' },
  ];

  // =========================================================================
  // 🔠 UNIT 2: KATAKANA BASICS 1-4
  // =========================================================================

  // Katakana 1: A, K, S
  static final List<Map<String, dynamic>> _k1Star1 = [
    { 'type': 'multiple_choice', 'question': 'Pilihlah romaji yang tepat:', 'japanese': 'ア', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'i', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'e', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'イ', 'answer': 'i' },
  ];
  static final List<Map<String, dynamic>> _k1Star2 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'カ', 'answer': 'ka' },
  ];
  static final List<Map<String, dynamic>> _k1Star3 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'サ', 'answer': 'sa' },
  ];

  // Katakana 2: T, N, H
  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'question': 'Mirip dengan tanda senyum, karakter ini dibaca:', 'japanese': 'ツ', 'answer': 'tsu' },
  ];
  static final List<Map<String, dynamic>> _k2Star2 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'ニ', 'answer': 'ni' },
  ];
  static final List<Map<String, dynamic>> _k2Star3 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'ハ', 'answer': 'ha' },
  ];

  // Katakana 3: M, Y, R, W
  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'マ', 'answer': 'ma' },
  ];
  static final List<Map<String, dynamic>> _k3Star2 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji dari Katakana berikut:', 'japanese': 'ヤ', 'answer': 'ya' },
  ];
  static final List<Map<String, dynamic>> _k3Star3 = [
    { 'type': 'essay', 'question': 'Mirip huruf V, Katakana ini dibaca:', 'japanese': 'ワ', 'answer': 'wa' },
    { 'type': 'essay', 'question': 'Konsonan tunggal dalam Katakana:', 'japanese': 'ン', 'answer': 'n' },
  ];

  // Katakana 4: Dakuten & Handakuten
  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'question': 'Katakana "Ga" ditulis dengan tanda kutip:', 'japanese': 'ガ', 'answer': 'ga' },
  ];
  static final List<Map<String, dynamic>> _k4Star2 = [
    { 'type': 'essay', 'question': 'Katakana "Pa" ditulis dengan bulatan:', 'japanese': 'パ', 'answer': 'pa' },
  ];
  static final List<Map<String, dynamic>> _k4Star3 = [
    { 'type': 'essay', 'question': 'Tuliskan romaji gabungan berikut:', 'japanese': 'キャ', 'answer': 'kya' },
  ];

  // =========================================================================
  // 🎌 KATAKANA WORDS & LOANWORDS
  // =========================================================================
  static final List<Map<String, dynamic>> _kataWordStar1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Kamera":', 'japanese': 'カメラ', 'answer': 'kamera' }, ];
  static final List<Map<String, dynamic>> _kataWordStar2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "TV":', 'japanese': 'テレビ', 'answer': 'terebi' }, ];
  static final List<Map<String, dynamic>> _kataWordStar3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Hotel":', 'japanese': 'ホテル', 'answer': 'hoteru' }, ];

  static final List<Map<String, dynamic>> _loanStar1 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Coffee":', 'japanese': 'コーヒー', 'answer': 'koohii' }, ];
  static final List<Map<String, dynamic>> _loanStar2 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Computer":', 'japanese': 'コンピューター', 'answer': 'konpyuutaa' }, ];
  static final List<Map<String, dynamic>> _loanStar3 = [ { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Smartphone":', 'japanese': 'スマホ', 'answer': 'sumaho' }, ];

  static final List<Map<String, dynamic>> _u2UnitTest = [
    { 'type': 'essay', 'question': 'Tuliskan romaji Katakana untuk A:', 'japanese': 'ア', 'answer': 'a' },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Kopi:', 'japanese': 'コーヒー', 'answer': 'koohii' },
  ];
}