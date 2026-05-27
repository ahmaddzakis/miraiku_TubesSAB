class AlphabetData {
  // ==========================================
  // 📚 1. HIRAGANA
  // ==========================================

  // 46 Karakter Dasar (Gojuon)
  static const List<Map<String, String>> hiraBasic = [
    {'jp': 'あ', 'ro': 'A'}, {'jp': 'い', 'ro': 'I'}, {'jp': 'う', 'ro': 'U'}, {'jp': 'え', 'ro': 'E'}, {'jp': 'お', 'ro': 'O'},
    {'jp': 'か', 'ro': 'KA'}, {'jp': 'き', 'ro': 'KI'}, {'jp': 'く', 'ro': 'KU'}, {'jp': 'け', 'ro': 'KE'}, {'jp': 'こ', 'ro': 'KO'},
    {'jp': 'さ', 'ro': 'SA'}, {'jp': 'し', 'ro': 'SHI'}, {'jp': 'す', 'ro': 'SU'}, {'jp': 'せ', 'ro': 'SE'}, {'jp': 'そ', 'ro': 'SO'},
    {'jp': 'た', 'ro': 'TA'}, {'jp': 'ち', 'ro': 'CHI'}, {'jp': 'つ', 'ro': 'TSU'}, {'jp': 'て', 'ro': 'TE'}, {'jp': 'と', 'ro': 'TO'},
    {'jp': 'な', 'ro': 'NA'}, {'jp': 'に', 'ro': 'NI'}, {'jp': 'ぬ', 'ro': 'NU'}, {'jp': 'ね', 'ro': 'NE'}, {'jp': 'の', 'ro': 'NO'},
    {'jp': 'は', 'ro': 'HA'}, {'jp': 'ひ', 'ro': 'HI'}, {'jp': 'ふ', 'ro': 'FU'}, {'jp': 'へ', 'ro': 'HE'}, {'jp': 'ほ', 'ro': 'HO'},
    {'jp': 'ま', 'ro': 'MA'}, {'jp': 'み', 'ro': 'MI'}, {'jp': 'む', 'ro': 'MU'}, {'jp': 'め', 'ro': 'ME'}, {'jp': 'も', 'ro': 'MO'},
    {'jp': 'や', 'ro': 'YA'}, {'jp': 'ゆ', 'ro': 'YU'}, {'jp': 'よ', 'ro': 'YO'},
    {'jp': 'ら', 'ro': 'RA'}, {'jp': 'り', 'ro': 'RI'}, {'jp': 'る', 'ro': 'RU'}, {'jp': 'れ', 'ro': 'RE'}, {'jp': 'ろ', 'ro': 'RO'},
    {'jp': 'わ', 'ro': 'WA'}, {'jp': 'を', 'ro': 'WO'},
    {'jp': 'ん', 'ro': 'N'},
  ];

  // Dakuon (Tanda Kutip / Voiced)
  static const List<Map<String, String>> hiraDakuon = [
    {'jp': 'が', 'ro': 'GA'}, {'jp': 'ぎ', 'ro': 'GI'}, {'jp': 'ぐ', 'ro': 'GU'}, {'jp': 'げ', 'ro': 'GE'}, {'jp': 'ご', 'ro': 'GO'},
    {'jp': 'ざ', 'ro': 'ZA'}, {'jp': 'じ', 'ro': 'JI'}, {'jp': 'ず', 'ro': 'ZU'}, {'jp': 'ぜ', 'ro': 'ZE'}, {'jp': 'ぞ', 'ro': 'ZO'},
    {'jp': 'だ', 'ro': 'DA'}, {'jp': 'ぢ', 'ro': 'JI'}, {'jp': 'づ', 'ro': 'ZU'}, {'jp': 'で', 'ro': 'DE'}, {'jp': 'ど', 'ro': 'DO'},
    {'jp': 'ば', 'ro': 'BA'}, {'jp': 'び', 'ro': 'BI'}, {'jp': 'ぶ', 'ro': 'BU'}, {'jp': 'べ', 'ro': 'BE'}, {'jp': 'ぼ', 'ro': 'BO'},
  ];

  // Handakuon (Tanda Bulat / Semi-Voiced)
  static const List<Map<String, String>> hiraHandakuon = [
    {'jp': 'ぱ', 'ro': 'PA'}, {'jp': 'ぴ', 'ro': 'PI'}, {'jp': 'ぷ', 'ro': 'PU'}, {'jp': 'ぺ', 'ro': 'PE'}, {'jp': 'ぽ', 'ro': 'PO'},
  ];

  // Yoon (Gabungan ya, yu, yo kecil)
  static const List<Map<String, String>> hiraYoon = [
    {'jp': 'きゃ', 'ro': 'KYA'}, {'jp': 'きゅ', 'ro': 'KYU'}, {'jp': 'きょ', 'ro': 'KYO'},
    {'jp': 'しゃ', 'ro': 'SHA'}, {'jp': 'しゅ', 'ro': 'SHU'}, {'jp': 'しょ', 'ro': 'SHO'},
    {'jp': 'ちゃ', 'ro': 'CHA'}, {'jp': 'ちゅ', 'ro': 'CHU'}, {'jp': 'ちょ', 'ro': 'CHO'},
    {'jp': 'にゃ', 'ro': 'NYA'}, {'jp': 'にゅ', 'ro': 'NYU'}, {'jp': 'にょ', 'ro': 'NYO'},
    {'jp': 'ひゃ', 'ro': 'HYA'}, {'jp': 'ひゅ', 'ro': 'HYU'}, {'jp': 'ひょ', 'ro': 'HYO'},
    {'jp': 'みゃ', 'ro': 'MYA'}, {'jp': 'みゅ', 'ro': 'MYU'}, {'jp': 'みょ', 'ro': 'MYO'},
    {'jp': 'りゃ', 'ro': 'RYA'}, {'jp': 'りゅ', 'ro': 'RYU'}, {'jp': 'りょ', 'ro': 'RYO'},
    {'jp': 'ぎゃ', 'ro': 'GYA'}, {'jp': 'ぎゅ', 'ro': 'GYU'}, {'jp': 'ぎょ', 'ro': 'GYO'},
    {'jp': 'じゃ', 'ro': 'JA'},  {'jp': 'じゅ', 'ro': 'JU'},  {'jp': 'じょ', 'ro': 'JO'},
    {'jp': 'びゃ', 'ro': 'BYA'}, {'jp': 'びゅ', 'ro': 'BYU'}, {'jp': 'びょ', 'ro': 'BYO'},
    {'jp': 'ぴゃ', 'ro': 'PYA'}, {'jp': 'ぴゅ', 'ro': 'PYU'}, {'jp': 'ぴょ', 'ro': 'PYO'},
  ];

  // ==========================================
  // 📚 2. KATAKANA
  // ==========================================

  // 46 Karakter Dasar (Gojuon)
  static const List<Map<String, String>> kataBasic = [
    {'jp': 'ア', 'ro': 'A'}, {'jp': 'イ', 'ro': 'I'}, {'jp': 'ウ', 'ro': 'U'}, {'jp': 'エ', 'ro': 'E'}, {'jp': 'オ', 'ro': 'O'},
    {'jp': 'カ', 'ro': 'KA'}, {'jp': 'キ', 'ro': 'KI'}, {'jp': 'ク', 'ro': 'KU'}, {'jp': 'ケ', 'ro': 'KE'}, {'jp': 'コ', 'ro': 'KO'},
    {'jp': 'サ', 'ro': 'SA'}, {'jp': 'シ', 'ro': 'SHI'}, {'jp': 'ス', 'ro': 'SU'}, {'jp': 'セ', 'ro': 'SE'}, {'jp': 'ソ', 'ro': 'SO'},
    {'jp': 'タ', 'ro': 'TA'}, {'jp': 'チ', 'ro': 'CHI'}, {'jp': 'ツ', 'ro': 'TSU'}, {'jp': 'テ', 'ro': 'TE'}, {'jp': 'ト', 'ro': 'TO'},
    {'jp': 'ナ', 'ro': 'NA'}, {'jp': 'ニ', 'ro': 'NI'}, {'jp': 'ヌ', 'ro': 'NU'}, {'jp': 'ネ', 'ro': 'NE'}, {'jp': 'ノ', 'ro': 'NO'},
    {'jp': 'ハ', 'ro': 'HA'}, {'jp': 'ヒ', 'ro': 'HI'}, {'jp': 'フ', 'ro': 'FU'}, {'jp': 'ヘ', 'ro': 'HE'}, {'jp': 'ホ', 'ro': 'HO'},
    {'jp': 'マ', 'ro': 'MA'}, {'jp': 'ミ', 'ro': 'MI'}, {'jp': 'ム', 'ro': 'MU'}, {'jp': 'メ', 'ro': 'ME'}, {'jp': 'モ', 'ro': 'MO'},
    {'jp': 'ヤ', 'ro': 'YA'}, {'jp': 'ユ', 'ro': 'YU'}, {'jp': 'ヨ', 'ro': 'YO'},
    {'jp': 'ラ', 'ro': 'RA'}, {'jp': 'リ', 'ro': 'RI'}, {'jp': 'ル', 'ro': 'RU'}, {'jp': 'レ', 'ro': 'RE'}, {'jp': 'ロ', 'ro': 'RO'},
    {'jp': 'ワ', 'ro': 'WA'}, {'jp': 'ヲ', 'ro': 'WO'},
    {'jp': 'ン', 'ro': 'N'},
  ];

  // Dakuon (Tanda Kutip / Voiced)
  static const List<Map<String, String>> kataDakuon = [
    {'jp': 'ガ', 'ro': 'GA'}, {'jp': 'ギ', 'ro': 'GI'}, {'jp': 'グ', 'ro': 'GU'}, {'jp': 'ゲ', 'ro': 'GE'}, {'jp': 'ゴ', 'ro': 'GO'},
    {'jp': 'ザ', 'ro': 'ZA'}, {'jp': 'ジ', 'ro': 'JI'}, {'jp': 'ズ', 'ro': 'ZU'}, {'jp': 'ゼ', 'ro': 'ZE'}, {'jp': 'ゾ', 'ro': 'ZO'},
    {'jp': 'ダ', 'ro': 'DA'}, {'jp': 'ヂ', 'ro': 'JI'}, {'jp': 'ヅ', 'ro': 'ZU'}, {'jp': 'デ', 'ro': 'DE'}, {'jp': 'ド', 'ro': 'DO'},
    {'jp': 'バ', 'ro': 'BA'}, {'jp': 'ビ', 'ro': 'BI'}, {'jp': 'ブ', 'ro': 'BU'}, {'jp': 'ベ', 'ro': 'BE'}, {'jp': 'ボ', 'ro': 'BO'},
  ];

  // Handakuon (Tanda Bulat / Semi-Voiced)
  static const List<Map<String, String>> kataHandakuon = [
    {'jp': 'パ', 'ro': 'PA'}, {'jp': 'ピ', 'ro': 'PI'}, {'jp': 'プ', 'ro': 'PU'}, {'jp': 'ペ', 'ro': 'PE'}, {'jp': 'ポ', 'ro': 'PO'},
  ];

  // Yoon (Gabungan ya, yu, yo kecil)
  static const List<Map<String, String>> kataYoon = [
    {'jp': 'キャ', 'ro': 'KYA'}, {'jp': 'キュ', 'ro': 'KYU'}, {'jp': 'キョ', 'ro': 'KYO'},
    {'jp': 'シャ', 'ro': 'SHA'}, {'jp': 'シュ', 'ro': 'SHU'}, {'jp': 'ショ', 'ro': 'SHO'},
    {'jp': 'チャ', 'ro': 'CHA'}, {'jp': 'チュ', 'ro': 'CHU'}, {'jp': 'チョ', 'ro': 'CHO'},
    {'jp': 'ニャ', 'ro': 'NYA'}, {'jp': 'ニュ', 'ro': 'NYU'}, {'jp': 'ニョ', 'ro': 'NYO'},
    {'jp': 'ヒャ', 'ro': 'HYA'}, {'jp': 'ヒュ', 'ro': 'HYU'}, {'jp': 'ヒョ', 'ro': 'HYO'},
    {'jp': 'ミャ', 'ro': 'MYA'}, {'jp': 'ミュ', 'ro': 'MYU'}, {'jp': 'ミョ', 'ro': 'MYO'},
    {'jp': 'リャ', 'ro': 'RYA'}, {'jp': 'リュ', 'ro': 'RYU'}, {'jp': 'リョ', 'ro': 'RYO'},
    {'jp': 'ギャ', 'ro': 'GYA'}, {'jp': 'ギュ', 'ro': 'GYU'}, {'jp': 'ギョ', 'ro': 'GYO'},
    {'jp': 'ジャ', 'ro': 'JA'},  {'jp': 'ジュ', 'ro': 'JU'},  {'jp': 'ジョ', 'ro': 'JO'},
    {'jp': 'ビャ', 'ro': 'BYA'}, {'jp': 'ビュ', 'ro': 'BYU'}, {'jp': 'ビョ', 'ro': 'BYO'},
    {'jp': 'ピャ', 'ro': 'PYA'}, {'jp': 'ピュ', 'ro': 'PYU'}, {'jp': 'ピョ', 'ro': 'PYO'},
  ];

  // ==========================================
  // 📚 3. KANJI (BASIC N5)
  // ==========================================

  // Numbers 1-10
  static const List<Map<String, String>> kanjiNumbers = [
    {'jp': '一', 'ro': 'ICHI', 'en': 'One', 'id': 'Satu'},
    {'jp': '二', 'ro': 'NI', 'en': 'Two', 'id': 'Dua'},
    {'jp': '三', 'ro': 'SAN', 'en': 'Three', 'id': 'Tiga'},
    {'jp': '四', 'ro': 'YON', 'en': 'Four', 'id': 'Empat'},
    {'jp': '五', 'ro': 'GO', 'en': 'Five', 'id': 'Lima'},
    {'jp': '六', 'ro': 'ROKU', 'en': 'Six', 'id': 'Enam'},
    {'jp': '七', 'ro': 'NANA', 'en': 'Seven', 'id': 'Tujuh'},
    {'jp': '八', 'ro': 'HACHI', 'en': 'Eight', 'id': 'Delapan'},
    {'jp': '九', 'ro': 'KYUU', 'en': 'Nine', 'id': 'Sembilan'},
    {'jp': '十', 'ro': 'JUU', 'en': 'Ten', 'id': 'Sepuluh'},
  ];

  // Nature & Elements
  static const List<Map<String, String>> kanjiNature = [
    {'jp': '日', 'ro': 'HI', 'en': 'Sun/Day', 'id': 'Matahari/Hari'},
    {'jp': '月', 'ro': 'TSUKI', 'en': 'Moon/Month', 'id': 'Bulan'},
    {'jp': '火', 'ro': 'HI', 'en': 'Fire', 'id': 'Api'},
    {'jp': '水', 'ro': 'MIZU', 'en': 'Water', 'id': 'Air'},
    {'jp': '木', 'ro': 'KI', 'en': 'Tree', 'id': 'Pohon'},
    {'jp': '金', 'ro': 'KANE', 'en': 'Gold/Money', 'id': 'Emas/Uang'},
    {'jp': '土', 'ro': 'TSUCHI', 'en': 'Soil/Earth', 'id': 'Tanah'},
    {'jp': '山', 'ro': 'YAMA', 'en': 'Mountain', 'id': 'Gunung'},
    {'jp': '川', 'ro': 'KAWA', 'en': 'River', 'id': 'Sungai'},
    {'jp': '田', 'ro': 'TA', 'en': 'Rice Field', 'id': 'Sawah'},
  ];

  // People & Directions
  static const List<Map<String, String>> kanjiPeople = [
    {'jp': '人', 'ro': 'HITO', 'en': 'Person', 'id': 'Orang'},
    {'jp': '子', 'ro': 'KO', 'en': 'Child', 'id': 'Anak'},
    {'jp': '女', 'ro': 'ONNA', 'en': 'Woman', 'id': 'Wanita'},
    {'jp': '男', 'ro': 'OTOKO', 'en': 'Man', 'id': 'Pria'},
    {'jp': '上', 'ro': 'UE', 'en': 'Up', 'id': 'Atas'},
    {'jp': '下', 'ro': 'SHITA', 'en': 'Down', 'id': 'Bawah'},
    {'jp': '左', 'ro': 'HIDARI', 'en': 'Left', 'id': 'Kiri'},
    {'jp': '右', 'ro': 'MIGI', 'en': 'Right', 'id': 'Kanan'},
  ];
}