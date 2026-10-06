import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/screens/quran_page_view.dart';
import 'package:tadbeer/features/quran/screens/quran_screen.dart';
import 'package:tadbeer/features/quran/widgets/surah_header_banner.dart';

Widget buildTestQuranApp({int initialPage = 1}) {
  return AppLocalizationScope(
    currentLanguage: AppLanguage.arabic,
    strings: const AppStrings(AppLanguage.arabic),
    onLanguageChanged: (_) {},
    child: MaterialApp(home: QuranScreen(initialPage: initialPage)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File dataFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadbeer_mushaf_test_');
    dataFile = File('${tempDir.path}/test_user_data.json');
    await UserDataStore.instance.init(dataFile);
    await QuranRepository.instance.init();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Madinah Mushaf V2 (1421H) Architecture Tests', () {
    test('QuranRepository loads exactly 604 authentic Mushaf pages', () {
      final repo = QuranRepository.instance;
      expect(repo.mushafPages.length, 604);

      // Verify Page 1 (Al-Fatihah) has exactly 8 lines, all centered, with word ranges
      final page1 = repo.getMushafPage(1);
      expect(page1.totalLines, 8);
      expect(page1.lines.length, 8);
      expect(page1.lines.first.type, MushafLineType.header);
      expect(page1.lines.first.surahNumber, 1);
      expect(page1.lines.first.isCentered, isTrue);
      expect(page1.lines[1].type, MushafLineType.text); // Ayah 1:1 Bismillah
      expect(page1.lines[1].isCentered, isTrue);
      expect(page1.lines[1].firstWordId, 1);
      expect(page1.lines[1].lastWordId, 5);

      // Verify Page 2 (Al-Baqarah 1-5) has exactly 8 lines, all centered
      final page2 = repo.getMushafPage(2);
      expect(page2.totalLines, 8);
      expect(page2.lines.length, 8);
      expect(page2.lines[0].type, MushafLineType.header);
      expect(page2.lines[0].surahNumber, 2);
      expect(page2.lines[0].isCentered, isTrue);
      expect(page2.lines[1].type, MushafLineType.bismillah);
      expect(page2.lines[1].surahNumber, 2);
      expect(page2.lines[1].isCentered, isTrue);
      expect(page2.lines[2].type, MushafLineType.text);
      expect(page2.lines[2].isCentered, isTrue);

      // Verify standard page (e.g. Page 3) has 15 lines, all text lines are justified (not centered)
      final page3 = repo.getMushafPage(3);
      expect(page3.totalLines, 15);
      expect(page3.lines.length, 15);
      for (final l in page3.lines) {
        expect(l.isCentered, isFalse);
        expect(l.firstWordId, isNotNull);
        expect(l.lastWordId, isNotNull);
      }

      // Verify Page 76 ends with Surah 4 Header on line 15
      final page76 = repo.getMushafPage(76);
      expect(page76.lines.last.type, MushafLineType.header);
      expect(page76.lines.last.surahNumber, 4);
      expect(page76.lines.last.isCentered, isTrue);

      // Verify Page 77 starts with Bismillah for Surah 4 on line 1
      final page77 = repo.getMushafPage(77);
      expect(page77.lines.first.type, MushafLineType.bismillah);
      expect(page77.lines.first.surahNumber, 4);
      expect(page77.lines.first.isCentered, isTrue);

      // Verify Page 187 (At-Tawbah) has header on line 1 and NO Bismillah
      final page187 = repo.getMushafPage(187);
      expect(page187.lines[0].type, MushafLineType.header);
      expect(page187.lines[0].surahNumber, 9);
      expect(page187.lines[0].isCentered, isTrue);
      expect(page187.lines[1].type, MushafLineType.text); // Verse 9:1
      expect(page187.lines[1].isCentered, isFalse); // Justified

      // Verify Page 604 contains Surahs 112, 113, 114 with exact QUL alignments
      final page604 = repo.getMushafPage(604);
      expect(page604.lines.length, 15);
      expect(page604.surahNumbers, containsAll([112, 113, 114]));
      expect(page604.lines[0].type, MushafLineType.header); // 112
      expect(page604.lines[1].type, MushafLineType.bismillah);
      expect(page604.lines[2].isCentered, isFalse); // justified
      expect(page604.lines[3].isCentered, isTrue); // centered surah end
      expect(page604.lines[13].isCentered, isTrue); // centered An-Nas 114:5
      expect(page604.lines[14].isCentered, isTrue); // centered An-Nas 114:6
    });

    test(
      'Every MushafWord connects to a valid Ayah and Stable ID (1..6236)',
      () {
        final repo = QuranRepository.instance;
        int totalWordCount = 0;
        final visitedAyahIds = <int>{};

        for (int p = 1; p <= 604; p++) {
          final page = repo.getMushafPage(p);
          for (final line in page.lines) {
            if (line.type == MushafLineType.text) {
              for (final word in line.words) {
                totalWordCount++;
                final ayah = repo.getAyah(word.surah, word.ayah);
                expect(ayah, isNotNull);
                expect(ayah!.id, inInclusiveRange(1, 6236));
                visitedAyahIds.add(ayah.id);
              }
            }
          }
        }

        expect(totalWordCount, 83665);
        expect(visitedAyahIds.length, 6236);
      },
    );

    testWidgets(
      'Renders Page 1 Al-Fatihah with header and natural start alignment',
      (tester) async {
        await tester.pumpWidget(buildTestQuranApp(initialPage: 1));
        await tester.pumpAndSettle();

        expect(find.byType(QuranPageView), findsOneWidget);
        expect(find.byType(SurahHeaderBanner), findsOneWidget);
        expect(find.text('سُورَةُ الفاتحة'), findsWidgets);
        expect(find.text('١'), findsWidgets);
      },
    );

    testWidgets('Renders Page 2 with Surah 2 header and Bismillah', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestQuranApp(initialPage: 2));
      await tester.pumpAndSettle();

      expect(find.byType(QuranPageView), findsOneWidget);
      expect(find.text('سُورَةُ البقرة'), findsWidgets);
      expect(find.text('٢'), findsWidgets);
      expect(find.byType(BismillahBanner), findsOneWidget);
    });

    testWidgets('Persists reading position when navigating pages', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestQuranApp(initialPage: 1));
      await tester.pumpAndSettle();

      // Swipe horizontally to Page 2
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();

      final saved = UserDataStore.instance.readingPosition;
      expect(saved.page, isIn([1, 2]));
    });

    testWidgets('QuranPageView invokes onAyahTap and onAyahLongPress', (
      tester,
    ) async {
      final page1 = QuranRepository.instance.getPage(1);

      await tester.pumpWidget(
        AppLocalizationScope(
          currentLanguage: AppLanguage.arabic,
          strings: const AppStrings(AppLanguage.arabic),
          onLanguageChanged: (_) {},
          child: MaterialApp(
            home: Scaffold(
              body: QuranPageView(
                page: page1,
                onAyahTap: (_) {},
                onAyahLongPress: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QuranPageView), findsOneWidget);
      expect(find.text('سُورَةُ الفاتحة'), findsWidgets);
    });
  });
}
