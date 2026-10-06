import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/app.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/home/home_screen.dart';
import 'package:tadbeer/features/tadabbur/tadbeer_intro_screen.dart';
import 'package:tadbeer/features/notes/note_editor_screen.dart';
import 'package:tadbeer/features/notes/notes_screen.dart';
import 'package:tadbeer/features/quran/screens/quran_screen.dart';
import 'package:tadbeer/features/search/search_screen.dart';

void main() {
  late Directory tempDir;
  late File dataFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadbeer_ui_test_');
    dataFile = File('${tempDir.path}/test_user_data.json');
    await UserDataStore.instance.init(dataFile);
    await QuranRepository.instance.init();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Tadbeer UI Flow Tests', () {
    testWidgets(
      'First Launch Shows Tadabbur Intro Screen with Verified Verse and Checkbox',
      (WidgetTester tester) async {
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();

        // Should show TadbeerIntroScreen
        expect(find.byType(TadbeerIntroScreen), findsOneWidget);
        // Should show checkbox "لا تظهر لي هذه النافذة مرة أخرى" (default: false)
        final checkboxTextFinder = find.text('لا تظهر لي هذه النافذة مرة أخرى');
        expect(checkboxTextFinder, findsOneWidget);
        final checkboxFinder = find.byType(Checkbox);
        final checkbox = tester.widget<Checkbox>(checkboxFinder);
        expect(checkbox.value, isFalse);

        // Should show continue button "متابعة"
        final continueFinder = find.text('متابعة');
        expect(continueFinder, findsOneWidget);
        await tester.ensureVisible(continueFinder);

        // Tapping "متابعة" without checking checkbox navigates to HomeScreen without permanent hiding
        await tester.tap(continueFinder);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          UserDataStore.instance.settings.hideTadbeerIntroPermanently,
          isFalse,
        );
      },
    );

    testWidgets(
      'Checking "لا تظهر لي هذه النافذة مرة أخرى" and tapping "متابعة" persists permanent hiding',
      (WidgetTester tester) async {
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();

        expect(find.byType(TadbeerIntroScreen), findsOneWidget);

        // Tap the checkbox
        final checkboxFinder = find.byType(Checkbox);
        await tester.ensureVisible(checkboxFinder);
        await tester.tap(checkboxFinder);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

        // Tap "متابعة" within runAsync because saving preference executes disk I/O
        final continueButton = find.text('متابعة');
        await tester.ensureVisible(continueButton);
        await tester.runAsync(() async {
          await tester.tap(continueButton);
          await Future.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();

        // Should now be on HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          UserDataStore.instance.settings.hideTadbeerIntroPermanently,
          isTrue,
        );

        // On next app start, should directly open HomeScreen
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(TadbeerIntroScreen), findsNothing);
      },
    );

    testWidgets('HomeScreen Displays Main Sections and Reading Position', (
      WidgetTester tester,
    ) async {
      // Ensure intro is hidden
      await tester.runAsync(() async {
        await UserDataStore.instance.updateSettings(
          UserDataStore.instance.settings.copyWith(
            hideTadbeerIntroPermanently: true,
          ),
        );
      });

      await tester.pumpWidget(const TadbeerApp());
      await tester.pumpAndSettle();

      // Check App Title
      expect(find.text('تَدْبِير'), findsOneWidget);

      // Check Main Sections
      expect(find.text('المصحف'), findsOneWidget);
      expect(find.text('الملاحظات'), findsOneWidget);
      expect(find.text('المحفوظات'), findsOneWidget);
      expect(find.text('المميزة'), findsOneWidget);
      expect(find.text('البحث'), findsOneWidget);
    });

    testWidgets(
      'QuranScreen top bar is hidden by default and toggles on tap with Search and Page jump',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await UserDataStore.instance.updateSettings(
            UserDataStore.instance.settings.copyWith(
              hideTadbeerIntroPermanently: true,
            ),
          );
        });

        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();

        // Tap Quran card on Home
        await tester.tap(find.text('المصحف').first);
        await tester.pumpAndSettle();

        // Should be on QuranScreen
        expect(find.byType(QuranScreen), findsOneWidget);

        // 1. Verify top bar is hidden by default
        final animatedOpacityFinder = find.descendant(
          of: find.byType(QuranScreen),
          matching: find.byType(AnimatedOpacity),
        );
        expect(animatedOpacityFinder, findsOneWidget);
        AnimatedOpacity opacityWidget = tester.widget(animatedOpacityFinder);
        expect(opacityWidget.opacity, 0.0);

        // 2. Tap on QuranScreen to reveal animated overlay top bar
        await tester.tap(find.byType(QuranScreen));
        await tester.pumpAndSettle();

        opacityWidget = tester.widget(animatedOpacityFinder);
        expect(opacityWidget.opacity, 1.0);

        // Verify Search button and Page Number button exist in top bar
        expect(find.byTooltip('البحث'), findsOneWidget);
        expect(find.textContaining('ص '), findsWidgets);

        // 3. Tap Page Number button to open jump-to-page dialog
        final pageButtonFinder = find
            .descendant(
              of: find.byType(QuranScreen),
              matching: find.textContaining('ص '),
            )
            .first;
        await tester.tap(pageButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);

        // Cancel dialog
        await tester.tap(find.text('إلغاء'));
        await tester.pumpAndSettle();

        // 4. Tap page to hide top bar again
        await tester.tap(find.byType(QuranScreen));
        await tester.pumpAndSettle();
        opacityWidget = tester.widget(animatedOpacityFinder);
        expect(opacityWidget.opacity, 0.0);

        // Reveal again to test search navigation
        await tester.tap(find.byType(QuranScreen));
        await tester.pumpAndSettle();

        // Tapping Search opens SearchScreen
        await tester.tap(find.byTooltip('البحث'));
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);

        // Back returns to QuranScreen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(QuranScreen), findsOneWidget);

        // Returning from QuranScreen goes back to HomeScreen
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets('NotesScreen opens NoteEditorScreen and saves a new note', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await UserDataStore.instance.updateSettings(
          UserDataStore.instance.settings.copyWith(
            hideTadbeerIntroPermanently: true,
          ),
        );
      });

      await tester.pumpWidget(const TadbeerApp());
      await tester.pumpAndSettle();

      // Open Notes from Home
      await tester.tap(find.text('الملاحظات'));
      await tester.pumpAndSettle();
      expect(find.byType(NotesScreen), findsOneWidget);

      // Tap Add Note FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should be on NoteEditorScreen
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('ملاحظة حرة'), findsOneWidget);

      // Enter title and content
      final titleField = find.byType(TextField).first;
      final contentField = find.byType(TextField).last;

      await tester.enterText(titleField, 'وقفة تدبرية');
      await tester.enterText(contentField, 'تأمل في عظمة الخالق سبحانه وتعالى');
      await tester.pumpAndSettle();

      // Tap Save button in AppBar within runAsync for real disk I/O
      final saveButton = find.byIcon(Icons.check);
      expect(saveButton, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(saveButton);
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Should return to NotesScreen
      expect(find.byType(NotesScreen), findsOneWidget);
      expect(find.text('وقفة تدبرية'), findsOneWidget);
    });
  });
}
