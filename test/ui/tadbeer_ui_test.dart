import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/app.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/data/quran/quran_repository.dart';
import 'package:tadbeer/features/home/home_screen.dart';
import 'package:tadbeer/features/home/tadabbur_intro_screen.dart';
import 'package:tadbeer/features/notes/note_editor_screen.dart';
import 'package:tadbeer/features/notes/notes_screen.dart';
import 'package:tadbeer/features/quran/quran_screen.dart';
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

        // Should show TadabburIntroScreen
        expect(find.byType(TadabburIntroScreen), findsOneWidget);
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
          UserDataStore.instance.settings.hideTadabburIntroPermanently,
          isFalse,
        );
      },
    );

    testWidgets(
      'Checking "لا تظهر لي هذه النافذة مرة أخرى" and tapping "متابعة" persists permanent hiding',
      (WidgetTester tester) async {
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();

        expect(find.byType(TadabburIntroScreen), findsOneWidget);

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
          UserDataStore.instance.settings.hideTadabburIntroPermanently,
          isTrue,
        );

        // On next app start, should directly open HomeScreen
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(TadabburIntroScreen), findsNothing);
      },
    );

    testWidgets('HomeScreen Displays Main Sections and Reading Position', (
      WidgetTester tester,
    ) async {
      // Ensure intro is hidden
      await tester.runAsync(() async {
        await UserDataStore.instance.updateSettings(
          UserDataStore.instance.settings.copyWith(
            hideTadabburIntroPermanently: true,
          ),
        );
      });

      await tester.pumpWidget(const TadbeerApp());
      await tester.pumpAndSettle();

      // Check App Title
      expect(find.text('تَدْبِير'), findsOneWidget);

      // Check 5 Main Sections (Quran appears on the action button and the navigation card)
      expect(find.text('المصحف'), findsNWidgets(2));
      expect(find.text('الملاحظات'), findsOneWidget);
      expect(find.text('المحفوظات'), findsOneWidget);
      expect(find.text('المميزة'), findsOneWidget);
      expect(find.text('البحث'), findsOneWidget);
    });

    testWidgets(
      'QuranScreen has Search, Back, and PopupMenu navigation actions',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await UserDataStore.instance.updateSettings(
            UserDataStore.instance.settings.copyWith(
              hideTadabburIntroPermanently: true,
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

        // Verify Back button, Search button, and PopupMenuButton exist in AppBar
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byTooltip('البحث'), findsOneWidget);
        expect(find.byType(PopupMenuButton<String>), findsOneWidget);

        // Tapping Search opens SearchScreen
        await tester.tap(find.byTooltip('البحث'));
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);

        // Back returns to QuranScreen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(QuranScreen), findsOneWidget);

        // Tapping BackButton on QuranScreen returns to HomeScreen
        await tester.tap(find.byType(BackButton));
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
            hideTadabburIntroPermanently: true,
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
