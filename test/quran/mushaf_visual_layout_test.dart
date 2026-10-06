import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/quran_models.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/screens/quran_page_view.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_canvas.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_line_widget.dart';
import 'package:tadbeer/features/quran/widgets/surah_header_banner.dart';

Widget buildTestFrame(Widget child) {
  return AppLocalizationScope(
    currentLanguage: AppLanguage.arabic,
    strings: const AppStrings(AppLanguage.arabic),
    onLanguageChanged: (_) {},
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File dataFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('visual_test_');
    dataFile = File('${tempDir.path}/test_user_data.json');
    await UserDataStore.instance.init(dataFile);
    await QuranRepository.instance.init();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Authentic Madinah Mushaf Engine Visual & Structural Verification', () {
    testWidgets('Visual Verification: Page 1 (Al-Fatihah, 8 lines, framed)', (
      tester,
    ) async {
      final repo = QuranRepository.instance;
      final layout = repo.getMushafPage(1);

      expect(layout.totalLines, 8);
      expect(layout.lines.length, 8);
      expect(layout.lines[0].type, MushafLineType.header);
      expect(layout.lines[0].surahNumber, 1);
      for (final l in layout.lines) {
        expect(
          l.isCentered,
          isTrue,
          reason: 'Line ${l.lineNumber} on Page 1 must be centered',
        );
      }

      await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 1)));
      await tester.pumpAndSettle();

      expect(find.byType(MushafCanvas), findsOneWidget);
      expect(find.byType(MushafLineWidget), findsNWidgets(8));
      expect(find.byType(SurahHeaderBanner), findsOneWidget);
      expect(find.text('سُورَةُ الفاتحة'), findsWidgets);
      expect(find.text('بِسْمِ'), findsOneWidget);
      expect(find.text('ٱلضَّآلِّينَ'), findsOneWidget);
    });

    testWidgets(
      'Visual Verification: Page 2 (Al-Baqarah 1-5, 8 lines, framed)',
      (tester) async {
        final repo = QuranRepository.instance;
        final layout = repo.getMushafPage(2);

        expect(layout.totalLines, 8);
        expect(layout.lines.length, 8);
        expect(layout.lines[0].type, MushafLineType.header);
        expect(layout.lines[0].surahNumber, 2);
        expect(layout.lines[1].type, MushafLineType.bismillah);
        for (final l in layout.lines) {
          expect(
            l.isCentered,
            isTrue,
            reason: 'Line ${l.lineNumber} on Page 2 must be centered',
          );
        }

        await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 2)));
        await tester.pumpAndSettle();

        expect(find.byType(MushafCanvas), findsOneWidget);
        expect(find.byType(MushafLineWidget), findsNWidgets(8));
        expect(find.byType(SurahHeaderBanner), findsOneWidget);
        expect(find.byType(BismillahBanner), findsOneWidget);
        expect(find.text('سُورَةُ البقرة'), findsWidgets);
        expect(find.text('الٓمٓ'), findsOneWidget);
        expect(find.text('ٱلْمُفْلِحُونَ'), findsOneWidget);
      },
    );

    testWidgets(
      'Visual Verification: Page 3 (Al-Baqarah 6-16, 15 lines, fully justified)',
      (tester) async {
        final repo = QuranRepository.instance;
        final layout = repo.getMushafPage(3);

        expect(layout.totalLines, 15);
        expect(layout.lines.length, 15);
        for (final l in layout.lines) {
          expect(l.type, MushafLineType.text);
          expect(
            l.isCentered,
            isFalse,
            reason: 'Line ${l.lineNumber} on Page 3 must be justified',
          );
        }

        // Verify line 1 begins with "إِنَّ" and ends with "تُنذِرْهُمْ"
        expect(layout.lines[0].words.first.text, 'إِنَّ');
        expect(layout.lines[0].words.last.text, 'تُنذِرْهُمْ');

        // Verify line 15 ends with ayah 16 marker
        expect(layout.lines[14].words.last.isAyahEnd, isTrue);
        expect(layout.lines[14].words.last.ayahNumber, 16);

        await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 3)));
        await tester.pumpAndSettle();

        expect(find.byType(MushafCanvas), findsOneWidget);
        expect(find.byType(MushafLineWidget), findsNWidgets(15));
        expect(find.text('إِنَّ'), findsWidgets);
        expect(find.text('تُنذِرْهُمْ'), findsOneWidget);
      },
    );

    testWidgets('Visual Verification: Page 10 (Al-Baqarah 62-69, 15 lines)', (
      tester,
    ) async {
      final repo = QuranRepository.instance;
      final layout = repo.getMushafPage(10);

      expect(layout.totalLines, 15);
      expect(layout.lines.length, 15);

      // Verify line 1 begins with "إِنَّ" and line 15 ends with ayah 69
      expect(layout.lines[0].words.first.text, 'إِنَّ');
      expect(layout.lines[14].words.last.isAyahEnd, isTrue);
      expect(layout.lines[14].words.last.ayahNumber, 69);

      await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 10)));
      await tester.pumpAndSettle();

      expect(find.byType(MushafCanvas), findsOneWidget);
      expect(find.byType(MushafLineWidget), findsNWidgets(15));
    });

    testWidgets('Visual Verification: Page 100 (An-Nisa 135-140, 15 lines)', (
      tester,
    ) async {
      final repo = QuranRepository.instance;
      final layout = repo.getMushafPage(100);

      expect(layout.totalLines, 15);
      expect(layout.lines.length, 15);
      expect(layout.lines[0].words.first.text, '۞ يَـٰٓأَيُّهَا');

      await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 100)));
      await tester.pumpAndSettle();

      expect(find.byType(MushafCanvas), findsOneWidget);
      expect(find.byType(MushafLineWidget), findsNWidgets(15));
    });

    testWidgets('Visual Verification: Page 300 (Al-Kahf 54-61, 15 lines)', (
      tester,
    ) async {
      final repo = QuranRepository.instance;
      final layout = repo.getMushafPage(300);

      expect(layout.totalLines, 15);
      expect(layout.lines.length, 15);
      expect(layout.lines[0].words.first.text, 'وَلَقَدْ');

      await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 300)));
      await tester.pumpAndSettle();

      expect(find.byType(MushafCanvas), findsOneWidget);
      expect(find.byType(MushafLineWidget), findsNWidgets(15));
    });

    testWidgets(
      'Visual Verification: Page 604 (Surahs 112, 113, 114, 15 lines)',
      (tester) async {
        final repo = QuranRepository.instance;
        final layout = repo.getMushafPage(604);

        expect(layout.totalLines, 15);
        expect(layout.lines.length, 15);

        // Verify exact Madinah Mushaf structure on page 604:
        // Line 1: Header 112 (Al-Ikhlas)
        // Line 2: Bismillah
        // Line 3: Text (justified)
        // Line 4: Text (centered)
        // Line 5: Header 113 (Al-Falaq)
        // Line 6: Bismillah
        // Line 7: Text (justified)
        // Line 8: Text (justified)
        // Line 9: Text (centered)
        // Line 10: Header 114 (An-Nas)
        // Line 11: Bismillah
        // Line 12: Text (justified)
        // Line 13: Text (justified)
        // Line 14: Text (centered)
        // Line 15: Text (centered)
        expect(layout.lines[0].type, MushafLineType.header);
        expect(layout.lines[0].surahNumber, 112);
        expect(layout.lines[1].type, MushafLineType.bismillah);
        expect(layout.lines[2].isCentered, isFalse);
        expect(layout.lines[3].isCentered, isTrue);

        expect(layout.lines[4].type, MushafLineType.header);
        expect(layout.lines[4].surahNumber, 113);
        expect(layout.lines[5].type, MushafLineType.bismillah);
        expect(layout.lines[6].isCentered, isFalse);
        expect(layout.lines[7].isCentered, isFalse);
        expect(layout.lines[8].isCentered, isTrue);

        expect(layout.lines[9].type, MushafLineType.header);
        expect(layout.lines[9].surahNumber, 114);
        expect(layout.lines[10].type, MushafLineType.bismillah);
        expect(layout.lines[11].isCentered, isFalse);
        expect(layout.lines[12].isCentered, isFalse);
        expect(layout.lines[13].isCentered, isTrue);
        expect(layout.lines[14].isCentered, isTrue);

        await tester.pumpWidget(buildTestFrame(QuranPageView(pageNumber: 604)));
        await tester.pumpAndSettle();

        expect(find.byType(MushafCanvas), findsOneWidget);
        expect(find.byType(MushafLineWidget), findsNWidgets(15));
        expect(find.byType(SurahHeaderBanner), findsNWidgets(3));
        expect(find.byType(BismillahBanner), findsNWidgets(3));
        expect(find.text('سُورَةُ الإخلاص'), findsWidgets);
        expect(find.text('سُورَةُ الفلق'), findsOneWidget);
        expect(find.text('سُورَةُ الناس'), findsOneWidget);
      },
    );

    testWidgets(
      'Interactivity Verification: Ayah Tap & Long Press invoke callbacks with stable ID',
      (tester) async {
        Ayah? tappedAyah;
        Ayah? longPressedAyah;

        await tester.pumpWidget(
          buildTestFrame(
            QuranPageView(
              pageNumber: 1,
              onAyahTap: (a) => tappedAyah = a,
              onAyahLongPress: (a) => longPressedAyah = a,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap on word "بِسْمِ" (Ayah 1:1, stable ID 1)
        await tester.tap(find.text('بِسْمِ'));
        await tester.pumpAndSettle();
        expect(tappedAyah, isNotNull);
        expect(tappedAyah!.id, 1);
        expect(tappedAyah!.surahNumber, 1);
        expect(tappedAyah!.ayahNumber, 1);

        // Long press on word "ٱلْحَمْدُ" (Ayah 1:2, stable ID 2)
        await tester.longPress(find.text('ٱلْحَمْدُ'));
        await tester.pumpAndSettle();
        expect(longPressedAyah, isNotNull);
        expect(longPressedAyah!.id, 2);
        expect(longPressedAyah!.surahNumber, 1);
        expect(longPressedAyah!.ayahNumber, 2);
      },
    );
  });
}
