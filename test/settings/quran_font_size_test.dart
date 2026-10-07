import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/core/storage/user_database.dart';
import 'package:tadbeer/features/quran/data/mushaf_layout_models.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/renderers/mushaf_word_widget.dart';
import 'package:tadbeer/features/settings/settings_screen.dart';
import 'package:tadbeer/features/settings/user_settings_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Font Size Model Tests', () {
    test('Default Quran font size is strictly 23.0', () {
      const settings = UserSettings();
      expect(settings.quranFontSize, equals(23.0));
      expect(UserSettings.defaultQuranFontSize, equals(23.0));
      expect(UserSettings.minQuranFontSize, equals(18.0));
      expect(UserSettings.maxQuranFontSize, equals(28.0));
    });

    test('Clamping logic in copyWith and fromJson', () {
      const settings = UserSettings();

      final low = settings.copyWith(quranFontSize: 15.0);
      expect(low.quranFontSize, equals(18.0));

      final high = settings.copyWith(quranFontSize: 35.0);
      expect(high.quranFontSize, equals(28.0));

      final jsonLow = UserSettings.fromJson({'quranFontSize': 12.0});
      expect(jsonLow.quranFontSize, equals(18.0));

      final jsonHigh = UserSettings.fromJson({'quranFontSize': 32.0});
      expect(jsonHigh.quranFontSize, equals(28.0));
    });

    test('JSON serialization and deserialization roundtrip', () {
      const settings = UserSettings(quranFontSize: 21.0);
      final json = settings.toJson();
      expect(json['quranFontSize'], equals(21.0));

      final restored = UserSettings.fromJson(json);
      expect(restored.quranFontSize, equals(21.0));
    });
  });

  group('UserDataStore Font Size Persistence Tests', () {
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

    test('Default store font size is 23.0', () {
      expect(store.quranFontSize, equals(23.0));
      expect(store.settings.quranFontSize, equals(23.0));
    });

    test('setQuranFontSize updates and persists to disk', () async {
      await store.setQuranFontSize(20.0);
      expect(store.quranFontSize, equals(20.0));

      // Re-read from disk to ensure persistence
      final content = testFile.readAsStringSync();
      expect(content, contains('"quranFontSize":20.0'));

      // Create new instance / re-init from file
      final newStore = UserDataStore.instance;
      await newStore.init(testFile);
      expect(newStore.quranFontSize, equals(20.0));
    });

    test('setQuranFontSize clamps within [18.0, 28.0]', () async {
      await store.setQuranFontSize(12.0);
      expect(store.quranFontSize, equals(18.0));

      await store.setQuranFontSize(30.0);
      expect(store.quranFontSize, equals(28.0));
    });
  });

  group('SettingsScreen Font Size Widget Tests', () {
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
      'Renders Quran font size section and slider in SettingsScreen',
      (tester) async {
        await tester.runAsync(() async {
          await UserDataStore.instance.setQuranFontSize(23.0);
        });

        await tester.pumpWidget(
          AppLocalizationScope(
            currentLanguage: AppLanguage.arabic,
            strings: const AppStrings(AppLanguage.arabic),
            onLanguageChanged: (_) {},
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Check section header exists
        expect(find.text('حجم خط المصحف'), findsOneWidget);

        // Check value indicator displays 23
        expect(find.text('23'), findsOneWidget);

        // Check Slider is present
        final sliderFinder = find.byType(Slider);
        expect(sliderFinder, findsOneWidget);

        final slider = tester.widget<Slider>(sliderFinder);
        expect(slider.min, equals(18.0));
        expect(slider.max, equals(28.0));
        expect(slider.value, equals(23.0));
        expect(slider.divisions, equals(10));
      },
    );
  });

  group('MushafWordWidget Dynamic Font Size Tests', () {
    late Directory tempDir;
    late File testFile;

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

    testWidgets('MushafWordWidget uses settings font size by default', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await UserDataStore.instance.setQuranFontSize(23.0);
      });

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

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MushafWordWidget(word: word)),
        ),
      );
      await tester.pumpAndSettle();

      final textFinder = find.byType(Text);
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, equals(23.0));

      // Now update font size in settings and verify rebuild
      await tester.runAsync(() async {
        await UserDataStore.instance.setQuranFontSize(20.0);
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MushafWordWidget(word: word)),
        ),
      );
      await tester.pumpAndSettle();

      final updatedText = tester.widget<Text>(textFinder);
      expect(updatedText.style?.fontSize, equals(20.0));
    });

    testWidgets('MushafWordWidget honors explicit fontSize override', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await UserDataStore.instance.setQuranFontSize(23.0);
      });

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
  });
}
