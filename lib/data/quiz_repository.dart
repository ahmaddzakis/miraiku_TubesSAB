class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars) {
    if (unit == 1) {
      if (difficulty == 'test') return _u1UnitTest;
      if (difficulty == 'hiragana_1') return _getStarSet(_h1Star1, _h1Star2, _h1Star3, currentStars);
      if (difficulty == 'hiragana_2') return _getStarSet(_h2Star1, _h2Star2, _h2Star3, currentStars);
      if (difficulty == 'hiragana_3') return _getStarSet(_h3Star1, _h3Star2, _h3Star3, currentStars);
      if (difficulty == 'hiragana_4') return _getStarSet(_h4Star1, _h4Star2, _h4Star3, currentStars);
      if (difficulty == 'greetings') return _getStarSet(_greetStar1, _greetStar2, _greetStar3, currentStars);
      if (difficulty == 'numbers') return _getStarSet(_numStar1, _numStar2, _numStar3, currentStars);
      if (difficulty == 'verbs') return _getStarSet(_verbStar1, _verbStar2, _verbStar3, currentStars);
    }
    if (unit == 2) {
      if (difficulty == 'test') return _u2UnitTest;
      if (difficulty == 'katakana_1') return _getStarSet(_k1Star1, _k1Star2, _k1Star3, currentStars);
      if (difficulty == 'katakana_2') return _getStarSet(_k2Star1, _k2Star2, _k2Star3, currentStars);
      if (difficulty == 'katakana_3') return _getStarSet(_k3Star1, _k3Star2, _k3Star3, currentStars);
      if (difficulty == 'katakana_4') return _getStarSet(_k4Star1, _k4Star2, _k4Star3, currentStars);
      if (difficulty == 'katakana_words') return _getStarSet(_kataWordStar1, _kataWordStar2, _kataWordStar3, currentStars);
      if (difficulty == 'loanwords') return _getStarSet(_loanWordStar1, _loanWordStar2, _loanWordStar3, currentStars);
    }
    if (unit == 3) {
      if (difficulty == 'test') return _u3UnitTest;
      if (difficulty == 'kanji_numbers') return _getStarSet(_knStar1, _knStar2, _knStar3, currentStars);
      if (difficulty == 'kanji_nature') return _getStarSet(_kanjiNatureStar1, _kanjiNatureStar2, _kanjiNatureStar3, currentStars);
      if (difficulty == 'kanji_people') return _getStarSet(_kanjiPeopleStar1, _kanjiPeopleStar2, _kanjiPeopleStar3, currentStars);
    }
    if (unit == 4) {
      if (difficulty == 'test') return _u4UnitTest;
      if (difficulty == 'grammar_particles') return _getStarSet(_gpStar1, _gpStar2, _gpStar3, currentStars);
      if (difficulty == 'grammar_verbs_1') return _getStarSet(_gv1Star1, _gv1Star2, _gv1Star3, currentStars);
      if (difficulty == 'grammar_verbs_2') return _getStarSet(_gv2Star1, _gv2Star2, _gv2Star3, currentStars);
      if (difficulty == 'grammar_adjectives') return _getStarSet(_adjStar1, _adjStar2, _adjStar3, currentStars);
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

  static final List<Map<String, dynamic>> _greetStar2 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "sumimasen" (すみません)?', 'japanese': 'すみません', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Terima kasih', 'romaji': ''}, {'code': 'B', 'text': 'Maaf / Permisi', 'romaji': ''}, {'code': 'C', 'text': 'Selamat tinggal', 'romaji': ''}, {'code': 'D', 'text': 'Sama-sama', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa bahasa Jepang dari "Senang bertemu denganmu"?', 'japanese': 'はじめまして', 'answer': 'hajimemashite' },
    { 'type': 'multiple_choice', 'question': 'Apa balasan yang tepat untuk "Arigatou"?', 'japanese': 'ありがとう', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Konbanwa', 'romaji': ''}, {'code': 'B', 'text': 'Oyasumi', 'romaji': ''}, {'code': 'C', 'text': 'Sayounara', 'romaji': ''}, {'code': 'D', 'text': 'Douitashimashite', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Sampai jumpa" (formal):', 'japanese': 'さようなら', 'answer': 'sayounara' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan hiragana yang benar untuk "Konnichiwa":', 'japanese': 'Konnichiwa', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'こんにちは', 'romaji': ''}, {'code': 'B', 'text': 'こにちわ', 'romaji': ''}, {'code': 'C', 'text': 'こんにちわ', 'romaji': ''}, {'code': 'D', 'text': 'こにちは', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "Itadakimasu" (いただきます)?', 'japanese': 'いただきます', 'answer': 'selamat makan' },
  ];

  static final List<Map<String, dynamic>> _greetStar3 = [
    { 'type': 'multiple_choice', 'question': 'Manakah ungkapan yang digunakan saat masuk rumah?', 'japanese': 'ただいま', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Itterasshai', 'romaji': ''}, {'code': 'B', 'text': 'Okaerinasai', 'romaji': ''}, {'code': 'C', 'text': 'Tadaima', 'romaji': ''}, {'code': 'D', 'text': 'Ojamashimasu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Lengkapi: A: Ogenki desu ka? B: Hai, ... desu.', 'japanese': 'げんき', 'answer': 'genki' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat untuk "Gomen nasai":', 'japanese': 'Gomen nasai', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ごめなさい', 'romaji': ''}, {'code': 'B', 'text': 'ごめんなさい', 'romaji': ''}, {'code': 'C', 'text': 'ごめんあさい', 'romaji': ''}, {'code': 'D', 'text': 'ごんめなさい', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk ungkapan "Sampai jumpa besok"?', 'japanese': 'またあした', 'answer': 'mata ashita' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "Osewa ni narimasu"?', 'japanese': 'おせわになります', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Terima kasih atas bantuannya', 'romaji': ''}, {'code': 'B', 'text': 'Selamat datang', 'romaji': ''}, {'code': 'C', 'text': 'Maaf mengganggu', 'romaji': ''}, {'code': 'D', 'text': 'Sampai nanti', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Ungkapan yang diucapkan saat keluar rumah:', 'japanese': 'いってきます', 'answer': 'ittekimasu' },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Satu)', 'japanese': 'いち', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Dua)', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Tiga)', 'japanese': 'さん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ichi', 'romaji': ''}, {'code': 'B', 'text': 'ni', 'romaji': ''}, {'code': 'C', 'text': 'san', 'romaji': ''}, {'code': 'D', 'text': 'yon', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Empat)', 'japanese': 'よん', 'answer': 'yon' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari angka ini? (Arti: Lima)', 'japanese': 'ご', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'yon', 'romaji': ''}, {'code': 'B', 'text': 'go', 'romaji': ''}, {'code': 'C', 'text': 'roku', 'romaji': ''}, {'code': 'D', 'text': 'nana', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari angka ini? (Arti: Sepuluh)', 'japanese': 'じゅう', 'answer': 'juu' },
  ];

  static final List<Map<String, dynamic>> _numStar2 = [
    { 'type': 'multiple_choice', 'question': 'Angka 7 dalam bahasa Jepang adalah:', 'japanese': 'なな', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'roku', 'romaji': ''}, {'code': 'B', 'text': 'hachi', 'romaji': ''}, {'code': 'C', 'text': 'kyuu', 'romaji': ''}, {'code': 'D', 'text': 'nana', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk angka 8?', 'japanese': 'はち', 'answer': 'hachi' },
    { 'type': 'multiple_choice', 'question': 'Bagaimana menyebut angka 11?', 'japanese': 'じゅういち', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'juuni', 'romaji': ''}, {'code': 'B', 'text': 'juuichi', 'romaji': ''}, {'code': 'C', 'text': 'ni-juu', 'romaji': ''}, {'code': 'D', 'text': 'ichi-juu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji untuk angka 20:', 'japanese': 'にじゅう', 'answer': 'nijuu' },
    { 'type': 'multiple_choice', 'question': 'Pilih hiragana yang benar untuk 100:', 'japanese': '100', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'はゃく', 'romaji': ''}, {'code': 'B', 'text': 'ひあく', 'romaji': ''}, {'code': 'C', 'text': 'ひゃく', 'romaji': ''}, {'code': 'D', 'text': 'びゃく', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "nana" (なな)?', 'japanese': 'なな', 'answer': 'tujuh' },
  ];

  static final List<Map<String, dynamic>> _numStar3 = [
    { 'type': 'multiple_choice', 'question': 'Berapa hasil dari: さん (3) + よん (4)?', 'japanese': 'なな', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'nana', 'romaji': ''}, {'code': 'B', 'text': 'hachi', 'romaji': ''}, {'code': 'C', 'text': 'roku', 'romaji': ''}, {'code': 'D', 'text': 'kyuu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk angka 35:', 'japanese': 'さんじゅうご', 'answer': 'sanjuugo' },
    { 'type': 'multiple_choice', 'question': 'Pilih cara baca yang benar untuk 90:', 'japanese': 'きゅうじゅう', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'kuujuu', 'romaji': ''}, {'code': 'B', 'text': 'kyujuu', 'romaji': ''}, {'code': 'C', 'text': 'kyuujuu', 'romaji': ''}, {'code': 'D', 'text': 'kuju', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk angka 1000?', 'japanese': 'せん', 'answer': 'sen' },
    { 'type': 'multiple_choice', 'question': 'Manakah angka yang paling besar?', 'japanese': 'まん', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Hyaku', 'romaji': ''}, {'code': 'B', 'text': 'Sen', 'romaji': ''}, {'code': 'C', 'text': 'Juu', 'romaji': ''}, {'code': 'D', 'text': 'Man', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan angka "lima puluh" dalam romaji:', 'japanese': 'ごじゅう', 'answer': 'gojuu' },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'japanese': 'たべる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'taberu', 'romaji': ''}, {'code': 'B', 'text': 'nomu', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'kiku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Minum)', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melihat)', 'japanese': 'みる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'yomu', 'romaji': ''}, {'code': 'B', 'text': 'kaku', 'romaji': ''}, {'code': 'C', 'text': 'miru', 'romaji': ''}, {'code': 'D', 'text': 'iku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membaca)', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pergi)', 'japanese': 'いく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kuru', 'romaji': ''}, {'code': 'B', 'text': 'iku', 'romaji': ''}, {'code': 'C', 'text': 'kaeru', 'romaji': ''}, {'code': 'D', 'text': 'neru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'japanese': 'たべる', 'answer': 'taberu' },
  ];

  static final List<Map<String, dynamic>> _verbStar2 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata "kaku" (かく)?', 'japanese': 'かく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Membaca', 'romaji': ''}, {'code': 'B', 'text': 'Menulis', 'romaji': ''}, {'code': 'C', 'text': 'Mendengar', 'romaji': ''}, {'code': 'D', 'text': 'Berjalan', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk kata kerja "Mendengar"?', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'multiple_choice', 'question': 'Pilih kata kerja yang berarti "Datang":', 'japanese': 'くる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'kuru', 'romaji': ''}, {'code': 'B', 'text': 'iku', 'romaji': ''}, {'code': 'C', 'text': 'kaeru', 'romaji': ''}, {'code': 'D', 'text': 'hashiru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata "neru" (ねる)?', 'japanese': 'ねる', 'answer': 'tidur' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Pulang"?', 'japanese': 'かえる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'kuru', 'romaji': ''}, {'code': 'B', 'text': 'iku', 'romaji': ''}, {'code': 'C', 'text': 'kaeru', 'romaji': ''}, {'code': 'D', 'text': 'hairu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk kata kerja "Membeli"?', 'japanese': 'かう', 'answer': 'kau' },
  ];

  static final List<Map<String, dynamic>> _verbStar3 = [
    { 'type': 'multiple_choice', 'question': 'Manakah pasangan yang benar?', 'japanese': 'べんきょうする', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Aruku - Berlari', 'romaji': ''}, {'code': 'B', 'text': 'Oyogu - Berjalan', 'romaji': ''}, {'code': 'C', 'text': 'Utau - Menari', 'romaji': ''}, {'code': 'D', 'text': 'Benkyou suru - Belajar', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Berbicara":', 'japanese': 'はなす', 'answer': 'hanasu' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "matsu" (まつ)?', 'japanese': 'まつ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Mati', 'romaji': ''}, {'code': 'B', 'text': 'Menunggu', 'romaji': ''}, {'code': 'C', 'text': 'Memakai', 'romaji': ''}, {'code': 'D', 'text': 'Memasak', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk kata kerja "Bekerja"?', 'japanese': 'はたらく', 'answer': 'hataraku' },
    { 'type': 'multiple_choice', 'question': 'Manakah kata kerja yang berkaitan dengan musik?', 'japanese': 'きく', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'taberu', 'romaji': ''}, {'code': 'B', 'text': 'nomu', 'romaji': ''}, {'code': 'C', 'text': 'kiku', 'romaji': ''}, {'code': 'D', 'text': 'neru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk kata kerja "Memahami/Mengerti":', 'japanese': 'わかる', 'answer': 'wakaru' },
  ];

  static final List<Map<String, dynamic>> _u1UnitTest = [
    ..._h1Star1.sublist(0, 2), ..._h1Star2.sublist(0, 1), ..._h1Star3.sublist(0, 1),
    ..._h2Star1.sublist(0, 2), ..._h2Star2.sublist(0, 1), ..._h2Star3.sublist(0, 1),
    ..._h3Star1.sublist(0, 2), ..._h3Star2.sublist(0, 1), ..._h3Star3.sublist(0, 1),
    ..._h4Star1.sublist(0, 2), ..._h4Star2.sublist(0, 1), ..._h4Star3.sublist(0, 1),
    ..._greetStar1.sublist(0, 2), ..._greetStar2.sublist(0, 1), ..._greetStar3.sublist(0, 1),
    ..._numStar1.sublist(0, 2), ..._numStar2.sublist(0, 1), ..._numStar3.sublist(0, 1),
    ..._verbStar1.sublist(0, 2), ..._verbStar2.sublist(0, 1), ..._verbStar3.sublist(0, 1),
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
  ];

  static final List<Map<String, dynamic>> _k1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk ini:', 'japanese': 'KI', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'サ', 'romaji': ''}, {'code': 'B', 'text': 'キ', 'romaji': ''}, {'code': 'C', 'text': 'チ', 'romaji': ''}, {'code': 'D', 'text': 'ケ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari kata ini: アイ', 'japanese': 'アイ', 'answer': 'ai' },
    { 'type': 'multiple_choice', 'question': 'Pilih cara baca yang tepat dari kata ini:', 'japanese': 'ガス', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'kasu', 'romaji': ''}, {'code': 'B', 'text': 'kusu', 'romaji': ''}, {'code': 'C', 'text': 'gasu', 'romaji': ''}, {'code': 'D', 'text': 'gesu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari: カキ', 'japanese': 'カキ', 'answer': 'kaki' },
    { 'type': 'multiple_choice', 'question': 'Manakah Katakana untuk ini?', 'japanese': 'SU', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'ヌ', 'romaji': ''}, {'code': 'B', 'text': 'マ', 'romaji': ''}, {'code': 'C', 'text': 'フ', 'romaji': ''}, {'code': 'D', 'text': 'ス', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: キカ', 'japanese': 'キカ', 'answer': 'kika' },
  ];

  static final List<Map<String, dynamic>> _k1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'アイス', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Es / Es Krim', 'romaji': ''}, {'code': 'B', 'text': 'Mata', 'romaji': ''}, {'code': 'C', 'text': 'Kursi', 'romaji': ''}, {'code': 'D', 'text': 'Buku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: スキー (ii)', 'japanese': 'スキー', 'answer': 'sukii' },
    { 'type': 'multiple_choice', 'question': 'Bagaimana penulisan Katakana-nya?', 'japanese': 'Kasa (Payung)', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'カセ', 'romaji': ''}, {'code': 'B', 'text': 'カサ', 'romaji': ''}, {'code': 'C', 'text': 'ケサ', 'romaji': ''}, {'code': 'D', 'text': 'クサ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata: ケサ (Kesa)?', 'japanese': 'ケサ', 'answer': 'pagi ini' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang benar untuk kata ini:', 'japanese': 'Cake / Keeki', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ゲーキ', 'romaji': ''}, {'code': 'B', 'text': 'ケエキ', 'romaji': ''}, {'code': 'C', 'text': 'ケーキ', 'romaji': ''}, {'code': 'D', 'text': 'ケッキ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: エコ', 'japanese': 'エコ', 'answer': 'eko' },
  ];

  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'japanese': 'タ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': 'チ', 'question': 'Apa cara baca karakter ini?', 'answer': 'chi' },
    { 'type': 'essay', 'japanese': 'ツ', 'question': 'Apa cara baca karakter ini?', 'answer': 'tsu' },
    { 'type': 'essay', 'japanese': 'テ', 'question': 'Apa cara baca karakter ini?', 'answer': 'te' },
    { 'type': 'essay', 'japanese': 'ト', 'question': 'Apa cara baca karakter ini?', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'ナ', 'question': 'Apa cara baca karakter ini?', 'answer': 'na' },
  ];

  static final List<Map<String, dynamic>> _k2Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk:', 'japanese': 'NI', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ミ', 'romaji': ''}, {'code': 'B', 'text': 'ヌ', 'romaji': ''}, {'code': 'C', 'text': 'ニ', 'romaji': ''}, {'code': 'D', 'text': 'ネ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari gabungan: ナニ', 'japanese': 'ナニ', 'answer': 'nani' },
    { 'type': 'multiple_choice', 'question': 'Apa cara baca kata ini? (Arti: Daging)', 'japanese': 'ニク', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'niku', 'romaji': ''}, {'code': 'B', 'text': 'naka', 'romaji': ''}, {'code': 'C', 'text': 'neko', 'romaji': ''}, {'code': 'D', 'text': 'noko', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: ツタ', 'japanese': 'ツタ', 'answer': 'tsuta' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang tepat untuk:', 'japanese': 'Teto', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'タト', 'romaji': ''}, {'code': 'B', 'text': 'テト', 'romaji': ''}, {'code': 'C', 'text': 'チト', 'romaji': ''}, {'code': 'D', 'text': 'ツト', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji dari: ヌネ', 'japanese': 'ヌネ', 'answer': 'nune' },
  ];

  static final List<Map<String, dynamic>> _k2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang benar dari:', 'japanese': 'Nekutai (Dasi)', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ネクタイ', 'romaji': ''}, {'code': 'B', 'text': 'ヌクタイ', 'romaji': ''}, {'code': 'C', 'text': 'ニクタイ', 'romaji': ''}, {'code': 'D', 'text': 'ネケタイ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti bahasa Indonesia dari "テニス" (tenisu)?', 'japanese': 'テニス', 'answer': 'tenis' },
    { 'type': 'multiple_choice', 'question': 'Pilih cara baca yang tepat untuk kata ini:', 'japanese': 'ツール', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'tsuru', 'romaji': ''}, {'code': 'B', 'text': 'tsure', 'romaji': ''}, {'code': 'C', 'text': 'tsuuru', 'romaji': ''}, {'code': 'D', 'text': 'shiru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk negara: カナダ', 'japanese': 'カナダ', 'answer': 'kanada' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'タクシー', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Bus', 'romaji': ''}, {'code': 'B', 'text': 'Taksi', 'romaji': ''}, {'code': 'C', 'text': 'Motor', 'romaji': ''}, {'code': 'D', 'text': 'Sepeda', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: ナタ (Arti: Parang)', 'japanese': 'ナタ', 'answer': 'nata' },
  ];

  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'japanese': 'ノ', 'question': 'Apa cara baca karakter ini?', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'ハ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ha' },
    { 'type': 'essay', 'japanese': 'ヒ', 'question': 'Apa cara baca karakter ini?', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': 'フ', 'question': 'Apa cara baca karakter ini?', 'answer': 'fu' },
    { 'type': 'essay', 'japanese': 'ヘ', 'question': 'Apa cara baca karakter ini?', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'ホ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ho' },
  ];

  static final List<Map<String, dynamic>> _k3Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk:', 'japanese': 'MA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'マ', 'romaji': ''}, {'code': 'B', 'text': 'ア', 'romaji': ''}, {'code': 'C', 'text': 'ム', 'romaji': ''}, {'code': 'D', 'text': 'メ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari: ハム (Daging)', 'japanese': 'ハム', 'answer': 'hamu' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang berarti "Memo"?', 'japanese': 'Memo', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'メメ', 'romaji': ''}, {'code': 'B', 'text': 'メモ', 'romaji': ''}, {'code': 'C', 'text': 'マモ', 'romaji': ''}, {'code': 'D', 'text': 'ムモ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ヒフ (Kulit)', 'japanese': 'ヒフ', 'answer': 'hifu' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana untuk:', 'japanese': 'YA', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'マ', 'romaji': ''}, {'code': 'B', 'text': 'ユ', 'romaji': ''}, {'code': 'C', 'text': 'セ', 'romaji': ''}, {'code': 'D', 'text': 'ヤ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji dari: ホヘ', 'japanese': 'ホヘ', 'answer': 'hohe' },
  ];

  static final List<Map<String, dynamic>> _k3Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'コーヒー', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Teh', 'romaji': ''}, {'code': 'B', 'text': 'Susu', 'romaji': ''}, {'code': 'C', 'text': 'Kopi', 'romaji': ''}, {'code': 'D', 'text': 'Air', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: ホテル', 'japanese': 'ホテル', 'answer': 'hoteru' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan Katakana yang benar untuk kata ini:', 'japanese': 'Movie', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ムービー', 'romaji': ''}, {'code': 'B', 'text': 'ムビ', 'romaji': ''}, {'code': 'C', 'text': 'モオビ', 'romaji': ''}, {'code': 'D', 'text': 'ヌービー', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk merk: ヤマハ', 'japanese': 'ヤマハ', 'answer': 'yamaha' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang berarti "Help"?', 'japanese': 'Help', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ハルプ', 'romaji': ''}, {'code': 'B', 'text': 'ヘルプ', 'romaji': ''}, {'code': 'C', 'text': 'ベルプ', 'romaji': ''}, {'code': 'D', 'text': 'ヘルフ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji untuk: ハハ (Ibu)', 'japanese': 'ハハ', 'answer': 'haha' },
  ];

  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'japanese': 'ユ', 'question': 'Apa cara baca karakter ini?', 'answer': 'yu' },
    { 'type': 'essay', 'japanese': 'ヨ', 'question': 'Apa cara baca karakter ini?', 'answer': 'yo' },
    { 'type': 'essay', 'japanese': 'ラ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ra' },
    { 'type': 'essay', 'japanese': 'リ', 'question': 'Apa cara baca karakter ini?', 'answer': 'ri' },
    { 'type': 'essay', 'japanese': 'ル', 'question': 'Apa cara baca karakter ini?', 'answer': 'ru' },
    { 'type': 'essay', 'japanese': 'レ', 'question': 'Apa cara baca karakter ini?', 'answer': 're' },
  ];

  static final List<Map<String, dynamic>> _k4Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk ini:', 'japanese': 'WA', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ウ', 'romaji': ''}, {'code': 'B', 'text': 'ク', 'romaji': ''}, {'code': 'C', 'text': 'ワ', 'romaji': ''}, {'code': 'D', 'text': 'フ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ラク (Rileks)', 'japanese': 'ラク', 'answer': 'raku' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang dibaca "Rain"?', 'japanese': 'Rain', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ラエン', 'romaji': ''}, {'code': 'B', 'text': 'ライン', 'romaji': ''}, {'code': 'C', 'text': 'ライソ', 'romaji': ''}, {'code': 'D', 'text': 'ヲイン', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: ヨル (Malam)', 'japanese': 'ヨル', 'answer': 'yoru' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk:', 'japanese': 'RO', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'コ', 'romaji': ''}, {'code': 'B', 'text': 'ヨ', 'romaji': ''}, {'code': 'C', 'text': 'ユ', 'romaji': ''}, {'code': 'D', 'text': 'ロ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ワヲン', 'japanese': 'ワヲン', 'answer': 'wawon' },
  ];

  static final List<Map<String, dynamic>> _k4Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'プラス', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Minus', 'romaji': ''}, {'code': 'B', 'text': 'Kali', 'romaji': ''}, {'code': 'C', 'text': 'Bagi', 'romaji': ''}, {'code': 'D', 'text': 'Plus / Tambah', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: ガラス (Gelas/Kaca)', 'japanese': 'ガラス', 'answer': 'garasu' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan "Radio" yang benar?', 'japanese': 'Radio', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ラジョ', 'romaji': ''}, {'code': 'B', 'text': 'ラジオ', 'romaji': ''}, {'code': 'C', 'text': 'ラジュ', 'romaji': ''}, {'code': 'D', 'text': 'ラヂオ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk robot legendaris ini: ガンダム', 'japanese': 'ガンダム', 'answer': 'gandamu' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'ページ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Halaman', 'romaji': ''}, {'code': 'B', 'text': 'Buku', 'romaji': ''}, {'code': 'C', 'text': 'Kertas', 'romaji': ''}, {'code': 'D', 'text': 'Pensil', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji untuk: パーティ', 'japanese': 'パーティ', 'answer': 'paati' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar1 = [
    { 'type': 'essay', 'japanese': 'カメラ', 'question': 'Apa romaji dari kata ini? (Arti: Kamera)', 'answer': 'kamera' },
    { 'type': 'essay', 'japanese': 'テレビ', 'question': 'Apa romaji dari kata ini? (Arti: TV)', 'answer': 'terebi' },
    { 'type': 'essay', 'japanese': 'ホテル', 'question': 'Apa romaji dari kata ini? (Arti: Hotel)', 'answer': 'hoteru' },
    { 'type': 'essay', 'japanese': 'バス', 'question': 'Apa romaji dari kata ini? (Arti: Bus)', 'answer': 'basu' },
    { 'type': 'essay', 'japanese': 'トイレ', 'question': 'Apa romaji dari kata ini? (Arti: Toilet)', 'answer': 'toire' },
    { 'type': 'essay', 'japanese': 'ドア', 'question': 'Apa romaji dari kata ini? (Arti: Pintu)', 'answer': 'doa' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk kata ini:', 'japanese': 'Wine', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ウイン', 'romaji': ''}, {'code': 'B', 'text': 'ワイン', 'romaji': ''}, {'code': 'C', 'text': 'ワン', 'romaji': ''}, {'code': 'D', 'text': 'ラチン', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ペン (Pena)', 'japanese': 'ペン', 'answer': 'pen' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang berarti "Kue (Cake)"?', 'japanese': 'Keeki', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ケキ', 'romaji': ''}, {'code': 'B', 'text': 'ゲエキ', 'romaji': ''}, {'code': 'C', 'text': 'ケーキ', 'romaji': ''}, {'code': 'D', 'text': 'ケッキ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: パン (Roti)', 'japanese': 'パン', 'answer': 'pan' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang benar untuk kata ini:', 'japanese': 'Taxi', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'ヲクシー', 'romaji': ''}, {'code': 'B', 'text': 'タクツ', 'romaji': ''}, {'code': 'C', 'text': 'タキシ', 'romaji': ''}, {'code': 'D', 'text': 'タクシー', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ノート (Buku Catatan)', 'japanese': 'ノート', 'answer': 'nooto' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'パソコン', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Televisi', 'romaji': ''}, {'code': 'B', 'text': 'Radio', 'romaji': ''}, {'code': 'C', 'text': 'Smartphone', 'romaji': ''}, {'code': 'D', 'text': 'PC / Laptop', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: カレンダー (Arti: Kalender)', 'japanese': 'カレンダー', 'answer': 'karendaa' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti kata berikut ini?', 'japanese': 'Department Store', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'スーパー', 'romaji': ''}, {'code': 'B', 'text': 'デパート', 'romaji': ''}, {'code': 'C', 'text': 'コンビニ', 'romaji': ''}, {'code': 'D', 'text': 'テパート', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk: ビデオ (Video)', 'japanese': 'ビデオ', 'answer': 'bideo' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan "Sofa" yang tepat:', 'japanese': 'Sofa', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ソファー', 'romaji': ''}, {'code': 'B', 'text': 'ンファー', 'romaji': ''}, {'code': 'C', 'text': 'シファー', 'romaji': ''}, {'code': 'D', 'text': 'ゾファ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji untuk: エアコン (AC)', 'japanese': 'エアコン', 'answer': 'eakon' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar1 = [
    { 'type': 'essay', 'japanese': 'レストラン', 'question': 'Apa romaji dari kata ini? (Arti: Restoran)', 'answer': 'resutoran' },
    { 'type': 'essay', 'japanese': 'スーパー', 'question': 'Apa romaji dari kata ini? (Arti: Supermarket)', 'answer': 'suupaa' },
    { 'type': 'essay', 'japanese': 'デパート', 'question': 'Apa romaji dari kata ini? (Arti: Toko Serba Ada)', 'answer': 'depaato' },
    { 'type': 'essay', 'japanese': 'コンビニ', 'question': 'Apa romaji dari kata ini? (Arti: Minimarket)', 'answer': 'konbini' },
    { 'type': 'essay', 'japanese': 'サラリーマン', 'question': 'Apa romaji dari kata ini? (Arti: Pekerja Kantor)', 'answer': 'sarariiman' },
    { 'type': 'essay', 'japanese': 'スマートフォン', 'question': 'Apa romaji dari kata ini? (Arti: Smartphone)', 'answer': 'sumaatofon' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk kata ini:', 'japanese': 'Internet', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'インタン', 'romaji': ''}, {'code': 'B', 'text': 'インターネット', 'romaji': ''}, {'code': 'C', 'text': 'インタネット', 'romaji': ''}, {'code': 'D', 'text': 'インラネット', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: ピザ (Pizza)', 'japanese': 'ピザ', 'answer': 'piza' },
    { 'type': 'multiple_choice', 'question': 'Manakah Katakana yang dibaca "Sarada" (Salad)?', 'japanese': 'Sarada', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'サラダ', 'romaji': ''}, {'code': 'B', 'text': 'サラタ', 'romaji': ''}, {'code': 'C', 'text': 'ゼラダ', 'romaji': ''}, {'code': 'D', 'text': 'サロタ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: スポーツ (Olahraga)', 'japanese': 'スポーツ', 'answer': 'supootsu' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat dari kata berikut:', 'japanese': 'Computer', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'コンピュタ', 'romaji': ''}, {'code': 'B', 'text': 'コンピュウタ', 'romaji': ''}, {'code': 'C', 'text': 'コンピューター', 'romaji': ''}, {'code': 'D', 'text': 'コッピューター', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk: ネクタイ (Dasi)', 'japanese': 'ネクタイ', 'answer': 'nekutai' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'サラリーマン', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Karyawan Swasta', 'romaji': ''}, {'code': 'B', 'text': 'Pelajar', 'romaji': ''}, {'code': 'C', 'text': 'Guru', 'romaji': ''}, {'code': 'D', 'text': 'Dokter', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: チョコレート (Cokelat)', 'japanese': 'チョコレート', 'answer': 'chokoreeto' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan Katakana yang berarti kata berikut ini?', 'japanese': 'Christmas', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'クリマッス', 'romaji': ''}, {'code': 'B', 'text': 'クリスマス', 'romaji': ''}, {'code': 'C', 'text': 'クルツマス', 'romaji': ''}, {'code': 'D', 'text': 'クリシマス', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk: ハンバーガー (Hamburger)', 'japanese': 'ハンバーガー', 'answer': 'hanbaagaa' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat untuk ini:', 'japanese': 'Ice Cream', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'マイスクリーム', 'romaji': ''}, {'code': 'B', 'text': 'アインクリーム', 'romaji': ''}, {'code': 'C', 'text': 'アスクルム', 'romaji': ''}, {'code': 'D', 'text': 'アイスクリーム', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tulis romaji untuk: プレゼント (Hadiah)', 'japanese': 'プレゼント', 'answer': 'purezento' },
  ];

  static final List<Map<String, dynamic>> _u2UnitTest = [
    ..._k1Star1.sublist(0, 2), ..._k1Star2.sublist(0, 1), ..._k1Star3.sublist(0, 1),
    ..._k2Star1.sublist(0, 2), ..._k2Star2.sublist(0, 1), ..._k2Star3.sublist(0, 1),
    ..._k3Star1.sublist(0, 2), ..._k3Star2.sublist(0, 1), ..._k3Star3.sublist(0, 1),
    ..._k4Star1.sublist(0, 2), ..._k4Star2.sublist(0, 1), ..._k4Star3.sublist(0, 1),
    ..._kataWordStar1.sublist(0, 2), ..._kataWordStar2.sublist(0, 1), ..._kataWordStar3.sublist(0, 1),
    ..._loanWordStar1.sublist(0, 2), ..._loanWordStar2.sublist(0, 1), ..._loanWordStar3.sublist(0, 1),
  ];

  // ==========================================
  // --- UNIT 3: BASIC KANJI ---
  // ==========================================

  // --- KANJI NUMBERS ---
  static final List<Map<String, dynamic>> _knStar1 = [
    { 'type': 'essay', 'japanese': '一', 'question': 'Apa cara baca Kanji ini? (Arti: Satu)', 'answer': 'ichi' },
    { 'type': 'essay', 'japanese': '二', 'question': 'Apa cara baca Kanji ini? (Arti: Dua)', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': '三', 'question': 'Apa cara baca Kanji ini? (Arti: Tiga)', 'answer': 'san' },
    { 'type': 'essay', 'japanese': '四', 'question': 'Apa cara baca Kanji ini? (Arti: Empat)', 'answer': 'yon' },
    { 'type': 'essay', 'japanese': '五', 'question': 'Apa cara baca Kanji ini? (Arti: Lima)', 'answer': 'go' },
    { 'type': 'essay', 'japanese': '六', 'question': 'Apa cara baca Kanji ini? (Arti: Enam)', 'answer': 'roku' },
  ];

  static final List<Map<String, dynamic>> _knStar2 = [
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Sembilan"?', 'japanese': 'Sembilan', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '九', 'romaji': ''}, {'code': 'B', 'text': '丸', 'romaji': ''}, {'code': 'C', 'text': '力', 'romaji': ''}, {'code': 'D', 'text': '刀', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '七', 'question': 'Apa cara baca Kanji ini? (Arti: Tujuh)', 'answer': 'nana' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Seribu" (Sen):', 'japanese': 'Seribu', 'correctIndex': 2, 'options': [{'code': 'A', 'text': '十', 'romaji': ''}, {'code': 'B', 'text': '土', 'romaji': ''}, {'code': 'C', 'text': '千', 'romaji': ''}, {'code': 'D', 'text': 'チ', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '八', 'question': 'Apa cara baca Kanji ini? (Arti: Delapan)', 'answer': 'hachi' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Delapan"?', 'japanese': 'Delapan', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '人', 'romaji': ''}, {'code': 'B', 'text': '八', 'romaji': ''}, {'code': 'C', 'text': '入', 'romaji': ''}, {'code': 'D', 'text': 'ハ', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '百', 'question': 'Apa cara baca Kanji ini? (Arti: Seratus)', 'answer': 'hyaku' },
  ];

  static final List<Map<String, dynamic>> _knStar3 = [
    { 'type': 'multiple_choice', 'question': 'Berapakah hasil dari: 十 + 五?', 'japanese': '十 + 五', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '10', 'romaji': ''}, {'code': 'B', 'text': '15', 'romaji': ''}, {'code': 'C', 'text': '50', 'romaji': ''}, {'code': 'D', 'text': '105', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jukugo ini: 三百', 'japanese': '三百', 'answer': 'sanbyaku' },
    { 'type': 'multiple_choice', 'question': 'Tuliskan "8000" dalam Kanji:', 'japanese': '8000', 'correctIndex': 3, 'options': [{'code': 'A', 'text': '八百', 'romaji': ''}, {'code': 'B', 'text': '八十', 'romaji': ''}, {'code': 'C', 'text': '千八', 'romaji': ''}, {'code': 'D', 'text': '八千', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa cara baca Kanji untuk "Sepuluh Ribu"? (万)', 'japanese': '万', 'answer': 'man' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "30"?', 'japanese': '30', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '三十', 'romaji': ''}, {'code': 'B', 'text': '十三', 'romaji': ''}, {'code': 'C', 'text': '三', 'romaji': ''}, {'code': 'D', 'text': '十', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk: 四百', 'japanese': '四百', 'answer': 'yonhyaku' },
  ];

  // --- KANJI NATURE ---
  static final List<Map<String, dynamic>> _kanjiNatureStar1 = [
    { 'type': 'essay', 'japanese': '日', 'question': 'Apa cara baca Kanji ini? (Arti: Matahari)', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': '月', 'question': 'Apa cara baca Kanji ini? (Arti: Bulan)', 'answer': 'tsuki' },
    { 'type': 'essay', 'japanese': '火', 'question': 'Apa cara baca Kanji ini? (Arti: Api)', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': '水', 'question': 'Apa cara baca Kanji ini? (Arti: Air)', 'answer': 'mizu' },
    { 'type': 'essay', 'japanese': '木', 'question': 'Apa cara baca Kanji ini? (Arti: Pohon)', 'answer': 'ki' },
    { 'type': 'essay', 'japanese': '金', 'question': 'Apa cara baca Kanji ini? (Arti: Emas/Uang)', 'answer': 'kane' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Tanah" (Tsuchi):', 'japanese': 'Tanah', 'correctIndex': 2, 'options': [{'code': 'A', 'text': '士', 'romaji': ''}, {'code': 'B', 'text': '干', 'romaji': ''}, {'code': 'C', 'text': '土', 'romaji': ''}, {'code': 'D', 'text': '千', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '山', 'question': 'Apa cara baca Kanji ini? (Arti: Gunung)', 'answer': 'yama' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Matahari"?', 'japanese': 'Matahari', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '口', 'romaji': ''}, {'code': 'D', 'text': '田', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '川', 'question': 'Apa cara baca Kanji ini? (Arti: Sungai)', 'answer': 'kawa' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Air" (Mizu):', 'japanese': 'Air', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '木', 'romaji': ''}, {'code': 'B', 'text': '水', 'romaji': ''}, {'code': 'C', 'text': '氷', 'romaji': ''}, {'code': 'D', 'text': '火', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '石', 'question': 'Apa cara baca Kanji ini? (Arti: Batu)', 'answer': 'ishi' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "火山" (Kazan)?', 'japanese': '火山', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Air terjun', 'romaji': ''}, {'code': 'B', 'text': 'Gunung Api', 'romaji': ''}, {'code': 'C', 'text': 'Tanah liat', 'romaji': ''}, {'code': 'D', 'text': 'Kebakaran', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jukugo ini: 水田', 'japanese': '水田', 'answer': 'suiden' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "土木" (Doboku)?', 'japanese': '土木', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Pohon besar', 'romaji': ''}, {'code': 'B', 'text': 'Hutan rimba', 'romaji': ''}, {'code': 'C', 'text': 'Pekerjaan sipil', 'romaji': ''}, {'code': 'D', 'text': 'Tanah subur', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jukugo ini: 金山', 'japanese': '金山', 'answer': 'kanayama' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Hari Senin" (Getsuyoubi):', 'japanese': 'Getsuyoubi', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '月曜日', 'romaji': ''}, {'code': 'B', 'text': '日曜日', 'romaji': ''}, {'code': 'C', 'text': '火曜日', 'romaji': ''}, {'code': 'D', 'text': '水曜日', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari Jukugo "Air Minum": 水道', 'japanese': '水道', 'answer': 'suidou' },
  ];

  // --- KANJI PEOPLE ---
  static final List<Map<String, dynamic>> _kanjiPeopleStar1 = [
    { 'type': 'essay', 'japanese': '人', 'question': 'Apa cara baca Kanji ini? (Arti: Orang)', 'answer': 'hito' },
    { 'type': 'essay', 'japanese': '子', 'question': 'Apa cara baca Kanji ini? (Arti: Anak)', 'answer': 'ko' },
    { 'type': 'essay', 'japanese': '女', 'question': 'Apa cara baca Kanji ini? (Arti: Wanita)', 'answer': 'onna' },
    { 'type': 'essay', 'japanese': '男', 'question': 'Apa cara baca Kanji ini? (Arti: Pria)', 'answer': 'otoko' },
    { 'type': 'essay', 'japanese': '目', 'question': 'Apa cara baca Kanji ini? (Arti: Mata)', 'answer': 'me' },
    { 'type': 'essay', 'japanese': '口', 'question': 'Apa cara baca Kanji ini? (Arti: Mulut)', 'answer': 'kuchi' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Orang" (Hito):', 'japanese': 'Orang', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '人', 'romaji': ''}, {'code': 'B', 'text': '入', 'romaji': ''}, {'code': 'C', 'text': '八', 'romaji': ''}, {'code': 'D', 'text': '力', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '耳', 'question': 'Apa cara baca Kanji ini? (Arti: Telinga)', 'answer': 'mimi' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Mata" (Me)?', 'japanese': 'Mata', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '口', 'romaji': ''}, {'code': 'D', 'text': '四', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '手', 'question': 'Apa cara baca Kanji ini? (Arti: Tangan)', 'answer': 'te' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Mulut" (Kuchi):', 'japanese': 'Mulut', 'correctIndex': 3, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '回', 'romaji': ''}, {'code': 'D', 'text': '口', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '父', 'question': 'Apa cara baca Kanji ini? (Arti: Ayah)', 'answer': 'chichi' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa romaji dari "日本人" (Orang Jepang)?', 'japanese': '日本人', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Nihonhito', 'romaji': ''}, {'code': 'B', 'text': 'Nipponhito', 'romaji': ''}, {'code': 'C', 'text': 'Nihonjin', 'romaji': ''}, {'code': 'D', 'text': 'Nihon-nin', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jukugo ini: 女子', 'japanese': '女子', 'answer': 'joshi' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari Jukugo "人口" (Jinkou)?', 'japanese': '人口', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Populasi', 'romaji': ''}, {'code': 'B', 'text': 'Pintu masuk', 'romaji': ''}, {'code': 'C', 'text': 'Orang besar', 'romaji': ''}, {'code': 'D', 'text': 'Mulut manis', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk Jukugo ini: 男子', 'japanese': '男子', 'answer': 'danshi' },
    { 'type': 'multiple_choice', 'question': 'Manakah Jukugo yang berarti "Ayah dan Ibu"?', 'japanese': 'Ayah & Ibu', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '男女', 'romaji': ''}, {'code': 'B', 'text': '父母', 'romaji': ''}, {'code': 'C', 'text': '門口', 'romaji': ''}, {'code': 'D', 'text': '大小', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari: 下手 (Payah/Tidak ahli)', 'japanese': '下手', 'answer': 'heta' },
  ];

  static final List<Map<String, dynamic>> _u3UnitTest = [
    ..._knStar1.sublist(0, 2), ..._knStar2.sublist(0, 2), ..._knStar3.sublist(0, 2),
    ..._kanjiNatureStar1.sublist(0, 2), ..._kanjiNatureStar2.sublist(0, 2), ..._kanjiNatureStar3.sublist(0, 2),
    ..._kanjiPeopleStar1.sublist(0, 2), ..._kanjiPeopleStar2.sublist(0, 2), ..._kanjiPeopleStar3.sublist(0, 2),
  ];

  // ==========================================
  // --- UNIT 4: BASIC GRAMMAR ---
  // ==========================================

  // --- GRAMMAR PARTICLES ---
  static final List<Map<String, dynamic>> _gpStar1 = [
    { 'type': 'essay', 'japanese': 'は', 'question': 'Apa romaji dari partikel ini? (Fungsi: Topik)', 'answer': 'wa' },
    { 'type': 'essay', 'japanese': 'を', 'question': 'Apa romaji dari partikel ini? (Fungsi: Objek)', 'answer': 'wo' },
    { 'type': 'essay', 'japanese': 'も', 'question': 'Apa romaji dari partikel ini? (Fungsi: Juga)', 'answer': 'mo' },
    { 'type': 'essay', 'japanese': 'に', 'question': 'Apa romaji dari partikel ini? (Fungsi: Lokasi/Tujuan)', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': 'へ', 'question': 'Apa romaji dari partikel ini? (Fungsi: Arah)', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'で', 'question': 'Apa romaji dari partikel ini? (Fungsi: Lokasi Kejadian)', 'answer': 'de' },
  ];

  static final List<Map<String, dynamic>> _gpStar2 = [
    { 'type': 'essay', 'japanese': 'と', 'question': 'Apa romaji dari partikel ini? (Fungsi: Bersama/Dan)', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'の', 'question': 'Apa romaji dari partikel ini? (Fungsi: Kepemilikan)', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'が', 'question': 'Apa romaji dari partikel ini? (Fungsi: Subjek)', 'answer': 'ga' },
    { 'type': 'essay', 'japanese': 'から', 'question': 'Apa romaji dari partikel ini? (Fungsi: Dari)', 'answer': 'kara' },
    { 'type': 'essay', 'japanese': 'まで', 'question': 'Apa romaji dari partikel ini? (Fungsi: Sampai)', 'answer': 'made' },
    { 'type': 'essay', 'japanese': 'か', 'question': 'Apa romaji dari partikel ini? (Fungsi: Pertanyaan)', 'answer': 'ka' },
  ];

  static final List<Map<String, dynamic>> _gpStar3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih partikel yang tepat: Watashi ... Gohan wo tabemasu.', 'japanese': 'は', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'は (wa)', 'romaji': ''}, {'code': 'B', 'text': 'を (wo)', 'romaji': ''}, {'code': 'C', 'text': 'に (ni)', 'romaji': ''}, {'code': 'D', 'text': 'で (de)', 'romaji': ''}] },
    { 'type': 'multiple_choice', 'question': 'Pilih partikel untuk menunjukkan arah: Gakkou ... ikimasu.', 'japanese': 'へ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'は', 'romaji': ''}, {'code': 'B', 'text': 'を', 'romaji': ''}, {'code': 'C', 'text': 'へ', 'romaji': ''}, {'code': 'D', 'text': 'の', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan partikel yang berarti "Milik" (Possessive):', 'japanese': 'の', 'answer': 'no' },
    { 'type': 'multiple_choice', 'question': 'Partikel untuk "di (lokasi kejadian)": Resutoran ... tabemasu.', 'japanese': 'で', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'に', 'romaji': ''}, {'code': 'B', 'text': 'へ', 'romaji': ''}, {'code': 'C', 'text': 'を', 'romaji': ''}, {'code': 'D', 'text': 'で', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Partikel penanda objek adalah:', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'multiple_choice', 'question': 'Partikel "mo" berarti:', 'japanese': 'も', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Hanya', 'romaji': ''}, {'code': 'B', 'text': 'Juga', 'romaji': ''}, {'code': 'C', 'text': 'Dan', 'romaji': ''}, {'code': 'D', 'text': 'Dari', 'romaji': ''}] },
  ];

  // --- GRAMMAR VERBS 1 ---
  static final List<Map<String, dynamic>> _gv1Star1 = [
    { 'type': 'essay', 'japanese': 'たべる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Makan)', 'answer': 'taberu' },
    { 'type': 'essay', 'japanese': 'のむ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Minum)', 'answer': 'nomu' },
    { 'type': 'essay', 'japanese': 'いく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pergi)', 'answer': 'iku' },
    { 'type': 'essay', 'japanese': 'くる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Datang)', 'answer': 'kuru' },
    { 'type': 'essay', 'japanese': 'する', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melakukan)', 'answer': 'suru' },
    { 'type': 'essay', 'japanese': 'かう', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membeli)', 'answer': 'kau' },
  ];

  static final List<Map<String, dynamic>> _gv1Star2 = [
    { 'type': 'essay', 'japanese': 'わかる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengerti)', 'answer': 'wakaru' },
    { 'type': 'essay', 'japanese': 'はなす', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berbicara)', 'answer': 'hanasu' },
    { 'type': 'essay', 'japanese': 'あります', 'question': 'Apa romaji dari kata kerja ini? (Arti: Ada - Benda Mati)', 'answer': 'arimasu' },
    { 'type': 'essay', 'japanese': 'います', 'question': 'Apa romaji dari kata kerja ini? (Arti: Ada - Benda Hidup)', 'answer': 'imasu' },
    { 'type': 'essay', 'japanese': 'はたらく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Bekerja)', 'answer': 'hataraku' },
    { 'type': 'essay', 'japanese': 'べんきょうする', 'question': 'Apa romaji dari kata kerja ini? (Arti: Belajar)', 'answer': 'benkyousuru' },
  ];

  static final List<Map<String, dynamic>> _gv1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Bentuk sopan (masu) dari "taberu" adalah:', 'japanese': 'たべます', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'tabemasu', 'romaji': ''}, {'code': 'B', 'text': 'taberimasu', 'romaji': ''}, {'code': 'C', 'text': 'tabemashita', 'romaji': ''}, {'code': 'D', 'text': 'tabenai', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "nomimasu"?', 'japanese': 'のみます', 'answer': 'minum' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Belajar"?', 'japanese': 'べんきょうする', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'hataraku', 'romaji': ''}, {'code': 'B', 'text': 'suru', 'romaji': ''}, {'code': 'C', 'text': 'benkyousuru', 'romaji': ''}, {'code': 'D', 'text': 'kuru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari "Ada" untuk orang?', 'japanese': 'います', 'answer': 'imasu' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "ikimasu" (pergi) adalah:', 'japanese': 'きます', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kaerimasu', 'romaji': ''}, {'code': 'B', 'text': 'kimasu', 'romaji': ''}, {'code': 'C', 'text': 'shimasu', 'romaji': ''}, {'code': 'D', 'text': 'arimasu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Membeli":', 'japanese': 'かう', 'answer': 'kau' },
  ];

  // --- GRAMMAR VERBS 2 ---
  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'japanese': 'みる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Melihat)', 'answer': 'miru' },
    { 'type': 'essay', 'japanese': 'きく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mendengar)', 'answer': 'kiku' },
    { 'type': 'essay', 'japanese': 'かく', 'question': 'Apa romaji dari kata kerja ini? (Arti: Menulis)', 'answer': 'kaku' },
    { 'type': 'essay', 'japanese': 'よむ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Membaca)', 'answer': 'yomu' },
    { 'type': 'essay', 'japanese': 'およぐ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berenang)', 'answer': 'oyogu' },
    { 'type': 'essay', 'japanese': 'まつ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Menunggu)', 'answer': 'matsu' },
  ];

  static final List<Map<String, dynamic>> _gv2Star2 = [
    { 'type': 'essay', 'japanese': 'かえる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Pulang)', 'answer': 'kaeru' },
    { 'type': 'essay', 'japanese': 'とる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengambil)', 'answer': 'toru' },
    { 'type': 'essay', 'japanese': 'たつ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Berdiri)', 'answer': 'tatsu' },
    { 'type': 'essay', 'japanese': 'すわる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Duduk)', 'answer': 'suwaru' },
    { 'type': 'essay', 'japanese': 'きる', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mengenakan)', 'answer': 'kiru' },
    { 'type': 'essay', 'japanese': 'しぬ', 'question': 'Apa romaji dari kata kerja ini? (Arti: Mati)', 'answer': 'shinu' },
  ];

  static final List<Map<String, dynamic>> _gv2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Bentuk sopan dari "miru" (melihat) adalah:', 'japanese': 'みます', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'mimasu', 'romaji': ''}, {'code': 'B', 'text': 'mirimasu', 'romaji': ''}, {'code': 'C', 'text': 'mishimasu', 'romaji': ''}, {'code': 'D', 'text': 'minai', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "kakimasu"?', 'japanese': 'かきます', 'answer': 'menulis' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Berenang"?', 'japanese': 'およぐ', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'kaku', 'romaji': ''}, {'code': 'B', 'text': 'yomu', 'romaji': ''}, {'code': 'C', 'text': 'matsu', 'romaji': ''}, {'code': 'D', 'text': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji dari "Mendengar"?', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "tatsu" (berdiri) adalah:', 'japanese': 'すわる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'miru', 'romaji': ''}, {'code': 'B', 'text': 'kaku', 'romaji': ''}, {'code': 'C', 'text': 'suwaru', 'romaji': ''}, {'code': 'D', 'text': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Membaca":', 'japanese': 'よむ', 'answer': 'yomu' },
  ];

  // --- BASIC ADJECTIVES ---
  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'japanese': 'おいしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Enak)', 'answer': 'oishii' },
    { 'type': 'essay', 'japanese': 'たかい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Mahal)', 'answer': 'takai' },
    { 'type': 'essay', 'japanese': 'やすい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Murah)', 'answer': 'yasui' },
    { 'type': 'essay', 'japanese': 'おおきい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Besar)', 'answer': 'ookii' },
    { 'type': 'essay', 'japanese': 'ちいさい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Kecil)', 'answer': 'chiisai' },
    { 'type': 'essay', 'japanese': 'あたらしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Baru)', 'answer': 'atarashii' },
  ];

  static final List<Map<String, dynamic>> _adjStar2 = [
    { 'type': 'essay', 'japanese': 'ふるい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Lama/Tua)', 'answer': 'furui' },
    { 'type': 'essay', 'japanese': 'いい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Bagus)', 'answer': 'ii' },
    { 'type': 'essay', 'japanese': 'わるい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Buruk)', 'answer': 'warui' },
    { 'type': 'essay', 'japanese': 'むずかしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Sulit)', 'answer': 'muzukashii' },
    { 'type': 'essay', 'japanese': 'やさしい', 'question': 'Apa romaji dari kata sifat ini? (Arti: Mudah)', 'answer': 'yasashii' },
    { 'type': 'essay', 'japanese': 'とても', 'question': 'Apa romaji dari kata ini? (Arti: Sangat)', 'answer': 'totemo' },
  ];

  static final List<Map<String, dynamic>> _adjStar3 = [
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "takai" (mahal) adalah:', 'japanese': 'やすい', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'oishii', 'romaji': ''}, {'code': 'B', 'text': 'yasui', 'romaji': ''}, {'code': 'C', 'text': 'furui', 'romaji': ''}, {'code': 'D', 'text': 'ookii', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "chiisai"?', 'japanese': 'ちいさい', 'answer': 'kecil' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Sulit"?', 'japanese': 'むずかしい', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'yasashii', 'romaji': ''}, {'code': 'B', 'text': 'atarashii', 'romaji': ''}, {'code': 'C', 'text': 'muzukashii', 'romaji': ''}, {'code': 'D', 'text': 'oishii', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa romaji untuk "Bagus"?', 'japanese': 'いい', 'answer': 'ii' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "atarashii" (baru) adalah:', 'japanese': 'ふるい', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'furui', 'romaji': ''}, {'code': 'B', 'text': 'takai', 'romaji': ''}, {'code': 'C', 'text': 'ookii', 'romaji': ''}, {'code': 'D', 'text': 'warui', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan romaji untuk "Enak":', 'japanese': 'おいしい', 'answer': 'oishii' },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [
    ..._gpStar1.sublist(0, 2), ..._gpStar2.sublist(0, 2), ..._gpStar3.sublist(0, 2),
    ..._gv1Star1.sublist(0, 2), ..._gv1Star2.sublist(0, 2), ..._gv1Star3.sublist(0, 2),
    ..._gv2Star1.sublist(0, 2), ..._gv2Star2.sublist(0, 2), ..._gv2Star3.sublist(0, 2),
    ..._adjStar1.sublist(0, 2), ..._adjStar2.sublist(0, 2), ..._adjStar3.sublist(0, 2),
  ];
}
