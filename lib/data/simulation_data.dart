class SimulationQuestion {
  final String section; // Vocabulary, Grammar, Reading, Listening
  final String question;
  final String? subQuestion; // For reading/context
  final List<String> options;
  final int correctAnswerIndex;
  final String? audioPath; // For listening

  SimulationQuestion({
    required this.section,
    required this.question,
    this.subQuestion,
    required this.options,
    required this.correctAnswerIndex,
    this.audioPath,
  });
}

class SimulationData {
  static List<SimulationQuestion> n5Questions = [
    // VOCABULARY
    SimulationQuestion(
      section: 'Vocabulary',
      question: 'きのう、デパートで　くつを　（　　）ました。',
      options: ['かき', 'かい', 'あき', 'きき'],
      correctAnswerIndex: 1, // かい (bought)
    ),
    SimulationQuestion(
      section: 'Vocabulary',
      question: 'わたしの　いえは　（　　）です。',
      options: ['ふるい', 'ひろい', 'ちかい', 'あかるい'],
      correctAnswerIndex: 1, // ひろい (spacious) - just as example
    ),

    // GRAMMAR
    SimulationQuestion(
      section: 'Grammar',
      question: 'つくえの　うえ　（　　）　ほんが　あります。',
      options: ['に', 'を', 'が', 'の'],
      correctAnswerIndex: 0, // に
    ),

    // LISTENING (Mock)
    SimulationQuestion(
      section: 'Listening',
      question: 'Which fruit did the woman buy?',
      options: ['Apple', 'Banana', 'Orange', 'Grape'],
      correctAnswerIndex: 0,
      audioPath: 'n5_listening_1.mp3',
    ),
  ];
}
