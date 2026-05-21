class QuizRepository {
  static List<Map<String, dynamic>> getQuestions(int unit, String difficulty, int currentStars) {
    // Memfilter data soal berdasarkan unit dan tingkat kesulitan
    if (unit == 1 && difficulty == 'basic') {
      switch (currentStars) {
        case 0:
          return _u1BasicQuestionsSet1; // 10 Soal untuk berburu Bintang Pertama
        case 1:
          return _u1BasicQuestionsSet2; // 10 Soal Berbeda untuk berburu Bintang Kedua
        case 2:
          return _u1BasicQuestionsSet3; // 10 Soal Berbeda untuk berburu Bintang Ketiga
        default:
          return _u1BasicQuestionsSet1;
      }
    }

    // Default fallback jika unit lain dipilih
    return _u1BasicQuestionsSet1;
  }

  // ==================== SET 1: KUIS BINTANG 1 (Dasar Vokal & Huruf Awal) ====================
  static final List<Map<String, dynamic>> _u1BasicQuestionsSet1 = [
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'あ',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'a', 'romaji': 'a'},
        {'code': 'B', 'text': 'i', 'romaji': 'i'},
        {'code': 'C', 'text': 'u', 'romaji': 'u'},
        {'code': 'D', 'text': 'e', 'romaji': 'e'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'い',
      'correctIndex': 1,
      'options': [
        {'code': 'A', 'text': 'o', 'romaji': 'o'},
        {'code': 'B', 'text': 'i', 'romaji': 'i'},
        {'code': 'C', 'text': 'a', 'romaji': 'a'},
        {'code': 'D', 'text': 'u', 'romaji': 'u'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'う',
      'correctIndex': 2,
      'options': [
        {'code': 'A', 'text': 'e', 'romaji': 'e'},
        {'code': 'B', 'text': 'n', 'romaji': 'n'},
        {'code': 'C', 'text': 'u', 'romaji': 'u'},
        {'code': 'D', 'text': 'o', 'romaji': 'o'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'え',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'e', 'romaji': 'e'},
        {'code': 'B', 'text': 'a', 'romaji': 'a'},
        {'code': 'C', 'text': 'o', 'romaji': 'o'},
        {'code': 'D', 'text': 'i', 'romaji': 'i'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'お',
      'correctIndex': 3,
      'options': [
        {'code': 'A', 'text': 'u', 'romaji': 'u'},
        {'code': 'B', 'text': 'e', 'romaji': 'e'},
        {'code': 'C', 'text': 'a', 'romaji': 'a'},
        {'code': 'D', 'text': 'o', 'romaji': 'o'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Kata "Aoi" (Biru) jika ditulis dalam Hiragana adalah...',
      'japanese': 'あおい',
      'correctIndex': 1,
      'options': [
        {'code': 'A', 'text': 'aka', 'romaji': 'aka'},
        {'code': 'B', 'text': 'aoi', 'romaji': 'aoi'},
        {'code': 'C', 'text': 'ie', 'romaji': 'ie'},
        {'code': 'D', 'text': 'uon', 'romaji': 'uon'},
      ]
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter berikut:',
      'japanese': 'か',
      'answer': 'ka'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter berikut:',
      'japanese': 'き',
      'answer': 'ki'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter berikut:',
      'japanese': 'く',
      'answer': 'ku'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan arti romaji dari kata "Ie" (Rumah) berikut:',
      'japanese': 'いえ',
      'answer': 'ie'
    },
  ];

  // ==================== SET 2: KUIS BINTANG 2 (Deret Sa, Ta, Na + Kosakata) ====================
  static final List<Map<String, dynamic>> _u1BasicQuestionsSet2 = [
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'か',
      'correctIndex': 1,
      'options': [
        {'code': 'A', 'text': 'sa', 'romaji': 'sa'},
        {'code': 'B', 'text': 'ka', 'romaji': 'ka'},
        {'code': 'C', 'text': 'ta', 'romaji': 'ta'},
        {'code': 'D', 'text': 'na', 'romaji': 'na'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'さ',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'sa', 'romaji': 'sa'},
        {'code': 'B', 'text': 'chi', 'romaji': 'chi'},
        {'code': 'C', 'text': 'ki', 'romaji': 'ki'}, // TERPERBAIKI: Titik dua diganti koma
        {'code': 'D', 'text': 'tsu', 'romaji': 'tsu'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Hati-hati dengan pengecualian! Karakter "し" dibaca...',
      'japanese': 'し',
      'correctIndex': 2,
      'options': [
        {'code': 'A', 'text': 'si', 'romaji': 'si'},
        {'code': 'B', 'text': 'su', 'romaji': 'su'},
        {'code': 'C', 'text': 'shi', 'romaji': 'shi'},
        {'code': 'D', 'text': 'se', 'romaji': 'se'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'た',
      'correctIndex': 3,
      'options': [
        {'code': 'A', 'text': 'na', 'romaji': 'na'},
        {'code': 'B', 'text': 'ni', 'romaji': 'ni'},
        {'code': 'C', 'text': 'ko', 'romaji': 'ko'},
        {'code': 'D', 'text': 'ta', 'romaji': 'ta'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Hati-hati dengan pengecualian! Karakter "ち" dibaca...',
      'japanese': 'ち',
      'correctIndex': 1,
      'options': [
        {'code': 'A', 'text': 'ti', 'romaji': 'ti'},
        {'code': 'B', 'text': 'chi', 'romaji': 'chi'},
        {'code': 'C', 'text': 'te', 'romaji': 'te'},
        {'code': 'D', 'text': 'tsu', 'romaji': 'tsu'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Kombinasi kata "Aka" (Merah) ditulis dengan kombinasi huruf...',
      'japanese': 'あか',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'aka', 'romaji': 'aka'},
        {'code': 'B', 'text': 'sake', 'romaji': 'sake'},
        {'code': 'C', 'text': 'iko', 'romaji': 'iko'},
        {'code': 'D', 'text': 'aoi', 'romaji': 'aoi'},
      ]
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter pengecualian "つ" berikut:',
      'japanese': 'つ',
      'answer': 'tsu'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter berikut:',
      'japanese': 'て',
      'answer': 'te'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari karakter berikut:',
      'japanese': 'と',
      'answer': 'to'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji untuk kata "Sake" (Minuman Jepang / Ikan Salmon):',
      'japanese': 'さけ',
      'answer': 'sake'
    },
  ];

  // ==================== SET 3: KUIS BINTANG 3 (Full Evaluasi & Pembentukan Kata) ====================
  static final List<Map<String, dynamic>> _u1BasicQuestionsSet3 = [
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'な',
      'correctIndex': 2,
      'options': [
        {'code': 'A', 'text': 'ta', 'romaji': 'ta'},
        {'code': 'B', 'text': 'ha', 'romaji': 'ha'},
        {'code': 'C', 'text': 'na', 'romaji': 'na'},
        {'code': 'D', 'text': 'ma', 'romaji': 'ma'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'に',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'ni', 'romaji': 'ni'},
        {'code': 'B', 'text': 'ko', 'romaji': 'ko'},
        {'code': 'C', 'text': 'ta', 'romaji': 'ta'},
        {'code': 'D', 'text': 'i', 'romaji': 'i'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'ぬ',
      'correctIndex': 3,
      'options': [
        {'code': 'A', 'text': 'me', 'romaji': 'me'},
        {'code': 'B', 'text': 'ne', 'romaji': 'ne'},
        {'code': 'C', 'text': 'no', 'romaji': 'no'},
        {'code': 'D', 'text': 'nu', 'romaji': 'nu'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Pilihlah romaji yang tepat untuk karakter berikut:',
      'japanese': 'ね',
      'correctIndex': 1,
      'options': [
        {'code': 'A', 'text': 'wa', 'romaji': 'wa'},
        {'code': 'B', 'text': 'ne', 'romaji': 'ne'},
        {'code': 'C', 'text': 're', 'romaji': 're'},
        {'code': 'D', 'text': 'nu', 'romaji': 'nu'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Karakter lingkaran/garis tunggal "の" dibaca...',
      'japanese': 'の',
      'correctIndex': 0,
      'options': [
        {'code': 'A', 'text': 'no', 'romaji': 'no'},
        {'code': 'B', 'text': 'me', 'romaji': 'me'},
        {'code': 'C', 'text': 'nu', 'romaji': 'nu'},
        {'code': 'D', 'text': 'a', 'romaji': 'a'},
      ]
    },
    {
      'type': 'multiple_choice',
      'question': 'Kata "Inu" (Anjing) terdiri dari gabungan huruf...',
      'japanese': 'いぬ',
      'correctIndex': 2,
      'options': [
        {'code': 'A', 'text': 'neko', 'romaji': 'neko'},
        {'code': 'B', 'text': 'sushi', 'romaji': 'sushi'},
        {'code': 'C', 'text': 'inu', 'romaji': 'inu'},
        {'code': 'D', 'text': 'aka', 'romaji': 'aka'},
      ]
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari kata berikut ini:',
      'japanese': 'すし',
      'answer': 'sushi'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari kata "Natsu" (Musim Panas):',
      'japanese': 'なつ',
      'answer': 'natsu'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari kata "Sakana" (Ikan):',
      'japanese': 'さかな',
      'answer': 'sakana'
    },
    {
      'type': 'essay',
      'question': 'Tuliskan romaji dari kata "Chika" (Bawah Tanah):',
      'japanese': 'ちか',
      'answer': 'chika'
    },
  ];
}