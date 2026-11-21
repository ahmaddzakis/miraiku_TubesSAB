import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miraiku/core/game_manager.dart';
import 'package:miraiku/core/localization/app_localizations.dart';
import 'package:miraiku/core/repository/local_repository.dart';
import 'package:miraiku/core/theme/app_theme.dart';
import 'package:miraiku/core/widgets/app_badge.dart';
import 'package:miraiku/core/widgets/app_button.dart';
import 'package:miraiku/core/widgets/app_card.dart';
import 'package:miraiku/core/widgets/app_progress_bar.dart';
import 'package:miraiku/data/quiz_repository.dart';
import 'package:miraiku/features/learn/screen_exercise.dart';
import 'package:miraiku/features/learn/widget_learn.dart';
import 'package:miraiku/widgets/path_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'setting_sound': false});
    await GameManager.resetProgress();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setting_sound', false);
  });

  group('GameManager & Octalysis Gamification Unit Tests', () {
    test('addXP and spendXP correctly update globalXP and SharedPreferences',
        () async {
      expect(globalXP.value, 0);

      await GameManager.addXP(500);
      expect(globalXP.value, 500);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('gm_xp'), 500);

      // Spend 200 XP (succeeds)
      final success = await GameManager.spendXP(200);
      expect(success, isTrue);
      expect(globalXP.value, 300);
      expect(prefs.getInt('gm_xp'), 300);

      // Spend 400 XP when only 300 XP is available (fails without deducting)
      final failed = await GameManager.spendXP(400);
      expect(failed, isFalse);
      expect(globalXP.value, 300);
    });

    test('decreaseHeart and buyHeartWithXP enforce heart limits and XP cost',
        () async {
      expect(globalHearts.value, 5);

      // Cannot buy heart when already at maxHearts (5)
      await GameManager.addXP(500);
      final buyWhenFull = await GameManager.buyHeartWithXP();
      expect(buyWhenFull, isFalse);
      expect(globalXP.value, 500);

      // Deduct 1 heart -> 4 hearts
      await GameManager.decreaseHeart();
      expect(globalHearts.value, 4);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('gm_hearts'), 4);
      expect(prefs.getString('gm_last_heart_loss'), isNotNull);

      // Buy 1 heart for 150 XP -> 5 hearts, 350 XP remaining
      final buySuccess = await GameManager.buyHeartWithXP();
      expect(buySuccess, isTrue);
      expect(globalHearts.value, 5);
      expect(globalXP.value, 350);
    });

    test(
        'buyStreakShieldWithXP (Core Drive 8: Loss & Avoidance) respects max shields and cost',
        () async {
      expect(globalStreakShields.value, 0);

      // Fails when XP < 300
      await GameManager.addXP(200);
      expect(await GameManager.buyStreakShieldWithXP(), isFalse);
      expect(globalStreakShields.value, 0);

      // Add XP to reach 1200 XP
      await GameManager.addXP(1000);
      expect(globalXP.value, 1200);

      // Buy up to maxStreakShields (3)
      expect(await GameManager.buyStreakShieldWithXP(), isTrue);
      expect(globalStreakShields.value, 1);
      expect(globalXP.value, 900);

      expect(await GameManager.buyStreakShieldWithXP(), isTrue);
      expect(globalStreakShields.value, 2);
      expect(globalXP.value, 600);

      expect(await GameManager.buyStreakShieldWithXP(), isTrue);
      expect(globalStreakShields.value, 3);
      expect(globalXP.value, 300);

      // Cannot exceed maxStreakShields (3)
      expect(await GameManager.buyStreakShieldWithXP(), isFalse);
      expect(globalStreakShields.value, 3);
      expect(globalXP.value, 300);
    });

    test(
        'updateKanaProgress (Core Drive 4: Ownership & Possession) tracks Hiragana, Katakana, and Kanji without duplicates',
        () async {
      await GameManager.updateKanaProgress('あ', 0);
      await GameManager.updateKanaProgress('あ', 0); // duplicate ignored
      await GameManager.updateKanaProgress('ア', 1);
      await GameManager.updateKanaProgress('日', 2);

      expect(globalLearnedHiragana.value, ['あ']);
      expect(globalLearnedKatakana.value, ['ア']);
      expect(globalLearnedKanji.value, ['日']);
    });
  });

  group('LocalRepository Offline-First Sync Queue Tests', () {
    test('queueActionsBatch deduplicates keys and caches values locally',
        () async {
      await LocalRepository.queueAction('gm_xp', 100, triggerSync: false);
      await LocalRepository.queueActionsBatch(
        {
          'gm_xp': 250,
          'gm_streak': 4,
          'gm_streak_shields': 2,
        },
        triggerSync: false,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('cache_gm_xp'), 250);
      expect(prefs.getInt('cache_gm_streak'), 4);
      expect(prefs.getInt('cache_gm_streak_shields'), 2);

      final pending = prefs.getStringList('pending_sync_actions') ?? [];
      expect(pending.length, 3);

      final Map<String, dynamic> decodedMap = {};
      for (final item in pending) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        decodedMap[decoded['key'] as String] = decoded['value'];
      }

      expect(decodedMap['gm_xp'], 250);
      expect(decodedMap['gm_streak'], 4);
      expect(decodedMap['gm_streak_shields'], 2);
    });
  });

  group('Design System & Core Reusable Widgets Tests', () {
    testWidgets('AppButton, AppCard, AppBadge, and AppProgressBar render properly',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                const AppCard(
                  child: Text('JLPT N5 Study Card'),
                ),
                const AppBadge(
                  label: '1500 XP',
                  icon: Icons.star_rounded,
                ),
                const AppProgressBar(
                  progress: 0.75,
                ),
                AppButton(
                  label: 'Start Quiz',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('JLPT N5 Study Card'), findsOneWidget);
      expect(find.text('1500 XP'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);

      await tester.tap(find.text('Start Quiz'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets(
        'UnitHeaderCard and PathNode render cleanly in Light & Dark themes',
        (WidgetTester tester) async {
      globalDarkMode.value = true;
      globalLanguage.value = 'en';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const UnitHeaderCard(
                    unitNumber: 1,
                    titleEn: 'GREETINGS & BASICS',
                    subtitleEn: 'Learn basic phrases and greet people',
                  ),
                  PathNode(
                    title: 'Hiragana Basics 1',
                    status: NodeStatus.completed,
                    alignment: Alignment.center,
                    icon: Icons.abc_rounded,
                    stars: 3,
                    onReplaySelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('UNIT 1'), findsOneWidget);
      expect(find.text('GREETINGS & BASICS'), findsOneWidget);
      expect(find.text('Hiragana Basics 1'), findsOneWidget);
    });
  });

  group('QuizRepository Localization & ExerciseScreen Word Meaning Tests', () {
    test(
        'QuizRepository.getQuestions localizes prompts, answers, and preserves kanji across ID and EN',
        () {
      // Indonesian localization (Unit 2, katakana_words, currentStars=0 -> _kataWordStar1, all essay word-meaning)
      final questionsId =
          QuizRepository.getQuestions(2, 'katakana_words', 0, 'id');
      expect(questionsId, isNotEmpty);

      for (final q in questionsId) {
        expect(q['question'], AppLocalizations.wordMeaningQuestion('id'));
        expect(q['answer'], isA<String>());
        expect((q['answer'] as String).isNotEmpty, isTrue);
        expect(q.containsKey('kanji'), isTrue);
      }

      // English localization (Unit 2, katakana_words, currentStars=0 -> _kataWordStar1)
      final questionsEn =
          QuizRepository.getQuestions(2, 'katakana_words', 0, 'en');
      expect(questionsEn, isNotEmpty);

      for (final q in questionsEn) {
        expect(q['question'], AppLocalizations.wordMeaningQuestion('en'));
        expect(q['answer'], isA<String>());
        expect((q['answer'] as String).isNotEmpty, isTrue);
        expect(q.containsKey('kanji'), isTrue);
      }

      // Unit 3 Kanji questions provide both kanji and hiragana reading
      final kanjiQuestions =
          QuizRepository.getQuestions(3, 'kanji_numbers', 0, 'id');
      expect(kanjiQuestions, isNotEmpty);
      for (final q in kanjiQuestions) {
        expect(q['question'], AppLocalizations.wordMeaningQuestion('id'));
        expect(q['kanji'], isNotNull);
        expect((q['kanji'] as String).isNotEmpty, isTrue);
        expect((q['japanese'] as String).isNotEmpty, isTrue);
        expect(q['kanji'], isNot(equals(q['japanese'])));
      }
    });

    testWidgets(
        'ExerciseScreen enforces single-choice selection (max 1), renders Kanji + Kana, and localizes prompts',
        (WidgetTester tester) async {
      // Use a realistic mobile screen viewport height so the bottom choice chips are visible without scrolling
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = false;

      // Unit 3, kanji_numbers, currentStars = 0 loads _knStar1 (all essay word-meaning with Kanji + Kana)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ExerciseScreen(
            unit: 3,
            difficulty: 'kanji_numbers',
            currentStars: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify localized prompt and placeholder
      expect(
        find.text(AppLocalizations.wordMeaningQuestion('id')),
        findsOneWidget,
      );
      expect(
        find.text(AppLocalizations.answerSlotPlaceholder('id')),
        findsOneWidget,
      );

      // Initially 0 selected -> CEK JAWABAN button is disabled
      AppButton checkBtn = tester.widget<AppButton>(
        find.widgetWithText(
          AppButton,
          AppLocalizations.checkAnswer('id'),
        ),
      );
      expect(checkBtn.onPressed, isNull);

      // Find the 4 choice chips in the Wrap
      final wrapFinder = find.byType(Wrap).last;
      final choiceGestures = find.descendant(
        of: wrapFinder,
        matching: find.byType(GestureDetector),
      );
      expect(choiceGestures, findsNWidgets(4));

      final firstChoiceTextWidget = tester.widget<Text>(
        find.descendant(
          of: choiceGestures.at(0),
          matching: find.byType(Text),
        ),
      );
      final secondChoiceTextWidget = tester.widget<Text>(
        find.descendant(
          of: choiceGestures.at(1),
          matching: find.byType(Text),
        ),
      );
      final firstChoiceLabel = firstChoiceTextWidget.data!;
      final secondChoiceLabel = secondChoiceTextWidget.data!;

      // Tap first option -> selected (appears in answer slot + choice bank = 2 texts)
      await tester.tap(choiceGestures.at(0));
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizations.answerSlotPlaceholder('id')),
        findsNothing,
      );
      expect(find.text(firstChoiceLabel), findsNWidgets(2));
      checkBtn = tester.widget<AppButton>(
        find.widgetWithText(
          AppButton,
          AppLocalizations.checkAnswer('id'),
        ),
      );
      expect(checkBtn.onPressed, isNotNull);

      // Tap second option -> replaces first option (single-choice maxSelection = 1)
      await tester.tap(choiceGestures.at(1));
      await tester.pumpAndSettle();

      expect(find.text(firstChoiceLabel), findsOneWidget); // only in choice bank
      expect(find.text(secondChoiceLabel), findsNWidgets(2)); // in slot + choice bank

      // Tap second option again -> cancels selection
      await tester.tap(choiceGestures.at(1));
      await tester.pumpAndSettle();

      expect(find.text(secondChoiceLabel), findsOneWidget);
      expect(
        find.text(AppLocalizations.answerSlotPlaceholder('id')),
        findsOneWidget,
      );
      checkBtn = tester.widget<AppButton>(
        find.widgetWithText(
          AppButton,
          AppLocalizations.checkAnswer('id'),
        ),
      );
      expect(checkBtn.onPressed, isNull);
    });
  });
}
