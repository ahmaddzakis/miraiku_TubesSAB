import '../core/localization/app_localizations.dart';

class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars, String languageCode) {
    List<Map<String, dynamic>> rawQuestions = [];
    if (unit == 1) {
      if (difficulty == 'test') {
        rawQuestions = _u1UnitTest;
      } else if (difficulty == 'hiragana_1') {
        rawQuestions = _getStarSet(_h1Star1, _h1Star2, _h1Star3, currentStars);
      } else if (difficulty == 'hiragana_2') {
        rawQuestions = _getStarSet(_h2Star1, _h2Star2, _h2Star3, currentStars);
      } else if (difficulty == 'hiragana_3') {
        rawQuestions = _getStarSet(_h3Star1, _h3Star2, _h3Star3, currentStars);
      } else if (difficulty == 'hiragana_4') {
        rawQuestions = _getStarSet(_h4Star1, _h4Star2, _h4Star3, currentStars);
      } else if (difficulty == 'greetings') {
        rawQuestions = _getStarSet(_greetStar1, _greetStar2, _greetStar3, currentStars);
      } else if (difficulty == 'numbers') {
        rawQuestions = _getStarSet(_numStar1, _numStar2, _numStar3, currentStars);
      } else if (difficulty == 'verbs') {
        rawQuestions = _getStarSet(_verbStar1, _verbStar2, _verbStar3, currentStars);
      }
    }
    else if (unit == 2) {
      if (difficulty == 'test') {
        rawQuestions = _u2UnitTest;
      } else if (difficulty == 'katakana_1') {
        rawQuestions = _getStarSet(_k1Star1, _k1Star2, _k1Star3, currentStars);
      } else if (difficulty == 'katakana_2') {
        rawQuestions = _getStarSet(_k2Star1, _k2Star2, _k2Star3, currentStars);
      } else if (difficulty == 'katakana_3') {
        rawQuestions = _getStarSet(_k3Star1, _k3Star2, _k3Star3, currentStars);
      } else if (difficulty == 'katakana_4') {
        rawQuestions = _getStarSet(_k4Star1, _k4Star2, _k4Star3, currentStars);
      } else if (difficulty == 'katakana_words') {
        rawQuestions = _getStarSet(_kataWordStar1, _kataWordStar2, _kataWordStar3, currentStars);
      } else if (difficulty == 'loanwords') {
        rawQuestions = _getStarSet(_loanWordStar1, _loanWordStar2, _loanWordStar3, currentStars);
      }
    }
    else if (unit == 3) {
      if (difficulty == 'test') {
        rawQuestions = _u3UnitTest;
      } else if (difficulty == 'kanji_numbers') {
        rawQuestions = _getStarSet(_knStar1, _knStar2, _knStar3, currentStars);
      } else if (difficulty == 'kanji_nature') {
        rawQuestions = _getStarSet(_kanjiNatureStar1, _kanjiNatureStar2, _kanjiNatureStar3, currentStars);
      } else if (difficulty == 'kanji_people') {
        rawQuestions = _getStarSet(_kanjiPeopleStar1, _kanjiPeopleStar2, _kanjiPeopleStar3, currentStars);
      }
    }
    else if (unit == 4) {
      if (difficulty == 'test') {
        rawQuestions = _u4UnitTest;
      } else if (difficulty == 'grammar_particles') {
        rawQuestions = _getStarSet(_gpStar1, _gpStar2, _gpStar3, currentStars);
      } else if (difficulty == 'grammar_verbs_1') {
        rawQuestions = _getStarSet(_gv1Star1, _gv1Star2, _gv1Star3, currentStars);
      } else if (difficulty == 'grammar_verbs_2') {
        rawQuestions = _getStarSet(_gv2Star1, _gv2Star2, _gv2Star3, currentStars);
      } else if (difficulty == 'grammar_adjectives') {
        rawQuestions = _getStarSet(_adjStar1, _adjStar2, _adjStar3, currentStars);
      }
    }

    if (rawQuestions.isEmpty) rawQuestions = _h1Star1;

    // Apply localization
    return rawQuestions.map((q) => _localizeQuestion(q, languageCode)).toList();
  }

  static Map<String, dynamic> _localizeQuestion(Map<String, dynamic> q, String lang) {
    final Map<String, dynamic> localized = Map<String, dynamic>.from(q);

    // 1. Localize question text via centralized AppLocalizations
    if (q['is_reading'] == true) {
      localized['question'] = AppLocalizations.characterReadingQuestion(lang);
    } else if (q.containsKey('hint_id') && q.containsKey('hint_en')) {
      localized['question'] = AppLocalizations.wordMeaningWithHintQuestion(
        q['hint_en'].toString(),
        q['hint_id'].toString(),
        lang,
      );
    } else if (q.containsKey('question_id') || q.containsKey('question_en')) {
      localized['question'] = lang == 'id'
          ? (q['question_id'] ?? q['question'] ?? q['question_en'])
          : (q['question_en'] ?? q['question'] ?? q['question_id']);
    } else if (q['type'] == 'essay') {
      localized['question'] = AppLocalizations.wordMeaningQuestion(lang);
    }

    // 2. Localize answer text (bilingual meaning: {id: ..., en: ...} or legacy answer_id/answer_en)
    final dynamic meaning = q['meaning'];
    if (meaning is Map) {
      localized['answer'] = lang == 'id'
          ? (meaning['id'] ?? meaning['en'])
          : (meaning['en'] ?? meaning['id']);
    } else if (q.containsKey('answer_id') || q.containsKey('answer_en')) {
      localized['answer'] = lang == 'id'
          ? (q['answer_id'] ?? q['answer'] ?? q['answer_en'])
          : (q['answer_en'] ?? q['answer'] ?? q['answer_id']);
    }

    // 3. Localize options (for multiple choice)
    if (q.containsKey('options')) {
      localized['options'] = (q['options'] as List).map((opt) {
        final Map<String, dynamic> optMap = Map<String, dynamic>.from(opt);
        if (optMap.containsKey('text_id') || optMap.containsKey('text_en')) {
          optMap['text'] = lang == 'id'
              ? (optMap['text_id'] ?? optMap['text'] ?? optMap['text_en'])
              : (optMap['text_en'] ?? optMap['text'] ?? optMap['text_id']);
        }
        return optMap;
      }).toList();
    }

    return localized;
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
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'A', 'correctIndex': 0, 'options': [{'code': 'A', 'text': 'あ', 'romaji': ''}, {'code': 'B', 'text': 'お', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'え', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'い', 'kanji': '胃', 'meaning': {'id': 'perut', 'en': 'stomach'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'U', 'correctIndex': 2, 'options': [{'code': 'A', 'text': 'い', 'romaji': ''}, {'code': 'B', 'text': 'え', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'あ', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'え', 'kanji': '絵', 'meaning': {'id': 'gambar', 'en': 'picture'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'O', 'correctIndex': 1, 'options': [{'code': 'A', 'text': 'あ', 'romaji': ''}, {'code': 'B', 'text': 'お', 'romaji': ''}, {'code': 'C', 'text': 'う', 'romaji': ''}, {'code': 'D', 'text': 'い', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'あお', 'kanji': '青', 'meaning': {'id': 'biru', 'en': 'blue'} },
  ];

  static final List<Map<String, dynamic>> _h1Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'KA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'か', 'text_en': 'ka', 'romaji': ''}, {'code': 'B', 'text_id': 'き', 'text_en': 'ki', 'romaji': ''}, {'code': 'C', 'text_id': 'く', 'text_en': 'ku', 'romaji': ''}, {'code': 'D', 'text_id': 'こ', 'text_en': 'ko', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'き', 'kanji': '木', 'meaning': {'id': 'pohon', 'en': 'tree'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'KU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'け', 'text_en': 'ke', 'romaji': ''}, {'code': 'B', 'text_id': 'こ', 'text_en': 'ko', 'romaji': ''}, {'code': 'C', 'text_id': 'く', 'text_en': 'ku', 'romaji': ''}, {'code': 'D', 'text_id': 'か', 'text_en': 'ka', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'け', 'kanji': '毛', 'meaning': {'id': 'rambut', 'en': 'hair'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'KO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'か', 'text_en': 'ka', 'romaji': ''}, {'code': 'B', 'text_id': 'こ', 'text_en': 'ko', 'romaji': ''}, {'code': 'C', 'text_id': 'き', 'text_en': 'ki', 'romaji': ''}, {'code': 'D', 'text_id': 'く', 'text_en': 'ku', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'かき', 'kanji': '柿', 'meaning': {'id': 'kesemek', 'en': 'persimmon'} },
  ];

  static final List<Map<String, dynamic>> _h1Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'SA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'さ', 'text_en': 'sa', 'romaji': ''}, {'code': 'B', 'text_id': 'し', 'text_en': 'shi', 'romaji': ''}, {'code': 'C', 'text_id': 'す', 'text_en': 'su', 'romaji': ''}, {'code': 'D', 'text_id': 'そ', 'text_en': 'so', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'し', 'kanji': '市', 'meaning': {'id': 'kota', 'en': 'city'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'SU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'せ', 'text_en': 'se', 'romaji': ''}, {'code': 'B', 'text_id': 'そ', 'text_en': 'so', 'romaji': ''}, {'code': 'C', 'text_id': 'す', 'text_en': 'su', 'romaji': ''}, {'code': 'D', 'text_id': 'さ', 'text_en': 'sa', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'せ', 'kanji': '背', 'meaning': {'id': 'punggung', 'en': 'back'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'SO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'さ', 'text_en': 'sa', 'romaji': ''}, {'code': 'B', 'text_id': 'そ', 'text_en': 'so', 'romaji': ''}, {'code': 'C', 'text_id': 'す', 'text_en': 'su', 'romaji': ''}, {'code': 'D', 'text_id': 'し', 'text_en': 'shi', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'すし', 'kanji': null, 'meaning': {'id': 'sushi', 'en': 'sushi'} },
  ];

  // HIRAGANA 2 (TA-TO, NA-NO, HA-HO)
  static final List<Map<String, dynamic>> _h2Star1 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'TA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'た', 'text_en': 'ta', 'romaji': ''}, {'code': 'B', 'text_id': 'ち', 'text_en': 'chi', 'romaji': ''}, {'code': 'C', 'text_id': 'つ', 'text_en': 'tsu', 'romaji': ''}, {'code': 'D', 'text_id': 'と', 'text_en': 'to', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ち', 'kanji': '血', 'meaning': {'id': 'darah', 'en': 'blood'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'TSU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'て', 'text_en': 'te', 'romaji': ''}, {'code': 'B', 'text_id': 'と', 'text_en': 'to', 'romaji': ''}, {'code': 'C', 'text_id': 'つ', 'text_en': 'tsu', 'romaji': ''}, {'code': 'D', 'text_id': 'た', 'text_en': 'ta', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'て', 'kanji': '手', 'meaning': {'id': 'tangan', 'en': 'hand'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'TO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'た', 'text_en': 'ta', 'romaji': ''}, {'code': 'B', 'text_id': 'と', 'text_en': 'to', 'romaji': ''}, {'code': 'C', 'text_id': 'て', 'text_en': 'te', 'romaji': ''}, {'code': 'D', 'text_id': 'つ', 'text_en': 'tsu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'てつ', 'kanji': '鉄', 'meaning': {'id': 'besi', 'en': 'iron'} },
  ];

  static final List<Map<String, dynamic>> _h2Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'NA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'な', 'text_en': 'na', 'romaji': ''}, {'code': 'B', 'text_id': 'に', 'text_en': 'ni', 'romaji': ''}, {'code': 'C', 'text_id': 'ぬ', 'text_en': 'nu', 'romaji': ''}, {'code': 'D', 'text_id': 'の', 'text_en': 'no', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'に', 'kanji': '二', 'meaning': {'id': 'dua', 'en': 'two'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'NU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ね', 'text_en': 'ne', 'romaji': ''}, {'code': 'B', 'text_id': 'の', 'text_en': 'no', 'romaji': ''}, {'code': 'C', 'text_id': 'ぬ', 'text_en': 'nu', 'romaji': ''}, {'code': 'D', 'text_id': 'な', 'text_en': 'na', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ね', 'kanji': '根', 'meaning': {'id': 'akar', 'en': 'root'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'NO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'な', 'text_en': 'na', 'romaji': ''}, {'code': 'B', 'text_id': 'の', 'text_en': 'no', 'romaji': ''}, {'code': 'C', 'text_id': 'に', 'text_en': 'ni', 'romaji': ''}, {'code': 'D', 'text_id': 'ぬ', 'text_en': 'nu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'なに', 'kanji': '何', 'meaning': {'id': 'apa', 'en': 'what'} },
  ];

  static final List<Map<String, dynamic>> _h2Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'HA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'は', 'text_en': 'ha', 'romaji': ''}, {'code': 'B', 'text_id': 'ひ', 'text_en': 'hi', 'romaji': ''}, {'code': 'C', 'text_id': 'ふ', 'text_en': 'fu', 'romaji': ''}, {'code': 'D', 'text_id': 'ほ', 'text_en': 'ho', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ひ', 'kanji': '火', 'meaning': {'id': 'api', 'en': 'fire'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'FU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'へ', 'text_en': 'he', 'romaji': ''}, {'code': 'B', 'text_id': 'ほ', 'text_en': 'ho', 'romaji': ''}, {'code': 'C', 'text_id': 'ふ', 'text_en': 'fu', 'romaji': ''}, {'code': 'D', 'text_id': 'は', 'text_en': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'は', 'kanji': '葉', 'meaning': {'id': 'daun', 'en': 'leaf'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'HO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'は', 'text_en': 'ha', 'romaji': ''}, {'code': 'B', 'text_id': 'ほ', 'text_en': 'ho', 'romaji': ''}, {'code': 'C', 'text_id': 'ひ', 'text_en': 'hi', 'romaji': ''}, {'code': 'D', 'text_id': 'ふ', 'text_en': 'fu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はな', 'kanji': '花', 'meaning': {'id': 'bunga', 'en': 'flower'} },
  ];

  // HIRAGANA 3 (MA-MO, YA-YO, RA-RO)
  static final List<Map<String, dynamic>> _h3Star1 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'MA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ま', 'text_en': 'ma', 'romaji': ''}, {'code': 'B', 'text_id': 'み', 'text_en': 'mi', 'romaji': ''}, {'code': 'C', 'text_id': 'む', 'text_en': 'mu', 'romaji': ''}, {'code': 'D', 'text_id': 'も', 'text_en': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'み', 'kanji': '実', 'meaning': {'id': 'buah', 'en': 'fruit'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'MU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'め', 'text_en': 'me', 'romaji': ''}, {'code': 'B', 'text_id': 'も', 'text_en': 'mo', 'romaji': ''}, {'code': 'C', 'text_id': 'む', 'text_en': 'mu', 'romaji': ''}, {'code': 'D', 'text_id': 'ま', 'text_en': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'め', 'kanji': '目', 'meaning': {'id': 'mata', 'en': 'eye'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'MO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ま', 'text_en': 'ma', 'romaji': ''}, {'code': 'B', 'text_id': 'も', 'text_en': 'mo', 'romaji': ''}, {'code': 'C', 'text_id': 'み', 'text_en': 'mi', 'romaji': ''}, {'code': 'D', 'text_id': 'む', 'text_en': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'もも', 'kanji': '桃', 'meaning': {'id': 'persik', 'en': 'peach'} },
  ];

  static final List<Map<String, dynamic>> _h3Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'YA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'や', 'text_en': 'ya', 'romaji': ''}, {'code': 'B', 'text_id': 'ゆ', 'text_en': 'yu', 'romaji': ''}, {'code': 'C', 'text_id': 'よ', 'text_en': 'yo', 'romaji': ''}, {'code': 'D', 'text_id': 'あ', 'text_en': 'a', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ゆ', 'kanji': '湯', 'meaning': {'id': 'air panas', 'en': 'hot water'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'YO', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'や', 'text_en': 'ya', 'romaji': ''}, {'code': 'B', 'text_id': 'ゆ', 'text_en': 'yu', 'romaji': ''}, {'code': 'C', 'text_id': 'よ', 'text_en': 'yo', 'romaji': ''}, {'code': 'D', 'text_id': 'お', 'text_en': 'o', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'やま', 'kanji': '山', 'meaning': {'id': 'gunung', 'en': 'mountain'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'YA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'や', 'text_en': 'ya', 'romaji': ''}, {'code': 'B', 'text_id': 'ゆ', 'text_en': 'yu', 'romaji': ''}, {'code': 'C', 'text_id': 'よ', 'text_en': 'yo', 'romaji': ''}, {'code': 'D', 'text_id': 'わ', 'text_en': 'wa', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ゆめ', 'kanji': '夢', 'meaning': {'id': 'mimpi', 'en': 'dream'} },
  ];

  static final List<Map<String, dynamic>> _h3Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'RA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ら', 'text_en': 'ra', 'romaji': ''}, {'code': 'B', 'text_id': 'り', 'text_en': 'ri', 'romaji': ''}, {'code': 'C', 'text_id': 'る', 'text_en': 'ru', 'romaji': ''}, {'code': 'D', 'text_id': 'ろ', 'text_en': 'ro', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'り', 'kanji': null, 'meaning': {'id': 'ri', 'en': 'ri'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'RU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'れ', 'text_en': 're', 'romaji': ''}, {'code': 'B', 'text_id': 'ろ', 'text_en': 'ro', 'romaji': ''}, {'code': 'C', 'text_id': 'る', 'text_en': 'ru', 'romaji': ''}, {'code': 'D', 'text_id': 'ら', 'text_en': 'ra', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'れ', 'kanji': null, 'meaning': {'id': 're', 'en': 're'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'RO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ら', 'text_en': 'ra', 'romaji': ''}, {'code': 'B', 'text_id': 'ろ', 'text_en': 'ro', 'romaji': ''}, {'code': 'C', 'text_id': 'る', 'text_en': 'ru', 'romaji': ''}, {'code': 'D', 'text_id': 'り', 'text_en': 'ri', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'そら', 'kanji': '空', 'meaning': {'id': 'langit', 'en': 'sky'} },
  ];

  // HIRAGANA 4 (WA-N, DAKUON, HANDAKUON)
  static final List<Map<String, dynamic>> _h4Star1 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'WA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'わ', 'text_en': 'wa', 'romaji': ''}, {'code': 'B', 'text_id': 'を', 'text_en': 'wo', 'romaji': ''}, {'code': 'C', 'text_id': 'ん', 'text_en': 'n', 'romaji': ''}, {'code': 'D', 'text_id': 'は', 'text_en': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'を', 'kanji': null, 'meaning': {'id': 'wo', 'en': 'wo'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'N', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'む', 'text_en': 'mu', 'romaji': ''}, {'code': 'B', 'text_id': 'め', 'text_en': 'me', 'romaji': ''}, {'code': 'C', 'text_id': 'ん', 'text_en': 'n', 'romaji': ''}, {'code': 'D', 'text_id': 'ぬ', 'text_en': 'nu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'わたし', 'kanji': '私', 'meaning': {'id': 'saya', 'en': 'I / me'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'にほん', 'kanji': '日本', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'china', 'text_en': 'China', 'romaji': ''}, {'code': 'B', 'text_id': 'jepang', 'text_en': 'Japan', 'romaji': ''}, {'code': 'C', 'text_id': 'korea', 'text_en': 'Korea', 'romaji': ''}, {'code': 'D', 'text_id': 'amerika', 'text_en': 'America', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'わ', 'kanji': null, 'meaning': {'id': 'wa', 'en': 'wa'} },
  ];

  static final List<Map<String, dynamic>> _h4Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'GA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'が', 'text_en': 'ga', 'romaji': ''}, {'code': 'B', 'text_id': 'ぎ', 'text_en': 'gi', 'romaji': ''}, {'code': 'C', 'text_id': 'ぐ', 'text_en': 'gu', 'romaji': ''}, {'code': 'D', 'text_id': 'げ', 'text_en': 'ge', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ざ', 'kanji': null, 'meaning': {'id': 'za', 'en': 'za'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'DA', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'た', 'text_en': 'ta', 'romaji': ''}, {'code': 'B', 'text_id': 'ざ', 'text_en': 'za', 'romaji': ''}, {'code': 'C', 'text_id': 'だ', 'text_en': 'da', 'romaji': ''}, {'code': 'D', 'text_id': 'ば', 'text_en': 'ba', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ば', 'kanji': null, 'meaning': {'id': 'ba', 'en': 'ba'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'まんが', 'kanji': '漫画', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'kartun', 'text_en': 'cartoon', 'romaji': ''}, {'code': 'B', 'text_id': 'komik', 'text_en': 'manga / comic', 'romaji': ''}, {'code': 'C', 'text_id': 'majalah', 'text_en': 'magazine', 'romaji': ''}, {'code': 'D', 'text_id': 'novel', 'text_en': 'novel', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'がっこう', 'kanji': '学校', 'meaning': {'id': 'sekolah', 'en': 'school'} },
  ];

  static final List<Map<String, dynamic>> _h4Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'PA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ぱ', 'text_en': 'pa', 'romaji': ''}, {'code': 'B', 'text_id': 'ば', 'text_en': 'ba', 'romaji': ''}, {'code': 'C', 'text_id': 'は', 'text_en': 'ha', 'romaji': ''}, {'code': 'D', 'text_id': 'ま', 'text_en': 'ma', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ぴ', 'kanji': null, 'meaning': {'id': 'pi', 'en': 'pi'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'PU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ふ', 'text_en': 'fu', 'romaji': ''}, {'code': 'B', 'text_id': 'ぶ', 'text_en': 'bu', 'romaji': ''}, {'code': 'C', 'text_id': 'ぷ', 'text_en': 'pu', 'romaji': ''}, {'code': 'D', 'text_id': 'む', 'text_en': 'mu', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ぺ', 'kanji': null, 'meaning': {'id': 'pe', 'en': 'pe'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'PO', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ほ', 'text_en': 'ho', 'romaji': ''}, {'code': 'B', 'text_id': 'ぽ', 'text_en': 'po', 'romaji': ''}, {'code': 'C', 'text_id': 'ぼ', 'text_en': 'bo', 'romaji': ''}, {'code': 'D', 'text_id': 'も', 'text_en': 'mo', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ぱん', 'kanji': null, 'meaning': {'id': 'roti', 'en': 'bread'} },
  ];

  static final List<Map<String, dynamic>> _greetStar1 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari ungkapan ini?', 'question_en': 'What does this expression mean?', 'japanese': 'おはよう', 'kanji': null, 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Selamat Pagi', 'text_en': 'Good Morning', 'romaji': ''}, {'code': 'B', 'text_id': 'Selamat Tidur', 'text_en': 'Good Night', 'romaji': ''}, {'code': 'C', 'text_id': 'Selamat Atas...', 'text_en': 'Congratulations on...', 'romaji': ''}, {'code': 'D', 'text_id': 'Selamat Datang', 'text_en': 'Welcome', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'こんにちは', 'kanji': null, 'meaning': {'id': 'selamat siang', 'en': 'good afternoon'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari ungkapan ini?', 'question_en': 'What does this expression mean?', 'japanese': 'こんばんは', 'kanji': null, 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Selamat Siang', 'text_en': 'Good Afternoon', 'romaji': ''}, {'code': 'B', 'text_id': 'Malam Ini', 'text_en': 'Tonight', 'romaji': ''}, {'code': 'C', 'text_id': 'Selamat Malam', 'text_en': 'Good Evening', 'romaji': ''}, {'code': 'D', 'text_id': 'Sore Hari', 'text_en': 'Afternoon', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'おやすみなさい', 'kanji': null, 'meaning': {'id': 'selamat tidur', 'en': 'good night'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari ungkapan ini?', 'question_en': 'What does this expression mean?', 'japanese': 'おげんきですか', 'kanji': 'お元気ですか', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Terima Kasih', 'text_en': 'Thank You', 'romaji': ''}, {'code': 'B', 'text_id': 'Apa Kabar?', 'text_en': 'How are you?', 'romaji': ''}, {'code': 'C', 'text_id': 'Selamat Pagi', 'text_en': 'Good Morning', 'romaji': ''}, {'code': 'D', 'text_id': 'Senang Bertemu', 'text_en': 'Nice to meet you', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ありがとう', 'kanji': null, 'meaning': {'id': 'terima kasih', 'en': 'thank you'} },
  ];

  static final List<Map<String, dynamic>> _greetStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari ungkapan ini?', 'question_en': 'What does this expression mean?', 'japanese': 'すみません', 'kanji': null, 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Terima kasih', 'text_en': 'Thank you', 'romaji': ''}, {'code': 'B', 'text_id': 'Maaf / Permisi', 'text_en': 'Sorry / Excuse me', 'romaji': ''}, {'code': 'C', 'text_id': 'Selamat tinggal', 'text_en': 'Goodbye', 'romaji': ''}, {'code': 'D', 'text_id': 'Sama-sama', 'text_en': 'You are welcome', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はじめまして', 'kanji': null, 'meaning': {'id': 'senang bertemu denganmu', 'en': 'nice to meet you'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa balasan yang tepat untuk ungkapan ini?', 'question_en': 'What is the appropriate response to this expression?', 'japanese': 'ありがとう', 'kanji': null, 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Selamat Malam', 'text_en': 'Good Evening', 'romaji': ''}, {'code': 'B', 'text_id': 'Selamat Tidur', 'text_en': 'Good Night', 'romaji': ''}, {'code': 'C', 'text_id': 'Selamat Tinggal', 'text_en': 'Goodbye', 'romaji': ''}, {'code': 'D', 'text_id': 'Sama-sama', 'text_en': 'You are welcome', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'さようなら', 'kanji': null, 'meaning': {'id': 'selamat tinggal', 'en': 'goodbye'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat untuk sapaan "Selamat Siang":', 'question_en': 'Choose the correct writing for the greeting "Good Afternoon":', 'japanese': 'Selamat Siang', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'こんにちは', 'text_en': 'konnichiha', 'romaji': ''}, {'code': 'B', 'text_id': 'こにちわ', 'text_en': 'konichiwa', 'romaji': ''}, {'code': 'C', 'text_id': 'こんにちわ', 'text_en': 'konnichiwa', 'romaji': ''}, {'code': 'D', 'text_id': 'こにちは', 'text_en': 'konichiha', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'いただきます', 'kanji': null, 'meaning': {'id': 'selamat makan', 'en': 'itadakimasu (before eating)'} },
  ];

  static final List<Map<String, dynamic>> _greetStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Manakah ungkapan yang digunakan saat masuk rumah?', 'question_en': 'Which expression is used when entering home?', 'japanese': 'ただいま', 'kanji': null, 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Selamat Jalan', 'text_en': 'Have a good trip', 'romaji': ''}, {'code': 'B', 'text_id': 'Selamat Datang Kembali', 'text_en': 'Welcome back', 'romaji': ''}, {'code': 'C', 'text_id': 'Aku Pulang', 'text_en': 'I am home', 'romaji': ''}, {'code': 'D', 'text_id': 'Permisi', 'text_en': 'Excuse me', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'げんき', 'kanji': '元気', 'meaning': {'id': 'sehat', 'en': 'healthy / well'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat untuk ungkapan permintaan maaf:', 'question_en': 'Choose the correct writing for the apology expression:', 'japanese': 'Maaf', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ごめなさい', 'text_en': 'gomenaai', 'romaji': ''}, {'code': 'B', 'text_id': 'ごめんなさい', 'text_en': 'gomenasai', 'romaji': ''}, {'code': 'C', 'text_id': 'ごめんあさい', 'text_en': 'gomenasai (wrong)', 'romaji': ''}, {'code': 'D', 'text_id': 'ごんめなさい', 'text_en': 'gonmenasai', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'またあした', 'kanji': 'また明日', 'meaning': {'id': 'sampai jumpa besok', 'en': 'see you tomorrow'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari ungkapan ini?', 'question_en': 'What does this expression mean?', 'japanese': 'おせわになります', 'kanji': 'お世話になります', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Terima kasih atas bantuannya', 'text_en': 'Thank you for your help', 'romaji': ''}, {'code': 'B', 'text_id': 'Selamat datang', 'text_en': 'Welcome', 'romaji': ''}, {'code': 'C', 'text_id': 'Maaf mengganggu', 'text_en': 'Sorry to bother you', 'romaji': ''}, {'code': 'D', 'text_id': 'Sampai nanti', 'text_en': 'See you later', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'いってきます', 'kanji': null, 'meaning': {'id': 'saya berangkat', 'en': 'I am leaving'} },
  ];

  static final List<Map<String, dynamic>> _numStar1 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'いち', 'kanji': '一', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Satu', 'text_en': 'One', 'romaji': ''}, {'code': 'B', 'text_id': 'Delapan', 'text_en': 'Eight', 'romaji': ''}, {'code': 'C', 'text_id': 'Tujuh', 'text_en': 'Seven', 'romaji': ''}, {'code': 'D', 'text_id': 'Dua', 'text_en': 'Two', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'に', 'kanji': '二', 'meaning': {'id': 'dua', 'en': 'two'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'さん', 'kanji': '三', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Tiga Puluh', 'text_en': 'Thirty', 'romaji': ''}, {'code': 'B', 'text_id': 'Seribu', 'text_en': 'Thousand', 'romaji': ''}, {'code': 'C', 'text_id': 'Tiga', 'text_en': 'Three', 'romaji': ''}, {'code': 'D', 'text_id': 'Tiga Belas', 'text_en': 'Thirteen', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'よん', 'kanji': '四', 'meaning': {'id': 'empat', 'en': 'four'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'ご', 'kanji': '五', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Empat', 'text_en': 'Four', 'romaji': ''}, {'code': 'B', 'text_id': 'Lima', 'text_en': 'Five', 'romaji': ''}, {'code': 'C', 'text_id': 'Sembilan', 'text_en': 'Nine', 'romaji': ''}, {'code': 'D', 'text_id': 'Delapan', 'text_en': 'Eight', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'じゅう', 'kanji': '十', 'meaning': {'id': 'sepuluh', 'en': 'ten'} },
  ];

  static final List<Map<String, dynamic>> _numStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Angka 7 dalam bahasa Jepang adalah:', 'question_en': 'The number 7 in Japanese is:', 'japanese': 'なな', 'kanji': '七', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'ねね (nene)', 'text_en': 'nene', 'romaji': ''}, {'code': 'B', 'text_id': 'ぬぬ (nunu)', 'text_en': 'nunu', 'romaji': ''}, {'code': 'C', 'text_id': 'まま (mama)', 'text_en': 'mama', 'romaji': ''}, {'code': 'D', 'text_id': 'なな (nana)', 'text_en': 'nana', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はち', 'kanji': '八', 'meaning': {'id': 'delapan', 'en': 'eight'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat untuk angka 11:', 'question_en': 'Choose the correct writing for the number 11:', 'japanese': 'Sebelas', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'じゅうに', 'text_en': 'juuni', 'romaji': ''}, {'code': 'B', 'text_id': 'じゅういち', 'text_en': 'juuichi', 'romaji': ''}, {'code': 'C', 'text_id': 'にじゅう', 'text_en': 'nijuu', 'romaji': ''}, {'code': 'D', 'text_id': 'いちじゅう', 'text_en': 'ichijuu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'にじゅう', 'kanji': '二十', 'meaning': {'id': 'dua puluh', 'en': 'twenty'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih hiragana yang benar untuk 100:', 'question_en': 'Choose the correct hiragana for 100:', 'japanese': '100', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'はゃく', 'text_en': 'hayaku', 'romaji': ''}, {'code': 'B', 'text_id': 'ひあく', 'text_en': 'hiaku', 'romaji': ''}, {'code': 'C', 'text_id': 'ひゃく', 'text_en': 'hyaku', 'romaji': ''}, {'code': 'D', 'text_id': 'びゃく', 'text_en': 'byaku', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'なな', 'kanji': '七', 'meaning': {'id': 'tujuh', 'en': 'seven'} },
  ];

  static final List<Map<String, dynamic>> _numStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Berapakah hasil dari ungkapan ini?', 'question_en': 'What is the result of this expression?', 'japanese': 'さん (3) + よん (4)', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Tujuh', 'text_en': 'Seven', 'romaji': ''}, {'code': 'B', 'text_id': 'Tujuh Puluh', 'text_en': 'Seventy', 'romaji': ''}, {'code': 'C', 'text_id': 'Delapan', 'text_en': 'Eight', 'romaji': ''}, {'code': 'D', 'text_id': 'Dua Belas', 'text_en': 'Twelve', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'さんじゅうご', 'kanji': '三十五', 'meaning': {'id': 'tiga puluh lima', 'en': 'thirty five'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan hiragana yang benar untuk 90:', 'question_en': 'Choose the correct hiragana writing for 90:', 'japanese': 'Sembilan Puluh', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'くうじゅう', 'text_en': 'kuujuu', 'romaji': ''}, {'code': 'B', 'text_id': 'きゅうじゅ', 'text_en': 'kyuuju', 'romaji': ''}, {'code': 'C', 'text_id': 'きゅうじゅう', 'text_en': 'kyuujuu', 'romaji': ''}, {'code': 'D', 'text_id': 'きゅうじゅん', 'text_en': 'kyuujun', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'せん', 'kanji': '千', 'meaning': {'id': 'seribu', 'en': 'thousand'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah angka yang memiliki nilai paling besar?', 'question_en': 'Which number has the largest value?', 'japanese': 'Nilai Terbesar', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Seratus', 'text_en': 'One hundred', 'romaji': ''}, {'code': 'B', 'text_id': 'Seribu', 'text_en': 'Thousand', 'romaji': ''}, {'code': 'C', 'text_id': 'Sepuluh Ribu (Yen)', 'text_en': 'Ten thousand (Yen)', 'romaji': ''}, {'code': 'D', 'text_id': 'Sepuluh Ribu', 'text_en': 'Ten thousand', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ごじゅう', 'kanji': '五十', 'meaning': {'id': 'lima puluh', 'en': 'fifty'} },
  ];

  static final List<Map<String, dynamic>> _verbStar1 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'たべる', 'kanji': '食べる', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Makan', 'text_en': 'Eat', 'romaji': ''}, {'code': 'B', 'text_id': 'Minum', 'text_en': 'Drink', 'romaji': ''}, {'code': 'C', 'text_id': 'Melihat', 'text_en': 'Look / Watch', 'romaji': ''}, {'code': 'D', 'text_id': 'Mendengar', 'text_en': 'Listen', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'のむ', 'kanji': '飲む', 'meaning': {'id': 'minum', 'en': 'drink'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'みる', 'kanji': '見る', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Membaca', 'text_en': 'Read', 'romaji': ''}, {'code': 'B', 'text_id': 'Menulis', 'text_en': 'Write', 'romaji': ''}, {'code': 'C', 'text_id': 'Melihat', 'text_en': 'Look / Watch', 'romaji': ''}, {'code': 'D', 'text_id': 'Pergi', 'text_en': 'Go', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'よむ', 'kanji': '読む', 'meaning': {'id': 'membaca', 'en': 'read'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'いく', 'kanji': '行く', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Datang', 'text_en': 'Come', 'romaji': ''}, {'code': 'B', 'text_id': 'Pergi', 'text_en': 'Go', 'romaji': ''}, {'code': 'C', 'text_id': 'Pulang', 'text_en': 'Return home', 'romaji': ''}, {'code': 'D', 'text_id': 'Tidur', 'text_en': 'Sleep', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'たべる', 'kanji': '食べる', 'meaning': {'id': 'makan', 'en': 'eat'} },
  ];

  static final List<Map<String, dynamic>> _verbStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'かく', 'kanji': '書く', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Membaca', 'text_en': 'Read', 'romaji': ''}, {'code': 'B', 'text_id': 'Menulis', 'text_en': 'Write', 'romaji': ''}, {'code': 'C', 'text_id': 'Mendengar', 'text_en': 'Listen', 'romaji': ''}, {'code': 'D', 'text_id': 'Berjalan', 'text_en': 'Walk', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'きく', 'kanji': '聞く', 'meaning': {'id': 'mendengar', 'en': 'listen / hear'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'くる', 'kanji': '来る', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Datang', 'text_en': 'Come', 'romaji': ''}, {'code': 'B', 'text_id': 'Pergi', 'text_en': 'Go', 'romaji': ''}, {'code': 'C', 'text_id': 'Pulang', 'text_en': 'Return home', 'romaji': ''}, {'code': 'D', 'text_id': 'Berlari', 'text_en': 'Run', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ねる', 'kanji': '寝る', 'meaning': {'id': 'tidur', 'en': 'sleep'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'かえる', 'kanji': '帰る', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Datang', 'text_en': 'Come', 'romaji': ''}, {'code': 'B', 'text_id': 'Pergi', 'text_en': 'Go', 'romaji': ''}, {'code': 'C', 'text_id': 'Pulang', 'text_en': 'Return home', 'romaji': ''}, {'code': 'D', 'text_id': 'Masuk', 'text_en': 'Enter', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'かう', 'kanji': '買う', 'meaning': {'id': 'membeli', 'en': 'buy'} },
  ];

  static final List<Map<String, dynamic>> _verbStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'べんきょうする', 'kanji': '勉強する', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Berjalan', 'text_en': 'Walk', 'romaji': ''}, {'code': 'B', 'text_id': 'Berenang', 'text_en': 'Swim', 'romaji': ''}, {'code': 'C', 'text_id': 'Menari', 'text_en': 'Dance', 'romaji': ''}, {'code': 'D', 'text_id': 'Belajar', 'text_en': 'Study', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はなす', 'kanji': '話す', 'meaning': {'id': 'berbicara', 'en': 'speak / talk'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'まつ', 'kanji': '待つ', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Mati', 'text_en': 'Die', 'romaji': ''}, {'code': 'B', 'text_id': 'Menunggu', 'text_en': 'Wait', 'romaji': ''}, {'code': 'C', 'text_id': 'Memakai', 'text_en': 'Wear', 'romaji': ''}, {'code': 'D', 'text_id': 'Memasak', 'text_en': 'Cook', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はたらく', 'kanji': '働く', 'meaning': {'id': 'bekerja', 'en': 'work'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah kata kerja yang berkaitan dengan musik?', 'question_en': 'Which verb is related to music?', 'japanese': 'Mendengar', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Makan', 'text_en': 'Eat', 'romaji': ''}, {'code': 'B', 'text_id': 'Minum', 'text_en': 'Drink', 'romaji': ''}, {'code': 'C', 'text_id': 'Mendengar', 'text_en': 'Listen', 'romaji': ''}, {'code': 'D', 'text_id': 'Tidur', 'text_en': 'Sleep', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'わかる', 'kanji': '分かる', 'meaning': {'id': 'mengerti', 'en': 'understand'} },
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
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ア', 'kanji': null, 'meaning': {'id': 'a', 'en': 'a'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'イ', 'kanji': null, 'meaning': {'id': 'i', 'en': 'i'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ウ', 'kanji': null, 'meaning': {'id': 'u', 'en': 'u'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'エ', 'kanji': null, 'meaning': {'id': 'e', 'en': 'e'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'オ', 'kanji': null, 'meaning': {'id': 'o', 'en': 'o'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'カ', 'kanji': null, 'meaning': {'id': 'ka', 'en': 'ka'} },
  ];

  static final List<Map<String, dynamic>> _k1Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'KI', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'サ', 'text_en': 'sa', 'romaji': ''}, {'code': 'B', 'text_id': 'キ', 'text_en': 'ki', 'romaji': ''}, {'code': 'C', 'text_id': 'チ', 'text_en': 'chi', 'romaji': ''}, {'code': 'D', 'text_id': 'ケ', 'text_en': 'ke', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'アイ', 'kanji': null, 'meaning': {'id': 'cinta', 'en': 'love'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'GASU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'カス', 'text_en': 'kasu', 'romaji': ''}, {'code': 'B', 'text_id': 'クス', 'text_en': 'kusu', 'romaji': ''}, {'code': 'C', 'text_id': 'ガス', 'text_en': 'gasu', 'romaji': ''}, {'code': 'D', 'text_id': 'ゲス', 'text_en': 'gesu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'カキ', 'kanji': null, 'meaning': {'id': 'kesemek', 'en': 'persimmon'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'SU', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'ヌ', 'text_en': 'nu', 'romaji': ''}, {'code': 'B', 'text_id': 'マ', 'text_en': 'ma', 'romaji': ''}, {'code': 'C', 'text_id': 'フ', 'text_en': 'fu', 'romaji': ''}, {'code': 'D', 'text_id': 'ス', 'text_en': 'su', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'キカ', 'kanji': null, 'meaning': {'id': 'geometri', 'en': 'geometry'} },
  ];

  static final List<Map<String, dynamic>> _k1Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'アイス', 'kanji': null, 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'es krim', 'text_en': 'ice cream', 'romaji': ''}, {'code': 'B', 'text_id': 'mata', 'text_en': 'eye', 'romaji': ''}, {'code': 'C', 'text_id': 'kursi', 'text_en': 'chair', 'romaji': ''}, {'code': 'D', 'text_id': 'buku', 'text_en': 'book', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'スキー', 'kanji': null, 'meaning': {'id': 'main ski', 'en': 'skiing'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Kasa (Payung)', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'カセ', 'text_en': 'kase', 'romaji': ''}, {'code': 'B', 'text_id': 'カサ', 'text_en': 'kasa', 'romaji': ''}, {'code': 'C', 'text_id': 'ケサ', 'text_en': 'kesa', 'romaji': ''}, {'code': 'D', 'text_id': 'クサ', 'text_en': 'kusa', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ケサ', 'kanji': null, 'meaning': {'id': 'pagi ini', 'en': 'this morning'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang benar untuk kata ini:', 'question_en': 'Choose the correct writing for this word:', 'japanese': 'Kue', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ゲーキ', 'text_en': 'geeki', 'romaji': ''}, {'code': 'B', 'text_id': 'ケエキ', 'text_en': 'keeeki', 'romaji': ''}, {'code': 'C', 'text_id': 'ケーキ', 'text_en': 'keeki', 'romaji': ''}, {'code': 'D', 'text_id': 'ケッキ', 'text_en': 'kekki', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'エコ', 'kanji': null, 'meaning': {'id': 'ekologi', 'en': 'ecology'} },
  ];

  static final List<Map<String, dynamic>> _k2Star1 = [
    { 'type': 'essay', 'is_reading': true, 'japanese': 'タ', 'kanji': null, 'meaning': {'id': 'ta', 'en': 'ta'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'チ', 'kanji': null, 'meaning': {'id': 'chi', 'en': 'chi'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ツ', 'kanji': null, 'meaning': {'id': 'tsu', 'en': 'tsu'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'テ', 'kanji': null, 'meaning': {'id': 'te', 'en': 'te'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ト', 'kanji': null, 'meaning': {'id': 'to', 'en': 'to'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ナ', 'kanji': null, 'meaning': {'id': 'na', 'en': 'na'} },
  ];

  static final List<Map<String, dynamic>> _k2Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'NI', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ミ', 'text_en': 'mi', 'romaji': ''}, {'code': 'B', 'text_id': 'ヌ', 'text_en': 'nu', 'romaji': ''}, {'code': 'C', 'text_id': 'ニ', 'text_en': 'ni', 'romaji': ''}, {'code': 'D', 'text_id': 'ネ', 'text_en': 'ne', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ナニ', 'kanji': null, 'meaning': {'id': 'apa', 'en': 'what'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Daging', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ニク', 'text_en': 'niku', 'romaji': ''}, {'code': 'B', 'text_id': 'ナカ', 'text_en': 'naka', 'romaji': ''}, {'code': 'C', 'text_id': 'ネコ', 'text_en': 'neko', 'romaji': ''}, {'code': 'D', 'text_id': 'ノコ', 'text_en': 'noko', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ツタ', 'kanji': null, 'meaning': {'id': 'tanaman rambat (ivy)', 'en': 'ivy vine'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'Teto', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'タト', 'text_en': 'tato', 'romaji': ''}, {'code': 'B', 'text_id': 'テト', 'text_en': 'teto', 'romaji': ''}, {'code': 'C', 'text_id': 'チト', 'text_en': 'chito', 'romaji': ''}, {'code': 'D', 'text_id': 'ツト', 'text_en': 'tsuto', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ヌネ', 'kanji': null, 'meaning': {'id': 'puncak', 'en': 'peak'} },
  ];

  static final List<Map<String, dynamic>> _k2Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'Dasi', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ネクタイ', 'text_en': 'necktai', 'romaji': ''}, {'code': 'B', 'text_id': 'ヌクタイ', 'text_en': 'nuctai', 'romaji': ''}, {'code': 'C', 'text_id': 'ニクタイ', 'text_en': 'nictai', 'romaji': ''}, {'code': 'D', 'text_id': 'ネケタイ', 'text_en': 'neketai', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'テニス', 'kanji': null, 'meaning': {'id': 'tenis', 'en': 'tennis'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'TSUURU', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ツル', 'text_en': 'tsuru', 'romaji': ''}, {'code': 'B', 'text_id': 'ツレ', 'text_en': 'tsure', 'romaji': ''}, {'code': 'C', 'text_id': 'ツール', 'text_en': 'tsuuru', 'romaji': ''}, {'code': 'D', 'text_id': 'シル', 'text_en': 'shiru', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'カナダ', 'kanji': null, 'meaning': {'id': 'kanada', 'en': 'Canada'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'タクシー', 'kanji': null, 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'bus', 'text_en': 'bus', 'romaji': ''}, {'code': 'B', 'text_id': 'taksi', 'text_en': 'taxi', 'romaji': ''}, {'code': 'C', 'text_id': 'motor', 'text_en': 'motorcycle', 'romaji': ''}, {'code': 'D', 'text_id': 'sepeda', 'text_en': 'bicycle', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ナタ', 'kanji': null, 'meaning': {'id': 'parang', 'en': 'machete'} },
  ];

  static final List<Map<String, dynamic>> _k3Star1 = [
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ノ', 'kanji': null, 'meaning': {'id': 'no', 'en': 'no'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ハ', 'kanji': null, 'meaning': {'id': 'ha', 'en': 'ha'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ヒ', 'kanji': null, 'meaning': {'id': 'hi', 'en': 'hi'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'フ', 'kanji': null, 'meaning': {'id': 'fu', 'en': 'fu'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ヘ', 'kanji': null, 'meaning': {'id': 'he', 'en': 'he'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ホ', 'kanji': null, 'meaning': {'id': 'ho', 'en': 'ho'} },
  ];

  static final List<Map<String, dynamic>> _k3Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'MA', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'マ', 'text_en': 'ma', 'romaji': ''}, {'code': 'B', 'text_id': 'ム', 'text_en': 'mu', 'romaji': ''}, {'code': 'C', 'text_id': 'ア', 'text_en': 'a', 'romaji': ''}, {'code': 'D', 'text_id': 'ヌ', 'text_en': 'nu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ハム', 'kanji': null, 'meaning': {'id': 'daging ham', 'en': 'ham'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Memo', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'メメ', 'text_en': 'meme', 'romaji': ''}, {'code': 'B', 'text_id': 'メモ', 'text_en': 'memo', 'romaji': ''}, {'code': 'C', 'text_id': 'マモ', 'text_en': 'mamo', 'romaji': ''}, {'code': 'D', 'text_id': 'ムモ', 'text_en': 'mumo', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ヒフ', 'kanji': null, 'meaning': {'id': 'kulit', 'en': 'skin'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'YA', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'マ', 'text_en': 'ma', 'romaji': ''}, {'code': 'B', 'text_id': 'ユ', 'text_en': 'yu', 'romaji': ''}, {'code': 'C', 'text_id': 'セ', 'text_en': 'se', 'romaji': ''}, {'code': 'D', 'text_id': 'ヤ', 'text_en': 'ya', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ホホ', 'kanji': null, 'meaning': {'id': 'pipi', 'en': 'cheeks'} },
  ];

  static final List<Map<String, dynamic>> _k3Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'コーヒー', 'kanji': null, 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Teh', 'text_en': 'tea', 'romaji': ''}, {'code': 'B', 'text_id': 'Susu', 'text_en': 'milk', 'romaji': ''}, {'code': 'C', 'text_id': 'Kopi', 'text_en': 'coffee', 'romaji': ''}, {'code': 'D', 'text_id': 'Air', 'text_en': 'water', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ホテル', 'kanji': null, 'meaning': {'id': 'hotel', 'en': 'hotel'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Movie', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ムービー', 'text_en': 'muubii', 'romaji': ''}, {'code': 'B', 'text_id': 'ムビ', 'text_en': 'mubi', 'romaji': ''}, {'code': 'C', 'text_id': 'モオビ', 'text_en': 'moobi', 'romaji': ''}, {'code': 'D', 'text_id': 'ヌービー', 'text_en': 'nuubii', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ヤマハ', 'kanji': null, 'meaning': {'id': 'yamaha', 'en': 'Yamaha'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Help', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ハルプ', 'text_en': 'harupu', 'romaji': ''}, {'code': 'B', 'text_id': 'ヘルプ', 'text_en': 'herupu', 'romaji': ''}, {'code': 'C', 'text_id': 'ベルプ', 'text_en': 'berupu', 'romaji': ''}, {'code': 'D', 'text_id': 'ヘルフ', 'text_en': 'herufu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ハハ', 'kanji': null, 'meaning': {'id': 'ibu', 'en': 'mother'} },
  ];

  static final List<Map<String, dynamic>> _k4Star1 = [
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ユ', 'kanji': null, 'meaning': {'id': 'yu', 'en': 'yu'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ヨ', 'kanji': null, 'meaning': {'id': 'yo', 'en': 'yo'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ラ', 'kanji': null, 'meaning': {'id': 'ra', 'en': 'ra'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'リ', 'kanji': null, 'meaning': {'id': 'ri', 'en': 'ri'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ル', 'kanji': null, 'meaning': {'id': 'ru', 'en': 'ru'} },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'レ', 'kanji': null, 'meaning': {'id': 're', 'en': 're'} },
  ];

  static final List<Map<String, dynamic>> _k4Star2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'WA', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ウ', 'text_en': 'u', 'romaji': ''}, {'code': 'B', 'text_id': 'ク', 'text_en': 'ku', 'romaji': ''}, {'code': 'C', 'text_id': 'ワ', 'text_en': 'wa', 'romaji': ''}, {'code': 'D', 'text_id': 'フ', 'text_en': 'fu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ラク', 'kanji': null, 'meaning': {'id': 'nyaman / mudah', 'en': 'comfortable / easy'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Rain', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ラエン', 'text_en': 'raen', 'romaji': ''}, {'code': 'B', 'text_id': 'ライン', 'text_en': 'rain', 'romaji': ''}, {'code': 'C', 'text_id': 'ライソ', 'text_en': 'raiso', 'romaji': ''}, {'code': 'D', 'text_id': 'ヲイン', 'text_en': 'woin', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ヨル', 'kanji': null, 'meaning': {'id': 'malam', 'en': 'night'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih karakter yang tepat:', 'question_en': 'Choose the correct character:', 'japanese': 'RO', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'コ', 'text_en': 'ko', 'romaji': ''}, {'code': 'B', 'text_id': 'ヨ', 'text_en': 'yo', 'romaji': ''}, {'code': 'C', 'text_id': 'ユ', 'text_en': 'yu', 'romaji': ''}, {'code': 'D', 'text_id': 'ロ', 'text_en': 'ro', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ワヲン', 'kanji': null, 'meaning': {'id': 'wawon', 'en': 'wawon'} },
  ];

  static final List<Map<String, dynamic>> _k4Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'プラス', 'kanji': null, 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Minus', 'text_en': 'minus', 'romaji': ''}, {'code': 'B', 'text_id': 'Kali', 'text_en': 'times', 'romaji': ''}, {'code': 'C', 'text_id': 'Bagi', 'text_en': 'divide', 'romaji': ''}, {'code': 'D', 'text_id': 'Tambah', 'text_en': 'plus', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ガラス', 'kanji': null, 'meaning': {'id': 'kaca / gelas', 'en': 'glass'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Radio', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ラジョ', 'text_en': 'rajyo', 'romaji': ''}, {'code': 'B', 'text_id': 'ラジオ', 'text_en': 'rajio', 'romaji': ''}, {'code': 'C', 'text_id': 'ラジュ', 'text_en': 'raju', 'romaji': ''}, {'code': 'D', 'text_id': 'ラヂオ', 'text_en': 'radio', 'romaji': ''}] },
    { 'type': 'essay', 'is_reading': true, 'japanese': 'ガンダム', 'kanji': null, 'meaning': {'id': 'gandamu', 'en': 'Gundam'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'ページ', 'kanji': null, 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Halaman', 'text_en': 'page', 'romaji': ''}, {'code': 'B', 'text_id': 'Buku', 'text_en': 'book', 'romaji': ''}, {'code': 'C', 'text_id': 'Kertas', 'text_en': 'paper', 'romaji': ''}, {'code': 'D', 'text_id': 'Pensil', 'text_en': 'pencil', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'パーティ', 'kanji': null, 'meaning': {'id': 'pesta', 'en': 'party'} },
  ];

  static final List<Map<String, dynamic>> _kataWordStar1 = [
    { 'type': 'essay', 'japanese': 'カメラ', 'kanji': null, 'meaning': {'id': 'kamera', 'en': 'camera'} },
    { 'type': 'essay', 'japanese': 'テレビ', 'kanji': null, 'meaning': {'id': 'televisi', 'en': 'television'} },
    { 'type': 'essay', 'japanese': 'ホテル', 'kanji': null, 'meaning': {'id': 'hotel', 'en': 'hotel'} },
    { 'type': 'essay', 'japanese': 'バス', 'kanji': null, 'meaning': {'id': 'bus', 'en': 'bus'} },
    { 'type': 'essay', 'japanese': 'トイレ', 'kanji': null, 'meaning': {'id': 'toilet', 'en': 'toilet'} },
    { 'type': 'essay', 'japanese': 'ドア', 'kanji': null, 'meaning': {'id': 'pintu', 'en': 'door'} },
  ];

  static final List<Map<String, dynamic>> _kataWordStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'Wine', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'ウイン', 'text_en': 'uin', 'romaji': ''}, {'code': 'B', 'text_id': 'ワイン', 'text_en': 'wain', 'romaji': ''}, {'code': 'C', 'text_id': 'ワン', 'text_en': 'wan', 'romaji': ''}, {'code': 'D', 'text_id': 'ラチン', 'text_en': 'rachin', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ペン', 'kanji': null, 'meaning': {'id': 'pena', 'en': 'pen'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah penulisan yang berarti "Kue"?', 'question_en': 'Which writing means "Cake"?', 'japanese': 'Kue', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'ケキ', 'text_en': 'keki', 'romaji': ''}, {'code': 'B', 'text_id': 'ゲエキ', 'text_en': 'geeiki', 'romaji': ''}, {'code': 'C', 'text_id': 'ケーキ', 'text_en': 'keeki', 'romaji': ''}, {'code': 'D', 'text_id': 'ケッキ', 'text_en': 'kekki', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'パン', 'kanji': null, 'meaning': {'id': 'roti', 'en': 'bread'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang benar untuk kata ini:', 'question_en': 'Choose the correct writing for this word:', 'japanese': 'Taksi', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Scale', 'text_en': 'scale', 'romaji': ''}, {'code': 'B', 'text_id': 'タクツ', 'text_en': 'takutsu', 'romaji': ''}, {'code': 'C', 'text_id': 'タキシ', 'text_en': 'takishi', 'romaji': ''}, {'code': 'D', 'text_id': 'タクシー', 'text_en': 'takushii', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ノート', 'kanji': null, 'meaning': {'id': 'buku catatan', 'en': 'notebook'} },
  ];

  static final List<Map<String, dynamic>> _kataWordStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'パソコン', 'kanji': null, 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'Televisi', 'text_en': 'television', 'romaji': ''}, {'code': 'B', 'text_id': 'Radio', 'text_en': 'radio', 'romaji': ''}, {'code': 'C', 'text_id': 'Smartphone', 'text_en': 'smartphone', 'romaji': ''}, {'code': 'D', 'text_id': 'PC / Laptop', 'text_en': 'PC / Laptop', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'カレンダー', 'kanji': null, 'meaning': {'id': 'kalender', 'en': 'calendar'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah yang berarti kata berikut ini?', 'question_en': 'Which means the following word?', 'japanese': 'Toserba', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'スーパー', 'text_en': 'suupaa', 'romaji': ''}, {'code': 'B', 'text_id': 'デパート', 'text_en': 'depaato', 'romaji': ''}, {'code': 'C', 'text_id': 'コンビニ', 'text_en': 'konbini', 'romaji': ''}, {'code': 'D', 'text_id': 'テパート', 'text_en': 'tepaato', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ビデオ', 'kanji': null, 'meaning': {'id': 'video', 'en': 'video'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Sofa', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'ソファー', 'text_en': 'sofaa', 'romaji': ''}, {'code': 'B', 'text_id': 'ンファー', 'text_en': 'nfaa', 'romaji': ''}, {'code': 'C', 'text_id': 'シファー', 'text_en': 'shifaa', 'romaji': ''}, {'code': 'D', 'text_id': 'ゾファ', 'text_en': 'zofa', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'エアコン', 'kanji': null, 'meaning': {'id': 'pendingin ruangan (AC)', 'en': 'air conditioner'} },
  ];

  static final List<Map<String, dynamic>> _loanWordStar1 = [
    { 'type': 'essay', 'japanese': 'レストラン', 'kanji': null, 'meaning': {'id': 'restoran', 'en': 'restaurant'} },
    { 'type': 'essay', 'japanese': 'スーパー', 'kanji': null, 'meaning': {'id': 'supermarket', 'en': 'supermarket'} },
    { 'type': 'essay', 'japanese': 'デパート', 'kanji': null, 'meaning': {'id': 'toko serba ada', 'en': 'department store'} },
    { 'type': 'essay', 'japanese': 'コンビニ', 'kanji': null, 'meaning': {'id': 'minimarket', 'en': 'convenience store'} },
    { 'type': 'essay', 'japanese': 'サラリーマン', 'kanji': null, 'meaning': {'id': 'pegawai kantor', 'en': 'office worker / salaryman'} },
    { 'type': 'essay', 'japanese': 'スマートフォン', 'kanji': null, 'meaning': {'id': 'ponsel pintar', 'en': 'smartphone'} },
  ];

  static final List<Map<String, dynamic>> _loanWordStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'Internet', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'インタン', 'text_en': 'intan', 'romaji': ''}, {'code': 'B', 'text_id': 'インターネット', 'text_en': 'intaanetto', 'romaji': ''}, {'code': 'C', 'text_id': 'インタネット', 'text_en': 'intanetto', 'romaji': ''}, {'code': 'D', 'text_id': 'インラネット', 'text_en': 'inranetto', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ピザ', 'kanji': null, 'meaning': {'id': 'pizza', 'en': 'pizza'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Katakana yang berarti "Salad"?', 'question_en': 'Which Katakana means "Salad"?', 'japanese': 'Salad', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'サラダ', 'text_en': 'sarada', 'romaji': ''}, {'code': 'B', 'text_id': 'サラタ', 'text_en': 'sarata', 'romaji': ''}, {'code': 'C', 'text_id': 'ゼラダ', 'text_en': 'zerada', 'romaji': ''}, {'code': 'D', 'text_id': 'サロタ', 'text_en': 'sarota', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'スポーツ', 'kanji': null, 'meaning': {'id': 'olahraga', 'en': 'sports'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih penulisan yang tepat:', 'question_en': 'Choose the correct writing:', 'japanese': 'Komputer', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'コンピュタ', 'text_en': 'konpyuta', 'romaji': ''}, {'code': 'B', 'text_id': 'コンピュウタ', 'text_en': 'konpyuuta', 'romaji': ''}, {'code': 'C', 'text_id': 'コンピューター', 'text_en': 'konpyuutaa', 'romaji': ''}, {'code': 'D', 'text_id': 'コッピューター', 'text_en': 'koppyuutaa', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ネクタイ', 'kanji': null, 'meaning': {'id': 'dasi', 'en': 'necktie'} },
  ];

  static final List<Map<String, dynamic>> _loanWordStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'サラリーマン', 'kanji': null, 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Karyawan Swasta', 'text_en': 'White-collar worker', 'romaji': ''}, {'code': 'B', 'text_id': 'Pelajar', 'text_en': 'Student', 'romaji': ''}, {'code': 'C', 'text_id': 'Guru', 'text_en': 'Teacher', 'romaji': ''}, {'code': 'D', 'text_id': 'Dokter', 'text_en': 'Doctor', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'チョコレート', 'kanji': null, 'meaning': {'id': 'cokelat', 'en': 'chocolate'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah penulisan yang berarti "Natal"?', 'question_en': 'Which writing means "Christmas"?', 'japanese': 'Natal', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'クリマッス', 'text_en': 'kurimassu', 'romaji': ''}, {'code': 'B', 'text_id': 'クリスマス', 'text_en': 'kurisumasu', 'romaji': ''}, {'code': 'C', 'text_id': 'クルツマス', 'text_en': 'kurutsumassu', 'romaji': ''}, {'code': 'D', 'text_id': 'クリシマス', 'text_en': 'kurishimasu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ハンバーガー', 'kanji': null, 'meaning': {'id': 'hamburger', 'en': 'hamburger'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Katakana yang tepat:', 'question_en': 'Choose the correct Katakana:', 'japanese': 'Es Krim', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'マイスクリーム', 'text_en': 'mai sukuriumu', 'romaji': ''}, {'code': 'B', 'text_id': 'アインクリーム', 'text_en': 'ain sukuriumu', 'romaji': ''}, {'code': 'C', 'text_id': 'アスクルム', 'text_en': 'asukurumu', 'romaji': ''}, {'code': 'D', 'text_id': 'アイスクリーム', 'text_en': 'aisukuriumu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'プレゼント', 'kanji': null, 'meaning': {'id': 'hadiah', 'en': 'gift'} },
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
    { 'type': 'essay', 'japanese': 'いち', 'kanji': '一', 'meaning': {'id': 'satu', 'en': 'one'} },
    { 'type': 'essay', 'japanese': 'に', 'kanji': '二', 'meaning': {'id': 'dua', 'en': 'two'} },
    { 'type': 'essay', 'japanese': 'さん', 'kanji': '三', 'meaning': {'id': 'tiga', 'en': 'three'} },
    { 'type': 'essay', 'japanese': 'よん', 'kanji': '四', 'meaning': {'id': 'empat', 'en': 'four'} },
    { 'type': 'essay', 'japanese': 'ご', 'kanji': '五', 'meaning': {'id': 'lima', 'en': 'five'} },
    { 'type': 'essay', 'japanese': 'ろく', 'kanji': '六', 'meaning': {'id': 'enam', 'en': 'six'} },
  ];

  static final List<Map<String, dynamic>> _knStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Manakah Kanji untuk "Sembilan"?', 'question_en': 'Which Kanji is for "Nine"?', 'japanese': 'Sembilan', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': '九', 'text_en': 'nine', 'romaji': ''}, {'code': 'B', 'text_id': '丸', 'text_en': 'maru', 'romaji': ''}, {'code': 'C', 'text_id': '力', 'text_en': 'power', 'romaji': ''}, {'code': 'D', 'text_id': '刀', 'text_en': 'sword', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'なな', 'kanji': '七', 'meaning': {'id': 'tujuh', 'en': 'seven'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Seribu":', 'question_en': 'Choose the Kanji for "Thousand":', 'japanese': 'Seribu', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': '十', 'text_en': 'ten', 'romaji': ''}, {'code': 'B', 'text_id': '土', 'text_en': 'earth', 'romaji': ''}, {'code': 'C', 'text_id': '千', 'text_en': 'thousand', 'romaji': ''}, {'code': 'D', 'text_id': '万', 'text_en': 'ten thousand', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'はち', 'kanji': '八', 'meaning': {'id': 'delapan', 'en': 'eight'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Kanji untuk "Delapan"?', 'question_en': 'Which Kanji is for "Eight"?', 'japanese': 'Delapan', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': '人', 'text_en': 'person', 'romaji': ''}, {'code': 'B', 'text_id': '八', 'text_en': 'eight', 'romaji': ''}, {'code': 'C', 'text_id': '入', 'text_en': 'enter', 'romaji': ''}, {'code': 'D', 'text_id': 'ハ', 'text_en': 'ha', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ひゃく', 'kanji': '百', 'meaning': {'id': 'seratus', 'en': 'one hundred'} },
  ];

  static final List<Map<String, dynamic>> _knStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Berapakah hasil dari: 十 + 五?', 'question_en': 'What is the result of: ten + five?', 'japanese': '十 + 五', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': '10', 'text_en': 'ten', 'romaji': ''}, {'code': 'B', 'text_id': '15', 'text_en': 'fifteen', 'romaji': ''}, {'code': 'C', 'text_id': '50', 'text_en': 'fifty', 'romaji': ''}, {'code': 'D', 'text_id': '51', 'text_en': 'fifty-one', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'さんびゃく', 'kanji': '三百', 'meaning': {'id': 'tiga ratus', 'en': 'three hundred'} },
    { 'type': 'multiple_choice', 'question_id': 'Tuliskan "8000" dalam Kanji:', 'question_en': 'Write "8000" in Kanji:', 'japanese': '8000', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': '八百', 'text_en': 'eight hundred', 'romaji': ''}, {'code': 'B', 'text_id': '八十', 'text_en': 'eighty', 'romaji': ''}, {'code': 'C', 'text_id': '千八', 'text_en': 'thousand eight', 'romaji': ''}, {'code': 'D', 'text_id': '八千', 'text_en': 'eight thousand', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'まん', 'kanji': '万', 'meaning': {'id': 'sepuluh ribu', 'en': 'ten thousand'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Kanji untuk "30"?', 'question_en': 'Which Kanji is for "30"?', 'japanese': '30', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': '三十', 'text_en': 'thirty', 'romaji': ''}, {'code': 'B', 'text_id': '十三', 'text_en': 'thirteen', 'romaji': ''}, {'code': 'C', 'text_id': '三', 'text_en': 'three', 'romaji': ''}, {'code': 'D', 'text_id': '十', 'text_en': 'ten', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'よんひゃく', 'kanji': '四百', 'meaning': {'id': 'empat ratus', 'en': 'four hundred'} },
  ];

  // --- KANJI NATURE ---
  static final List<Map<String, dynamic>> _kanjiNatureStar1 = [
    { 'type': 'essay', 'japanese': 'ひ', 'kanji': '日', 'meaning': {'id': 'matahari', 'en': 'sun'} },
    { 'type': 'essay', 'japanese': 'つき', 'kanji': '月', 'meaning': {'id': 'bulan', 'en': 'moon'} },
    { 'type': 'essay', 'japanese': 'ひ', 'kanji': '火', 'meaning': {'id': 'api', 'en': 'fire'} },
    { 'type': 'essay', 'japanese': 'みず', 'kanji': '水', 'meaning': {'id': 'air', 'en': 'water'} },
    { 'type': 'essay', 'japanese': 'き', 'kanji': '木', 'meaning': {'id': 'pohon', 'en': 'tree'} },
    { 'type': 'essay', 'japanese': 'きん', 'kanji': '金', 'meaning': {'id': 'emas', 'en': 'gold'} },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Tanah":', 'question_en': 'Choose the Kanji for "Soil":', 'japanese': 'Tanah', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': '士', 'text_en': 'warrior', 'romaji': ''}, {'code': 'B', 'text_id': '干', 'text_en': 'dry', 'romaji': ''}, {'code': 'C', 'text_id': '土', 'text_en': 'soil', 'romaji': ''}, {'code': 'D', 'text_id': '千', 'text_en': 'thousand', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'やま', 'kanji': '山', 'meaning': {'id': 'gunung', 'en': 'mountain'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Kanji untuk "Matahari"?', 'question_en': 'Which Kanji is for "Sun"?', 'japanese': 'Matahari', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': '日', 'text_en': 'sun', 'romaji': ''}, {'code': 'B', 'text_id': '目', 'text_en': 'eye', 'romaji': ''}, {'code': 'C', 'text_id': '口', 'text_en': 'mouth', 'romaji': ''}, {'code': 'D', 'text_id': '田', 'text_en': 'rice field', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'かわ', 'kanji': '川', 'meaning': {'id': 'sungai', 'en': 'river'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Air":', 'question_en': 'Choose the Kanji for "Water":', 'japanese': 'Air', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': '木', 'text_en': 'tree', 'romaji': ''}, {'code': 'B', 'text_id': '水', 'text_en': 'water', 'romaji': ''}, {'code': 'C', 'text_id': '氷', 'text_en': 'ice', 'romaji': ''}, {'code': 'D', 'text_id': '火', 'text_en': 'fire', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'いし', 'kanji': '石', 'meaning': {'id': 'batu', 'en': 'stone'} },
  ];

  static final List<Map<String, dynamic>> _kanjiNatureStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'かざん', 'kanji': '火山', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Air terjun', 'text_en': 'Waterfall', 'romaji': ''}, {'code': 'B', 'text_id': 'Gunung Api', 'text_en': 'Volcano', 'romaji': ''}, {'code': 'C', 'text_id': 'Tanah liat', 'text_en': 'Clay', 'romaji': ''}, {'code': 'D', 'text_id': 'Kebakaran', 'text_en': 'Fire', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'すいでん', 'kanji': '水田', 'meaning': {'id': 'sawah', 'en': 'rice field'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'どぼく', 'kanji': '土木', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Pohon besar', 'text_en': 'Large tree', 'romaji': ''}, {'code': 'B', 'text_id': 'Hutan rimba', 'text_en': 'Jungle', 'romaji': ''}, {'code': 'C', 'text_id': 'Pekerjaan sipil', 'text_en': 'Civil engineering', 'romaji': ''}, {'code': 'D', 'text_id': 'Tanah subur', 'text_en': 'Fertile land', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'きんざん', 'kanji': '金山', 'meaning': {'id': 'tambang emas', 'en': 'gold mine'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Hari Senin":', 'question_en': 'Choose the Kanji for "Monday":', 'japanese': 'Hari Senin', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': '月曜日', 'text_en': 'Monday', 'romaji': ''}, {'code': 'B', 'text_id': '日曜日', 'text_en': 'Sunday', 'romaji': ''}, {'code': 'C', 'text_id': '火曜日', 'text_en': 'Tuesday', 'romaji': ''}, {'code': 'D', 'text_id': '水曜日', 'text_en': 'Wednesday', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'すいどう', 'kanji': '水道', 'meaning': {'id': 'saluran air', 'en': 'water supply'} },
  ];

  // --- KANJI PEOPLE ---
  static final List<Map<String, dynamic>> _kanjiPeopleStar1 = [
    { 'type': 'essay', 'japanese': 'ひと', 'kanji': '人', 'meaning': {'id': 'orang', 'en': 'person'} },
    { 'type': 'essay', 'japanese': 'こ', 'kanji': '子', 'meaning': {'id': 'anak', 'en': 'child'} },
    { 'type': 'essay', 'japanese': 'おんな', 'kanji': '女', 'meaning': {'id': 'wanita', 'en': 'woman'} },
    { 'type': 'essay', 'japanese': 'おとこ', 'kanji': '男', 'meaning': {'id': 'pria', 'en': 'man'} },
    { 'type': 'essay', 'japanese': 'め', 'kanji': '目', 'meaning': {'id': 'mata', 'en': 'eye'} },
    { 'type': 'essay', 'japanese': 'くち', 'kanji': '口', 'meaning': {'id': 'mulut', 'en': 'mouth'} },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar2 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Orang":', 'question_en': 'Choose the Kanji for "Person":', 'japanese': 'Orang', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': '人', 'text_en': 'person', 'romaji': ''}, {'code': 'B', 'text_id': '入', 'text_en': 'enter', 'romaji': ''}, {'code': 'C', 'text_id': '八', 'text_en': 'eight', 'romaji': ''}, {'code': 'D', 'text_id': '力', 'text_en': 'power', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'みみ', 'kanji': '耳', 'meaning': {'id': 'telinga', 'en': 'ear'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Kanji untuk "Mata"?', 'question_en': 'Which Kanji is for "Eye"?', 'japanese': 'Mata', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': '日', 'text_en': 'sun', 'romaji': ''}, {'code': 'B', 'text_id': '目', 'text_en': 'eye', 'romaji': ''}, {'code': 'C', 'text_id': '口', 'text_en': 'mouth', 'romaji': ''}, {'code': 'D', 'text_id': '四', 'text_en': 'four', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'て', 'kanji': '手', 'meaning': {'id': 'tangan', 'en': 'hand'} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih Kanji untuk "Mulut":', 'question_en': 'Choose the Kanji for "Mouth":', 'japanese': 'Mulut', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': '日', 'text_en': 'sun', 'romaji': ''}, {'code': 'B', 'text_id': '目', 'text_en': 'eye', 'romaji': ''}, {'code': 'C', 'text_id': '回', 'text_en': 'times', 'romaji': ''}, {'code': 'D', 'text_id': '口', 'text_en': 'mouth', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ちち', 'kanji': '父', 'meaning': {'id': 'ayah', 'en': 'father'} },
  ];

  static final List<Map<String, dynamic>> _kanjiPeopleStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'にほんじん', 'kanji': '日本人', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Orang China', 'text_en': 'Chinese person', 'romaji': ''}, {'code': 'B', 'text_id': 'Orang Korea', 'text_en': 'Korean person', 'romaji': ''}, {'code': 'C', 'text_id': 'Orang Jepang', 'text_en': 'Japanese person', 'romaji': ''}, {'code': 'D', 'text_id': 'Orang Amerika', 'text_en': 'American person', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'じょし', 'kanji': '女子', 'meaning': {'id': 'anak perempuan', 'en': 'girl'} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'じんこう', 'kanji': '人口', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Populasi', 'text_en': 'Population', 'romaji': ''}, {'code': 'B', 'text_id': 'Pintu masuk', 'text_en': 'Entrance', 'romaji': ''}, {'code': 'C', 'text_id': 'Orang besar', 'text_en': 'Great person', 'romaji': ''}, {'code': 'D', 'text_id': 'Mulut manis', 'text_en': 'Sweet talker', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'だんし', 'kanji': '男子', 'meaning': {'id': 'anak laki-laki', 'en': 'boy'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah Jukugo yang berarti "Ayah dan Ibu"?', 'question_en': 'Which compound word means "Father and Mother"?', 'japanese': 'Ayah & Ibu', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': '男女', 'text_en': 'Men and women', 'romaji': ''}, {'code': 'B', 'text_id': '父母', 'text_en': 'Father and mother', 'romaji': ''}, {'code': 'C', 'text_id': '門口', 'text_en': 'Gateway', 'romaji': ''}, {'code': 'D', 'text_id': '大小', 'text_en': 'Large and small', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'へた', 'kanji': '下手', 'meaning': {'id': 'tidak mahir', 'en': 'unskillful'} },
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
    { 'type': 'essay', 'japanese': 'は', 'kanji': null, 'meaning': {'id': 'penanda topik', 'en': 'topic marker'}, 'decoys': {'id': ['penanda objek', 'arah tujuan', 'kepemilikan'], 'en': ['object marker', 'direction', 'possession']} },
    { 'type': 'essay', 'japanese': 'を', 'kanji': null, 'meaning': {'id': 'penanda objek', 'en': 'object marker'}, 'decoys': {'id': ['penanda topik', 'lokasi keberadaan', 'kepemilikan'], 'en': ['topic marker', 'location', 'possession']} },
    { 'type': 'essay', 'japanese': 'も', 'kanji': null, 'meaning': {'id': 'juga', 'en': 'also'}, 'decoys': {'id': ['dan', 'dari', 'sampai'], 'en': ['and', 'from', 'until']} },
    { 'type': 'essay', 'japanese': 'に', 'kanji': null, 'meaning': {'id': 'lokasi / waktu', 'en': 'location / time'}, 'decoys': {'id': ['penanda topik', 'penanda objek', 'kepemilikan'], 'en': ['topic marker', 'object marker', 'possession']} },
    { 'type': 'essay', 'japanese': 'へ', 'kanji': null, 'meaning': {'id': 'arah tujuan', 'en': 'direction'}, 'decoys': {'id': ['penanda topik', 'penanda objek', 'kepemilikan'], 'en': ['topic marker', 'object marker', 'possession']} },
    { 'type': 'essay', 'japanese': 'で', 'kanji': null, 'meaning': {'id': 'tempat aktivitas', 'en': 'place of action'}, 'decoys': {'id': ['penanda topik', 'kepemilikan', 'penanda tanya'], 'en': ['topic marker', 'possession', 'question marker']} },
  ];

  static final List<Map<String, dynamic>> _gpStar2 = [
    { 'type': 'essay', 'japanese': 'と', 'kanji': null, 'meaning': {'id': 'dan / bersama', 'en': 'and / with'}, 'decoys': {'id': ['dari', 'sampai', 'juga'], 'en': ['from', 'until', 'also']} },
    { 'type': 'essay', 'japanese': 'の', 'kanji': null, 'meaning': {'id': 'kepemilikan', 'en': 'possession'}, 'decoys': {'id': ['penanda topik', 'penanda objek', 'arah tujuan'], 'en': ['topic marker', 'object marker', 'direction']} },
    { 'type': 'essay', 'japanese': 'が', 'kanji': null, 'meaning': {'id': 'penanda subjek', 'en': 'subject marker'}, 'decoys': {'id': ['kepemilikan', 'arah tujuan', 'tempat aktivitas'], 'en': ['possession', 'direction', 'place of action']} },
    { 'type': 'essay', 'japanese': 'から', 'kanji': null, 'meaning': {'id': 'dari', 'en': 'from'}, 'decoys': {'id': ['sampai', 'juga', 'dan'], 'en': ['until', 'also', 'and']} },
    { 'type': 'essay', 'japanese': 'まで', 'kanji': null, 'meaning': {'id': 'sampai', 'en': 'until'}, 'decoys': {'id': ['dari', 'juga', 'dan'], 'en': ['from', 'also', 'and']} },
    { 'type': 'essay', 'japanese': 'か', 'kanji': null, 'meaning': {'id': 'penanda tanya', 'en': 'question marker'}, 'decoys': {'id': ['penanda topik', 'penanda objek', 'kepemilikan'], 'en': ['topic marker', 'object marker', 'possession']} },
  ];

  static final List<Map<String, dynamic>> _gpStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Pilih partikel yang tepat: わたし ... ごはん を たべます。', 'question_en': 'Choose the correct particle: I ... eat rice.', 'japanese': 'は', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'は', 'text_en': 'wa', 'romaji': ''}, {'code': 'B', 'text_id': 'を', 'text_en': 'wo', 'romaji': ''}, {'code': 'C', 'text_id': 'に', 'text_en': 'ni', 'romaji': ''}, {'code': 'D', 'text_id': 'で', 'text_en': 'de', 'romaji': ''}] },
    { 'type': 'multiple_choice', 'question_id': 'Pilih partikel untuk menunjukkan arah: がっこう ... いきます。', 'question_en': 'Choose the particle to indicate direction: Go ... school.', 'japanese': 'へ', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'は', 'text_en': 'wa', 'romaji': ''}, {'code': 'B', 'text_id': 'を', 'text_en': 'wo', 'romaji': ''}, {'code': 'C', 'text_id': 'へ', 'text_en': 'e', 'romaji': ''}, {'code': 'D', 'text_id': 'の', 'text_en': 'no', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'の', 'kanji': null, 'meaning': {'id': 'kepemilikan', 'en': 'possession'}, 'decoys': {'id': ['penanda topik', 'penanda objek', 'arah tujuan'], 'en': ['topic marker', 'object marker', 'direction']} },
    { 'type': 'multiple_choice', 'question_id': 'Pilih partikel yang tepat: レストラン ... たべます。', 'question_en': 'Choose the correct particle: Eat ... restaurant.', 'japanese': 'で', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'に', 'text_en': 'ni', 'romaji': ''}, {'code': 'B', 'text_id': 'へ', 'text_en': 'e', 'romaji': ''}, {'code': 'C', 'text_id': 'を', 'text_en': 'wo', 'romaji': ''}, {'code': 'D', 'text_id': 'で', 'text_en': 'de', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'を', 'kanji': null, 'meaning': {'id': 'penanda objek', 'en': 'object marker'}, 'decoys': {'id': ['penanda topik', 'kepemilikan', 'arah tujuan'], 'en': ['topic marker', 'possession', 'direction']} },
    { 'type': 'multiple_choice', 'question_id': 'Apa arti dari kata ini?', 'question_en': 'What does this word mean?', 'japanese': 'も', 'kanji': null, 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Hanya', 'text_en': 'Only', 'romaji': ''}, {'code': 'B', 'text_id': 'Juga', 'text_en': 'Also', 'romaji': ''}, {'code': 'C', 'text_id': 'Dan', 'text_en': 'And', 'romaji': ''}, {'code': 'D', 'text_id': 'Dari', 'text_en': 'From', 'romaji': ''}] },
  ];

  // --- GRAMMAR VERBS 1 ---
  static final List<Map<String, dynamic>> _gv1Star1 = [
    { 'type': 'essay', 'japanese': 'たべる', 'kanji': '食べる', 'meaning': {'id': 'makan', 'en': 'eat'} },
    { 'type': 'essay', 'japanese': 'のむ', 'kanji': '飲む', 'meaning': {'id': 'minum', 'en': 'drink'} },
    { 'type': 'essay', 'japanese': 'いく', 'kanji': '行く', 'meaning': {'id': 'pergi', 'en': 'go'} },
    { 'type': 'essay', 'japanese': 'くる', 'kanji': '来る', 'meaning': {'id': 'datang', 'en': 'come'} },
    { 'type': 'essay', 'japanese': 'する', 'kanji': null, 'meaning': {'id': 'melakukan', 'en': 'do'} },
    { 'type': 'essay', 'japanese': 'かう', 'kanji': '買う', 'meaning': {'id': 'membeli', 'en': 'buy'} },
  ];

  static final List<Map<String, dynamic>> _gv1Star2 = [
    { 'type': 'essay', 'japanese': 'わかる', 'kanji': '分かる', 'meaning': {'id': 'mengerti', 'en': 'understand'} },
    { 'type': 'essay', 'japanese': 'はなす', 'kanji': '話す', 'meaning': {'id': 'berbicara', 'en': 'speak / talk'} },
    { 'type': 'essay', 'japanese': 'あります', 'kanji': null, 'meaning': {'id': 'ada (benda mati)', 'en': 'exist (inanimate)'} },
    { 'type': 'essay', 'japanese': 'います', 'kanji': null, 'meaning': {'id': 'ada (makhluk hidup)', 'en': 'exist (animate)'} },
    { 'type': 'essay', 'japanese': 'はたらく', 'kanji': '働く', 'meaning': {'id': 'bekerja', 'en': 'work'} },
    { 'type': 'essay', 'japanese': 'べんきょうする', 'kanji': '勉強する', 'meaning': {'id': 'belajar', 'en': 'study'} },
  ];

  static final List<Map<String, dynamic>> _gv1Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Bentuk sopan (masu) dari "taberu" adalah:', 'question_en': 'The polite form (masu) of "taberu" is:', 'japanese': 'たべます', 'kanji': '食べます', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'tabemasu', 'text_en': 'tabemasu', 'romaji': ''}, {'code': 'B', 'text_id': 'taberimasu', 'text_en': 'taberimasu', 'romaji': ''}, {'code': 'C', 'text_id': 'tabemashita', 'text_en': 'tabemashita', 'romaji': ''}, {'code': 'D', 'text_id': 'tabenai', 'text_en': 'tabenai', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'のみます', 'kanji': '飲みます', 'meaning': {'id': 'minum', 'en': 'drink'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah yang berarti "Belajar"?', 'question_en': 'Which one means "Study"?', 'japanese': 'べんきょうする', 'kanji': '勉強する', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'hataraku', 'text_en': 'hataraku', 'romaji': ''}, {'code': 'B', 'text_id': 'suru', 'text_en': 'suru', 'romaji': ''}, {'code': 'C', 'text_id': 'benkyousuru', 'text_en': 'benkyousuru', 'romaji': ''}, {'code': 'D', 'text_id': 'kuru', 'text_en': 'kuru', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'います', 'kanji': null, 'meaning': {'id': 'ada (makhluk hidup)', 'en': 'exist (animate)'} },
    { 'type': 'multiple_choice', 'question_id': 'Lawan kata dari "ikimasu" (pergi) adalah:', 'question_en': 'The opposite of "ikimasu" (go) is:', 'japanese': 'きます', 'kanji': '来ます', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'kaerimasu', 'text_en': 'kaerimasu', 'romaji': ''}, {'code': 'B', 'text_id': 'kimasu', 'text_en': 'kimasu', 'romaji': ''}, {'code': 'C', 'text_id': 'shimasu', 'text_en': 'shimasu', 'romaji': ''}, {'code': 'D', 'text_id': 'arimasu', 'text_en': 'arimasu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'かう', 'kanji': '買う', 'meaning': {'id': 'membeli', 'en': 'buy'} },
  ];

  // --- GRAMMAR VERBS 2 ---
  static final List<Map<String, dynamic>> _gv2Star1 = [
    { 'type': 'essay', 'japanese': 'みる', 'kanji': '見る', 'meaning': {'id': 'melihat', 'en': 'look / watch / see'} },
    { 'type': 'essay', 'japanese': 'きく', 'kanji': '聞く', 'meaning': {'id': 'mendengar', 'en': 'listen / hear'} },
    { 'type': 'essay', 'japanese': 'かく', 'kanji': '書く', 'meaning': {'id': 'menulis', 'en': 'write'} },
    { 'type': 'essay', 'japanese': 'よむ', 'kanji': '読む', 'meaning': {'id': 'membaca', 'en': 'read'} },
    { 'type': 'essay', 'japanese': 'およぐ', 'kanji': '泳ぐ', 'meaning': {'id': 'berenang', 'en': 'swim'} },
    { 'type': 'essay', 'japanese': 'まつ', 'kanji': '待つ', 'meaning': {'id': 'menunggu', 'en': 'wait'} },
  ];

  static final List<Map<String, dynamic>> _gv2Star2 = [
    { 'type': 'essay', 'japanese': 'かえる', 'kanji': '帰る', 'meaning': {'id': 'pulang', 'en': 'return home'} },
    { 'type': 'essay', 'japanese': 'とる', 'kanji': '取る', 'meaning': {'id': 'mengambil', 'en': 'take'} },
    { 'type': 'essay', 'japanese': 'たつ', 'kanji': '立つ', 'meaning': {'id': 'berdiri', 'en': 'stand up'} },
    { 'type': 'essay', 'japanese': 'すわる', 'kanji': '座る', 'meaning': {'id': 'duduk', 'en': 'sit down'} },
    { 'type': 'essay', 'japanese': 'きる', 'kanji': '着る', 'meaning': {'id': 'memakai (pakaian)', 'en': 'wear / put on'} },
    { 'type': 'essay', 'japanese': 'しぬ', 'kanji': '死ぬ', 'meaning': {'id': 'mati', 'en': 'die'} },
  ];

  static final List<Map<String, dynamic>> _gv2Star3 = [
    { 'type': 'multiple_choice', 'question_id': 'Bentuk sopan dari "miru" (melihat) adalah:', 'question_en': 'The polite form of "miru" (see) is:', 'japanese': 'みます', 'kanji': '見ます', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'mimasu', 'text_en': 'mimasu', 'romaji': ''}, {'code': 'B', 'text_id': 'mirimasu', 'text_en': 'mirimasu', 'romaji': ''}, {'code': 'C', 'text_id': 'mishimasu', 'text_en': 'mishimasu', 'romaji': ''}, {'code': 'D', 'text_id': 'minai', 'text_en': 'minai', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'かきます', 'kanji': '書きます', 'meaning': {'id': 'menulis', 'en': 'write'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah yang berarti "Berenang"?', 'question_en': 'Which one means "Swim"?', 'japanese': 'およぐ', 'kanji': '泳ぐ', 'correctIndex': 3, 'options': [{'code': 'A', 'text_id': 'kaku', 'text_en': 'kaku', 'romaji': ''}, {'code': 'B', 'text_id': 'yomu', 'text_en': 'yomu', 'romaji': ''}, {'code': 'C', 'text_id': 'matsu', 'text_en': 'matsu', 'romaji': ''}, {'code': 'D', 'text_id': 'oyogu', 'text_en': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'きく', 'kanji': '聞く', 'meaning': {'id': 'mendengar', 'en': 'listen / hear'} },
    { 'type': 'multiple_choice', 'question_id': 'Lawan kata dari "tatsu" (berdiri) adalah:', 'question_en': 'The opposite of "tatsu" (stand) is:', 'japanese': 'すわる', 'kanji': '座る', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'miru', 'text_en': 'miru', 'romaji': ''}, {'code': 'B', 'text_id': 'kaku', 'text_en': 'kaku', 'romaji': ''}, {'code': 'C', 'text_id': 'suwaru', 'text_en': 'suwaru', 'romaji': ''}, {'code': 'D', 'text_id': 'oyogu', 'text_en': 'oyogu', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'よむ', 'kanji': '読む', 'meaning': {'id': 'membaca', 'en': 'read'} },
  ];

  // --- BASIC ADJECTIVES ---
  static final List<Map<String, dynamic>> _adjStar1 = [
    { 'type': 'essay', 'japanese': 'おいしい', 'kanji': null, 'meaning': {'id': 'enak', 'en': 'delicious'} },
    { 'type': 'essay', 'japanese': 'たかい', 'kanji': '高い', 'meaning': {'id': 'mahal / tinggi', 'en': 'expensive / high'} },
    { 'type': 'essay', 'japanese': 'やすい', 'kanji': '安い', 'meaning': {'id': 'murah', 'en': 'cheap'} },
    { 'type': 'essay', 'japanese': 'おおきい', 'kanji': '大きい', 'meaning': {'id': 'besar', 'en': 'big'} },
    { 'type': 'essay', 'japanese': 'ちいさい', 'kanji': '小さい', 'meaning': {'id': 'kecil', 'en': 'small'} },
    { 'type': 'essay', 'japanese': 'あたらしい', 'kanji': '新しい', 'meaning': {'id': 'baru', 'en': 'new'} },
  ];

  static final List<Map<String, dynamic>> _adjStar2 = [
    { 'type': 'essay', 'japanese': 'ふるい', 'kanji': '古い', 'meaning': {'id': 'lama (benda)', 'en': 'old (things)'} },
    { 'type': 'essay', 'japanese': 'いい', 'kanji': null, 'meaning': {'id': 'bagus / baik', 'en': 'good'} },
    { 'type': 'essay', 'japanese': 'わるい', 'kanji': '悪い', 'meaning': {'id': 'buruk', 'en': 'bad'} },
    { 'type': 'essay', 'japanese': 'むずかしい', 'kanji': '難しい', 'meaning': {'id': 'sulit', 'en': 'difficult'} },
    { 'type': 'essay', 'japanese': 'やさしい', 'kanji': null, 'meaning': {'id': 'mudah / ramah', 'en': 'easy / kind'} },
    { 'type': 'essay', 'japanese': 'とても', 'kanji': null, 'meaning': {'id': 'sangat', 'en': 'very'} },
  ];

  static final List<Map<String, dynamic>> _adjStar3 = [
    { 'type': 'multiple_choice', 'question_id': 'Lawan kata dari "takai" (mahal) adalah:', 'question_en': 'The opposite of "takai" (expensive) is:', 'japanese': 'やすい', 'kanji': '安い', 'correctIndex': 1, 'options': [{'code': 'A', 'text_id': 'Enak', 'text_en': 'Delicious', 'romaji': ''}, {'code': 'B', 'text_id': 'Murah', 'text_en': 'Cheap', 'romaji': ''}, {'code': 'C', 'text_id': 'Lama/Tua', 'text_en': 'Old', 'romaji': ''}, {'code': 'D', 'text_id': 'Besar', 'text_en': 'Big', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'ちいさい', 'kanji': '小さい', 'meaning': {'id': 'kecil', 'en': 'small'} },
    { 'type': 'multiple_choice', 'question_id': 'Manakah yang berarti "Sulit"?', 'question_en': 'Which one means "Difficult"?', 'japanese': 'むずかしい', 'kanji': '難しい', 'correctIndex': 2, 'options': [{'code': 'A', 'text_id': 'Mudah', 'text_en': 'Easy', 'romaji': ''}, {'code': 'B', 'text_id': 'Baru', 'text_en': 'New', 'romaji': ''}, {'code': 'C', 'text_id': 'Sulit', 'text_en': 'Difficult', 'romaji': ''}, {'code': 'D', 'text_id': 'Enak', 'text_en': 'Delicious', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'いい', 'kanji': null, 'meaning': {'id': 'bagus / baik', 'en': 'good'} },
    { 'type': 'multiple_choice', 'question_id': 'Lawan kata dari "atarashii" (baru) adalah:', 'question_en': 'The opposite of "atarashii" (new) is:', 'japanese': 'ふるい', 'kanji': '古い', 'correctIndex': 0, 'options': [{'code': 'A', 'text_id': 'Lama/Tua', 'text_en': 'Old', 'romaji': ''}, {'code': 'B', 'text_id': 'Mahal', 'text_en': 'Expensive', 'romaji': ''}, {'code': 'C', 'text_id': 'Besar', 'text_en': 'Big', 'romaji': ''}, {'code': 'D', 'text_id': 'Buruk', 'text_en': 'Bad', 'romaji': ''}] },
    { 'type': 'essay', 'japanese': 'おいしい', 'kanji': null, 'meaning': {'id': 'enak', 'en': 'delicious'} },
  ];

  static final List<Map<String, dynamic>> _u4UnitTest = [
    ..._gpStar1.sublist(0, 2), ..._gpStar2.sublist(0, 2), ..._gpStar3.sublist(0, 2),
    ..._gv1Star1.sublist(0, 2), ..._gv1Star2.sublist(0, 2), ..._gv1Star3.sublist(0, 2),
    ..._gv2Star1.sublist(0, 2), ..._gv2Star2.sublist(0, 2), ..._gv2Star3.sublist(0, 2),
    ..._adjStar1.sublist(0, 2), ..._adjStar2.sublist(0, 2), ..._adjStar3.sublist(0, 2),
  ];
}
