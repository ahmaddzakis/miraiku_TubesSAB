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
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'A', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'あ', 'romaji': ''}, {'code': 'B', 'text': 'お', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'え', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'い', 'answer': 'perut' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'U', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'い', 'romaji': ''}, {'code': 'B', 'text': 'え', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'あ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'え', 'answer': 'gambar' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'O', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'あ', 'romaji': ''}, {'code': 'B', 'text': 'お', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'い', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'あお', 'answer': 'biru' },
  ];

  static final List<Map<String, dynamic>> _h1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'KA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'か', 'romaji': ''}, {'code': 'B', 'text': 'き', 'romaji': ''}, {'code': 'C', 'text': 'く', 'romaji': ''}, {'code': 'D', 'text': 'こ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'き', 'answer': 'pohon' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'KU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'け', 'romaji': ''}, {'code': 'B', 'text': 'こ', 'romaji': ''}, {'code': 'C', 'text': 'く', 'romaji': ''}, {'code': 'D', 'text': 'か', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'け', 'answer': 'rambut' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'KO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'か', 'romaji': ''}, {'code': 'B', 'text': 'こ', 'romaji': ''}, {'code': 'C', 'text': 'き', 'romaji': ''}, {'code': 'D', 'text': 'く', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'かき', 'answer': 'kesemek' },
  ];

  static final List<Map<String, dynamic>> _h1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'SA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'さ', 'romaji': ''}, {'code': 'B', 'text': 'し', 'romaji': ''}, {'code': 'C', 'text': 'す', 'romaji': ''}, {'code': 'D', 'text': 'そ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'し', 'answer': 'kota' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'SU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'せ', 'romaji': ''}, {'code': 'B', 'text': 'そ', 'romaji': ''}, {'code': 'C', 'text': 'す', 'romaji': ''}, {'code': 'D', 'text': 'さ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'せ', 'answer': 'punggung' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'SO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'さ', 'romaji': ''}, {'code': 'B', 'text': 'そ', 'romaji': ''}, {'code': 'C', 'text': 'す', 'romaji': ''}, {'code': 'D', 'text': 'し', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'すし', 'answer': 'sushi' },
  ];

  // HIRAGANA 2 (TA-TO, NA-NO, HA-HO)
  static final List<Map<String, dynamic>> _h2Star1 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'TA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'た', 'romaji': ''}, {'code': 'B', 'text': 'ち', 'romaji': ''}, {'code': 'C', 'text': 'つ', 'romaji': ''}, {'code': 'D', 'text': 'と', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ち', 'answer': 'darah' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'TSU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'て', 'romaji': ''}, {'code': 'B', 'text': 'と', 'romaji': ''}, {'code': 'C', 'text': 'つ', 'romaji': ''}, {'code': 'D', 'text': 'た', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'て', 'answer': 'tangan' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'TO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'た', 'romaji': ''}, {'code': 'B', 'text': 'と', 'romaji': ''}, {'code': 'C', 'text': 'て', 'romaji': ''}, {'code': 'D', 'text': 'つ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'てつ', 'answer': 'besi' },
  ];

  static final List<Map<String, dynamic>> _h2Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'NA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'な', 'romaji': ''}, {'code': 'B', 'text': 'に', 'romaji': ''}, {'code': 'C', 'text': 'ぬ', 'romaji': ''}, {'code': 'D', 'text': 'の', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'に', 'answer': 'dua' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'NU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ね', 'romaji': ''}, {'code': 'B', 'text': 'の', 'romaji': ''}, {'code': 'C', 'text': 'ぬ', 'romaji': ''}, {'code': 'D', 'text': 'な', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ね', 'answer': 'akar' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'NO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'な', 'romaji': ''}, {'code': 'B', 'text': 'の', 'romaji': ''}, {'code': 'C', 'text': 'に', 'romaji': ''}, {'code': 'D', 'text': 'ぬ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'なに', 'answer': 'apa' },
  ];

  static final List<Map<String, dynamic>> _h2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'HA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'は', 'romaji': ''}, {'code': 'B', 'text': 'ひ', 'romaji': ''}, {'code': 'C', 'text': 'ふ', 'romaji': ''}, {'code': 'D', 'text': 'ほ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ひ', 'answer': 'api' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'FU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'へ', 'romaji': ''}, {'code': 'B', 'text': 'ほ', 'romaji': ''}, {'code': 'C', 'text': 'ふ', 'romaji': ''}, {'code': 'D', 'text': 'は', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'は', 'answer': 'daun' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'HO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'は', 'romaji': ''}, {'code': 'B', 'text': 'ほ', 'romaji': ''}, {'code': 'C', 'text': 'ひ', 'romaji': ''}, {'code': 'D', 'text': 'ふ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'はな', 'answer': 'bunga' },
  ];

  // HIRAGANA 3 (MA-MO, YA-YO, RA-RO)
  static final List<Map<String, dynamic>> _h3Star1 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'MA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ま', 'romaji': ''}, {'code': 'B', 'text': 'み', 'romaji': ''}, {'code': 'C', 'text': 'む', 'romaji': ''}, {'code': 'D', 'text': 'も', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini? (Hint: Buah)', 'japanese': 'み', 'answer': 'buah' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'MU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'め', 'romaji': ''}, {'code': 'B', 'text': 'も', 'romaji': ''}, {'code': 'C', 'text': 'む', 'romaji': ''}, {'code': 'D', 'text': 'ま', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini? (Hint: Mata)', 'japanese': 'め', 'answer': 'mata' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'MO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ま', 'romaji': ''}, {'code': 'B', 'text': 'も', 'romaji': ''}, {'code': 'C', 'text': 'み', 'romaji': ''}, {'code': 'D', 'text': 'む', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'もも', 'answer': 'persik' },
  ];

  static final List<Map<String, dynamic>> _h3Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'YA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'や', 'romaji': ''}, {'code': 'B', 'text': 'ゆ', 'romaji': ''}, {'code': 'C', 'text': 'よ', 'romaji': ''}, {'code': 'D', 'text': 'あ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini? (Hint: Air Panas)', 'japanese': 'ゆ', 'answer': 'air panas' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'YO', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'や', 'romaji': ''}, {'code': 'B', 'text': 'ゆ', 'romaji': ''}, {'code': 'C', 'text': 'よ', 'romaji': ''}, {'code': 'D', 'text': 'お', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'やま', 'answer': 'gunung' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'YA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'や', 'romaji': ''}, {'code': 'B', 'text': 'ゆ', 'romaji': ''}, {'code': 'C', 'text': 'よ', 'romaji': ''}, {'code': 'D', 'text': 'わ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ゆめ', 'answer': 'mimpi' },
  ];

  static final List<Map<String, dynamic>> _h3Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'RA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ら', 'romaji': ''}, {'code': 'B', 'text': 'り', 'romaji': ''}, {'code': 'C', 'text': 'る', 'romaji': ''}, {'code': 'D', 'text': 'ろ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'り', 'answer': 'ri' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'RU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'れ', 'romaji': ''}, {'code': 'B', 'text': 'ろ', 'romaji': ''}, {'code': 'C', 'text': 'る', 'romaji': ''}, {'code': 'D', 'text': 'ら', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'れ', 'answer': 're' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'RO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ら', 'romaji': ''}, {'code': 'B', 'text': 'ろ', 'romaji': ''}, {'code': 'C', 'text': 'る', 'romaji': ''}, {'code': 'D', 'text': 'り', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'そら', 'answer': 'langit' },
  ];

  // HIRAGANA 4 (WA-N, DAKUON, HANDAKUON)
  static final List<Map<String, dynamic>> _h4Star1 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'WA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'わ', 'romaji': ''}, {'code': 'B', 'text': 'を', 'romaji': ''}, {'code': 'C', 'text': 'ん', 'romaji': ''}, {'code': 'D', 'text': 'は', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'を', 'answer': 'wo' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'N', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'む', 'romaji': ''}, {'code': 'B', 'text': 'め', 'romaji': ''}, {'code': 'C', 'text': 'ん', 'romaji': ''}, {'code': 'D', 'text': 'ぬ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'わたし', 'answer': 'saya' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'にほん', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'china', 'romaji': ''}, {'code': 'B', 'text': 'jepang', 'romaji': ''}, {'code': 'C', 'text': 'korea', 'romaji': ''}, {'code': 'D', 'text': 'amerika', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'わ', 'answer': 'wa' },
  ];

  static final List<Map<String, dynamic>> _h4Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'GA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'が', 'romaji': ''}, {'code': 'B', 'text': 'ぎ', 'romaji': ''}, {'code': 'C', 'text': 'ぐ', 'romaji': ''}, {'code': 'D', 'text': 'げ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'ざ', 'answer': 'za' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'DA', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'た', 'romaji': ''}, {'code': 'B', 'text': 'ざ', 'romaji': ''}, {'code': 'C', 'text': 'だ', 'romaji': ''}, {'code': 'D', 'text': 'ば', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'ば', 'answer': 'ba' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'まんが', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kartun', 'romaji': ''}, {'code': 'B', 'text': 'komik', 'romaji': ''}, {'code': 'C', 'text': 'majalah', 'romaji': ''}, {'code': 'D', 'text': 'novel', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': '가っこう', 'answer': 'sekolah' },
  ];

  static final List<Map<String, dynamic>> _h4Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'PA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ぱ', 'romaji': ''}, {'code': 'B', 'text': 'ば', 'romaji': ''}, {'code': 'C', 'text': 'は', 'romaji': ''}, {'code': 'D', 'text': 'ま', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'ぴ', 'answer': 'pi' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'PU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ふ', 'romaji': ''}, {'code': 'B', 'text': 'ぶ', 'romaji': ''}, {'code': 'C', 'text': 'pu', 'romaji': ''}, {'code': 'D', 'text': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Manakah cara baca karakter ini?', 'japanese': 'ぺ', 'answer': 'pe' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'PO', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ほ', 'romaji': ''}, {'code': 'B', 'text': 'ぽ', 'romaji': ''}, {'code': 'C', 'text': 'ぼ', 'romaji': ''}, {'code': 'D', 'text': 'も', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ぱん', 'answer': 'roti' },
  ];

  static final List<Map<String, dynamic>> _greetStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'おはよう', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Selamat Pagi', 'romaji': ''}, {'code': 'B', 'text': 'Selamat Tidur', 'romaji': ''}, {'code': 'C', 'text': 'Selamat Atas...', 'romaji': ''}, {'code': 'D', 'text': 'Selamat Datang', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'こんにちは', 'answer': 'selamat siang' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'こんばんは', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Selamat Siang', 'romaji': ''}, {'code': 'B', 'text': 'Malam Ini', 'romaji': ''}, {'code': 'C', 'text': 'Selamat Malam', 'romaji': ''}, {'code': 'D', 'text': 'Sore Hari', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'おやすみなさい', 'answer': 'selamat tidur' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'おげんきですか', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Terima Kasih', 'romaji': ''}, {'code': 'B', 'text': 'Apa Kabar?', 'romaji': ''}, {'code': 'C', 'text': 'Selamat Pagi', 'romaji': ''}, {'code': 'D', 'text': 'Senang Bertemu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'ありがとう', 'answer': 'terima kasih' },
  ];

  static final List<Map<String, dynamic>> _greetStar2 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'すみません', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Terima kasih', 'romaji': ''}, {'code': 'B', 'text': 'Maaf / Permisi', 'romaji': ''}, {'code': 'C', 'text': 'Selamat tinggal', 'romaji': ''}, {'code': 'D', 'text': 'Sama-sama', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'はじめまして', 'answer': 'senang bertemu denganmu' },
    { 'type': 'multiple_choice', 'question': 'Apa balasan yang tepat untuk ungkapan ini?', 'japanese': 'ありがとう', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Selamat Malam', 'romaji': ''}, {'code': 'B', 'text': 'Selamat Tidur', 'romaji': ''}, {'code': 'C', 'text': 'Selamat Tinggal', 'romaji': ''}, {'code': 'D', 'text': 'Sama-sama', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'さようなら', 'answer': 'selamat tinggal' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat untuk sapaan "Selamat Siang":', 'japanese': 'Selamat Siang', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'こんにちは', 'romaji': ''}, {'code': 'B', 'text': 'こにちわ', 'romaji': ''}, {'code': 'C', 'text': 'こんにちわ', 'romaji': ''}, {'code': 'D', 'text': 'こにちは', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini?', 'japanese': 'いただきます', 'answer': 'selamat makan' },
  ];

  static final List<Map<String, dynamic>> _greetStar3 = [
    { 'type': 'multiple_choice', 'question': 'Manakah ungkapan yang digunakan saat masuk rumah?', 'japanese': 'ただいま', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Selamat Jalan', 'romaji': ''}, {'code': 'B', 'text': 'Selamat Datang Kembali', 'romaji': ''}, {'code': 'C', 'text': 'Aku Pulang', 'romaji': ''}, {'code': 'D', 'text': 'Permisi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata yang hilang ini?', 'japanese': 'げんき', 'answer': 'sehat' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat untuk ungkapan permintaan maaf:', 'japanese': 'Maaf', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ごめなさい', 'romaji': ''}, {'code': 'B', 'text': 'ごめんなさい', 'romaji': ''}, {'code': 'C', 'text': 'ごめんあさい', 'romaji': ''}, {'code': 'D', 'text': 'ごんめなさい', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini dalam bahasa Indonesia?', 'japanese': 'またあした', 'answer': 'sampai jumpa besok' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari ungkapan ini?', 'japanese': 'おせわになります', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Terima kasih atas bantuannya', 'romaji': ''}, {'code': 'B', 'text': 'Selamat datang', 'romaji': ''}, {'code': 'C', 'text': 'Maaf mengganggu', 'romaji': ''}, {'code': 'D', 'text': 'Sampai nanti', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari ungkapan ini?', 'japanese': 'いってきます', 'answer': 'saya berangkat' },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'いち', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Satu', 'romaji': ''}, {'code': 'B', 'text': 'Delapan', 'romaji': ''}, {'code': 'C', 'text': 'Tujuh', 'romaji': ''}, {'code': 'D', 'text': 'Dua', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'に', 'answer': 'dua' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'さん', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Tiga Puluh', 'romaji': ''}, {'code': 'B', 'text': 'Seribu', 'romaji': ''}, {'code': 'C', 'text': 'Tiga', 'romaji': ''}, {'code': 'D', 'text': 'Tiga Belas', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'よん', 'answer': 'empat' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'ご', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Empat', 'romaji': ''}, {'code': 'B', 'text': 'Lima', 'romaji': ''}, {'code': 'C', 'text': 'Sembilan', 'romaji': ''}, {'code': 'D', 'text': 'Delapan', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'じゅう', 'answer': 'sepuluh' },
  ];

  static final List<Map<String, dynamic>> _numStar2 = [
    { 'type': 'multiple_choice', 'question': 'Angka 7 dalam bahasa Jepang adalah:', 'japanese': 'なな', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'ねね (nene)', 'romaji': ''}, {'code': 'B', 'text': 'ぬぬ (nunu)', 'romaji': ''}, {'code': 'C', 'text': 'まま (mama)', 'romaji': ''}, {'code': 'D', 'text': 'なな (nana)', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'はち', 'answer': 'delapan' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat untuk angka 11:', 'japanese': 'Sebelas', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'じゅうに', 'romaji': ''}, {'code': 'B', 'text': 'じゅういち', 'romaji': ''}, {'code': 'C', 'text': 'にじゅう', 'romaji': ''}, {'code': 'D', 'text': 'いちじゅう', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'にじゅう', 'answer': 'dua puluh' },
    { 'type': 'multiple_choice', 'question': 'Pilih hiragana yang benar untuk 100:', 'japanese': '100', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'はゃく', 'romaji': ''}, {'code': 'B', 'text': 'ひあく', 'romaji': ''}, {'code': 'C', 'text': 'ひゃく', 'romaji': ''}, {'code': 'D', 'text': 'びゃく', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "nana" (なな)?', 'japanese': 'なな', 'answer': 'tujuh' },
  ];

  static final List<Map<String, dynamic>> _numStar3 = [
    { 'type': 'multiple_choice', 'question': 'Berapakah hasil dari ungkapan ini?', 'japanese': 'さん (3) + よん (4)', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Tujuh', 'romaji': ''}, {'code': 'B', 'text': 'Tujuh Puluh', 'romaji': ''}, {'code': 'C', 'text': 'Delapan', 'romaji': ''}, {'code': 'D', 'text': 'Dua Belas', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'さんじゅうご', 'answer': 'tiga puluh lima' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan hiragana yang benar untuk 90:', 'japanese': 'Sembilan Puluh', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'くうじゅう', 'romaji': ''}, {'code': 'B', 'text': 'きゅうじゅ', 'romaji': ''}, {'code': 'C', 'text': 'きゅうじゅう', 'romaji': ''}, {'code': 'D', 'text': 'きゅうじゅん', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'せん', 'answer': 'seribu' },
    { 'type': 'multiple_choice', 'question': 'Manakah angka yang memiliki nilai paling besar?', 'japanese': 'Nilai Terbesar', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Seratus', 'romaji': ''}, {'code': 'B', 'text': 'Seribu', 'romaji': ''}, {'code': 'C', 'text': 'Sepuluh Ribu (Yen)', 'romaji': ''}, {'code': 'D', 'text': 'Sepuluh Ribu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari angka ini dalam bahasa Indonesia?', 'japanese': 'ごじゅう', 'answer': 'lima puluh' },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'たべる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Makan', 'romaji': ''}, {'code': 'B', 'text': 'Minum', 'romaji': ''}, {'code': 'C', 'text': 'Melihat', 'romaji': ''}, {'code': 'D', 'text': 'Mendengar', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'のむ', 'answer': 'minum' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'みる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Membaca', 'romaji': ''}, {'code': 'B', 'text': 'Menulis', 'romaji': ''}, {'code': 'C', 'text': 'Melihat', 'romaji': ''}, {'code': 'D', 'text': 'Pergi', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'よむ', 'answer': 'membaca' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'いく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Datang', 'romaji': ''}, {'code': 'B', 'text': 'Pergi', 'romaji': ''}, {'code': 'C', 'text': 'Pulang', 'romaji': ''}, {'code': 'D', 'text': 'Tidur', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'たべる', 'answer': 'makan' },
  ];

  static final List<Map<String, dynamic>> _verbStar2 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'かく', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Membaca', 'romaji': ''}, {'code': 'B', 'text': 'Menulis', 'romaji': ''}, {'code': 'C', 'text': 'Mendengar', 'romaji': ''}, {'code': 'D', 'text': 'Berjalan', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'きく', 'answer': 'mendengar' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'くる', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Datang', 'romaji': ''}, {'code': 'B', 'text': 'Pergi', 'romaji': ''}, {'code': 'C', 'text': 'Pulang', 'romaji': ''}, {'code': 'D', 'text': 'Berlari', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'ねる', 'answer': 'tidur' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'かえる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Datang', 'romaji': ''}, {'code': 'B', 'text': 'Pergi', 'romaji': ''}, {'code': 'C', 'text': 'Pulang', 'romaji': ''}, {'code': 'D', 'text': 'Masuk', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'かう', 'answer': 'membeli' },
  ];

  static final List<Map<String, dynamic>> _verbStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'べんきょうする', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Berjalan', 'romaji': ''}, {'code': 'B', 'text': 'Berenang', 'romaji': ''}, {'code': 'C', 'text': 'Menari', 'romaji': ''}, {'code': 'D', 'text': 'Belajar', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'はなす', 'answer': 'berbicara' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'まつ', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Mati', 'romaji': ''}, {'code': 'B', 'text': 'Menunggu', 'romaji': ''}, {'code': 'C', 'text': 'Memakai', 'romaji': ''}, {'code': 'D', 'text': 'Memasak', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'はたらく', 'answer': 'bekerja' },
    { 'type': 'multiple_choice', 'question': 'Manakah kata kerja yang berkaitan dengan musik?', 'japanese': 'Mendengar', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Makan', 'romaji': ''}, {'code': 'B', 'text': 'Minum', 'romaji': ''}, {'code': 'C', 'text': 'Mendengar', 'romaji': ''}, {'code': 'D', 'text': 'Tidur', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'japanese': 'わかる', 'answer': 'mengerti' },
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
    { 'type': 'essay', 'japanese': 'ア', 'question': 'Pilih karakter yang tepat:', 'answer': 'a' },
    { 'type': 'essay', 'japanese': 'イ', 'question': 'Pilih karakter yang tepat:', 'answer': 'i' },
    { 'type': 'essay', 'japanese': 'ウ', 'question': 'Pilih karakter yang tepat:', 'answer': 'u' },
    { 'type': 'essay', 'japanese': 'エ', 'question': 'Pilih karakter yang tepat:', 'answer': 'e' },
    { 'type': 'essay', 'japanese': 'オ', 'question': 'Pilih karakter yang tepat:', 'answer': 'o' },
    { 'type': 'essay', 'japanese': 'カ', 'question': 'Pilih karakter yang tepat:', 'answer': 'ka' },
  ];

  static final List<Map<String, dynamic>> _k1Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'KI', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'サ', 'romaji': ''}, {'code': 'B', 'text': 'キ', 'romaji': ''}, {'code': 'C', 'text': 'チ', 'romaji': ''}, {'code': 'D', 'text': 'ケ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'アイ', 'answer': 'cinta' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'GASU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'カス', 'romaji': ''}, {'code': 'B', 'text': 'クス', 'romaji': ''}, {'code': 'C', 'text': 'ガス', 'romaji': ''}, {'code': 'D', 'text': 'ゲス', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'カキ', 'answer': 'kesemek' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'SU', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'ヌ', 'romaji': ''}, {'code': 'B', 'text': 'マ', 'romaji': ''}, {'code': 'C', 'text': 'フ', 'romaji': ''}, {'code': 'D', 'text': 'ス', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'キカ', 'answer': 'geometri' },
  ];

  static final List<Map<String, dynamic>> _k1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'アイス', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'es krim', 'romaji': ''}, {'code': 'B', 'text': 'mata', 'romaji': ''}, {'code': 'C', 'text': 'kursi', 'romaji': ''}, {'code': 'D', 'text': 'buku', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'スキー', 'answer': 'main ski' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Kasa (Payung)', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'カセ', 'romaji': ''}, {'code': 'B', 'text': 'カサ', 'romaji': ''}, {'code': 'C', 'text': 'ケサ', 'romaji': ''}, {'code': 'D', 'text': 'クサ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ケサ', 'answer': 'pagi ini' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang benar untuk kata ini:', 'japanese': 'Kue', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ゲーキ', 'romaji': ''}, {'code': 'B', 'text': 'ケエキ', 'romaji': ''}, {'code': 'C', 'text': 'ケーキ', 'romaji': ''}, {'code': 'D', 'text': 'ケッキ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'エコ', 'answer': 'ekologi' },
  ];

  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'japanese': 'タ', 'question': 'Pilih karakter yang tepat:', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': 'チ', 'question': 'Pilih karakter yang tepat:', 'answer': 'chi' },
    { 'type': 'essay', 'japanese': 'ツ', 'question': 'Pilih karakter yang tepat:', 'answer': 'tsu' },
    { 'type': 'essay', 'japanese': 'テ', 'question': 'Pilih karakter yang tepat:', 'answer': 'te' },
    { 'type': 'essay', 'japanese': 'ト', 'question': 'Pilih karakter yang tepat:', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'ナ', 'question': 'Pilih karakter yang tepat:', 'answer': 'na' },
  ];

  static final List<Map<String, dynamic>> _k2Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'NI', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ミ', 'romaji': ''}, {'code': 'B', 'text': 'ヌ', 'romaji': ''}, {'code': 'C', 'text': 'ニ', 'romaji': ''}, {'code': 'D', 'text': 'ネ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ナニ', 'answer': 'apa' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Daging', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ニク', 'romaji': ''}, {'code': 'B', 'text': 'ナカ', 'romaji': ''}, {'code': 'C', 'text': 'ネコ', 'romaji': ''}, {'code': 'D', 'text': 'ノコ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ツタ', 'answer': 'ivy' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'Teto', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'タト', 'romaji': ''}, {'code': 'B', 'text': 'テト', 'romaji': ''}, {'code': 'C', 'text': 'チト', 'romaji': ''}, {'code': 'D', 'text': 'ツト', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ヌネ', 'answer': 'puncak' },
  ];

  static final List<Map<String, dynamic>> _k2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'Dasi', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ネクタイ', 'romaji': ''}, {'code': 'B', 'text': 'ヌクタイ', 'romaji': ''}, {'code': 'C', 'text': 'ニクタイ', 'romaji': ''}, {'code': 'D', 'text': 'ネケタイ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'テニス', 'answer': 'tenis' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'TSUURU', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ツル', 'romaji': ''}, {'code': 'B', 'text': 'ツレ', 'romaji': ''}, {'code': 'C', 'text': 'ツール', 'romaji': ''}, {'code': 'D', 'text': 'シル', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'カナダ', 'answer': 'kanada' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'タクシー', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'bus', 'romaji': ''}, {'code': 'B', 'text': 'taksi', 'romaji': ''}, {'code': 'C', 'text': 'motor', 'romaji': ''}, {'code': 'D', 'text': 'sepeda', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ナタ', 'answer': 'parang' },
  ];

  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'japanese': 'ノ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'ハ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'ha' },
    { 'type': 'essay', 'japanese': 'ヒ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': 'フ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'fu' },
    { 'type': 'essay', 'japanese': 'ヘ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'ホ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'ho' },
  ];

  static final List<Map<String, dynamic>> _k3Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'MA', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'マ', 'romaji': ''}, {'code': 'B', 'text': 'ム', 'romaji': ''}, {'code': 'C', 'text': 'ア', 'romaji': ''}, {'code': 'D', 'text': 'ヌ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ハム', 'answer': 'daging' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Memo', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'メメ', 'romaji': ''}, {'code': 'B', 'text': 'メモ', 'romaji': ''}, {'code': 'C', 'text': 'マモ', 'romaji': ''}, {'code': 'D', 'text': 'ムモ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ヒフ', 'answer': 'kulit' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'YA', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'マ', 'romaji': ''}, {'code': 'B', 'text': 'ユ', 'romaji': ''}, {'code': 'C', 'text': 'セ', 'romaji': ''}, {'code': 'D', 'text': 'ヤ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ホホ', 'answer': 'pipi' },
  ];

  static final List<Map<String, dynamic>> _k3Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'コーヒー', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Teh', 'romaji': ''}, {'code': 'B', 'text': 'Susu', 'romaji': ''}, {'code': 'C', 'text': 'Kopi', 'romaji': ''}, {'code': 'D', 'text': 'Air', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ホテル', 'answer': 'hotel' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Movie', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ムービー', 'romaji': ''}, {'code': 'B', 'text': 'ムビ', 'romaji': ''}, {'code': 'C', 'text': 'モオビ', 'romaji': ''}, {'code': 'D', 'text': 'ヌービー', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ヤマハ', 'answer': 'yamaha' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Help', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ハルプ', 'romaji': ''}, {'code': 'B', 'text': 'ヘルプ', 'romaji': ''}, {'code': 'C', 'text': 'ベルプ', 'romaji': ''}, {'code': 'D', 'text': 'ヘルフ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ハハ', 'answer': 'ibu' },
  ];

  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'japanese': 'ユ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'yu' },
    { 'type': 'essay', 'japanese': 'ヨ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'yo' },
    { 'type': 'essay', 'japanese': 'ラ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'ra' },
    { 'type': 'essay', 'japanese': 'リ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'ri' },
    { 'type': 'essay', 'japanese': 'ル', 'question': 'Apa bunyi dari karakter ini?', 'answer': 'ru' },
    { 'type': 'essay', 'japanese': 'レ', 'question': 'Apa bunyi dari karakter ini?', 'answer': 're' },
  ];

  static final List<Map<String, dynamic>> _k4Star2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'WA', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ウ', 'romaji': ''}, {'code': 'B', 'text': 'ク', 'romaji': ''}, {'code': 'C', 'text': 'ワ', 'romaji': ''}, {'code': 'D', 'text': 'フ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ラク', 'answer': 'rileks' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Rain', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ラエン', 'romaji': ''}, {'code': 'B', 'text': 'ライン', 'romaji': ''}, {'code': 'C', 'text': 'ライソ', 'romaji': ''}, {'code': 'D', 'text': 'ヲイン', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ヨル', 'answer': 'malam' },
    { 'type': 'multiple_choice', 'question': 'Pilih karakter yang tepat:', 'japanese': 'RO', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'コ', 'romaji': ''}, {'code': 'B', 'text': 'ヨ', 'romaji': ''}, {'code': 'C', 'text': 'ユ', 'romaji': ''}, {'code': 'D', 'text': 'ロ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa bunyi dari gabungan karakter ini?', 'japanese': 'ワヲン', 'answer': 'wawon' },
  ];

  static final List<Map<String, dynamic>> _k4Star3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'プラス', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Minus', 'romaji': ''}, {'code': 'B', 'text': 'Kali', 'romaji': ''}, {'code': 'C', 'text': 'Bagi', 'romaji': ''}, {'code': 'D', 'text': 'Tambah', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ガラス', 'answer': 'gelas' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Radio', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ラジョ', 'romaji': ''}, {'code': 'B', 'text': 'ラジオ', 'romaji': ''}, {'code': 'C', 'text': 'ラジュ', 'romaji': ''}, {'code': 'D', 'text': 'ラヂオ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan bunyi untuk robot legendaris ini:', 'japanese': 'ガンダム', 'answer': 'gandamu' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'ページ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Halaman', 'romaji': ''}, {'code': 'B', 'text': 'Buku', 'romaji': ''}, {'code': 'C', 'text': 'Kertas', 'romaji': ''}, {'code': 'D', 'text': 'Pensil', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'パーティ', 'answer': 'pesta' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar1 = [
    { 'type': 'essay', 'japanese': 'カメラ', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'kamera' },
    { 'type': 'essay', 'japanese': 'テレビ', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'tv' },
    { 'type': 'essay', 'japanese': 'ホテル', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'hotel' },
    { 'type': 'essay', 'japanese': 'バス', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'bus' },
    { 'type': 'essay', 'japanese': 'トイレ', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'toilet' },
    { 'type': 'essay', 'japanese': 'ドア', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'pintu' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'Wine', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'ウイン', 'romaji': ''}, {'code': 'B', 'text': 'ワイン', 'romaji': ''}, {'code': 'C', 'text': 'ワン', 'romaji': ''}, {'code': 'D', 'text': 'ラチン', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ペン', 'answer': 'pena' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan yang berarti "Kue"?', 'japanese': 'Kue', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'ケキ', 'romaji': ''}, {'code': 'B', 'text': 'ゲエキ', 'romaji': ''}, {'code': 'C', 'text': 'ケーキ', 'romaji': ''}, {'code': 'D', 'text': 'ケッキ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'パン', 'answer': 'roti' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang benar untuk kata ini:', 'japanese': 'Taksi', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Scale', 'romaji': ''}, {'code': 'B', 'text': 'タクツ', 'romaji': ''}, {'code': 'C', 'text': 'タキシ', 'romaji': ''}, {'code': 'D', 'text': 'タクシー', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ノート', 'answer': 'buku catatan' },
  ];

  static final List<Map<String, dynamic>> _kataWordStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'パソコン', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'Televisi', 'romaji': ''}, {'code': 'B', 'text': 'Radio', 'romaji': ''}, {'code': 'C', 'text': 'Smartphone', 'romaji': ''}, {'code': 'D', 'text': 'PC / Laptop', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'カレンダー', 'answer': 'kalender' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti kata berikut ini?', 'japanese': 'Toserba', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'スーパー', 'romaji': ''}, {'code': 'B', 'text': 'デパート', 'romaji': ''}, {'code': 'C', 'text': 'コンビニ', 'romaji': ''}, {'code': 'D', 'text': 'テパート', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ビデオ', 'answer': 'video' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Sofa', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'ソファー', 'romaji': ''}, {'code': 'B', 'text': 'ンファー', 'romaji': ''}, {'code': 'C', 'text': 'シファー', 'romaji': ''}, {'code': 'D', 'text': 'ゾファ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'エアコン', 'answer': 'ac' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar1 = [
    { 'type': 'essay', 'japanese': 'レストラン', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'restoran' },
    { 'type': 'essay', 'japanese': 'スーパー', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'supermarket' },
    { 'type': 'essay', 'japanese': 'デパート', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'toko serba ada' },
    { 'type': 'essay', 'japanese': 'コンビニ', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'minimarket' },
    { 'type': 'essay', 'japanese': 'サラリーマン', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'karyawan' },
    { 'type': 'essay', 'japanese': 'スマートフォン', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'smartphone' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'Internet', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'インタン', 'romaji': ''}, {'code': 'B', 'text': 'インターネット', 'romaji': ''}, {'code': 'C', 'text': 'インタネット', 'romaji': ''}, {'code': 'D', 'text': 'インラネット', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ピザ', 'answer': 'pizza' },
    { 'type': 'multiple_choice', 'question': 'Manakah Katakana yang berarti "Salad"?', 'japanese': 'Salad', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'サラダ', 'romaji': ''}, {'code': 'B', 'text': 'サラタ', 'romaji': ''}, {'code': 'C', 'text': 'ゼラダ', 'romaji': ''}, {'code': 'D', 'text': 'サロタ', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'スポーツ', 'answer': 'olahraga' },
    { 'type': 'multiple_choice', 'question': 'Pilih penulisan yang tepat:', 'japanese': 'Komputer', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'コンピュタ', 'romaji': ''}, {'code': 'B', 'text': 'コンピュウタ', 'romaji': ''}, {'code': 'C', 'text': 'コンピューター', 'romaji': ''}, {'code': 'D', 'text': 'コッピューター', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ネクタイ', 'answer': 'dasi' },
  ];

  static final List<Map<String, dynamic>> _loanWordStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari kata ini?', 'japanese': 'サラリーマン', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Karyawan Swasta', 'romaji': ''}, {'code': 'B', 'text': 'Pelajar', 'romaji': ''}, {'code': 'C', 'text': 'Guru', 'romaji': ''}, {'code': 'D', 'text': 'Dokter', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'チョコレート', 'answer': 'cokelat' },
    { 'type': 'multiple_choice', 'question': 'Manakah penulisan yang berarti "Natal"?', 'japanese': 'Natal', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'クリマッス', 'romaji': ''}, {'code': 'B', 'text': 'クリスマス', 'romaji': ''}, {'code': 'C', 'text': 'クルツマス', 'romaji': ''}, {'code': 'D', 'text': 'クリシマス', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'ハンバーガー', 'answer': 'hamburger' },
    { 'type': 'multiple_choice', 'question': 'Pilih Katakana yang tepat:', 'japanese': 'Es Krim', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'マイスクリーム', 'romaji': ''}, {'code': 'B', 'text': 'アインクリーム', 'romaji': ''}, {'code': 'C', 'text': 'アスクルム', 'romaji': ''}, {'code': 'D', 'text': 'アイスクリーム', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'japanese': 'プレゼント', 'answer': 'hadiah' },
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
    { 'type': 'essay', 'japanese': '一', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'satu' },
    { 'type': 'essay', 'japanese': '二', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'dua' },
    { 'type': 'essay', 'japanese': '三', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'tiga' },
    { 'type': 'essay', 'japanese': '四', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'empat' },
    { 'type': 'essay', 'japanese': '五', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'lima' },
    { 'type': 'essay', 'japanese': '六', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'enam' },
  ];

  static final List<Map<String, dynamic>> _knStar2 = [
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Sembilan"?', 'japanese': 'Sembilan', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '九', 'romaji': ''}, {'code': 'B', 'text': '丸', 'romaji': ''}, {'code': 'C', 'text': '力', 'romaji': ''}, {'code': 'D', 'text': '刀', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '七', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'tujuh' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Seribu":', 'japanese': 'Seribu', 'correctIndex': 2, 'options': [{'code': 'A', 'text': '十', 'romaji': ''}, {'code': 'B', 'text': '土', 'romaji': ''}, {'code': 'C', 'text': '千', 'romaji': ''}, {'code': 'D', 'text': '万', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '八', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'delapan' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Delapan"?', 'japanese': 'Delapan', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '人', 'romaji': ''}, {'code': 'B', 'text': '八', 'romaji': ''}, {'code': 'C', 'text': '入', 'romaji': ''}, {'code': 'D', 'text': 'ハ', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '百', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'seratus' },
  ];

  static final List<Map<String, dynamic>> _knStar3 = [
    { 'type': 'multiple_choice', 'question': 'Berapakah hasil dari: 十 + 五?', 'japanese': '十 + 五', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '10', 'romaji': ''}, {'code': 'B', 'text': '15', 'romaji': ''}, {'code': 'C', 'text': '50', 'romaji': ''}, {'code': 'D', 'text': '51', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari Jukugo ini dalam bahasa Indonesia?', 'japanese': '三百', 'answer': 'tiga ratus' },
    { 'type': 'multiple_choice', 'question': 'Tuliskan "8000" dalam Kanji:', 'japanese': '8000', 'correctIndex': 3, 'options': [{'code': 'A', 'text': '八百', 'romaji': ''}, {'code': 'B', 'text': '八十', 'romaji': ''}, {'code': 'C', 'text': '千八', 'romaji': ''}, {'code': 'D', 'text': '八千', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'japanese': '万', 'answer': 'sepuluh ribu' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "30"?', 'japanese': '30', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '三十', 'romaji': ''}, {'code': 'B', 'text': '十三', 'romaji': ''}, {'code': 'C', 'text': '三', 'romaji': ''}, {'code': 'D', 'text': '十', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari Jukugo ini dalam bahasa Indonesia?', 'japanese': '四百', 'answer': 'empat ratus' },
  ];

  // --- KANJI NATURE ---
  static final List<Map<String, dynamic>> _kanjiNatureStar1 = [
    { 'type': 'essay', 'japanese': '日', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'matahari' },
    { 'type': 'essay', 'japanese': '月', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'bulan' },
    { 'type': 'essay', 'japanese': '火', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'api' },
    { 'type': 'essay', 'japanese': '水', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'air' },
    { 'type': 'essay', 'japanese': '木', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'pohon' },
    { 'type': 'essay', 'japanese': '金', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'emas' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Tanah":', 'japanese': 'Tanah', 'correctIndex': 2, 'options': [{'code': 'A', 'text': '士', 'romaji': ''}, {'code': 'B', 'text': '干', 'romaji': ''}, {'code': 'C', 'text': '土', 'romaji': ''}, {'code': 'D', 'text': '千', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '山', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'gunung' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Matahari"?', 'japanese': 'Matahari', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '口', 'romaji': ''}, {'code': 'D', 'text': '田', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '川', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'sungai' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Air":', 'japanese': 'Air', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '木', 'romaji': ''}, {'code': 'B', 'text': '水', 'romaji': ''}, {'code': 'C', 'text': '氷', 'romaji': ''}, {'code': 'D', 'text': '火', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '石', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'batu' },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "火山"?', 'japanese': '火山', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Air terjun', 'romaji': ''}, {'code': 'B', 'text': 'Gunung Api', 'romaji': ''}, {'code': 'C', 'text': 'Tanah liat', 'romaji': ''}, {'code': 'D', 'text': 'Kebakaran', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari Jukugo ini dalam bahasa Indonesia?', 'japanese': '水田', 'answer': 'sawah' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari "土木"?', 'japanese': '土木', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Pohon besar', 'romaji': ''}, {'code': 'B', 'text': 'Hutan rimba', 'romaji': ''}, {'code': 'C', 'text': 'Pekerjaan sipil', 'romaji': ''}, {'code': 'D', 'text': 'Tanah subur', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari Jukugo ini dalam bahasa Indonesia?', 'japanese': '金山', 'answer': 'tambang emas' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Hari Senin":', 'japanese': 'Hari Senin', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '月曜日', 'romaji': ''}, {'code': 'B', 'text': '日曜日', 'romaji': ''}, {'code': 'C', 'text': '火曜日', 'romaji': ''}, {'code': 'D', 'text': '水曜日', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari Jukugo ini dalam bahasa Indonesia?', 'japanese': '水道', 'answer': 'saluran air' },
  ];

  // --- KANJI PEOPLE ---
  static final List<Map<String, dynamic>> _kanjiPeopleStar1 = [
    { 'type': 'essay', 'japanese': '人', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'orang' },
    { 'type': 'essay', 'japanese': '子', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'anak' },
    { 'type': 'essay', 'japanese': '女', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'wanita' },
    { 'type': 'essay', 'japanese': '男', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'pria' },
    { 'type': 'essay', 'japanese': '目', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'mata' },
    { 'type': 'essay', 'japanese': '口', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'mulut' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar2 = [
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Orang":', 'japanese': 'Orang', 'correctIndex': 0, 'options': [{'code': 'A', 'text': '人', 'romaji': ''}, {'code': 'B', 'text': '入', 'romaji': ''}, {'code': 'C', 'text': '八', 'romaji': ''}, {'code': 'D', 'text': '力', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '耳', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'telinga' },
    { 'type': 'multiple_choice', 'question': 'Manakah Kanji untuk "Mata"?', 'japanese': 'Mata', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '口', 'romaji': ''}, {'code': 'D', 'text': '四', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '手', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'tangan' },
    { 'type': 'multiple_choice', 'question': 'Pilih Kanji untuk "Mulut":', 'japanese': 'Mulut', 'correctIndex': 3, 'options': [{'code': 'A', 'text': '日', 'romaji': ''}, {'code': 'B', 'text': '目', 'romaji': ''}, {'code': 'C', 'text': '回', 'romaji': ''}, {'code': 'D', 'text': '口', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': '父', 'question': 'Apa arti dari karakter Kanji ini dalam bahasa Indonesia?', 'answer': 'ayah' },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar3 = [
    { 'type': 'multiple_choice', 'question': 'Apa arti dari Jukugo "日本人"?', 'japanese': '日本人', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Orang China', 'romaji': ''}, {'code': 'B', 'text': 'Orang Korea', 'romaji': ''}, {'code': 'C', 'text': 'Orang Jepang', 'romaji': ''}, {'code': 'D', 'text': 'Orang Amerika', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan arti untuk Jukugo ini: 女子', 'japanese': '女子', 'answer': 'anak perempuan' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari Jukugo "人口"?', 'japanese': '人口', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Populasi', 'romaji': ''}, {'code': 'B', 'text': 'Pintu masuk', 'romaji': ''}, {'code': 'C', 'text': 'Orang besar', 'romaji': ''}, {'code': 'D', 'text': 'Mulut manis', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan arti untuk Jukugo ini: 男子', 'japanese': '男子', 'answer': 'anak laki-laki' },
    { 'type': 'multiple_choice', 'question': 'Manakah Jukugo yang berarti "Ayah dan Ibu"?', 'japanese': 'Ayah & Ibu', 'correctIndex': 1, 'options': [{'code': 'A', 'text': '男女', 'romaji': ''}, {'code': 'B', 'text': '父母', 'romaji': ''}, {'code': 'C', 'text': '門口', 'romaji': ''}, {'code': 'D', 'text': '大小', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata ini: 下手', 'japanese': '下手', 'answer': 'tidak ahli' },
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
    { 'type': 'essay', 'japanese': 'は', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'topik' },
    { 'type': 'essay', 'japanese': 'を', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'objek' },
    { 'type': 'essay', 'japanese': 'も', 'question': 'Apa arti dari partikel ini dalam bahasa Indonesia?', 'answer': 'juga' },
    { 'type': 'essay', 'japanese': 'に', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'lokasi' },
    { 'type': 'essay', 'japanese': 'へ', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'arah' },
    { 'type': 'essay', 'japanese': 'で', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'lokasi kejadian' },
  ];

  static final List<Map<String, dynamic>> _gpStar2 = [
    { 'type': 'essay', 'japanese': 'と', 'question': 'Apa arti dari partikel ini dalam bahasa Indonesia?', 'answer': 'dan' },
    { 'type': 'essay', 'japanese': 'の', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'kepemilikan' },
    { 'type': 'essay', 'japanese': 'が', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'subjek' },
    { 'type': 'essay', 'japanese': 'から', 'question': 'Apa arti dari partikel ini dalam bahasa Indonesia?', 'answer': 'dari' },
    { 'type': 'essay', 'japanese': 'まで', 'question': 'Apa arti dari partikel ini dalam bahasa Indonesia?', 'answer': 'sampai' },
    { 'type': 'essay', 'japanese': 'か', 'question': 'Apa fungsi dari partikel ini dalam kalimat?', 'answer': 'pertanyaan' },
  ];

  static final List<Map<String, dynamic>> _gpStar3 = [
    { 'type': 'multiple_choice', 'question': 'Pilih partikel yang tepat: わたし ... ごはん を たべます。', 'japanese': 'は', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'は', 'romaji': ''}, {'code': 'B', 'text': 'を', 'romaji': ''}, {'code': 'C', 'text': 'に', 'romaji': ''}, {'code': 'D', 'text': 'で', 'romaji': ''}] },
    { 'type': 'multiple_choice', 'question': 'Pilih partikel untuk menunjukkan arah: がっこう ... いきます。', 'japanese': 'へ', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'は', 'romaji': ''}, {'code': 'B', 'text': 'を', 'romaji': ''}, {'code': 'C', 'text': 'へ', 'romaji': ''}, {'code': 'D', 'text': 'の', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Tuliskan partikel yang menandakan kepemilikan:', 'japanese': 'の', 'answer': 'の' },
    { 'type': 'multiple_choice', 'question': 'Pilih partikel yang tepat: レストラン ... たべます。', 'japanese': 'で', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'に', 'romaji': ''}, {'code': 'B', 'text': 'へ', 'romaji': ''}, {'code': 'C', 'text': 'を', 'romaji': ''}, {'code': 'D', 'text': 'で', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa karakter untuk partikel penanda objek?', 'japanese': 'を', 'answer': 'を' },
    { 'type': 'multiple_choice', 'question': 'Apa arti dari partikel "も"?', 'japanese': 'も', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Hanya', 'romaji': ''}, {'code': 'B', 'text': 'Juga', 'romaji': ''}, {'code': 'C', 'text': 'Dan', 'romaji': ''}, {'code': 'D', 'text': 'Dari', 'romaji': ''}] },
  ];

  // --- GRAMMAR VERBS 1 ---
  static final List<Map<String, dynamic>> _gv1Star1 = [
    { 'type': 'essay', 'japanese': 'たべる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'makan' },
    { 'type': 'essay', 'japanese': 'のむ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'minum' },
    { 'type': 'essay', 'japanese': 'いく', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'pergi' },
    { 'type': 'essay', 'japanese': 'くる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'datang' },
    { 'type': 'essay', 'japanese': 'する', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'melakukan' },
    { 'type': 'essay', 'japanese': 'かう', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'membeli' },
  ];

  static final List<Map<String, dynamic>> _gv1Star2 = [
    { 'type': 'essay', 'japanese': 'わかる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'mengerti' },
    { 'type': 'essay', 'japanese': 'はなす', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'berbicara' },
    { 'type': 'essay', 'japanese': 'あります', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'ada' },
    { 'type': 'essay', 'japanese': 'います', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'ada' },
    { 'type': 'essay', 'japanese': 'はたらく', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'bekerja' },
    { 'type': 'essay', 'japanese': 'べんきょうする', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'belajar' },
  ];

  static final List<Map<String, dynamic>> _gv1Star3 = [
    { 'type': 'multiple_choice', 'question': 'Bentuk sopan (masu) dari "taberu" adalah:', 'japanese': 'たべます', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'tabemasu', 'romaji': ''}, {'code': 'B', 'text': 'taberimasu', 'romaji': ''}, {'code': 'C', 'text': 'tabemashita', 'romaji': ''}, {'code': 'D', 'text': 'tabenai', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "nomimasu"?', 'japanese': 'のみます', 'answer': 'minum' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Belajar"?', 'japanese': 'べんきょうする', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'hataraku', 'romaji': ''}, {'code': 'B', 'text': 'suru', 'romaji': ''}, {'code': 'C', 'text': 'benkyousuru', 'romaji': ''}, {'code': 'D', 'text': 'kuru', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata "imasu"?', 'japanese': 'います', 'answer': 'ada' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "ikimasu" (pergi) adalah:', 'japanese': 'きます', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'kaerimasu', 'romaji': ''}, {'code': 'B', 'text': 'kimasu', 'romaji': ''}, {'code': 'C', 'text': 'shimasu', 'romaji': ''}, {'code': 'D', 'text': 'arimasu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata kerja "かう"?', 'japanese': 'かう', 'answer': 'membeli' },
  ];

  // --- GRAMMAR VERBS 2 ---
  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'japanese': 'みる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'melihat' },
    { 'type': 'essay', 'japanese': 'きく', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'mendengar' },
    { 'type': 'essay', 'japanese': 'かく', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'menulis' },
    { 'type': 'essay', 'japanese': 'よむ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'membaca' },
    { 'type': 'essay', 'japanese': 'およぐ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'berenang' },
    { 'type': 'essay', 'japanese': 'まつ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'menunggu' },
  ];

  static final List<Map<String, dynamic>> _gv2Star2 = [
    { 'type': 'essay', 'japanese': 'かえる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'pulang' },
    { 'type': 'essay', 'japanese': 'とる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'mengambil' },
    { 'type': 'essay', 'japanese': 'たつ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'berdiri' },
    { 'type': 'essay', 'japanese': 'すわる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'duduk' },
    { 'type': 'essay', 'japanese': 'きる', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'mengenakan' },
    { 'type': 'essay', 'japanese': 'しぬ', 'question': 'Apa arti dari kata kerja ini dalam bahasa Indonesia?', 'answer': 'mati' },
  ];

  static final List<Map<String, dynamic>> _gv2Star3 = [
    { 'type': 'multiple_choice', 'question': 'Bentuk sopan dari "miru" (melihat) adalah:', 'japanese': 'みます', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'mimasu', 'romaji': ''}, {'code': 'B', 'text': 'mirimasu', 'romaji': ''}, {'code': 'C', 'text': 'mishimasu', 'romaji': ''}, {'code': 'D', 'text': 'minai', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "kakimasu"?', 'japanese': 'かきます', 'answer': 'menulis' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Berenang"?', 'japanese': 'およぐ', 'correctIndex': 3, 'options': [{'code': 'A', 'text': 'kaku', 'romaji': ''}, {'code': 'B', 'text': 'yomu', 'romaji': ''}, {'code': 'C', 'text': 'matsu', 'romaji': ''}, {'code': 'D', 'text': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata "kiku"?', 'japanese': 'きく', 'answer': 'mendengar' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "tatsu" (berdiri) adalah:', 'japanese': 'すわる', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'miru', 'romaji': ''}, {'code': 'B', 'text': 'kaku', 'romaji': ''}, {'code': 'C', 'text': 'suwaru', 'romaji': ''}, {'code': 'D', 'text': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari kata "yomu"?', 'japanese': 'よむ', 'answer': 'membaca' },
  ];

  // --- BASIC ADJECTIVES ---
  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'japanese': 'おいしい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'enak' },
    { 'type': 'essay', 'japanese': 'たかい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'mahal' },
    { 'type': 'essay', 'japanese': 'やすい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'murah' },
    { 'type': 'essay', 'japanese': 'おおきい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'besar' },
    { 'type': 'essay', 'japanese': 'ちいさい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'kecil' },
    { 'type': 'essay', 'japanese': 'あたらしい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'baru' },
  ];

  static final List<Map<String, dynamic>> _adjStar2 = [
    { 'type': 'essay', 'japanese': 'ふるい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'lama' },
    { 'type': 'essay', 'japanese': 'いい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'bagus' },
    { 'type': 'essay', 'japanese': 'わるい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'buruk' },
    { 'type': 'essay', 'japanese': 'むずかしい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'sulit' },
    { 'type': 'essay', 'japanese': 'やさしい', 'question': 'Apa arti dari kata sifat ini dalam bahasa Indonesia?', 'answer': 'mudah' },
    { 'type': 'essay', 'japanese': 'とても', 'question': 'Apa arti dari kata ini dalam bahasa Indonesia?', 'answer': 'sangat' },
  ];

  static final List<Map<String, dynamic>> _adjStar3 = [
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "takai" (mahal) adalah:', 'japanese': 'やすい', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'Enak', 'romaji': ''}, {'code': 'B', 'text': 'Murah', 'romaji': ''}, {'code': 'C', 'text': 'Lama/Tua', 'romaji': ''}, {'code': 'D', 'text': 'Besar', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "chiisai"?', 'japanese': 'ちいさい', 'answer': 'kecil' },
    { 'type': 'multiple_choice', 'question': 'Manakah yang berarti "Sulit"?', 'japanese': 'むずかしい', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'Mudah', 'romaji': ''}, {'code': 'B', 'text': 'Baru', 'romaji': ''}, {'code': 'C', 'text': 'Sulit', 'romaji': ''}, {'code': 'D', 'text': 'Enak', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "ii"?', 'japanese': 'いい', 'answer': 'bagus' },
    { 'type': 'multiple_choice', 'question': 'Lawan kata dari "atarashii" (baru) adalah:', 'japanese': 'ふるい', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'Lama/Tua', 'romaji': ''}, {'code': 'B', 'text': 'Mahal', 'romaji': ''}, {'code': 'C', 'text': 'Besar', 'romaji': ''}, {'code': 'D', 'text': 'Buruk', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'Apa arti dari "oishii"?', 'japanese': 'おいしい', 'answer': 'enak' },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [
    ..._gpStar1.sublist(0, 2), ..._gpStar2.sublist(0, 2), ..._gpStar3.sublist(0, 2),
    ..._gv1Star1.sublist(0, 2), ..._gv1Star2.sublist(0, 2), ..._gv1Star3.sublist(0, 2),
    ..._gv2Star1.sublist(0, 2), ..._gv2Star2.sublist(0, 2), ..._gv2Star3.sublist(0, 2),
    ..._adjStar1.sublist(0, 2), ..._adjStar2.sublist(0, 2), ..._adjStar3.sublist(0, 2),
  ];
}
