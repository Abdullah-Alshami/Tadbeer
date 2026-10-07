import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/core/storage/user_database.dart';
import 'package:tadbeer/features/notes/note_model.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_word_widget.dart';
import 'package:tadbeer/features/quran/widgets/ayah_action_sheet.dart';
import 'package:tadbeer/features/tadabbur/tadbeer_intro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File dataFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('marker_test_');
    dataFile = File('${tempDir.path}/test_user_data.json');
    await UserDataStore.instance.init(dataFile);
    await QuranRepository.instance.init();
  });

  tearDown(() async {
    await UserDatabase.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget wrapWithApp(Widget child) {
    return AppLocalizationScope(
      currentLanguage: AppLanguage.arabic,
      strings: const AppStrings(AppLanguage.arabic),
      onLanguageChanged: (_) {},
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('Ayah End Marker States & Spacing Invariance Tests', () {
    const endMarkerWord = MushafWord(
      ayahId: 1,
      pageNumber: 1,
      lineNumber: 2,
      position: 5,
      text: '١',
      glyph: 'ﰀ',
      surah: 1,
      ayah: 1,
      ayahNumber: 1,
      isAyahEnd: true,
    );

    testWidgets('Normal State: displays authentic rosette glyph', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ﰀ'), findsOneWidget);
      expect(find.text('🔖'), findsNothing);
      expect(find.text('📝'), findsNothing);
      expect(find.text('🔖📝'), findsNothing);
    });

    testWidgets('Bookmarked State: displays 🔖 overlay', (tester) async {
      final ayah = QuranRepository.instance.getAyah(1, 1)!;
      await tester.runAsync(() async {
        await UserDataStore.instance.toggleBookmark(ayah);
      });

      await tester.pumpWidget(
        wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
      );
      await tester.pumpAndSettle();

      expect(find.text('🔖'), findsOneWidget);
      expect(find.text('📝'), findsNothing);
      expect(find.text('🔖📝'), findsNothing);
    });

    testWidgets('Note State: displays 📝 overlay', (tester) async {
      final ayah = QuranRepository.instance.getAyah(1, 1)!;
      await tester.runAsync(() async {
        await UserDataStore.instance.saveNote(
          type: NoteType.ayah,
          content: 'تدبر الآية',
          ayahId: 1,
          surahNumber: 1,
          ayahNumber: 1,
          page: 1,
          ayahText: ayah.text,
        );
      });

      await tester.pumpWidget(
        wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
      );
      await tester.pumpAndSettle();

      expect(find.text('📝'), findsOneWidget);
      expect(find.text('🔖'), findsNothing);
      expect(find.text('🔖📝'), findsNothing);
    });

    testWidgets('Bookmarked + Note State: displays 🔖📝 overlay', (
      tester,
    ) async {
      final ayah = QuranRepository.instance.getAyah(1, 1)!;
      await tester.runAsync(() async {
        await UserDataStore.instance.toggleBookmark(ayah);
        await UserDataStore.instance.saveNote(
          type: NoteType.ayah,
          content: 'تدبر الآية',
          ayahId: 1,
          surahNumber: 1,
          ayahNumber: 1,
          page: 1,
          ayahText: ayah.text,
        );
      });

      await tester.pumpWidget(
        wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
      );
      await tester.pumpAndSettle();

      expect(find.text('🔖📝'), findsOneWidget);
    });

    testWidgets(
      'Overlay does NOT alter line layout width (spacing invariance)',
      (tester) async {
        // Measure unadorned size
        await tester.pumpWidget(
          wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
        );
        await tester.pumpAndSettle();
        final normalSize = tester.getSize(find.byType(MushafWordWidget));

        // Add Bookmark
        final ayah = QuranRepository.instance.getAyah(1, 1)!;
        await tester.runAsync(() async {
          await UserDataStore.instance.toggleBookmark(ayah);
        });
        await tester.pumpWidget(
          wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
        );
        await tester.pumpAndSettle();
        final bookmarkSize = tester.getSize(find.byType(MushafWordWidget));
        expect(bookmarkSize.width, equals(normalSize.width));

        // Add Note (Bookmarked + Note)
        await tester.runAsync(() async {
          await UserDataStore.instance.saveNote(
            type: NoteType.ayah,
            content: 'ملاحظة',
            ayahId: 1,
            surahNumber: 1,
            ayahNumber: 1,
            page: 1,
            ayahText: ayah.text,
          );
        });
        await tester.pumpWidget(
          wrapWithApp(const MushafWordWidget(word: endMarkerWord)),
        );
        await tester.pumpAndSettle();
        final combinedSize = tester.getSize(find.byType(MushafWordWidget));
        expect(combinedSize.width, equals(normalSize.width));
      },
    );
  });

  group('AyahActionSheet Centering & All 6 Actions Tests', () {
    testWidgets('Action sheet renders all 6 actions in equal Expanded slots', (
      tester,
    ) async {
      final ayah = QuranRepository.instance.getAyah(1, 1)!;

      await tester.pumpWidget(wrapWithApp(AyahActionSheet(ayah: ayah)));
      await tester.pumpAndSettle();

      // Check all 6 actions exist
      expect(find.text('وقفة تدبر'), findsOneWidget);
      expect(find.text('رابط آيات'), findsOneWidget);
      expect(find.text('ملاحظة'), findsOneWidget);
      expect(find.text('حفظ'), findsOneWidget);
      expect(find.text('تمييز'), findsOneWidget);
      expect(find.text('نسخ'), findsOneWidget);

      // Check that each of the 6 actions is wrapped in an Expanded widget
      final actionsRowFinder = find.byWidgetPredicate(
        (w) =>
            w is Row &&
            w.mainAxisAlignment == MainAxisAlignment.spaceEvenly &&
            w.children.length == 6,
      );
      expect(actionsRowFinder, findsOneWidget);

      final row = tester.widget<Row>(actionsRowFinder);
      for (final child in row.children) {
        expect(child, isA<Expanded>());
      }
    });
  });

  group('TadbeerIntroScreen Checkbox Offset Tests', () {
    testWidgets('Checkbox option is raised upwards with reduced top spacing', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithApp(const TadbeerIntroScreen()));
      await tester.pumpAndSettle();

      expect(find.text('لا تظهر لي هذه النافذة مرة أخرى'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Find the SizedBox preceding the InkWell (height was reduced from 16 to 6)
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final hasReducedSpacing = sizedBoxes.any((box) => box.height == 6.0);
      expect(
        hasReducedSpacing,
        isTrue,
        reason: 'Intro screen option must be raised by ~10px using SizedBox(height: 6)',
      );
    });
  });
}
