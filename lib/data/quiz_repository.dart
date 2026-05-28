class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars) {
    if (unit == 1) {
      if (difficulty == 'test') return _u1UnitTest;
      if (difficulty == 'hiragana_1') return _getStarSet(_h1Star1, _h1Star2, _h1Star3, currentStars);
      if (difficulty == 'hiragana_2') return _getStarSet(_h2Star1, _h2Star2, _h2Star3, currentStars);
      if (difficulty == 'hiragana_3') return _getStarSet(_h3Star1, _h3Star2, _h3Star3, currentStars);
      if (difficulty == 'hiragana_4') return _getStarSet(_h4Star1, _h4Star2, _h4Star3, currentStars);
      if (difficulty == 'greetings') return _getStarSet(_greetStar1, _greetStar1, _greetStar1, currentStars);
      if (difficulty == 'numbers') return _getStarSet(_numStar1, _numStar1, _numStar1, currentStars);
      if (difficulty == 'verbs') return _getStarSet(_verbStar1, _verbStar1, _verbStar1, currentStars);
    }
    if (unit == 2) {
      if (difficulty == 'test') return _u2UnitTest;
      if (difficulty == 'katakana_1') return _getStarSet(_k1Star1, _k1Star1, _k1Star1, currentStars);
      if (difficulty == 'katakana_2') return _getStarSet(_k2Star1, _k2Star1, _k2Star1, currentStars);
      if (difficulty == 'katakana_3') return _getStarSet(_k3Star1, _k3Star1, _k3Star1, currentStars);
      if (difficulty == 'katakana_4') return _getStarSet(_k4Star1, _k4Star1, _k4Star1, currentStars);
      if (difficulty == 'katakana_words') return _getStarSet(_kataWordStar1, _kataWordStar1, _kataWordStar1, currentStars);
      if (difficulty == 'loanwords') return _getStarSet(_loanWordStar1, _loanWordStar1, _loanWordStar1, currentStars);
    }
    if (unit == 3) {
      if (difficulty == 'test') return _u3UnitTest;
      if (difficulty == 'kanji_numbers') return _getStarSet(_knStar1, _knStar1, _knStar1, currentStars);
      if (difficulty == 'kanji_nature') return _getStarSet(_kanjiNatureStar1, _kanjiNatureStar1, _kanjiNatureStar1, currentStars);
      if (difficulty == 'kanji_people') return _getStarSet(_kanjiPeopleStar1, _kanjiPeopleStar1, _kanjiPeopleStar1, currentStars);
    }
    if (unit == 4) {
      if (difficulty == 'test') return _u4UnitTest;
      if (difficulty == 'grammar_particles') return _getStarSet(_gpStar1, _gpStar1, _gpStar1, currentStars);
      if (difficulty == 'grammar_verbs_1') return _getStarSet(_gv1Star1, _gv1Star1, _gv1Star1, currentStars);
      if (difficulty == 'grammar_verbs_2') return _getStarSet(_gv2Star1, _gv2Star1, _gv2Star1, currentStars);
      if (difficulty == 'grammar_adjectives') return _getStarSet(_adjStar1, _adjStar1, _adjStar1, currentStars);
    }
    return _h1Star1;
  }

  static List<Map<String, dynamic>> _getStarSet(List<Map<String, dynamic>> s1, List<Map<String, dynamic>> s2, List<Map<String, dynamic>> s3, int stars) {
    if (stars == 0) return s1;
    if (stars == 1) return s2;
    return s3;
  }

  // ==========================================
  // --- UNIT 1: HIRAGANA (A-O, KA-KO, SA-SO) ---
  // ==========================================

  // HIRAGANA 1 (A-O, KA-KO, SA-SO)
  static final List<Map<String, dynamic>> _h1Star1 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "A"', 'japanese': 'あ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'o', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'e', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "I"', 'japanese': 'い', 'answer': 'i' },
    { 'type': 'multiple_choice', 'question': 'Karakter "U"', 'japanese': 'う', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'i', 'romaji': ''}, {'code': 'B', 'text': 'e', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'a', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "E"', 'japanese': 'え', 'answer': 'e' },
    { 'type': 'multiple_choice', 'question': 'Karakter "O"', 'japanese': 'お', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'o', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'i', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "AO" (Biru)', 'japanese': 'あお', 'answer': 'ao' },
  ];

  static final List<Map<String, dynamic>> _h1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "KA"', 'japanese': 'か', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ka', 'romaji': ''}, {'code': 'B', 'text': 'ki', 'romaji': ''}, {'code': 'C', 'text': 'ku', 'romaji': ''}, {'code': 'D', 'text': 'ko', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "KI"', 'japanese': 'き', 'answer': 'ki' },
    { 'type': 'multiple_choice', 'question': 'Karakter "KU"', 'japanese': 'く', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ke', 'romaji': ''}, {'code': 'B', 'text': 'ko', 'romaji': ''}, {'code': 'C', 'text': 'ku', 'romaji': ''}, {'code': 'D', 'text': 'ka', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "KE"', 'japanese': 'け', 'answer': 'ke' },
    { 'type': 'multiple_choice', 'question': 'Karakter "KO"', 'japanese': 'こ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ka', 'romaji': ''}, {'code': 'B', 'text': 'ko', 'romaji': ''}, {'code': 'C', 'text': 'ki', 'romaji': ''}, {'code': 'D', 'text': 'ku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "KAKI" (Kesemek)', 'japanese': 'かき', 'answer': 'kaki' },
  ];

  static final List<Map<String, dynamic>> _h1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "SA"', 'japanese': 'さ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'sa', 'romaji': ''}, {'code': 'B', 'text': 'shi', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'so', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "SHI"', 'japanese': 'し', 'answer': 'shi' },
    { 'type': 'multiple_choice', 'question': 'Karakter "SU"', 'japanese': 'す', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'se', 'romaji': ''}, {'code': 'B', 'text': 'so', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'sa', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "SE"', 'japanese': 'せ', 'answer': 'se' },
    { 'type': 'multiple_choice', 'question': 'Karakter "SO"', 'japanese': 'そ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'sa', 'romaji': ''}, {'code': 'B', 'text': 'so', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'shi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "SUSHI"', 'japanese': 'すし', 'answer': 'sushi' },
  ];

  // HIRAGANA 2 (TA-TO, NA-NO, HA-HO)
  static final List<Map<String, dynamic>> _h2Star1 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "TA"', 'japanese': 'た', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'chi', 'romaji': ''}, {'code': 'C', 'text': 'tsu', 'romaji': ''}, {'code': 'D', 'text': 'to', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "CHI"', 'japanese': 'ち', 'answer': 'chi' },
    { 'type': 'multiple_choice', 'question': 'Karakter "TSU"', 'japanese': 'つ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'te', 'romaji': ''}, {'code': 'B', 'text': 'to', 'romaji': ''}, {'code': 'C', 'text': 'tsu', 'romaji': ''}, {'code': 'D', 'text': 'ta', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "TE"', 'japanese': 'て', 'answer': 'te' },
    { 'type': 'multiple_choice', 'question': 'Karakter "TO"', 'japanese': 'と', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'to', 'romaji': ''}, {'code': 'C', 'text': 'te', 'romaji': ''}, {'code': 'D', 'text': 'tsu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "TETSU" (Besi)', 'japanese': 'てつ', 'answer': 'tetsu' },
  ];

  static final List<Map<String, dynamic>> _h2Star2 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "NA"', 'japanese': 'な', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'na', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'nu', 'romaji': ''}, {'code': 'D', 'text': 'no', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "NI"', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'multiple_choice', 'question': 'Karakter "NU"', 'japanese': 'ぬ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ne', 'romaji': ''}, {'code': 'B', 'text': 'no', 'romaji': ''}, {'code': 'C', 'text': 'nu', 'romaji': ''}, {'code': 'D', 'text': 'na', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "NE"', 'japanese': 'ね', 'answer': 'ne' },
    { 'type': 'multiple_choice', 'question': 'Karakter "NO"', 'japanese': 'の', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'na', 'romaji': ''}, {'code': 'B', 'text': 'no', 'romaji': ''}, {'code': 'C', 'text': 'ni', 'romaji': ''}, {'code': 'D', 'text': 'nu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "NANI" (Apa)', 'japanese': 'なに', 'answer': 'nani' },
  ];

  static final List<Map<String, dynamic>> _h2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "HA"', 'japanese': 'は', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ha', 'romaji': ''}, {'code': 'B', 'text': 'hi', 'romaji': ''}, {'code': 'C', 'text': 'fu', 'romaji': ''}, {'code': 'D', 'text': 'ho', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "HI"', 'japanese': 'ひ', 'answer': 'hi' },
    { 'type': 'multiple_choice', 'question': 'Karakter "FU"', 'japanese': 'ふ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'he', 'romaji': ''}, {'code': 'B', 'text': 'ho', 'romaji': ''}, {'code': 'C', 'text': 'fu', 'romaji': ''}, {'code': 'D', 'text': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "HE"', 'japanese': 'へ', 'answer': 'he' },
    { 'type': 'multiple_choice', 'question': 'Karakter "HO"', 'japanese': 'ほ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ha', 'romaji': ''}, {'code': 'B', 'text': 'ho', 'romaji': ''}, {'code': 'C', 'text': 'hi', 'romaji': ''}, {'code': 'D', 'text': 'fu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "HANA" (Bunga)', 'japanese': 'はな', 'answer': 'hana' },
  ];

  // HIRAGANA 3 (MA-MO, YA-YO, RA-RO)
  static final List<Map<String, dynamic>> _h3Star1 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "MA"', 'japanese': 'ま', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ma', 'romaji': ''}, {'code': 'B', 'text': 'mi', 'romaji': ''}, {'code': 'C', 'text': 'mu', 'romaji': ''}, {'code': 'D', 'text': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "MI"', 'japanese': 'み', 'answer': 'mi' },
    { 'type': 'multiple_choice', 'question': 'Karakter "MU"', 'japanese': 'む', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'me', 'romaji': ''}, {'code': 'B', 'text': 'mo', 'romaji': ''}, {'code': 'C', 'text': 'mu', 'romaji': ''}, {'code': 'D', 'text': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "ME"', 'japanese': 'め', 'answer': 'me' },
    { 'type': 'multiple_choice', 'question': 'Karakter "MO"', 'japanese': 'も', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ma', 'romaji': ''}, {'code': 'B', 'text': 'mo', 'romaji': ''}, {'code': 'C', 'text': 'mi', 'romaji': ''}, {'code': 'D', 'text': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "MOMO" (Persik)', 'japanese': 'もも', 'answer': 'momo' },
  ];

  static final List<Map<String, dynamic>> _h3Star2 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "YA"', 'japanese': 'や', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'yu', 'romaji': ''}, {'code': 'C', 'text': 'yo', 'romaji': ''}, {'code': 'D', 'text': 'a', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "YU"', 'japanese': 'ゆ', 'answer': 'yu' },
    { 'type': 'multiple_choice', 'question': 'Karakter "YO"', 'japanese': 'よ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'yu', 'romaji': ''}, {'code': 'C', 'text': 'yo', 'romaji': ''}, {'code': 'D', 'text': 'o', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "YAMA" (Gunung)', 'japanese': 'やま', 'answer': 'yama' },
    { 'type': 'multiple_choice', 'question': 'Karakter "YA" lagi?', 'japanese': 'や', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'ka', 'romaji': ''}, {'code': 'C', 'text': 'sa', 'romaji': ''}, {'code': 'D', 'text': 'ta', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "YUYU"', 'japanese': 'ゆゆ', 'answer': 'yuyu' },
  ];

  static final List<Map<String, dynamic>> _h3Star3 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "RA"', 'japanese': 'ら', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ra', 'romaji': ''}, {'code': 'B', 'text': 'ri', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ro', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "RI"', 'japanese': 'り', 'answer': 'ri' },
    { 'type': 'multiple_choice', 'question': 'Karakter "RU"', 'japanese': 'る', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 're', 'romaji': ''}, {'code': 'B', 'text': 'ro', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ra', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "RE"', 'japanese': 'れ', 'answer': 're' },
    { 'type': 'multiple_choice', 'question': 'Karakter "RO"', 'japanese': 'ろ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ra', 'romaji': ''}, {'code': 'B', 'text': 'ro', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ri', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "SORA" (Langit)', 'japanese': 'そら', 'answer': 'sora' },
  ];

  // HIRAGANA 4 (WA-N, DAKUON, HANDAKUON)
  static final List<Map<String, dynamic>> _h4Star1 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "WA"', 'japanese': 'わ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'wa', 'romaji': ''}, {'code': 'B', 'text': 'wo', 'romaji': ''}, {'code': 'C', 'text': 'n', 'romaji': ''}, {'code': 'D', 'text': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "WO"', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'multiple_choice', 'question': 'Karakter "N"', 'japanese': 'ん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'm', 'romaji': ''}, {'code': 'B', 'text': 'h', 'romaji': ''}, {'code': 'C', 'text': 'n', 'romaji': ''}, {'code': 'D', 'text': 'ng', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "WATASHI" (Saya)', 'japanese': 'わたし', 'answer': 'watashi' },
    { 'type': 'multiple_choice', 'question': 'Tulis "NIHON" (Jepang)', 'japanese': 'にほん', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'nihn', 'romaji': ''}, {'code': 'B', 'text': 'nihon', 'romaji': ''}, {'code': 'C', 'text': 'niho', 'romaji': ''}, {'code': 'D', 'text': 'nihnn', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "WA" lagi?', 'japanese': 'わ', 'answer': 'wa' },
  ];

  static final List<Map<String, dynamic>> _h4Star2 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "GA"', 'japanese': 'が', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ga', 'romaji': ''}, {'code': 'B', 'text': 'gi', 'romaji': ''}, {'code': 'C', 'text': 'gu', 'romaji': ''}, {'code': 'D', 'text': 'ge', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "ZA"', 'japanese': 'ざ', 'answer': 'za' },
    { 'type': 'multiple_choice', 'question': 'Karakter "DA"', 'japanese': 'だ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'za', 'romaji': ''}, {'code': 'C', 'text': 'da', 'romaji': ''}, {'code': 'D', 'text': 'ba', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "BA"', 'japanese': 'ば', 'answer': 'ba' },
    { 'type': 'multiple_choice', 'question': 'Tulis "MANGA"', 'japanese': 'まんが', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'manka', 'romaji': ''}, {'code': 'B', 'text': 'manga', 'romaji': ''}, {'code': 'C', 'text': 'maga', 'romaji': ''}, {'code': 'D', 'text': 'manna', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "GAKKO" (Sekolah)', 'japanese': 'がっこう', 'answer': 'gakkou' },
  ];

  static final List<Map<String, dynamic>> _h4Star3 = [
    { 'type': 'multiple_choice', 'question': 'Karakter "PA"', 'japanese': 'ぱ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'pa', 'romaji': ''}, {'code': 'B', 'text': 'ba', 'romaji': ''}, {'code': 'C', 'text': 'ha', 'romaji': ''}, {'code': 'D', 'text': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "PI"', 'japanese': 'ぴ', 'answer': 'pi' },
    { 'type': 'multiple_choice', 'question': 'Karakter "PU"', 'japanese': 'ぷ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'fu', 'romaji': ''}, {'code': 'B', 'text': 'bu', 'romaji': ''}, {'code': 'C', 'text': 'pu', 'romaji': ''}, {'code': 'D', 'text': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Karakter "PE"', 'japanese': 'ぺ', 'answer': 'pe' },
    { 'type': 'multiple_choice', 'question': 'Karakter "PO"', 'japanese': 'ぽ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ho', 'romaji': ''}, {'code': 'B', 'text': 'po', 'romaji': ''}, {'code': 'C', 'text': 'bo', 'romaji': ''}, {'code': 'D', 'text': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "PAN" (Roti)', 'japanese': 'ぱん', 'answer': 'pan' },
  ];

  static final List<Map<String, dynamic>> _greetStar1 = [
    { 'type': 'multiple_choice', 'question': 'Selamat Pagi:', 'japanese': 'おはよう', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ohayou', 'romaji': ''}, {'code': 'B', 'text': 'konnichiwa', 'romaji': ''}, {'code': 'C', 'text': 'konbanwa', 'romaji': ''}, {'code': 'D', 'text': 'oyasumi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Selamat Siang:', 'japanese': 'こんにちは', 'answer': 'konnichiwa' },
    { 'type': 'multiple_choice', 'question': 'Selamat Malam:', 'japanese': 'こんばんは', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ohayou', 'romaji': ''}, {'code': 'B', 'text': 'konnichiwa', 'romaji': ''}, {'code': 'C', 'text': 'konbanwa', 'romaji': ''}, {'code': 'D', 'text': 'oyasumi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Selamat Tidur:', 'japanese': 'おやすみなさい', 'answer': 'oyasuminasai' },
    { 'type': 'multiple_choice', 'question': 'Apa Kabar?', 'japanese': 'おげんきですか', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'arigatou', 'romaji': ''}, {'code': 'B', 'text': 'ogenkidesuka', 'romaji': ''}, {'code': 'C', 'text': 'sumimasen', 'romaji': ''}, {'code': 'D', 'text': 'hajimemashite', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Terima Kasih:', 'japanese': 'ありがとう', 'answer': 'arigatou' },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'multiple_choice', 'question': 'Satu (1):', 'japanese': 'いち', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Dua (2):', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'multiple_choice', 'question': 'Tiga (3):', 'japanese': 'さん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Empat (4):', 'japanese': 'よん', 'answer': 'yon' },
    { 'type': 'multiple_choice', 'question': 'Lima (5):', 'japanese': 'ご', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'yon', 'romaji': ''}, {'code': 'B', 'text': 'go', 'romaji': ''}, {'code': 'C', 'text': 'roku', 'romaji': ''}, {'code': 'D', 'text': 'nana', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Sepuluh (10):', 'japanese': 'じゅう', 'answer': 'juu' },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'multiple_choice', 'question': 'Makan:', 'japanese': 'たべる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'taberu', 'romaji': ''}, {'code': 'B', 'text': 'nomu', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'kiku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Minum:', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'multiple_choice', 'question': 'Melihat:', 'japanese': 'みる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'yomu', 'romaji': ''}, {'code': 'B', 'text': 'kaku', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'iku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Membaca:', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'multiple_choice', 'question': 'Pergi:', 'japanese': 'いく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kuru', 'romaji': ''}, {'code': 'B', 'text': 'iku', 'romaji': ''}, {'code': 'C', 'text': 'kaeru', 'romaji': ''}, {'code': 'D', 'text': 'neru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis "Makan" (Taberu)', 'japanese': 'たべる', 'answer': 'taberu' },
  ];

  static final List<Map<String, dynamic>> _u1UnitTest = [
    ..._h1Star1, ..._h1Star2, ..._h1Star3,
    ..._greetStar1.sublist(0, 4),
    ..._numStar1.sublist(0, 4),
    ..._verbStar1.sublist(0, 4)
  ];

  // ==========================================
  // --- UNIT 2: KATAKANA ---
  // ==========================================
  static final List<Map<String, dynamic>> _k1Star1 = [
    { 'type': 'essay', 'japanese': 'ア', 'question': 'A:', 'answer': 'a' },
    { 'type': 'essay', 'japanese': 'イ', 'question': 'I:', 'answer': 'i' },
    { 'type': 'essay', 'japanese': 'ウ', 'question': 'U:', 'answer': 'u' },
    { 'type': 'essay', 'japanese': 'エ', 'question': 'E:', 'answer': 'e' },
    { 'type': 'essay', 'japanese': 'オ', 'question': 'O:', 'answer': 'o' },
    { 'type': 'essay', 'japanese': 'カ', 'question': 'Ka:', 'answer': 'ka' },
    { 'type': 'essay', 'japanese': 'キ', 'question': 'Ki:', 'answer': 'ki' },
    { 'type': 'essay', 'japanese': 'ク', 'question': 'Ku:', 'answer': 'ku' },
    { 'type': 'essay', 'japanese': 'ケ', 'question': 'Ke:', 'answer': 'ke' },
    { 'type': 'essay', 'japanese': 'コ', 'question': 'Ko:', 'answer': 'ko' },
    { 'type': 'essay', 'japanese': 'サ', 'question': 'Sa:', 'answer': 'sa' },
    { 'type': 'essay', 'japanese': 'シ', 'question': 'Shi:', 'answer': 'shi' },
  ];

  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'japanese': 'ス', 'question': 'Su:', 'answer': 'su' },
    { 'type': 'essay', 'japanese': 'セ', 'question': 'Se:', 'answer': 'se' },
    { 'type': 'essay', 'japanese': 'ソ', 'question': 'So:', 'answer': 'so' },
    { 'type': 'essay', 'japanese': 'タ', 'question': 'Ta:', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': 'チ', 'question': 'Chi:', 'answer': 'chi' },
    { 'type': 'essay', 'japanese': 'ツ', 'question': 'Tsu:', 'answer': 'tsu' },
    { 'type': 'essay', 'japanese': 'テ', 'question': 'Te:', 'answer': 'te' },
    { 'type': 'essay', 'japanese': 'ト', 'question': 'To:', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'ナ', 'question': 'Na:', 'answer': 'na' },
    { 'type': 'essay', 'japanese': 'ニ', 'question': 'Ni:', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': 'ヌ', 'question': 'Nu:', 'answer': 'nu' },
    { 'type': 'essay', 'japanese': 'ネ', 'question': 'Ne:', 'answer': 'ne' },
  ];

  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'japanese': 'ノ', 'question': 'No:', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'ハ', 'question': 'Ha:', 'answer': 'ha' },
    { 'type': 'essay', 'japanese': 'ひ', 'question': 'Hi:', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': 'フ', 'question': 'Fu:', 'answer': 'fu' },
    { 'type': 'essay', 'japanese': 'ヘ', 'question': 'He:', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'ホ', 'question': 'Ho:', 'answer': 'ho' },
    { 'type': 'essay', 'japanese': 'マ', 'question': 'Ma:', 'answer': 'ma' },
    { 'type': 'essay', 'japanese': 'ミ', 'question': 'Mi:', 'answer': 'mi' },
    { 'type': 'essay', 'japanese': 'ム', 'question': 'Mu:', 'answer': 'mu' },
    { 'type': 'essay', 'japanese': 'メ', 'question': 'Me:', 'answer': 'me' },
    { 'type': 'essay', 'japanese': 'モ', 'question': 'Mo:', 'answer': 'mo' },
    { 'type': 'essay', 'japanese': 'ヤ', 'question': 'Ya:', 'answer': 'ya' },
  ];

  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'japanese': 'ユ', 'question': 'Yu:', 'answer': 'yu' },
    { 'type': 'essay', 'japanese': 'ヨ', 'question': 'Yo:', 'answer': 'yo' },
    { 'type': 'essay', 'japanese': 'ら', 'question': 'Ra:', 'answer': 'ra' },
    { 'type': 'essay', 'japanese': 'り', 'question': 'Ri:', 'answer': 'ri' },
    { 'type': 'essay', 'japanese': 'る', 'question': 'Ru:', 'answer': 'ru' },
    { 'type': 'essay', 'japanese': 'れ', 'question': 'Re:', 'answer': 're' },
    { 'type': 'essay', 'japanese': 'ろ', 'question': 'Ro:', 'answer': 'ro' },
    { 'type': 'essay', 'japanese': 'わ', 'question': 'Wa:', 'answer': 'wa' },
    { 'type': 'essay', 'japanese': 'を', 'question': 'Wo:', 'answer': 'wo' },
    { 'type': 'essay', 'japanese': 'ん', 'question': 'N:', 'answer': 'n' },
    { 'type': 'essay', 'japanese': 'が', 'question': 'Ga:', 'answer': 'ga' },
    { 'type': 'essay', 'japanese': 'ぱ', 'question': 'Pa:', 'answer': 'pa' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar1 = [
    { 'type': 'essay', 'japanese': 'カメラ', 'question': 'Kamera:', 'answer': 'kamera' },
    { 'type': 'essay', 'japanese': 'テレビ', 'question': 'TV:', 'answer': 'terebi' },
    { 'type': 'essay', 'japanese': 'ホテル', 'question': 'Hotel:', 'answer': 'hoteru' },
    { 'type': 'essay', 'japanese': 'バス', 'question': 'Bus:', 'answer': 'basu' },
    { 'type': 'essay', 'japanese': 'トイレ', 'question': 'Toilet:', 'answer': 'toire' },
    { 'type': 'essay', 'japanese': 'ドア', 'question': 'Door:', 'answer': 'doa' },
    { 'type': 'essay', 'japanese': 'ペン', 'question': 'Pen:', 'answer': 'pen' },
    { 'type': 'essay', 'japanese': 'パン', 'question': 'Roti:', 'answer': 'pan' },
    { 'type': 'essay', 'japanese': 'ワイン', 'question': 'Wine:', 'answer': 'wain' },
    { 'type': 'essay', 'japanese': 'ケーキ', 'question': 'Kue:', 'answer': 'keeki' },
    { 'type': 'essay', 'japanese': 'コーヒー', 'question': 'Kopi:', 'answer': 'koohii' },
    { 'type': 'essay', 'japanese': 'タクシー', 'question': 'Taksi:', 'answer': 'takushii' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar1 = [
    { 'type': 'essay', 'japanese': 'レストラン', 'question': 'Restoran:', 'answer': 'resutoran' },
    { 'type': 'essay', 'japanese': 'スーパー', 'question': 'Supermarket:', 'answer': 'suupaa' },
    { 'type': 'essay', 'japanese': 'デパート', 'question': 'Department Store:', 'answer': 'depaato' },
    { 'type': 'essay', 'japanese': 'コンビニ', 'question': 'Convenience Store:', 'answer': 'konbini' },
    { 'type': 'essay', 'japanese': 'サラリーマン', 'question': 'Office Worker:', 'answer': 'sarariiman' },
    { 'type': 'essay', 'japanese': 'スマートフォン', 'question': 'Smartphone:', 'answer': 'sumaatofon' },
    { 'type': 'essay', 'japanese': 'コンピューター', 'question': 'Computer:', 'answer': 'konpyuutaa' },
    { 'type': 'essay', 'japanese': 'インターネット', 'question': 'Internet:', 'answer': 'intaanetto' },
    { 'type': 'essay', 'japanese': 'ピザ', 'question': 'Pizza:', 'answer': 'piza' },
    { 'type': 'essay', 'japanese': 'サラダ', 'question': 'Salad:', 'answer': 'sarada' },
    { 'type': 'essay', 'japanese': 'スポーツ', 'question': 'Sport:', 'answer': 'supootsu' },
    { 'type': 'essay', 'japanese': 'ネクタイ', 'question': 'Necktie:', 'answer': 'nekutai' },
  ];

  static final List<Map<String, dynamic>> _u2UnitTest = [..._k1Star1, ..._kataWordStar1, ..._loanWordStar1.sublist(0, 6)];

  // ==========================================
  // --- UNIT 3: BASIC KANJI ---
  // ==========================================
  static final List<Map<String, dynamic>> _knStar1 = [
    { 'type': 'essay', 'question': 'Satu (1):', 'japanese': '一', 'answer': 'ichi' },
    { 'type': 'essay', 'question': 'Dua (2):', 'japanese': '二', 'answer': 'ni' },
    { 'type': 'essay', 'question': 'Tiga (3):', 'japanese': '三', 'answer': 'san' },
    { 'type': 'essay', 'question': 'Empat (4):', 'japanese': '四', 'answer': 'yon' },
    { 'type': 'essay', 'question': 'Lima (5):', 'japanese': '五', 'answer': 'go' },
    { 'type': 'essay', 'question': 'Enam (6):', 'japanese': '六', 'answer': 'roku' },
    { 'type': 'essay', 'question': 'Tujuh (7):', 'japanese': '七', 'answer': 'nana' },
    { 'type': 'essay', 'question': 'Delapan (8):', 'japanese': '八', 'answer': 'hachi' },
    { 'type': 'essay', 'question': 'Sembilan (9):', 'japanese': '九', 'answer': 'kyuu' },
    { 'type': 'essay', 'question': 'Sepuluh (10):', 'japanese': '十', 'answer': 'juu' },
    { 'type': 'essay', 'question': 'Seratus (100):', 'japanese': '百', 'answer': 'hyaku' },
    { 'type': 'essay', 'question': 'Seribu (1000):', 'japanese': '千', 'answer': 'sen' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar1 = [
    { 'type': 'essay', 'question': 'Matahari:', 'japanese': '日', 'answer': 'hi' },
    { 'type': 'essay', 'question': 'Bulan:', 'japanese': '月', 'answer': 'tsuki' },
    { 'type': 'essay', 'question': 'Api:', 'japanese': '火', 'answer': 'hi' },
    { 'type': 'essay', 'question': 'Air:', 'japanese': '水', 'answer': 'mizu' },
    { 'type': 'essay', 'japanese': '木', 'question': 'Pohon:', 'answer': 'ki' },
    { 'type': 'essay', 'japanese': '金', 'question': 'Logam/Uang:', 'answer': 'kane' },
    { 'type': 'essay', 'japanese': '土', 'question': 'Tanah:', 'answer': 'tsuchi' },
    { 'type': 'essay', 'japanese': '山', 'question': 'Gunung:', 'answer': 'yama' },
    { 'type': 'essay', 'japanese': '川', 'question': 'Sungai:', 'answer': 'kawa' },
    { 'type': 'essay', 'japanese': '田', 'question': 'Sawah:', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': '天', 'question': 'Langit:', 'answer': 'ten' },
    { 'type': 'essay', 'japanese': '石', 'question': 'Batu:', 'answer': 'ishi' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar1 = [
    { 'type': 'essay', 'question': 'Orang:', 'japanese': '人', 'answer': 'hito' },
    { 'type': 'essay', 'question': 'Anak:', 'japanese': '子', 'answer': 'ko' },
    { 'type': 'essay', 'question': 'Wanita:', 'japanese': '女', 'answer': 'onna' },
    { 'type': 'essay', 'question': 'Pria:', 'japanese': '男', 'answer': 'otoko' },
    { 'type': 'essay', 'question': 'Mata:', 'japanese': '目', 'answer': 'me' },
    { 'type': 'essay', 'question': 'Mulut:', 'japanese': '口', 'answer': 'kuchi' },
    { 'type': 'essay', 'question': 'Telinga:', 'japanese': '耳', 'answer': 'mimi' },
    { 'type': 'essay', 'question': 'Tangan:', 'japanese': '手', 'answer': 'te' },
    { 'type': 'essay', 'question': 'Kaki:', 'japanese': '足', 'answer': 'ashi' },
    { 'type': 'essay', 'question': 'Kekuatan:', 'japanese': '力', 'answer': 'chikara' },
    { 'type': 'essay', 'question': 'Gerbang:', 'japanese': '門', 'answer': 'mon' },
    { 'type': 'essay', 'question': 'Ayah:', 'japanese': '父', 'answer': 'chichi' },
  ];

  static final List<Map<String, dynamic>> _u3UnitTest = [..._knStar1, ..._kanjiNatureStar1, ..._kanjiPeopleStar1.sublist(0, 6)];

  // ==========================================
  // --- UNIT 4: BASIC GRAMMAR ---
  // ==========================================
  static final List<Map<String, dynamic>> _gpStar1 = [
    { 'type': 'essay', 'question': 'Partikel Topik:', 'japanese': 'は', 'answer': 'wa' },
    { 'type': 'essay', 'question': 'Partikel Objek:', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'essay', 'question': 'Partikel Juga:', 'japanese': 'も', 'answer': 'mo' },
    { 'type': 'essay', 'question': 'Partikel Lokasi/Tujuan:', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'essay', 'question': 'Partikel Arah:', 'japanese': 'へ', 'answer': 'he' },
    { 'type': 'essay', 'question': 'Partikel Lokasi Kejadian:', 'japanese': 'で', 'answer': 'de' },
    { 'type': 'essay', 'question': 'Partikel Bersama/Dan:', 'japanese': 'と', 'answer': 'to' },
    { 'type': 'essay', 'question': 'Partikel Kepemilikan:', 'japanese': 'の', 'answer': 'no' },
    { 'type': 'essay', 'question': 'Partikel Subjek:', 'japanese': 'が', 'answer': 'ga' },
    { 'type': 'essay', 'question': 'Dari:', 'japanese': 'から', 'answer': 'kara' },
    { 'type': 'essay', 'question': 'Sampai:', 'japanese': 'まで', 'answer': 'made' },
    { 'type': 'essay', 'question': 'Partikel Pertanyaan:', 'japanese': 'か', 'answer': 'ka' },
  ];

  static final List<Map<String, dynamic>> _gv1Star1 = [
    { 'type': 'essay', 'question': 'Makan:', 'japanese': 'たべる', 'answer': 'taberu' },
    { 'type': 'essay', 'question': 'Minum:', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'essay', 'question': 'Pergi:', 'japanese': 'いく', 'answer': 'iku' },
    { 'type': 'essay', 'japanese': 'くる', 'question': 'Datang:', 'answer': 'kuru' },
    { 'type': 'essay', 'japanese': 'する', 'question': 'Melakukan:', 'answer': 'suru' },
    { 'type': 'essay', 'japanese': 'かう', 'question': 'Membeli:', 'answer': 'kau' },
    { 'type': 'essay', 'japanese': 'わかる', 'question': 'Mengerti:', 'answer': 'wakaru' },
    { 'type': 'essay', 'japanese': 'はなす', 'question': 'Berbicara:', 'answer': 'hanasu' },
    { 'type': 'essay', 'japanese': 'あります', 'question': 'Ada (Benda Mati):', 'answer': 'arimasu' },
    { 'type': 'essay', 'japanese': 'います', 'question': 'Ada (Benda Hidup):', 'answer': 'imasu' },
    { 'type': 'essay', 'japanese': 'はたらく', 'question': 'Bekerja:', 'answer': 'hataraku' },
    { 'type': 'essay', 'japanese': 'べんきょうする', 'question': 'Belajar:', 'answer': 'benkyousuru' },
  ];

  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'question': 'Melihat:', 'japanese': 'みる', 'answer': 'miru' },
    { 'type': 'essay', 'question': 'Mendengar:', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'essay', 'question': 'Menulis:', 'japanese': 'かく', 'answer': 'kaku' },
    { 'type': 'essay', 'question': 'Membaca:', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'essay', 'japanese': 'およぐ', 'question': 'Berenang:', 'answer': 'oyogu' },
    { 'type': 'essay', 'japanese': 'まつ', 'question': 'Menunggu:', 'answer': 'matsu' },
    { 'type': 'essay', 'japanese': 'かえる', 'question': 'Pulang:', 'answer': 'kaeru' },
    { 'type': 'essay', 'japanese': 'とる', 'question': 'Mengambil:', 'answer': 'toru' },
    { 'type': 'essay', 'japanese': 'たつ', 'question': 'Berdiri:', 'answer': 'tatsu' },
    { 'type': 'essay', 'japanese': 'すわる', 'question': 'Duduk:', 'answer': 'suwaru' },
    { 'type': 'essay', 'japanese': 'きる', 'question': 'Mengenakan:', 'answer': 'kiru' },
    { 'type': 'essay', 'japanese': 'しぬ', 'question': 'Mati:', 'answer': 'shinu' },
  ];

  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'question': 'Enak:', 'japanese': 'おいしい', 'answer': 'oishii' },
    { 'type': 'essay', 'question': 'Mahal:', 'japanese': 'たかい', 'answer': 'takai' },
    { 'type': 'essay', 'question': 'Murah:', 'japanese': 'やすい', 'answer': 'yasui' },
    { 'type': 'essay', 'question': 'Besar:', 'japanese': 'おおきい', 'answer': 'ookii' },
    { 'type': 'essay', 'japanese': 'ちいさい', 'question': 'Kecil:', 'answer': 'chiisai' },
    { 'type': 'essay', 'japanese': 'あたらしい', 'question': 'Baru:', 'answer': 'atarashii' },
    { 'type': 'essay', 'japanese': 'ふるい', 'question': 'Lama/Tua:', 'answer': 'furui' },
    { 'type': 'essay', 'japanese': 'いい', 'question': 'Bagus:', 'answer': 'ii' },
    { 'type': 'essay', 'japanese': 'わるい', 'question': 'Buruk:', 'answer': 'warui' },
    { 'type': 'essay', 'japanese': 'むずかしい', 'question': 'Sulit:', 'answer': 'muzukashii' },
    { 'type': 'essay', 'japanese': 'やさしい', 'question': 'Mudah:', 'answer': 'やさしい' },
    { 'type': 'essay', 'japanese': 'とても', 'question': 'Sangat:', 'answer': 'totemo' },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [..._gpStar1, ..._gv1Star1, ..._adjStar1.sublist(0, 6)];
}
