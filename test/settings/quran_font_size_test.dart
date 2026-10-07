import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/core/storage/user_database.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/quran_models.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_word_widget.dart';
import 'package:tadbeer/features/quran/widgets/ayah_action_sheet.dart';
import 'package:tadbeer/features/settings/settings_screen.dart';
import 'package:tadbeer/features/settings/user_settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Font Size Model Tests', () {
    test('Default Quran font size is strictly 20.0', () {
      const settings = UserSettings();
      expect(settings.quranFontSize, equals(20.0));
      expect(UserSettings.defaultQuranFontSize, equals(20.0));
    });

    test('JSON serialization roundtrip maintains 20.0', () {
      const settings = UserSettings(quranFontSize: 20.0);
      final json = settings.toJson();
      expect(json['quranFontSize'], equals(20.0));

      final restored = UserSettings.fromJson(json);
      expect(restored.quranFontSize, equals(20.0));
    });
  });

  group('UserDataStore Fixed Font Size Tests', () {
    late Directory tempDir;
    late File testFile;
    late UserDataStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tadbeer_font_test_');
      testFile = File('${tempDir.path}/test_settings.json');
      store = UserDataStore.instance;
      await store.init(testFile);
    });

    tearDown(() async {
      await UserDatabase.instance.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Store font size is strictly 20.0', () {
      expect(store.quranFontSize, equals(20.0));
      expect(store.settings.quranFontSize, equals(20.0));
    });
  });

  group('SettingsScreen Font Size Removal Tests', () {
    late Directory tempDir;
    late File testFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tadbeer_ui_test_');
      testFile = File('${tempDir.path}/test_settings_ui.json');
      await UserDataStore.instance.init(testFile);
    });

    tearDown(() async {
      await UserDatabase.instance.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets(
      'SettingsScreen does NOT render Quran font size section or slider',
      (tester) async {
        await tester.pumpWidget(
          AppLocalizationScope(
            currentLanguage: AppLanguage.arabic,
            strings: const AppStrings(AppLanguage.arabic),
            onLanguageChanged: (_) {},
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Check font size section header is completely absent
        expect(find.text('حجم خط المصحف'), findsNothing);

        // Check Slider is absent
        expect(find.byType(Slider), findsNothing);
      },
    );
  });

  group('MushafWordWidget Typography & Interaction Tests', () {
    late Directory tempDir;
    late File testFile;

    const word = MushafWord(
      pageNumber: 1,
      lineNumber: 2,
      surah: 1,
      ayah: 1,
      position: 1,
      text: 'بِسْمِ',
      glyph: 'ﭓ',
      isAyahEnd: false,
    );

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tadbeer_word_test_');
      testFile = File('${tempDir.path}/test_word.json');
      await UserDataStore.instance.init(testFile);
      await QuranRepository.instance.init();
    });

    tearDown(() async {
      await UserDatabase.instance.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('MushafWordWidget uses fixed 20.0 font size by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MushafWordWidget(word: word)),
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(20.0));
      expect(MushafWordWidget.defaultQuranFontSize, equals(20.0));
      expect(MushafWordWidget.quranFontSize, equals(20.0));
    });

    testWidgets('MushafWordWidget honors explicit fontSize override', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MushafWordWidget(word: word, fontSize: 19.0)),
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(19.0));
    });

    testWidgets(
      'Normal tap invokes onAyahTap and does NOT open AyahActionSheet',
      (tester) async {
        Ayah? tappedAyah;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MushafWordWidget(
                word: word,
                onAyahTap: (a) => tappedAyah = a,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Normal tap
        await tester.tap(find.byType(MushafWordWidget));
        await tester.pumpAndSettle();

        expect(tappedAyah, isNotNull);
        expect(tappedAyah!.surahNumber, equals(1));
        expect(tappedAyah!.ayahNumber, equals(1));

        // ActionSheet should NOT be shown
        expect(find.byType(AyahActionSheet), findsNothing);
      },
    );

    testWidgets('Short press (< 2.0s) does NOT trigger long press', (
      tester,
    ) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafWordWidget(
              word: word,
              onAyahLongPress: (_) => longPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hold pointer for 1000ms (less than 2000ms threshold)
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MushafWordWidget)),
      );
      await tester.pump(const Duration(milliseconds: 1000));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(longPressed, isFalse);
    });

    testWidgets('Long press (held for 2000ms) triggers onAyahLongPress', (
      tester,
    ) async {
      Ayah? longPressedAyah;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafWordWidget(
              word: word,
              onAyahLongPress: (a) => longPressedAyah = a,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hold pointer down for 2100ms
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MushafWordWidget)),
      );
      await tester.pump(const Duration(milliseconds: 2100));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(longPressedAyah, isNotNull);
      expect(longPressedAyah!.surahNumber, equals(1));
      expect(longPressedAyah!.ayahNumber, equals(1));
    });

    testWidgets('Horizontal drag cancels 2.0s timer immediately', (
      tester,
    ) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MushafWordWidget(
              word: word,
              onAyahLongPress: (_) => longPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Start pointer down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MushafWordWidget)),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Drag horizontally by 30px
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 2000));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(longPressed, isFalse);
    });
  });
}
