import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/localization.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/core/storage/user_database.dart';
import 'package:tadbeer/features/quran/data/quran_repository.dart';
import 'package:tadbeer/features/quran/screens/quran_screen.dart';
import 'package:tadbeer/features/quran/widgets/quran_side_menu.dart';
import 'package:tadbeer/features/search/search_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File testFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadbeer_toolbar_test_');
    testFile = File('${tempDir.path}/test_toolbar.json');
    await UserDataStore.instance.init(testFile);
    await QuranRepository.instance.init();
    await UserDataStore.instance.updateSettings(
      UserDataStore.instance.settings.copyWith(
        hideTadbeerIntroPermanently: true,
      ),
    );
  });

  tearDown(() async {
    await UserDatabase.instance.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Widget buildTestScreen() {
    return AppLocalizationScope(
      currentLanguage: AppLanguage.arabic,
      strings: const AppStrings(AppLanguage.arabic),
      onLanguageChanged: (_) {},
      child: const MaterialApp(home: QuranScreen(initialPage: 112)),
    );
  }

  group('QuranScreen Toolbar Layout & Interaction Tests', () {
    testWidgets('Toolbar is hidden by default and toggles on tap', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      final animatedOpacityFinder = find.descendant(
        of: find.byType(QuranScreen),
        matching: find.byType(AnimatedOpacity),
      );
      expect(animatedOpacityFinder, findsOneWidget);

      // 1. Hidden by default
      AnimatedOpacity opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.0);

      // 2. Tap page to reveal toolbar
      await tester.tap(find.byType(QuranScreen));
      await tester.pumpAndSettle();

      opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 1.0);

      // 3. Tap page again to hide toolbar
      await tester.tap(find.byType(QuranScreen));
      await tester.pumpAndSettle();

      opacityWidget = tester.widget(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.0);
    });

    testWidgets('Swipe does NOT show toolbar automatically', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      final animatedOpacityFinder = find.descendant(
        of: find.byType(QuranScreen),
        matching: find.byType(AnimatedOpacity),
      );

      // Swipe horizontally to next page
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      final opacityWidget = tester.widget<AnimatedOpacity>(
        animatedOpacityFinder,
      );
      expect(opacityWidget.opacity, 0.0);
    });

    testWidgets(
      'Toolbar has ☰ at right, page number next, search next, and no obsolete items',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await tester.pumpAndSettle();

        // Tap to reveal toolbar
        await tester.tap(find.byType(QuranScreen));
        await tester.pumpAndSettle();

        // Check Toolbar children order in RTL
        final menuFinder = find.byIcon(Icons.menu);
        final pageFinder = find.textContaining('ص ');
        final searchFinder = find.byIcon(Icons.search);

        expect(menuFinder, findsOneWidget);
        expect(pageFinder, findsWidgets);
        expect(searchFinder, findsOneWidget);

        // Verify obsolete items are NOT in toolbar
        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byIcon(Icons.arrow_forward), findsNothing);

        // In RTL: Menu button (☰) is furthest to the right (largest dx)
        final menuOffset = tester.getCenter(menuFinder);
        final pageOffset = tester.getCenter(pageFinder.first);
        final searchOffset = tester.getCenter(searchFinder);

        // In RTL: x coordinates increase from left to right:
        // menu (far right) > page > search (to the left)
        expect(menuOffset.dx, greaterThan(pageOffset.dx));
        expect(pageOffset.dx, greaterThan(searchOffset.dx));

        // Test ☰ opens Drawer
        await tester.tap(menuFinder);
        await tester.pumpAndSettle();
        expect(find.byType(QuranSideMenu), findsOneWidget);

        // Close Drawer
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Test Page jump dialog
        await tester.tap(pageFinder.first);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('الانتقال إلى صفحة'), findsOneWidget);

        // Cancel dialog
        await tester.tap(find.text('إلغاء'));
        await tester.pumpAndSettle();

        // Test Search button opens SearchScreen
        await tester.tap(searchFinder);
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);
      },
    );
  });
}
