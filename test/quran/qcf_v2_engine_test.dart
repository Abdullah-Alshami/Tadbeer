import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/qcf_font_manager.dart';
import 'package:tadbeer/features/quran/data/qcf_glyph_service.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_word_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await QuranRepository.instance.init();
  });

  group('Genuine King Fahd Complex QCF V2 Engine Verification', () {
    test('1. All 604 QCF font files exist in assets/quran/qcf_v2/fonts/', () {
      final fontDir = Directory('assets/quran/qcf_v2/fonts');
      expect(fontDir.existsSync(), isTrue);

      final files = fontDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.ttf'))
          .toList();

      expect(
        files.length,
        604,
        reason: 'Exactly 604 font files must exist for pages 1..604',
      );

      for (int page = 1; page <= 604; page++) {
        final fontFile = File('assets/quran/qcf_v2/fonts/p$page.ttf');
        expect(
          fontFile.existsSync(),
          isTrue,
          reason: 'Font file for page $page (p$page.ttf) must exist',
        );
        expect(
          fontFile.lengthSync(),
          greaterThan(10000),
          reason: 'Font file p$page.ttf must be a valid non-empty binary',
        );
      }
    });

    test(
      '2. Dynamic loading and family resolution for pages p1, p70, p604',
      () async {
        expect(QcfFontManager.fontFamilyForPage(1), 'QCF2_P1');
        expect(QcfFontManager.fontFamilyForPage(70), 'QCF2_P70');
        expect(QcfFontManager.fontFamilyForPage(604), 'QCF2_P604');

        // Verify loadPageFont runs without throwing
        await QcfFontManager.loadPageFont(1);
        await QcfFontManager.loadPageFont(70);
        await QcfFontManager.loadPageFont(604);

        // Verify preload surrounding pages executes cleanly
        QcfFontManager.preloadSurroundingPages(70);
      },
    );

    test('3. Glyphs data loading and authentic coverage across all 6,236 ayat', () {
      final glyphService = QcfGlyphService.instance;
      expect(glyphService.isLoaded, isTrue);

      final repo = QuranRepository.instance;
      expect(repo.allAyahs.length, 6236);

      // Verify every single Ayah in the Quran has valid non-empty QCF V2 glyphs
      for (final ayah in repo.allAyahs) {
        final glyphs = glyphService.getGlyphsForAyah(
          ayah.surahNumber,
          ayah.ayahNumber,
        );
        expect(
          glyphs.isNotEmpty,
          isTrue,
          reason:
              'Ayah ${ayah.surahNumber}:${ayah.ayahNumber} must have non-empty glyphs',
        );
      }

      // Verify authentic Muqatta'at overrides
      final s2a1 = glyphService.getGlyphsForAyah(2, 1);
      expect(s2a1.length, 2);
      expect(s2a1[0], String.fromCharCode(0xfc41));
      expect(s2a1[1], String.fromCharCode(0xfc42));

      final s7a1 = glyphService.getGlyphsForAyah(7, 1);
      expect(s7a1.length, 2);
      expect(s7a1[0], String.fromCharCode(0xfc41));
      expect(s7a1[1], String.fromCharCode(0xfc42));
    });

    test('4. Word linking to page-specific font and enriched metadata', () {
      final repo = QuranRepository.instance;

      for (final pageNumber in [1, 2, 70, 121, 300, 604]) {
        final pageLayout = repo.getMushafPage(pageNumber);
        expect(pageLayout.pageNumber, pageNumber);

        for (final line in pageLayout.lines) {
          if (line.type != MushafLineType.text) continue;

          for (final word in line.words) {
            expect(word.pageNumber, pageNumber);
            expect(word.lineNumber, line.lineNumber);
            expect(word.ayahId, greaterThan(0));
            expect(word.glyph.isNotEmpty, isTrue);
            expect(word.glyphCode, isNotNull);
          }
        }
      }
    });

    testWidgets(
      '5. Mushaf words strictly do NOT use AmiriQuran or DigitalKhatt as primary font',
      (tester) async {
        final repo = QuranRepository.instance;
        final p1 = repo.getMushafPage(1);
        final firstTextLine = p1.lines.firstWhere(
          (l) => l.type == MushafLineType.text,
        );
        final word1 = firstTextLine.words.first;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: MushafWordWidget(word: word1)),
          ),
        );
        await tester.pumpAndSettle();

        final textWidget = tester.widget<Text>(find.byType(Text));
        final fontFamily = textWidget.style?.fontFamily;

        expect(
          fontFamily,
          'QCF2_P1',
          reason: 'Word must use its page QCF V2 font family QCF2_P1',
        );
        expect(fontFamily, isNot('AmiriQuran'));
        expect(fontFamily, isNot('DigitalKhatt'));
        expect(textWidget.data, word1.glyph);
      },
    );

    test(
      '6. Exact 15-line consistency on standard pages (8 on pages 1 & 2)',
      () {
        final repo = QuranRepository.instance;

        // Opening page 1: Al-Fatihah (8 lines)
        final p1 = repo.getMushafPage(1);
        expect(p1.totalLines, 8);
        expect(p1.lines.length, 8);

        // Opening page 2: Al-Baqarah 1-5 (8 lines)
        final p2 = repo.getMushafPage(2);
        expect(p2.totalLines, 8);
        expect(p2.lines.length, 8);

        // All remaining standard Madinah pages (3 to 604): exactly 15 lines
        for (int page = 3; page <= 604; page++) {
          final p = repo.getMushafPage(page);
          expect(p.totalLines, 15, reason: 'Page $page totalLines must be 15');
          expect(
            p.lines.length,
            15,
            reason: 'Page $page lines count must be 15',
          );
        }
      },
    );
  });
}
