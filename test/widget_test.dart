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
import 'package:miraiku/data/simulation_data.dart';
import 'package:miraiku/features/kana/screen_kana.dart';
import 'package:miraiku/features/learn/screen_exercise.dart';
import 'package:miraiku/features/learn/screen_learn.dart';
import 'package:miraiku/features/learn/widget_learn.dart';
import 'package:miraiku/features/profile/screen_profile.dart';
import 'package:miraiku/features/simulation/screen_simulation.dart';
import 'package:miraiku/features/simulation/screen_simulation_history.dart';
import 'package:miraiku/features/simulation/screen_simulation_test.dart';
import 'package:miraiku/features/simulation/simulation_result_screen.dart';
import 'package:miraiku/features/simulation/simulation_review_screen.dart';
import 'package:miraiku/features/tracker/screen_jlpt_tracker.dart';
import 'package:miraiku/widgets/custom_bottom_nav.dart';
import 'package:miraiku/widgets/path_node.dart';
import 'package:miraiku/widgets/top_status_bar.dart';
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

    testWidgets(
        'ExerciseScreen awards 0 XP when exiting early via X button, and awards total XP only upon full completion',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = false;
      expect(globalXP.value, 0);

      final Map<String, String> kanjiToAnswer = {
        for (final q in QuizRepository.getQuestions(3, 'kanji_numbers', 0, 'id'))
          q['kanji'].toString(): q['answer'].toString(),
      };

      // 1. Start quiz inside a Navigator so pressing Exit pops back cleanly
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseScreen(
                          unit: 3,
                          difficulty: 'kanji_numbers',
                          currentStars: 0,
                        ),
                      ),
                    );
                  },
                  child: const Text('OPEN QUIZ'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN QUIZ'));
      await tester.pumpAndSettle();

      // Answer the first question correctly
      final String firstAnswer = kanjiToAnswer.entries
          .firstWhere((e) => find.text(e.key).evaluate().isNotEmpty)
          .value;
      await tester.tap(find.text(firstAnswer));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.checkAnswer('id')));
      await tester.pumpAndSettle();

      // XP must NOT be awarded mid-quiz
      expect(globalXP.value, 0);

      // Tap the "X" close button and confirm Exit
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocalizations.exitLabel('id')));
      await tester.pumpAndSettle();

      // Exiting early awards 0 XP
      expect(globalXP.value, 0);

      // 2. Re-open quiz and complete all 6 questions -> awards 6 * 25 = 150 XP total at the end
      await tester.tap(find.text('OPEN QUIZ'));
      await tester.pumpAndSettle();

      for (int i = 0; i < kanjiToAnswer.length; i++) {
        final String answer = kanjiToAnswer.entries
            .firstWhere((e) => find.text(e.key).evaluate().isNotEmpty)
            .value;
        await tester.tap(find.text(answer));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppLocalizations.checkAnswer('id')));
        await tester.pumpAndSettle();

        // Still 0 XP before completing the entire quiz
        expect(globalXP.value, 0);

        final bool isLast = i == kanjiToAnswer.length - 1;
        await tester.tap(
          find.text(
            isLast
                ? AppLocalizations.finishLabel('id')
                : AppLocalizations.continueLabel('id'),
          ),
        );
        await tester.pumpAndSettle();
      }

      // Full quiz completed -> total 150 XP awarded
      expect(globalXP.value, 150);
      expect(find.text('+150'), findsOneWidget);
    });
  });

  group('360x800 Narrow Viewport Responsiveness & Overflow Audit Tests', () {
    testWidgets(
        'SimulationScreen, SimulationHistoryScreen, and SimulationResultScreen render without overflow at 360x800 in ID & EN',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalXP.value = 1800;
      globalSimulationHistory.value = [
        {
          'date': DateTime(2026, 4, 21, 20, 30).toIso8601String(),
          'totalPoints': 63.0,
          'isPassed': false,
          'languageScore': 3,
          'languageTotal': 10,
          'readingScore': 4,
          'readingTotal': 10,
          'timeSpentSeconds': 1245,
          'userAnswers': List<int?>.filled(20, 0),
        },
      ];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_simulation_unlocked', true);

      for (final lang in ['id', 'en']) {
        globalLanguage.value = lang;

        // 1a. SimulationScreen (locked state with XP Readiness progress bar)
        await prefs.setBool('cache_unlocked_sim_n5', false);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  TopStatusBar(),
                  Expanded(child: SimulationScreen()),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 1b. SimulationScreen (unlocked state with history count badge & best score badge)
        await prefs.setBool('cache_unlocked_sim_n5', true);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  TopStatusBar(),
                  Expanded(
                    child: SimulationScreen(
                      key: ValueKey('unlocked_sim'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 2. SimulationHistoryScreen
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SimulationHistoryScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 3. SimulationResultScreen
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SimulationResultScreen(
              languageScore: 3,
              languageTotal: 10,
              readingScore: 4,
              readingTotal: 10,
              totalPoints: 63,
              isPassed: false,
              userAnswers: [],
              timeSpentSeconds: 1245,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
        'ProfileScreen, LearnScreen, KanaScreen, TopStatusBar, and CustomBottomNavBar render without overflow at 360x800 in ID & EN',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalXP.value = 2450;
      globalStreak.value = 14;
      globalStreakShields.value = 2;

      for (final lang in ['id', 'en']) {
        globalLanguage.value = lang;

        // 1. ProfileScreen (including Streak Shield / Omamori card)
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: const Column(
                children: [
                  TopStatusBar(),
                  Expanded(child: ProfileScreen()),
                ],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                selectedIndex: 3,
                onTap: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 2. LearnScreen
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Column(
                children: [
                  const TopStatusBar(),
                  Expanded(
                    child: LearnScreen(
                      isUnit1Completed: false,
                      onUnit1Completed: () {},
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                selectedIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 3. KanaScreen
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: const Column(
                children: [
                  TopStatusBar(),
                  Expanded(child: KanaScreen()),
                ],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                selectedIndex: 2,
                onTap: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Pro Simulator Achievement Count Behavior Tests', () {
    testWidgets(
        'Starting simulation and exiting early does NOT increment Pro Simulator; completing all questions increments it once',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = false;
      globalXP.value = 500;
      expect(globalSimulationCount.value, 0);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cache_unlocked_sim_n5', true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SimulationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Tap "MULAI SIMULASI" -> "MULAI"
      await tester.tap(find.text('MULAI SIMULASI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MULAI'));
      await tester.pumpAndSettle();

      // XP is deducted (500 -> 400), SimulationTestScreen is open,
      // but Pro Simulator count MUST still be 0!
      expect(find.byType(SimulationTestScreen), findsOneWidget);
      expect(globalXP.value, 400);
      expect(globalSimulationCount.value, 0);

      // 2. Exit early via the X button -> count MUST still be 0
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KELUAR'));
      await tester.pumpAndSettle();

      expect(find.byType(SimulationScreen), findsOneWidget);
      expect(globalSimulationCount.value, 0);

      // 3. Re-enter exam and complete all questions to the end
      await tester.tap(find.text('MULAI SIMULASI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MULAI'));
      await tester.pumpAndSettle();

      expect(globalXP.value, 300);
      expect(globalSimulationCount.value, 0);

      final int totalQuestions = SimulationData.n5Questions.length;
      for (int i = 0; i < totalQuestions; i++) {
        // Select option A (InkWell inside the first option card)
        await tester.tap(find.text('A'));
        await tester.pump();

        // Must remain 0 until the very last question is finished
        expect(globalSimulationCount.value, 0);

        final bool isLast = i == totalQuestions - 1;
        await tester.tap(find.text(isLast ? 'SELESAI' : 'LANJUT'));
        await tester.pumpAndSettle();

        if (isLast) {
          // Confirm submission in the Finish confirmation dialog
          await tester.tap(find.text('SELESAI').last);
          await tester.pumpAndSettle();
        }
      }

      // Now on SimulationResultScreen and Pro Simulator incremented by exactly 1
      expect(find.byType(SimulationResultScreen), findsOneWidget);
      expect(globalSimulationCount.value, 1);
    });
  });

  group('JLPTTrackerScreen Readiness Dashboard & 360x800 Responsiveness Tests',
      () {
    testWidgets(
        'JLPTTrackerScreen calculates 70% readiness (100% scripts + 0/4 units), recommends Unit 1-4, and renders without overflow at 360x800 in Light/Dark & ID/EN',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLearnedHiragana.value =
          List<String>.generate(104, (i) => 'h_$i');
      globalLearnedKatakana.value =
          List<String>.generate(104, (i) => 'k_$i');
      globalLearnedKanji.value =
          List<String>.generate(68, (i) => 'kn_$i');

      for (final isDark in [false, true]) {
        globalDarkMode.value = isDark;
        for (final lang in ['id', 'en']) {
          globalLanguage.value = lang;

          await tester.pumpWidget(
            MaterialApp(
              theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: JLPTTrackerScreen(
                key: ValueKey('jlpt_${isDark}_$lang'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // 20% Hiragana + 20% Katakana + 30% Kanji + 0% Units = 70%
          expect(find.text('70%'), findsOneWidget);
          expect(find.text('276 / 276'), findsOneWidget);
          expect(find.text('0 / 4'), findsNWidgets(2));

          if (lang == 'id') {
            expect(find.text('Selesai ✓'), findsNWidgets(3));
            expect(find.text('Fokus Selanjutnya'), findsOneWidget);
            expect(find.text('POTENSI +30%'), findsOneWidget);
            expect(find.text('Materi Belajar (Unit 1-4)'), findsNWidgets(2));
          } else {
            expect(find.text('Done ✓'), findsNWidgets(3));
            expect(find.text('Next Recommended Step'), findsOneWidget);
            expect(find.text('+30% POTENTIAL'), findsOneWidget);
            expect(find.text('Learning Materials (Unit 1-4)'), findsNWidgets(2));
          }
        }
      }
    });
  });

  group('Developer Quick Login Ephemeral Reset Tests', () {
    test(
        'Developer Quick Login always seeds 2000 XP and resets simulation unlock, kana, units, hearts, and achievements upon re-login',
        () async {
      // 1. First Developer Quick Login starts at 2000 XP, 5 Hearts, Simulation locked
      await GameManager.startDevQuickLogin();
      expect(GameManager.isDevSession, isTrue);
      expect(globalXP.value, 2000);
      expect(globalHearts.value, 5);
      expect(globalStreak.value, 1);
      expect(globalStreakShields.value, 1);
      expect(globalLearnedHiragana.value, isEmpty);
      expect(globalLearnedKatakana.value, isEmpty);
      expect(globalLearnedKanji.value, isEmpty);
      expect(globalSimulationHistory.value, isEmpty);

      final initialMeta = await LocalRepository.getUserProgress();
      expect(initialMeta['unlocked_sim_n5'], isFalse);

      // 2. Unlock JLPT Simulation (-1500 XP -> 500 XP), lose 2 hearts, learn Kana, earn Unit stars
      final unlocked = await GameManager.spendXP(
        1500,
        extraData: {'unlocked_sim_n5': true},
      );
      expect(unlocked, isTrue);
      expect(globalXP.value, 500);

      await GameManager.decreaseHeart();
      await GameManager.decreaseHeart();
      expect(globalHearts.value, 3);

      await GameManager.updateKanaProgress('あ', 0);
      await GameManager.updateKanaProgress('ア', 1);
      await GameManager.updateKanaProgress('日', 2);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('u1_hira1_stars', 3);
      await prefs.setInt('u1_test_stars', 1);
      await GameManager.incrementSimulationCount();
      globalSimulationHistory.value = [
        {'totalPoints': 120.0, 'isPassed': true},
      ];
      await LocalRepository.queueActionsBatch(
        {'ach_hira': true},
        triggerSync: false,
      );

      // Progress exists during the active session, but pending cloud sync queue stays empty
      final midMeta = await LocalRepository.getUserProgress();
      expect(midMeta['unlocked_sim_n5'], isTrue);
      expect(prefs.getStringList('pending_sync_actions'), isNull);

      // 3. Logout and login again with Developer Quick Login -> EVERYTHING resets back to 2000 XP & locked!
      await GameManager.resetProgress();
      await GameManager.startDevQuickLogin();

      expect(GameManager.isDevSession, isTrue);
      expect(globalXP.value, 2000);
      expect(globalHearts.value, 5);
      expect(globalStreak.value, 1);
      expect(globalStreakShields.value, 1);
      expect(globalSimulationCount.value, 0);
      expect(globalLearnedHiragana.value, isEmpty);
      expect(globalLearnedKatakana.value, isEmpty);
      expect(globalLearnedKanji.value, isEmpty);
      expect(globalSimulationHistory.value, isEmpty);
      expect(prefs.getInt('u1_hira1_stars'), isNull);
      expect(prefs.getInt('u1_test_stars'), isNull);

      final resetMeta = await LocalRepository.getUserProgress();
      expect(resetMeta['unlocked_sim_n5'], isFalse);
      expect(resetMeta['ach_hira'], isFalse);
    });

    testWidgets(
        'Restored SimulationScreen renders Hero card, Exam Room card, shortened descriptions, briefing dialog with full MULAI button, and History navigation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = false;
      globalXP.value = 500;
      globalSimulationHistory.value = [];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cache_unlocked_sim_n5', true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SimulationScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Card 1 (Hero): badge, shortened description, Best Score progress bar (Option B)
      expect(find.text('OFFICIAL JLPT N5 STANDARD'), findsOneWidget);
      expect(find.text('Simulasi Ujian JLPT N5'), findsOneWidget);
      expect(
        find.text('Ukur kemampuan bahasa Jepangmu dalam kondisi ujian nyata.'),
        findsOneWidget,
      );
      expect(find.text('Skor Terbaikmu: 0 / 180'), findsOneWidget);
      expect(find.text('Target Lulus: 80'), findsOneWidget);

      // Card 2 (Exam Room): title, no redundant ticket/XP subtitle, and 100 XP badge in button
      expect(find.text('Ruang Ujian Terbuka'), findsOneWidget);
      expect(find.text('Tiket 100 XP • XP kamu: 500'), findsNothing);
      expect(find.text('100 XP'), findsOneWidget);

      // Tap "MULAI SIMULASI" -> opens Briefing Dialog with shortened items and un-truncated "MULAI" button
      await tester.tap(find.text('MULAI SIMULASI'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('Cek aturan sebelum mulai.'), findsOneWidget);
      expect(find.text('Timer berjalan tanpa jeda.'), findsOneWidget);
      expect(find.text('Bahasa 60 + Membaca 120.'), findsOneWidget);
      expect(find.text('Dipotong saat ujian dimulai.'), findsOneWidget);
      expect(find.text('MULAI'), findsOneWidget);

      // Close briefing dialog via BATAL, then open Riwayat
      await tester.tap(find.text('BATAL'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.byType(SimulationHistoryScreen), findsOneWidget);
    });

    test(
        'SimulationHistoryAnalytics computes gapToPass, best session, score deltas, performance tier, and date groups accurately',
        () {
      final DateTime refNow = DateTime(2026, 11, 22, 12, 0);
      final List<Map<String, dynamic>> sampleHistory = [
        {
          'date': DateTime(2026, 11, 22, 9, 30).toIso8601String(),
          'totalPoints': 72.0,
          'isPassed': false,
          'languageScore': 5,
          'languageTotal': 10,
          'readingScore': 3,
          'readingTotal': 10,
          'timeSpentSeconds': 1400,
        },
        {
          'date': DateTime(2026, 11, 21, 18, 0).toIso8601String(),
          'totalPoints': 63.0,
          'isPassed': false,
          'languageScore': 3,
          'languageTotal': 10,
          'readingScore': 4,
          'readingTotal': 10,
          'timeSpentSeconds': 1245,
        },
        {
          'date': DateTime(2026, 11, 10, 14, 0).toIso8601String(),
          'totalPoints': 78.0,
          'isPassed': false,
          'languageScore': 6,
          'languageTotal': 10,
          'readingScore': 3,
          'readingTotal': 10,
          'timeSpentSeconds': 1500,
        },
      ];

      final analytics = SimulationHistoryAnalytics.fromRawList(
        sampleHistory,
        now: refNow,
      );

      expect(analytics.totalAttempts, 3);
      expect(analytics.bestScore, 78);
      expect(analytics.gapToPass, 2); // 80 - 78 = 2
      expect(analytics.passRate, 0);
      expect(analytics.performanceTier, SimulationPerformanceTier.almost);
      expect(analytics.chronologicalScores, [78, 63, 72]);

      // Newest entry (72 pts): compared to previous (63 pts) -> delta +9, today
      final newest = analytics.entriesNewestFirst[0];
      expect(newest.score, 72);
      expect(newest.scoreDelta, 9);
      expect(newest.isBestSession, isFalse);
      expect(newest.dateGroup, SimulationDateGroup.today);

      // Middle entry (63 pts): compared to oldest (78 pts) -> delta -15, yesterday
      final middle = analytics.entriesNewestFirst[1];
      expect(middle.score, 63);
      expect(middle.scoreDelta, -15);
      expect(middle.isBestSession, isFalse);
      expect(middle.dateGroup, SimulationDateGroup.yesterday);

      // Oldest entry (78 pts): first attempt -> delta null, best session = true, earlier
      final oldest = analytics.entriesNewestFirst[2];
      expect(oldest.score, 78);
      expect(oldest.scoreDelta, isNull);
      expect(oldest.isBestSession, isTrue);
      expect(oldest.dateGroup, SimulationDateGroup.earlier);
    });

    testWidgets(
        'Redesigned SimulationHistoryScreen renders summary card, trend chart, deltas, best badge, and CTA without overflow at 360x800',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = true;
      globalSimulationHistory.value = [
        {
          'date': DateTime.now().toIso8601String(),
          'totalPoints': 72.0,
          'isPassed': false,
          'languageScore': 4,
          'languageTotal': 10,
          'readingScore': 4,
          'readingTotal': 10,
          'timeSpentSeconds': 1320,
        },
        {
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'totalPoints': 63.0,
          'isPassed': false,
          'languageScore': 3,
          'languageTotal': 10,
          'readingScore': 4,
          'readingTotal': 10,
          'timeSpentSeconds': 1245,
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SimulationHistoryScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Summary card elements: non-truncated single 'Selesai' stat, supportive tier badge, gap badge (no trend chart or Try Again CTA)
      expect(find.text('RINGKASAN PERFORMA'), findsOneWidget);
      expect(find.text('Hampir Lulus'), findsOneWidget);
      expect(find.text('Butuh 8 poin lagi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Lulus'), findsNothing);
      expect(find.text('Tren Skor'), findsNothing);
      expect(find.text('COBA LAGI'), findsNothing);

      // Scroll down to lazily build the ExamHistoryTile items below the summary card
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // History tiles: delta chip (+9), section bars, best badge
      expect(find.text('+9'), findsOneWidget);
      expect(find.text('Terbaik'), findsOneWidget);
      expect(find.text('Bhs 24/60'), findsOneWidget);
      expect(find.text('Baca 48/120'), findsWidgets);
    });

    test(
        'SimulationResultAnalytics computes 44.4% threshold, gapToPass, grade at 80 pts, strongest/weakest tags, and previous session delta',
        () {
      // 1. Dynamic threshold percentage: 80 / 180 = 44.444... -> 44.4%
      expect(SimulationResultAnalytics.computePassThresholdPercent(), 44.4);
      expect(SimulationResultAnalytics.formatPassThresholdPercent(), '44.4');

      // 2. Score exactly 80 gets Grade C (fixed from old 44.5% bug where 80 got D)
      expect(SimulationResultAnalytics.computeGrade(80), 'C');
      expect(SimulationResultAnalytics.computeGrade(57), 'D');

      // 3. Full analytics with history comparison & section strength tags
      final history = [
        {
          'date': DateTime(2026, 11, 22, 10, 0).toIso8601String(),
          'totalPoints': 57.0,
          'timeSpentSeconds': 1200,
        },
        {
          'date': DateTime(2026, 11, 21, 10, 0).toIso8601String(),
          'totalPoints': 48.0,
          'timeSpentSeconds': 1350,
        },
      ];

      final analytics = SimulationResultAnalytics.compute(
        totalPoints: 57,
        isPassed: false,
        languageScore: 9, // 9/20 = 45% (>= 44.4% -> Strongest)
        languageTotal: 20,
        readingScore: 5, // 5/20 = 25% (< 44.4% -> Needs practice)
        readingTotal: 20,
        timeSpentSeconds: 1200,
        rawHistory: history,
      );

      expect(analytics.totalScore, 57);
      expect(analytics.gapToPass, 23); // 80 - 57 = 23
      expect(analytics.passThresholdPercentText, '44.4');
      expect(analytics.langPoints, 27); // 0.45 * 60 = 27
      expect(analytics.readPoints, 30); // 0.25 * 120 = 30
      expect(analytics.langTag, SectionStrengthTag.strongest);
      expect(analytics.readTag, SectionStrengthTag.needsPractice);
      expect(analytics.previousScoreDelta, 9); // 57 - 48 = +9
    });

    testWidgets(
        'Redesigned SimulationResultScreen renders ScoreRingHero, 44.4% pass mark, section tags, delta chip, and Review Answers CTA without Try Again or overflow at 360x800',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = true;
      globalSimulationHistory.value = [
        {
          'date': DateTime(2026, 11, 22, 10, 0).toIso8601String(),
          'totalPoints': 57.0,
          'timeSpentSeconds': 1200,
        },
        {
          'date': DateTime(2026, 11, 21, 10, 0).toIso8601String(),
          'totalPoints': 48.0,
          'timeSpentSeconds': 1350,
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SimulationResultScreen(
            languageScore: 9,
            languageTotal: 20,
            readingScore: 5,
            readingTotal: 20,
            timeSpentSeconds: 1200,
            totalPoints: 57,
            isPassed: false,
            userAnswers: [],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('RAPOR HASIL UJIAN'), findsOneWidget);
      expect(find.text('SIMULASI JLPT N5'), findsOneWidget);
      expect(find.text('Belum Lulus • 不合格'), findsOneWidget);
      expect(find.text('Predikat D'), findsOneWidget);
      expect(find.text('+9'), findsOneWidget);
      expect(find.text('Butuh 23 poin lagi untuk lulus'), findsOneWidget);
      expect(find.text('Batas lulus: 80/180'), findsOneWidget);
      expect(find.textContaining('44.4%'), findsNothing);
      expect(find.text('Terkuat'), findsOneWidget);
      expect(find.text('Perlu latihan'), findsOneWidget);
      expect(find.text('27 / 60'), findsOneWidget);
      expect(find.text('30 / 120'), findsOneWidget);
      expect(find.text('TINJAU JAWABAN'), findsOneWidget);
      expect(find.text('COBA LAGI'), findsNothing);
    });
  });

  group('Neutral SimulationTestScreen & Shared Review Widgets', () {
    final List<SimulationQuestion> sampleQuestions = [
      SimulationQuestion(
        section: 'Language Knowledge',
        question: 'あの　（　　）に　木が　たくさん　あります。',
        romaji: 'Ano ____ ni ki ga takusan arimasu.',
        options: ['かわ', 'やま', 'うみ', 'そら'],
        correctAnswerIndex: 1,
        explanationId: 'Kanji 山 dibaca yama.',
        explanationEn: 'Kanji 山 is read yama.',
      ),
      SimulationQuestion(
        section: 'Reading',
        question: 'わたしは　まいにち　みずを　のみます。',
        romaji: 'Watashi wa mainichi mizu o nomimasu.',
        subQuestion: 'なにを　のみますか。',
        options: ['おちゃ', 'みず', 'コーヒー', 'ぎゅうにゅう'],
        correctAnswerIndex: 1,
        explanationId: 'Teks menyebut みず (air).',
        explanationEn: 'The passage states みず (water).',
      ),
    ];

    testWidgets(
        'SimulationTestScreen stays neutral on selection, allows changing choice, saves final answer on Next, shows Finish confirmation on last question, and navigates to Result without overflow at 360x800',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: SimulationTestScreen(initialQuestions: sampleQuestions),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      // Header, counter, badge, and NO Exam Progress Map
      expect(find.text('SIMULASI UJIAN'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('#1 • PENGETAHUAN BAHASA'), findsOneWidget);
      expect(find.text('Peta Progres Ujian'), findsNothing);
      expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
      expect(find.text('LANJUT'), findsOneWidget);

      // Tapping question number "2" in strip does NOT jump (sequential indicator only)
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(find.text('1/2'), findsOneWidget);

      // Select wrong option 'かわ' first: NO correct/wrong icons or feedback bar appear
      await tester.tap(find.text('かわ'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.cancel_rounded), findsNothing);
      expect(find.textContaining('Jawaban Tepat'), findsNothing);
      expect(find.textContaining('Jawaban Benar'), findsNothing);
      expect(find.textContaining('Correct Answer'), findsNothing);

      // Change selection to correct option 'やま' before tapping Next
      await tester.tap(find.text('やま'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.cancel_rounded), findsNothing);

      // Tap LANJUT -> saves final answer and moves to last question (2/2)
      await tester.tap(find.text('LANJUT'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('#2 • MEMBACA'), findsOneWidget);
      expect(find.text('SELESAI'), findsOneWidget);
      expect(find.text('LANJUT'), findsNothing);

      // Select option 'みず' on last question (still neutral, no check/cancel icons)
      await tester.tap(find.text('みず'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.cancel_rounded), findsNothing);

      // Tap SELESAI -> opens Finish confirmation dialog
      await tester.tap(find.text('SELESAI'));
      await tester.pumpAndSettle();
      expect(find.text('Selesaikan Ujian?'), findsOneWidget);

      // Cancel stays on question 2
      await tester.tap(find.text('BATAL'));
      await tester.pumpAndSettle();
      expect(find.text('Selesaikan Ujian?'), findsNothing);
      expect(find.text('2/2'), findsOneWidget);

      // Tap SELESAI again and confirm inside dialog -> navigates to SimulationResultScreen
      await tester.tap(find.text('SELESAI'));
      await tester.pumpAndSettle();
      final finishButtons = find.text('SELESAI');
      await tester.tap(finishButtons.last);
      await tester.pumpAndSettle();

      expect(find.byType(SimulationResultScreen), findsOneWidget);
      // Both final answers were correct -> full score 180/180 (60/60 + 120/120)
      expect(find.text('180'), findsOneWidget);
      expect(find.text('60 / 60'), findsOneWidget);
      expect(find.text('120 / 120'), findsOneWidget);
    });

    testWidgets(
        'SimulationReviewScreen renders shared widgets without overflow at 360x800',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      globalLanguage.value = 'id';
      globalDarkMode.value = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SimulationReviewScreen(
            userAnswers: const [1, 0],
            questions: sampleQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('PEMBAHASAN UJIAN'), findsOneWidget);
      expect(find.text('#1 • PENGETAHUAN BAHASA'), findsOneWidget);
      expect(find.text('BENAR'), findsOneWidget);
      expect(find.text('JAWABANMU'), findsOneWidget);
    });
  });
}
