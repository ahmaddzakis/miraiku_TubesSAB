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
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'あ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'o', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'e', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'い', 'answer': 'i' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'う', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'i', 'romaji': ''}, {'code': 'B', 'text': 'e', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'a', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'え', 'answer': 'e' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'お', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'o', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'i', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Biru)', 'japanese': 'あお', 'answer': 'ao' },
  ];

  static final List<Map<String, dynamic>> _h1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'か', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ka', 'romaji': ''}, {'code': 'B', 'text': 'ki', 'romaji': ''}, {'code': 'C', 'text': 'ku', 'romaji': ''}, {'code': 'D', 'text': 'ko', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'き', 'answer': 'ki' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'く', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ke', 'romaji': ''}, {'code': 'B', 'text': 'ko', 'romaji': ''}, {'code': 'C', 'text': 'ku', 'romaji': ''}, {'code': 'D', 'text': 'ka', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'け', 'answer': 'ke' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'こ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ka', 'romaji': ''}, {'code': 'B', 'text': 'ko', 'romaji': ''}, {'code': 'C', 'text': 'ki', 'romaji': ''}, {'code': 'D', 'text': 'ku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Kesemek)', 'japanese': 'かき', 'answer': 'kaki' },
  ];

  static final List<Map<String, dynamic>> _h1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'さ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'sa', 'romaji': ''}, {'code': 'B', 'text': 'shi', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'so', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'し', 'answer': 'shi' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'す', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'se', 'romaji': ''}, {'code': 'B', 'text': 'so', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'sa', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'せ', 'answer': 'se' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'そ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'sa', 'romaji': ''}, {'code': 'B', 'text': 'so', 'romaji': ''}, {'code': 'C', 'text': 'su', 'romaji': ''}, {'code': 'D', 'text': 'shi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Sushi)', 'japanese': 'すし', 'answer': 'sushi' },
  ];

  // HIRAGANA 2 (TA-TO, NA-NO, HA-HO)
  static final List<Map<String, dynamic>> _h2Star1 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'た', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'chi', 'romaji': ''}, {'code': 'C', 'text': 'tsu', 'romaji': ''}, {'code': 'D', 'text': 'to', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ち', 'answer': 'chi' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'つ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'te', 'romaji': ''}, {'code': 'B', 'text': 'to', 'romaji': ''}, {'code': 'C', 'text': 'tsu', 'romaji': ''}, {'code': 'D', 'text': 'ta', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'て', 'answer': 'te' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'と', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'to', 'romaji': ''}, {'code': 'C', 'text': 'te', 'romaji': ''}, {'code': 'D', 'text': 'tsu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Besi)', 'japanese': 'てつ', 'answer': 'tetsu' },
  ];

  static final List<Map<String, dynamic>> _h2Star2 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'な', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'na', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'nu', 'romaji': ''}, {'code': 'D', 'text': 'no', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'ぬ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ne', 'romaji': ''}, {'code': 'B', 'text': 'no', 'romaji': ''}, {'code': 'C', 'text': 'nu', 'romaji': ''}, {'code': 'D', 'text': 'na', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ね', 'answer': 'ne' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'の', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'na', 'romaji': ''}, {'code': 'B', 'text': 'no', 'romaji': ''}, {'code': 'C', 'text': 'ni', 'romaji': ''}, {'code': 'D', 'text': 'nu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Apa)', 'japanese': 'なに', 'answer': 'nani' },
  ];

  static final List<Map<String, dynamic>> _h2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'は', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ha', 'romaji': ''}, {'code': 'B', 'text': 'hi', 'romaji': ''}, {'code': 'C', 'text': 'fu', 'romaji': ''}, {'code': 'D', 'text': 'ho', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ひ', 'answer': 'hi' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'ふ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'he', 'romaji': ''}, {'code': 'B', 'text': 'ho', 'romaji': ''}, {'code': 'C', 'text': 'fu', 'romaji': ''}, {'code': 'D', 'text': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'へ', 'answer': 'he' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ほ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ha', 'romaji': ''}, {'code': 'B', 'text': 'ho', 'romaji': ''}, {'code': 'C', 'text': 'hi', 'romaji': ''}, {'code': 'D', 'text': 'fu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Bunga)', 'japanese': 'はな', 'answer': 'hana' },
  ];

  // HIRAGANA 3 (MA-MO, YA-YO, RA-RO)
  static final List<Map<String, dynamic>> _h3Star1 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ま', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ma', 'romaji': ''}, {'code': 'B', 'text': 'mi', 'romaji': ''}, {'code': 'C', 'text': 'mu', 'romaji': ''}, {'code': 'D', 'text': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'み', 'answer': 'mi' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'む', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'me', 'romaji': ''}, {'code': 'B', 'text': 'mo', 'romaji': ''}, {'code': 'C', 'text': 'mu', 'romaji': ''}, {'code': 'D', 'text': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'め', 'answer': 'me' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'も', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ma', 'romaji': ''}, {'code': 'B', 'text': 'mo', 'romaji': ''}, {'code': 'C', 'text': 'mi', 'romaji': ''}, {'code': 'D', 'text': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Persik)', 'japanese': 'もも', 'answer': 'momo' },
  ];

  static final List<Map<String, dynamic>> _h3Star2 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'や', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'yu', 'romaji': ''}, {'code': 'C', 'text': 'yo', 'romaji': ''}, {'code': 'D', 'text': 'a', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ゆ', 'answer': 'yu' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'よ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'yu', 'romaji': ''}, {'code': 'C', 'text': 'yo', 'romaji': ''}, {'code': 'D', 'text': 'o', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Gunung)', 'japanese': 'やま', 'answer': 'yama' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'や', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ya', 'romaji': ''}, {'code': 'B', 'text': 'ka', 'romaji': ''}, {'code': 'C', 'text': 'sa', 'romaji': ''}, {'code': 'D', 'text': 'ta', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Mimpi)', 'japanese': 'ゆめ', 'answer': 'yume' },
  ];

  static final List<Map<String, dynamic>> _h3Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ら', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ra', 'romaji': ''}, {'code': 'B', 'text': 'ri', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ro', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'り', 'answer': 'ri' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat:', 'japanese': 'る', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 're', 'romaji': ''}, {'code': 'B', 'text': 'ro', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ra', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'れ', 'answer': 're' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ろ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ra', 'romaji': ''}, {'code': 'B', 'text': 'ro', 'romaji': ''}, {'code': 'C', 'text': 'ru', 'romaji': ''}, {'code': 'D', 'text': 'ri', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Langit)', 'japanese': 'そら', 'answer': 'sora' },
  ];

  // HIRAGANA 4 (WA-N, DAKUON, HANDAKUON)
  static final List<Map<String, dynamic>> _h4Star1 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'わ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'wa', 'romaji': ''}, {'code': 'B', 'text': 'wo', 'romaji': ''}, {'code': 'C', 'text': 'n', 'romaji': ''}, {'code': 'D', 'text': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'm', 'romaji': ''}, {'code': 'B', 'text': 'h', 'romaji': ''}, {'code': 'C', 'text': 'n', 'romaji': ''}, {'code': 'D', 'text': 'ng', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Saya)', 'japanese': 'わたし', 'answer': 'watashi' },
    { 'type': 'multiple_choice', 'question': 'Pilih romaji yang tepat dari kata ini? (Arti: Jepang)', 'japanese': 'にほん', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'nihn', 'romaji': ''}, {'code': 'B', 'text': 'nihon', 'romaji': ''}, {'code': 'C', 'text': 'niho', 'romaji': ''}, {'code': 'D', 'text': 'nihnn', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'わ', 'answer': 'wa' },
  ];

  static final List<Map<String, dynamic>> _h4Star2 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'が', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ga', 'romaji': ''}, {'code': 'B', 'text': 'gi', 'romaji': ''}, {'code': 'C', 'text': 'gu', 'romaji': ''}, {'code': 'D', 'text': 'ge', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ざ', 'answer': 'za' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'だ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ta', 'romaji': ''}, {'code': 'B', 'text': 'za', 'romaji': ''}, {'code': 'C', 'text': 'da', 'romaji': ''}, {'code': 'D', 'text': 'ba', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ば', 'answer': 'ba' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata ini? (Arti: Komik)', 'japanese': 'まんが', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'manka', 'romaji': ''}, {'code': 'B', 'text': 'manga', 'romaji': ''}, {'code': 'C', 'text': 'maga', 'romaji': ''}, {'code': 'D', 'text': 'manna', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Sekolah)', 'japanese': 'がっこう', 'answer': 'gakkou' },
  ];

  static final List<Map<String, dynamic>> _h4Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ぱ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'pa', 'romaji': ''}, {'code': 'B', 'text': 'ba', 'romaji': ''}, {'code': 'C', 'text': 'ha', 'romaji': ''}, {'code': 'D', 'text': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ぴ', 'answer': 'pi' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ぷ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'fu', 'romaji': ''}, {'code': 'B', 'text': 'bu', 'romaji': ''}, {'code': 'C', 'text': 'pu', 'romaji': ''}, {'code': 'D', 'text': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ぺ', 'answer': 'pe' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca karakter ini?', 'japanese': 'ぽ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ho', 'romaji': ''}, {'code': 'B', 'text': 'po', 'romaji': ''}, {'code': 'C', 'text': 'bo', 'romaji': ''}, {'code': 'D', 'text': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata ini? (Arti: Roti)', 'japanese': 'ぱん', 'answer': 'pan' },
  ];

  static final List<Map<String, dynamic>> _greetStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari ungkapan ini? (Arti: Selamat Pagi)', 'japanese': 'おはよう', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ohayou', 'romaji': ''}, {'code': 'B', 'text': 'konnichiwa', 'romaji': ''}, {'code': 'C', 'text': 'konbanwa', 'romaji': ''}, {'code': 'D', 'text': 'oyasumi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari ungkapan ini? (Arti: Selamat Siang)', 'japanese': 'こんにちは', 'answer': 'konnichiwa' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari ungkapan ini? (Arti: Selamat Malam)', 'japanese': 'こんばんは', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ohayou', 'romaji': ''}, {'code': 'B', 'text': 'konnichiwa', 'romaji': ''}, {'code': 'C', 'text': 'konbanwa', 'romaji': ''}, {'code': 'D', 'text': 'oyasumi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari ungkapan ini? (Arti: Selamat Tidur)', 'japanese': 'おやすみなさい', 'answer': 'oyasuminasai' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari ungkapan ini? (Arti: Apa Kabar?)', 'japanese': 'おげんきですか', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'arigatou', 'romaji': ''}, {'code': 'B', 'text': 'ogenkidesuka', 'romaji': ''}, {'code': 'C', 'text': 'sumimasen', 'romaji': ''}, {'code': 'D', 'text': 'hajimemashite', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari ungkapan ini? (Arti: Terima Kasih)', 'japanese': 'ありがとう', 'answer': 'arigatou' },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Satu)', 'japanese': 'いち', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Dua)', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Tiga)', 'japanese': 'さん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Empat)', 'japanese': 'よん', 'answer': 'yon' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Lima)', 'japanese': 'ご', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'yon', 'romaji': ''}, {'code': 'B', 'text': 'go', 'romaji': ''}, {'code': 'C', 'text': 'roku', 'romaji': ''}, {'code': 'D', 'text': 'nana', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Sepuluh)', 'japanese': 'じゅう', 'answer': 'juu' },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'japanese': 'たべる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'taberu', 'romaji': ''}, {'code': 'B', 'text': 'nomu', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'kiku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Minum)', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melihat)', 'japanese': 'みる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'yomu', 'romaji': ''}, {'code': 'B', 'text': 'kaku', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'iku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membaca)', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pergi)', 'japanese': 'いく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kuru', 'romaji': ''}, {'code': 'B', 'text': 'iku', 'romaji': ''}, {'code': 'C', 'text': 'kaeru', 'romaji': ''}, {'code': 'D', 'text': 'neru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'japanese': 'たべる', 'answer': 'taberu' },
  ];

  static final List<Map<String, dynamic>> _u1UnitTest = [
    ..._h1Star1.sublist(0, 2), ..._h1Star2.sublist(0, 2), ..._h1Star3.sublist(0, 2),
    ..._h2Star1.sublist(0, 2), ..._h2Star2.sublist(0, 2), ..._h2Star3.sublist(0, 2),
    ..._h3Star1.sublist(0, 2), ..._h3Star2.sublist(0, 2), ..._h3Star3.sublist(0, 2),
    ..._h4Star1.sublist(0, 2), ..._h4Star2.sublist(0, 2), ..._h4Star3.sublist(0, 2),
    ..._greetStar1.sublist(0, 2),
    ..._numStar1.sublist(0, 2),
    ..._verbStar1.sublist(0, 2)
  ];

  // ==========================================
  // --- UNIT 2: KATAKANA ---
  // ==========================================
  static final List<Map<String, dynamic>> _k1Star1 = [
    { 'type': 'essay', 'japanese': 'ア', 'question': 'Apa cara baca karakter ini?', 'answer': 'a' },
    { 'type': 'essay', 'japanese': 'イ', 'question': 'Apa cara baca karakter ini?', 'answer': 'i' },
    { 'type': 'essay', 'japanese': 'ウ', 'question': 'Apa cara baca karakter ini?', 'answer': 'u' },
    { 'type': 'essay', 'japanese': 'エ', 'question': 'Apa cara baca karakter ini?', 'answer': 'e' },
    { 'type': 'essay', 'japanese': 'オ', 'question': 'Apa cara baca karakter ini?', 'answer': 'o' },
    { 'type': 'essay', 'japanese': 'カ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ka' },
    { 'type': 'essay', 'japanese': 'キ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ki' },
    { 'type': 'essay', 'japanese': 'ク', 'question': 'Apa cara baca karakter ini?', 'answer': 'ku' },
    { 'type': 'essay', 'japanese': 'ケ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ke' },
    { 'type': 'essay', 'japanese': 'コ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ko' },
    { 'type': 'essay', 'japanese': 'サ', 'question': 'Apa cara baca karakter ini?', 'answer': 'sa' },
    { 'type': 'essay', 'japanese': 'シ', 'question': 'Apa cara baca karakter ini?', 'answer': 'shi' },
  ];

  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'japanese': 'ス', 'question': 'Apa cara baca karakter ini?', 'answer': 'su' },
    { 'type': 'essay', 'japanese': 'セ', 'question': 'Apa cara baca karakter ini?', 'answer': 'se' },
    { 'type': 'essay', 'japanese': 'ソ', 'question': 'Apa cara baca karakter ini?', 'answer': 'so' },
    { 'type': 'essay', 'japanese': 'タ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': 'チ', 'question': 'Apa cara baca karakter ini?', 'answer': 'chi' },
    { 'type': 'essay', 'japanese': 'ツ', 'question': 'Apa cara baca karakter ini?', 'answer': 'tsu' },
    { 'type': 'essay', 'japanese': 'テ', 'question': 'Apa cara baca karakter ini?', 'answer': 'te' },
    { 'type': 'essay', 'japanese': 'ト', 'question': 'Apa cara baca karakter ini?', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'ナ', 'question': 'Apa cara baca karakter ini?', 'answer': 'na' },
    { 'type': 'essay', 'japanese': 'ニ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': 'ヌ', 'question': 'Apa cara baca karakter ini?', 'answer': 'nu' },
    { 'type': 'essay', 'japanese': 'ネ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ne' },
  ];

  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'japanese': 'ノ', 'question': 'Apa cara baca karakter ini?', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'ハ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ha' },
    { 'type': 'essay', 'japanese': 'ヒ', 'question': 'Apa cara baca karakter ini?', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': 'フ', 'question': 'Apa cara baca karakter ini?', 'answer': 'fu' },
    { 'type': 'essay', 'japanese': 'ヘ', 'question': 'Apa cara baca karakter ini?', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'ホ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ho' },
    { 'type': 'essay', 'japanese': 'マ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ma' },
    { 'type': 'essay', 'japanese': 'ミ', 'question': 'Apa cara baca karakter ini?', 'answer': 'mi' },
    { 'type': 'essay', 'japanese': 'ム', 'question': 'Apa cara baca karakter ini?', 'answer': 'mu' },
    { 'type': 'essay', 'japanese': 'メ', 'question': 'Apa cara baca karakter ini?', 'answer': 'me' },
    { 'type': 'essay', 'japanese': 'モ', 'question': 'Apa cara baca karakter ini?', 'answer': 'mo' },
    { 'type': 'essay', 'japanese': 'ヤ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ya' },
  ];

  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'japanese': 'ユ', 'question': 'Apa cara baca karakter ini?', 'answer': 'yu' },
    { 'type': 'essay', 'japanese': 'ヨ', 'question': 'Apa cara baca karakter ini?', 'answer': 'yo' },
    { 'type': 'essay', 'japanese': 'ラ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ra' },
    { 'type': 'essay', 'japanese': 'リ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ri' },
    { 'type': 'essay', 'japanese': 'ル', 'question': 'Apa cara baca karakter ini?', 'answer': 'ru' },
    { 'type': 'essay', 'japanese': 'レ', 'question': 'Apa cara baca karakter ini?', 'answer': 're' },
    { 'type': 'essay', 'japanese': 'ロ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ro' },
    { 'type': 'essay', 'japanese': 'ワ', 'question': 'Apa cara baca karakter ini?', 'answer': 'wa' },
    { 'type': 'essay', 'japanese': 'ヲ', 'question': 'Apa cara baca karakter ini?', 'answer': 'wo' },
    { 'type': 'essay', 'japanese': 'ン', 'question': 'Apa cara baca karakter ini?', 'answer': 'n' },
    { 'type': 'essay', 'japanese': 'ガ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ga' },
    { 'type': 'essay', 'japanese': 'パ', 'question': 'Apa cara baca karakter ini?', 'answer': 'pa' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar1 = [
    { 'type': 'essay', 'japanese': 'カメラ', 'question': 'Apa romaji dari kata ini? (Arti: Kamera)', 'answer': 'kamera' },
    { 'type': 'essay', 'japanese': 'テレビ', 'question': 'Apa romaji dari kata ini? (Arti: TV)', 'answer': 'terebi' },
    { 'type': 'essay', 'japanese': 'ホテル', 'question': 'Apa romaji dari kata ini? (Arti: Hotel)', 'answer': 'hoteru' },
    { 'type': 'essay', 'japanese': 'バス', 'question': 'Apa romaji dari kata ini? (Arti: Bus)', 'answer': 'basu' },
    { 'type': 'essay', 'japanese': 'トイレ', 'question': 'Apa romaji dari kata ini? (Arti: Toilet)', 'answer': 'toire' },
    { 'type': 'essay', 'japanese': 'ドア', 'question': 'Apa romaji dari kata ini? (Arti: Pintu)', 'answer': 'doa' },
    { 'type': 'essay', 'japanese': 'ペン', 'question': 'Apa romaji dari kata ini? (Arti: Pena)', 'answer': 'pen' },
    { 'type': 'essay', 'japanese': 'パン', 'question': 'Apa romaji dari kata ini? (Arti: Roti)', 'answer': 'pan' },
    { 'type': 'essay', 'japanese': 'ワイン', 'question': 'Apa romaji dari kata ini? (Arti: Wine)', 'answer': 'wain' },
    { 'type': 'essay', 'japanese': 'ケーキ', 'question': 'Apa romaji dari kata ini? (Arti: Kue)', 'answer': 'keeki' },
    { 'type': 'essay', 'japanese': 'コーヒー', 'question': 'Apa romaji dari kata ini? (Arti: Kopi)', 'answer': 'koohii' },
    { 'type': 'essay', 'japanese': 'タクシー', 'question': 'Apa romaji dari kata ini? (Arti: Taksi)', 'answer': 'takushii' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar1 = [
    { 'type': 'essay', 'japanese': 'レストラン', 'question': 'Apa romaji dari kata ini? (Arti: Restoran)', 'answer': 'resutoran' },
    { 'type': 'essay', 'japanese': 'スーパー', 'question': 'Apa romaji dari kata ini? (Arti: Supermarket)', 'answer': 'suupaa' },
    { 'type': 'essay', 'japanese': 'デパート', 'question': 'Apa romaji dari kata ini? (Arti: Toko Serba Ada)', 'answer': 'depaato' },
    { 'type': 'essay', 'japanese': 'コンビニ', 'question': 'Apa romaji dari kata ini? (Arti: Minimarket)', 'answer': 'konbini' },
    { 'type': 'essay', 'japanese': 'サラリーマン', 'question': 'Apa romaji dari kata ini? (Arti: Pekerja Kantor)', 'answer': 'sarariiman' },
    { 'type': 'essay', 'japanese': 'スマートフォン', 'question': 'Apa romaji dari kata ini? (Arti: Smartphone)', 'answer': 'sumaatofon' },
    { 'type': 'essay', 'japanese': 'コンピューター', 'question': 'Apa romaji dari kata ini? (Arti: Komputer)', 'answer': 'konpyuutaa' },
    { 'type': 'essay', 'japanese': 'インターネット', 'question': 'Apa romaji dari kata ini? (Arti: Internet)', 'answer': 'intaanetto' },
    { 'type': 'essay', 'japanese': 'ピザ', 'question': 'Apa romaji dari kata ini? (Arti: Pizza)', 'answer': 'piza' },
    { 'type': 'essay', 'japanese': 'サラダ', 'question': 'Apa romaji dari kata ini? (Arti: Salad)', 'answer': 'sarada' },
    { 'type': 'essay', 'japanese': 'スポーツ', 'question': 'Apa romaji dari kata ini? (Arti: Olahraga)', 'answer': 'supootsu' },
    { 'type': 'essay', 'japanese': 'ネクタイ', 'question': 'Apa romaji dari kata ini? (Arti: Dasi)', 'answer': 'nekutai' },
  ];

  static final List<Map<String, dynamic>> _u2UnitTest = [
    ..._k1Star1.sublist(0, 4),
    ..._k2Star1.sublist(0, 4),
    ..._k3Star1.sublist(0, 4),
    ..._k4Star1.sublist(0, 4),
    ..._kataWordStar1.sublist(0, 4),
    ..._loanWordStar1.sublist(0, 4),
  ];

  // ==========================================
  // --- UNIT 3: BASIC KANJI ---
  // ==========================================
  static final List<Map<String, dynamic>> _knStar1 = [
    { 'type': 'essay', 'japanese': '一', 'question': 'Apa cara baca Kanji ini? (Arti: Satu)', 'answer': 'ichi' },
    { 'type': 'essay', 'japanese': '二', 'question': 'Apa cara baca Kanji ini? (Arti: Dua)', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': '三', 'question': 'Apa cara baca Kanji ini? (Arti: Tiga)', 'answer': 'san' },
    { 'type': 'essay', 'japanese': '四', 'question': 'Apa cara baca Kanji ini? (Arti: Empat)', 'answer': 'yon' },
    { 'type': 'essay', 'japanese': '五', 'question': 'Apa cara baca Kanji ini? (Arti: Lima)', 'answer': 'go' },
    { 'type': 'essay', 'japanese': '六', 'question': 'Apa cara baca Kanji ini? (Arti: Enam)', 'answer': 'roku' },
    { 'type': 'essay', 'japanese': '七', 'question': 'Apa cara baca Kanji ini? (Arti: Tujuh)', 'answer': 'nana' },
    { 'type': 'essay', 'japanese': '八', 'question': 'Apa cara baca Kanji ini? (Arti: Delapan)', 'answer': 'hachi' },
    { 'type': 'essay', 'japanese': '九', 'question': 'Apa cara baca Kanji ini? (Arti: Sembilan)', 'answer': 'kyuu' },
    { 'type': 'essay', 'japanese': '十', 'question': 'Apa cara baca Kanji ini? (Arti: Sepuluh)', 'answer': 'juu' },
    { 'type': 'essay', 'japanese': '百', 'question': 'Apa cara baca Kanji ini? (Arti: Seratus)', 'answer': 'hyaku' },
    { 'type': 'essay', 'japanese': '千', 'question': 'Apa cara baca Kanji ini? (Arti: Seribu)', 'answer': 'sen' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar1 = [
    { 'type': 'essay', 'japanese': '日', 'question': 'Apa cara baca Kanji ini? (Arti: Matahari)', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': '月', 'question': 'Apa cara baca Kanji ini? (Arti: Bulan)', 'answer': 'tsuki' },
    { 'type': 'essay', 'japanese': '火', 'question': 'Apa cara baca Kanji ini? (Arti: Api)', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': '水', 'question': 'Apa cara baca Kanji ini? (Arti: Air)', 'answer': 'mizu' },
    { 'type': 'essay', 'japanese': '木', 'question': 'Apa cara baca Kanji ini? (Arti: Pohon)', 'answer': 'ki' },
    { 'type': 'essay', 'japanese': '金', 'question': 'Apa cara baca Kanji ini? (Arti: Logam/Uang)', 'answer': 'kane' },
    { 'type': 'essay', 'japanese': '土', 'question': 'Apa cara baca Kanji ini? (Arti: Tanah)', 'answer': 'tsuchi' },
    { 'type': 'essay', 'japanese': '山', 'question': 'Apa cara baca Kanji ini? (Arti: Gunung)', 'answer': 'yama' },
    { 'type': 'essay', 'japanese': '川', 'question': 'Apa cara baca Kanji ini? (Arti: Sungai)', 'answer': 'kawa' },
    { 'type': 'essay', 'japanese': '田', 'question': 'Apa cara baca Kanji ini? (Arti: Sawah)', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': '天', 'question': 'Apa cara baca Kanji ini? (Arti: Langit)', 'answer': 'ten' },
    { 'type': 'essay', 'japanese': '石', 'question': 'Apa cara baca Kanji ini? (Arti: Batu)', 'answer': 'ishi' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar1 = [
    { 'type': 'essay', 'japanese': '人', 'question': 'Apa cara baca Kanji ini? (Arti: Orang)', 'answer': 'hito' },
    { 'type': 'essay', 'japanese': '子', 'question': 'Apa cara baca Kanji ini? (Arti: Anak)', 'answer': 'ko' },
    { 'type': 'essay', 'japanese': '女', 'question': 'Apa cara baca Kanji ini? (Arti: Wanita)', 'answer': 'onna' },
    { 'type': 'essay', 'japanese': '男', 'question': 'Apa cara baca Kanji ini? (Arti: Pria)', 'answer': 'otoko' },
    { 'type': 'essay', 'japanese': '目', 'question': 'Apa cara baca Kanji ini? (Arti: Mata)', 'answer': 'me' },
    { 'type': 'essay', 'japanese': '口', 'question': 'Apa cara baca Kanji ini? (Arti: Mulut)', 'answer': 'kuchi' },
    { 'type': 'essay', 'japanese': '耳', 'question': 'Apa cara baca Kanji ini? (Arti: Telinga)', 'answer': 'mimi' },
    { 'type': 'essay', 'japanese': '手', 'question': 'Apa cara baca Kanji ini? (Arti: Tangan)', 'answer': 'te' },
    { 'type': 'essay', 'japanese': '足', 'question': 'Apa cara baca Kanji ini? (Arti: Kaki)', 'answer': 'ashi' },
    { 'type': 'essay', 'japanese': '力', 'question': 'Apa cara baca Kanji ini? (Arti: Kekuatan)', 'answer': 'chikara' },
    { 'type': 'essay', 'japanese': '門', 'question': 'Apa cara baca Kanji ini? (Arti: Gerbang)', 'answer': 'mon' },
    { 'type': 'essay', 'japanese': '父', 'question': 'Apa cara baca Kanji ini? (Arti: Ayah)', 'answer': 'chichi' },
  ];

  static final List<Map<String, dynamic>> _u3UnitTest = [
    ..._knStar1.sublist(0, 6),
    ..._kanjiNatureStar1.sublist(0, 6),
    ..._kanjiPeopleStar1.sublist(0, 6),
  ];

  // ==========================================
  // --- UNIT 4: BASIC GRAMMAR ---
  // ==========================================
  static final List<Map<String, dynamic>> _gpStar1 = [
    { 'type': 'essay', 'japanese': 'は', 'question': 'Apa romaji dari partikel ini? (Fungsi: Topik)', 'answer': 'wa' },
    { 'type': 'essay', 'japanese': 'を', 'question': 'Apa romaji dari partikel ini? (Fungsi: Objek)', 'answer': 'wo' },
    { 'type': 'essay', 'japanese': 'も', 'question': 'Apa romaji dari partikel ini? (Fungsi: Juga)', 'answer': 'mo' },
    { 'type': 'essay', 'japanese': 'に', 'question': 'Apa romaji dari partikel ini? (Fungsi: Lokasi/Tujuan)', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': 'へ', 'question': 'Apa romaji dari partikel ini? (Fungsi: Arah)', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'で', 'question': 'Apa romaji dari partikel ini? (Fungsi: Lokasi Kejadian)', 'answer': 'de' },
    { 'type': 'essay', 'japanese': 'と', 'question': 'Apa romaji dari partikel ini? (Fungsi: Bersama/Dan)', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'の', 'question': 'Apa romaji dari partikel ini? (Fungsi: Kepemilikan)', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'が', 'question': 'Apa romaji dari partikel ini? (Fungsi: Subjek)', 'answer': 'ga' },
    { 'type': 'essay', 'japanese': 'から', 'question': 'Apa romaji dari partikel ini? (Fungsi: Dari)', 'answer': 'kara' },
    { 'type': 'essay', 'japanese': 'まで', 'question': 'Apa romaji dari partikel ini? (Fungsi: Sampai)', 'answer': 'made' },
    { 'type': 'essay', 'japanese': 'か', 'question': 'Apa romaji dari partikel ini? (Fungsi: Pertanyaan)', 'answer': 'ka' },
  ];

  static final List<Map<String, dynamic>> _gv1Star1 = [
    { 'type': 'essay', 'japanese': 'たべる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'answer': 'taberu' },
    { 'type': 'essay', 'japanese': 'のむ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Minum)', 'answer': 'nomu' },
    { 'type': 'essay', 'japanese': 'いく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pergi)', 'answer': 'iku' },
    { 'type': 'essay', 'japanese': 'くる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Datang)', 'answer': 'kuru' },
    { 'type': 'essay', 'japanese': 'する', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melakukan)', 'answer': 'suru' },
    { 'type': 'essay', 'japanese': 'かう', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membeli)', 'answer': 'kau' },
    { 'type': 'essay', 'japanese': 'わかる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengerti)', 'answer': 'wakaru' },
    { 'type': 'essay', 'japanese': 'はなす', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berbicara)', 'answer': 'hanasu' },
    { 'type': 'essay', 'japanese': 'あります', 'question': 'Apa romaji dari kata kerja ini? (Arti: Ada - Benda Mati)', 'answer': 'arimasu' },
    { 'type': 'essay', 'japanese': 'います', 'question': 'Apa romaji dari kata kerja ini? (Arti: Ada - Benda Hidup)', 'answer': 'imasu' },
    { 'type': 'essay', 'japanese': 'はたらく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Bekerja)', 'answer': 'hataraku' },
    { 'type': 'essay', 'japanese': 'べんきょうする', 'question': 'Apa romaji dari kata kerja ini? (Arti: Belajar)', 'answer': 'benkyousuru' },
  ];

  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'japanese': 'みる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melihat)', 'answer': 'miru' },
    { 'type': 'essay', 'japanese': 'きく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mendengar)', 'answer': 'kiku' },
    { 'type': 'essay', 'japanese': 'かく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Menulis)', 'answer': 'kaku' },
    { 'type': 'essay', 'japanese': 'よむ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membaca)', 'answer': 'yomu' },
    { 'type': 'essay', 'japanese': 'およぐ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berenang)', 'answer': 'oyogu' },
    { 'type': 'essay', 'japanese': 'まつ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Menunggu)', 'answer': 'matsu' },
    { 'type': 'essay', 'japanese': 'かえる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pulang)', 'answer': 'kaeru' },
    { 'type': 'essay', 'japanese': 'とる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengambil)', 'answer': 'toru' },
    { 'type': 'essay', 'japanese': 'たつ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berdiri)', 'answer': 'tatsu' },
    { 'type': 'essay', 'japanese': 'すわる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Duduk)', 'answer': 'suwaru' },
    { 'type': 'essay', 'japanese': 'きる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengenakan)', 'answer': 'kiru' },
    { 'type': 'essay', 'japanese': 'しぬ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mati)', 'answer': 'shinu' },
  ];

  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'japanese': 'おいしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Enak)', 'answer': 'oishii' },
    { 'type': 'essay', 'japanese': 'たかい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Mahal)', 'answer': 'takai' },
    { 'type': 'essay', 'japanese': 'やすい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Murah)', 'answer': 'yasui' },
    { 'type': 'essay', 'japanese': 'おおきい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Besar)', 'answer': 'ookii' },
    { 'type': 'essay', 'japanese': 'ちいさい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Kecil)', 'answer': 'chiisai' },
    { 'type': 'essay', 'japanese': 'あたらしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Baru)', 'answer': 'atarashii' },
    { 'type': 'essay', 'japanese': 'ふるい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Lama/Tua)', 'answer': 'furui' },
    { 'type': 'essay', 'japanese': 'いい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Bagus)', 'answer': 'ii' },
    { 'type': 'essay', 'japanese': 'わるい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Buruk)', 'answer': 'warui' },
    { 'type': 'essay', 'japanese': 'むずかしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Sulit)', 'answer': 'muzukashii' },
    { 'type': 'essay', 'japanese': 'やさしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Mudah)', 'answer': 'yasashii' },
    { 'type': 'essay', 'japanese': 'とても', 'question': 'Apa romaji dari kata ini? (Arti: Sangat)', 'answer': 'totemo' },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [
    ..._gpStar1.sublist(0, 6),
    ..._gv1Star1.sublist(0, 6),
    ..._gv2Star1.sublist(0, 6),
    ..._adjStar1.sublist(0, 6),
  ];
}
