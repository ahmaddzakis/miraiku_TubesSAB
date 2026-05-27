class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars) {
    if (unit == 1) {
      if (difficulty == 'test') return _u1UnitTest;
      if (difficulty == 'hiragana_1') return _getStarSet(_h1Star1, _h1Star1, _h1Star1, currentStars);
      if (difficulty == 'hiragana_2') return _getStarSet(_h2Star1, _h2Star1, _h2Star1, currentStars);
      if (difficulty == 'hiragana_3') return _getStarSet(_h3Star1, _h3Star1, _h3Star1, currentStars);
      if (difficulty == 'hiragana_4') return _getStarSet(_h4Star1, _h4Star1, _h4Star1, currentStars);
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

  // --- UNIT 1: HIRAGANA (12 Soal) ---
  static final List<Map<String, dynamic>> _h1Star1 = [
    { 'type': 'multiple_choice', 'question': 'A:', 'japanese': 'あ', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'a', 'romaji': ''}, {'code': 'B', 'text': 'i', 'romaji': ''}, {'code': 'C', 'text': 'u', 'romaji': ''}, {'code': 'D', 'text': 'e', 'romaji': ''}] },
    { 'type': 'essay', 'question': 'I:', 'japanese': 'い', 'answer': 'i' },
    { 'type': 'essay', 'question': 'U:', 'japanese': 'う', 'answer': 'u' },
    { 'type': 'essay', 'question': 'E:', 'japanese': 'え', 'answer': 'e' },
    { 'type': 'essay', 'question': 'O:', 'japanese': 'お', 'answer': 'o' },
    { 'type': 'essay', 'question': 'Ka:', 'japanese': 'か', 'answer': 'ka' },
    { 'type': 'essay', 'question': 'Ki:', 'japanese': 'き', 'answer': 'ki' },
    { 'type': 'essay', 'question': 'Ku:', 'japanese': 'く', 'answer': 'ku' },
    { 'type': 'essay', 'question': 'Ke:', 'japanese': 'け', 'answer': 'ke' },
    { 'type': 'essay', 'question': 'Ko:', 'japanese': 'こ', 'answer': 'ko' },
    { 'type': 'essay', 'question': 'Sa:', 'japanese': 'さ', 'answer': 'sa' },
    { 'type': 'essay', 'question': 'Shi:', 'japanese': 'し', 'answer': 'shi' },
  ];

  static final List<Map<String, dynamic>> _h2Star1 = [
    { 'type': 'essay', 'japanese': 'す', 'question': 'Su:', 'answer': 'su' },
    { 'type': 'essay', 'japanese': 'せ', 'question': 'Se:', 'answer': 'se' },
    { 'type': 'essay', 'japanese': 'そ', 'question': 'So:', 'answer': 'so' },
    { 'type': 'essay', 'japanese': 'た', 'question': 'Ta:', 'answer': 'ta' },
    { 'type': 'essay', 'japanese': 'ち', 'question': 'Chi:', 'answer': 'chi' },
    { 'type': 'essay', 'japanese': 'つ', 'question': 'Tsu:', 'answer': 'tsu' },
    { 'type': 'essay', 'japanese': 'て', 'question': 'Te:', 'answer': 'te' },
    { 'type': 'essay', 'japanese': 'と', 'question': 'To:', 'answer': 'to' },
    { 'type': 'essay', 'japanese': 'な', 'question': 'Na:', 'answer': 'na' },
    { 'type': 'essay', 'japanese': 'に', 'question': 'Ni:', 'answer': 'ni' },
    { 'type': 'essay', 'japanese': 'ぬ', 'question': 'Nu:', 'answer': 'nu' },
    { 'type': 'essay', 'japanese': 'ね', 'question': 'Ne:', 'answer': 'ne' },
  ];

  static final List<Map<String, dynamic>> _h3Star1 = [
    { 'type': 'essay', 'japanese': 'の', 'question': 'No:', 'answer': 'no' },
    { 'type': 'essay', 'japanese': 'は', 'question': 'Ha:', 'answer': 'ha' },
    { 'type': 'essay', 'japanese': 'ひ', 'question': 'Hi:', 'answer': 'hi' },
    { 'type': 'essay', 'japanese': 'ふ', 'question': 'Fu:', 'answer': 'fu' },
    { 'type': 'essay', 'japanese': 'へ', 'question': 'He:', 'answer': 'he' },
    { 'type': 'essay', 'japanese': 'ほ', 'question': 'Ho:', 'answer': 'ho' },
    { 'type': 'essay', 'japanese': 'ま', 'question': 'Ma:', 'answer': 'ma' },
    { 'type': 'essay', 'japanese': 'み', 'question': 'Mi:', 'answer': 'mi' },
    { 'type': 'essay', 'japanese': 'む', 'question': 'Mu:', 'answer': 'mu' },
    { 'type': 'essay', 'japanese': 'め', 'question': 'Me:', 'answer': 'me' },
    { 'type': 'essay', 'japanese': 'も', 'question': 'Mo:', 'answer': 'mo' },
    { 'type': 'essay', 'japanese': 'や', 'question': 'Ya:', 'answer': 'ya' },
  ];

  static final List<Map<String, dynamic>> _h4Star1 = [
    { 'type': 'essay', 'japanese': 'ゆ', 'question': 'Yu:', 'answer': 'yu' },
    { 'type': 'essay', 'japanese': 'よ', 'question': 'Yo:', 'answer': 'yo' },
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

  static final List<Map<String, dynamic>> _greetStar1 = [
    { 'type': 'essay', 'question': 'Pagi:', 'japanese': 'おはよう', 'answer': 'ohayou' },
    { 'type': 'essay', 'question': 'Siang:', 'japanese': 'こんにちは', 'answer': 'konnichiwa' },
    { 'type': 'essay', 'question': 'Malam:', 'japanese': 'こんばんは', 'answer': 'konbanwa' },
    { 'type': 'essay', 'question': 'Tidur:', 'japanese': 'おやすみなさい', 'answer': 'oyasuminasai' },
    { 'type': 'essay', 'question': 'Kabar?', 'japanese': 'おげんきですか', 'answer': 'ogenkidesuka' },
    { 'type': 'essay', 'question': 'Senang bertemu:', 'japanese': 'はじめまして', 'answer': 'hajimemashite' },
    { 'type': 'essay', 'question': 'Terima kasih:', 'japanese': 'ありがとう', 'answer': 'arigatou' },
    { 'type': 'essay', 'question': 'Sama-sama:', 'japanese': 'どういたしまして', 'answer': 'douitashimashite' },
    { 'type': 'essay', 'question': 'Maaf:', 'japanese': 'ごめんなさい', 'answer': 'gomennasai' },
    { 'type': 'essay', 'question': 'Permisi:', 'japanese': 'すみません', 'answer': 'sumimasen' },
    { 'type': 'essay', 'question': 'Sampai jumpa:', 'japanese': 'さようなら', 'answer': 'sayounara' },
    { 'type': 'essay', 'question': 'Nanti ya:', 'japanese': 'またね', 'answer': 'matane' },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'essay', 'question': '1:', 'japanese': 'いち', 'answer': 'ichi' },
    { 'type': 'essay', 'question': '2:', 'japanese': 'に', 'answer': 'ni' },
    { 'type': 'essay', 'question': '3:', 'japanese': 'さん', 'answer': 'san' },
    { 'type': 'essay', 'question': '4:', 'japanese': 'よん', 'answer': 'yon' },
    { 'type': 'essay', 'question': '5:', 'japanese': 'ご', 'answer': 'go' },
    { 'type': 'essay', 'question': '6:', 'japanese': 'ろく', 'answer': 'roku' },
    { 'type': 'essay', 'question': '7:', 'japanese': 'なな', 'answer': 'nana' },
    { 'type': 'essay', 'question': '8:', 'japanese': 'はち', 'answer': 'hachi' },
    { 'type': 'essay', 'question': '9:', 'japanese': 'きゅう', 'answer': 'kyuu' },
    { 'type': 'essay', 'question': '10:', 'japanese': 'じゅう', 'answer': 'juu' },
    { 'type': 'essay', 'question': '100:', 'japanese': 'ひゃく', 'answer': 'hyaku' },
    { 'type': 'essay', 'question': '1000:', 'japanese': 'せん', 'answer': 'sen' },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'essay', 'question': 'Makan:', 'japanese': 'たべる', 'answer': 'taberu' },
    { 'type': 'essay', 'question': 'Minum:', 'japanese': 'のむ', 'answer': 'nomu' },
    { 'type': 'essay', 'question': 'Melihat:', 'japanese': 'みる', 'answer': 'miru' },
    { 'type': 'essay', 'question': 'Mendengar:', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'essay', 'question': 'Membaca:', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'essay', 'question': 'Menulis:', 'japanese': 'かく', 'answer': 'kaku' },
    { 'type': 'essay', 'question': 'Pergi:', 'japanese': 'いく', 'answer': 'iku' },
    { 'type': 'essay', 'question': 'Datang:', 'japanese': 'くる', 'answer': 'kuru' },
    { 'type': 'essay', 'question': 'Pulang:', 'japanese': 'かえる', 'answer': 'kaeru' },
    { 'type': 'essay', 'question': 'Tidur:', 'japanese': 'ねる', 'answer': 'neru' },
    { 'type': 'essay', 'question': 'Bermain:', 'japanese': 'あそぶ', 'answer': 'asobu' },
    { 'type': 'essay', 'question': 'Membeli:', 'japanese': 'かう', 'answer': 'kau' },
  ];

  static final List<Map<String, dynamic>> _u1UnitTest = [
    ..._h1Star1, ..._h2Star1, ..._greetStar1.sublist(0, 6)
  ].sublist(0, 30);

  // --- UNIT 2: KATAKANA (Sample) ---
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
    { 'type': 'essay', 'japanese': 'ヒ', 'question': 'Hi:', 'answer': 'hi' },
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
    { 'type': 'essay', 'japanese': 'ラ', 'question': 'Ra:', 'answer': 'ra' },
    { 'type': 'essay', 'japanese': 'リ', 'question': 'Ri:', 'answer': 'ri' },
    { 'type': 'essay', 'japanese': 'ル', 'question': 'Ru:', 'answer': 'ru' },
    { 'type': 'essay', 'japanese': 'レ', 'question': 'Re:', 'answer': 're' },
    { 'type': 'essay', 'japanese': 'ロ', 'question': 'Ro:', 'answer': 'ro' },
    { 'type': 'essay', 'japanese': 'ワ', 'question': 'Wa:', 'answer': 'wa' },
    { 'type': 'essay', 'japanese': 'ヲ', 'question': 'Wo:', 'answer': 'wo' },
    { 'type': 'essay', 'japanese': 'ン', 'question': 'N:', 'answer': 'n' },
    { 'type': 'essay', 'japanese': 'ガ', 'question': 'Ga:', 'answer': 'ga' },
    { 'type': 'essay', 'japanese': 'パ', 'question': 'Pa:', 'answer': 'pa' },
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

  // --- UNIT 3: BASIC KANJI ---
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
    { 'type': 'essay', 'question': 'Pohon:', 'japanese': '木', 'answer': 'ki' },
    { 'type': 'essay', 'question': 'Logam/Uang:', 'japanese': '金', 'answer': 'kane' },
    { 'type': 'essay', 'question': 'Tanah:', 'japanese': '土', 'answer': 'tsuchi' },
    { 'type': 'essay', 'question': 'Gunung:', 'japanese': '山', 'answer': 'yama' },
    { 'type': 'essay', 'question': 'Sungai:', 'japanese': '川', 'answer': 'kawa' },
    { 'type': 'essay', 'question': 'Sawah:', 'japanese': '田', 'answer': 'ta' },
    { 'type': 'essay', 'question': 'Langit:', 'japanese': '天', 'answer': 'ten' },
    { 'type': 'essay', 'question': 'Batu:', 'japanese': '石', 'answer': 'ishi' },
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

  // --- UNIT 4: BASIC GRAMMAR ---
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
    { 'type': 'essay', 'question': 'Datang:', 'japanese': 'くる', 'answer': 'kuru' },
    { 'type': 'essay', 'question': 'Melakukan:', 'japanese': 'する', 'answer': 'suru' },
    { 'type': 'essay', 'question': 'Membeli:', 'japanese': 'かう', 'answer': 'kau' },
    { 'type': 'essay', 'question': 'Mengerti:', 'japanese': 'わかる', 'answer': 'wakaru' },
    { 'type': 'essay', 'question': 'Berbicara:', 'japanese': 'はなす', 'answer': 'hanasu' },
    { 'type': 'essay', 'question': 'Ada (Benda Mati):', 'japanese': 'あります', 'answer': 'arimasu' },
    { 'type': 'essay', 'question': 'Ada (Benda Hidup):', 'japanese': 'います', 'answer': 'imasu' },
    { 'type': 'essay', 'question': 'Bekerja:', 'japanese': 'はたらく', 'answer': 'hataraku' },
    { 'type': 'essay', 'question': 'Belajar:', 'japanese': 'べんきょうする', 'answer': 'benkyousuru' },
  ];

  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'question': 'Melihat:', 'japanese': 'みる', 'answer': 'miru' },
    { 'type': 'essay', 'question': 'Mendengar:', 'japanese': 'きく', 'answer': 'kiku' },
    { 'type': 'essay', 'question': 'Menulis:', 'japanese': 'かく', 'answer': 'kaku' },
    { 'type': 'essay', 'question': 'Membaca:', 'japanese': 'よむ', 'answer': 'yomu' },
    { 'type': 'essay', 'question': 'Berenang:', 'japanese': 'およぐ', 'answer': 'oyogu' },
    { 'type': 'essay', 'question': 'Menunggu:', 'japanese': 'まつ', 'answer': 'matsu' },
    { 'type': 'essay', 'question': 'Pulang:', 'japanese': 'かえる', 'answer': 'kaeru' },
    { 'type': 'essay', 'question': 'Mengambil:', 'japanese': 'とる', 'answer': 'toru' },
    { 'type': 'essay', 'question': 'Berdiri:', 'japanese': 'たつ', 'answer': 'tatsu' },
    { 'type': 'essay', 'question': 'Duduk:', 'japanese': 'すわる', 'answer': 'suwaru' },
    { 'type': 'essay', 'question': 'Mengenakan:', 'japanese': 'きる', 'answer': 'kiru' },
    { 'type': 'essay', 'question': 'Mati:', 'japanese': 'しぬ', 'answer': 'shinu' },
  ];

  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'question': 'Enak:', 'japanese': 'おいしい', 'answer': 'oishii' },
    { 'type': 'essay', 'question': 'Mahal:', 'japanese': 'たかい', 'answer': 'takai' },
    { 'type': 'essay', 'question': 'Murah:', 'japanese': 'やすい', 'answer': 'yasui' },
    { 'type': 'essay', 'question': 'Besar:', 'japanese': 'おおきい', 'answer': 'ookii' },
    { 'type': 'essay', 'question': 'Kecil:', 'japanese': 'ちいさい', 'answer': 'chiisai' },
    { 'type': 'essay', 'question': 'Baru:', 'japanese': 'あたらしい', 'answer': 'atarashii' },
    { 'type': 'essay', 'question': 'Lama/Tua:', 'japanese': 'ふるい', 'answer': 'furui' },
    { 'type': 'essay', 'question': 'Bagus:', 'japanese': 'いい', 'answer': 'ii' },
    { 'type': 'essay', 'question': 'Buruk:', 'japanese': 'わるい', 'answer': 'warui' },
    { 'type': 'essay', 'question': 'Sulit:', 'japanese': 'むずかしい', 'answer': 'muzukashii' },
    { 'type': 'essay', 'question': 'Mudah:', 'japanese': 'やさしい', 'answer': 'yasashii' },
    { 'type': 'essay', 'question': 'Sangat:', 'japanese': 'とても', 'answer': 'totemo' },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [..._gpStar1, ..._gv1Star1, ..._adjStar1.sublist(0, 6)];
}
