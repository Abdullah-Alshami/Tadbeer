import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/app/app.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/data/ayah_links/ayah_link_repository.dart';
import 'package:tadbeer/data/quran/quran_repository.dart';
import 'package:tadbeer/features/ayah_links/ayah_link_detail_screen.dart';
import 'package:tadbeer/features/ayah_links/ayah_links_screen.dart';
import 'package:tadbeer/features/ayah_links/views/ayah_link_cards_view.dart';
import 'package:tadbeer/features/ayah_links/views/ayah_link_network_view.dart';
import 'package:tadbeer/features/ayah_links/views/ayah_link_ordered_view.dart';
import 'package:tadbeer/features/quran/quran_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File dataFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'tadbeer_ayah_links_ui_test_',
    );
    dataFile = File('${tempDir.path}/test_user_data.json');
    await UserDataStore.instance.init(dataFile);
    await QuranRepository.instance.init();
    await UserDataStore.instance.updateSettings(
      UserDataStore.instance.settings.copyWith(
        hideTadabburIntroPermanently: true,
      ),
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Ayah Links UI & Flow Tests', () {
    testWidgets(
      'AyahLinksScreen renders, creates a link and navigates to detail',
      (WidgetTester tester) async {
        await tester.pumpWidget(const TadbeerApp());
        await tester.pumpAndSettle();

        // Open Ayah Links from Home Dashboard
        final linksFinder = find.text('روابط الآيات');
        expect(linksFinder, findsWidgets);
        await tester.ensureVisible(linksFinder.first);
        await tester.tap(linksFinder.first);
        await tester.pumpAndSettle();

        expect(find.byType(AyahLinksScreen), findsOneWidget);
        expect(find.text('لا توجد روابط آيات بعد'), findsOneWidget);

        // Tap create link FAB
        final createFab = find.byType(FloatingActionButton);
        expect(createFab, findsOneWidget);
        await tester.tap(createFab);
        await tester.pumpAndSettle();

        // Enter Title
        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, 'الصبر عند الشدة');
        await tester.pumpAndSettle();

        // Submit
        final submitButton = find.text('إنشاء');
        expect(submitButton, findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(submitButton);
          await Future.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();

        // Should navigate to AyahLinkDetailScreen
        expect(find.byType(AyahLinkDetailScreen), findsOneWidget);
        expect(find.text('الصبر عند الشدة'), findsOneWidget);
      },
    );

    testWidgets(
      'Detail Screen switches smoothly between Network, Ordered, and Cards views',
      (WidgetTester tester) async {
        final repo = AyahLinkRepository();
        final link = await repo.createLink(
          title: 'الاستعانة بالصبر',
          description: 'وصف التجربة',
        );
        await repo.addVerseToLink(
          link.id,
          ayahId: 160,
          surahNumber: 2,
          ayahNumber: 153,
          page: 23,
        );

        await tester.pumpWidget(
          MaterialApp(home: AyahLinkDetailScreen(linkId: link.id)),
        );
        await tester.pumpAndSettle();

        // Starts in Network View
        expect(find.byType(AyahLinkNetworkView), findsOneWidget);
        expect(find.byType(AyahLinkOrderedView), findsOneWidget);
        expect(find.byType(AyahLinkCardsView), findsOneWidget);

        // Switch to Ordered view
        final orderedTab = find.text('مرتب');
        expect(orderedTab, findsOneWidget);
        await tester.tap(orderedTab);
        await tester.pumpAndSettle();

        // Switch to Cards view
        final cardsTab = find.text('بطاقات');
        expect(cardsTab, findsOneWidget);
        await tester.tap(cardsTab);
        await tester.pumpAndSettle();

        // Verify verse content is visible in Cards view
        expect(find.textContaining('استعينوا بالصبر'), findsOneWidget);
      },
    );

    testWidgets(
      '13: Open in Quran from Ayah Link opens correct page and surah in QuranScreen',
      (WidgetTester tester) async {
        final repo = AyahLinkRepository();
        final link = await repo.createLink(title: 'الانتقال للمصحف');
        await repo.addVerseToLink(
          link.id,
          ayahId: 160,
          surahNumber: 2,
          ayahNumber: 153,
          page: 23,
        );

        await tester.pumpWidget(
          MaterialApp(home: AyahLinkDetailScreen(linkId: link.id)),
        );
        await tester.pumpAndSettle();

        // Switch to Cards view
        await tester.tap(find.text('بطاقات'));
        await tester.pumpAndSettle();

        // Tap verse text or menu
        final verseTextFinder = find.textContaining('استعينوا بالصبر');
        expect(verseTextFinder, findsOneWidget);
        await tester.tap(verseTextFinder);
        await tester.pumpAndSettle();

        // QuranScreen should open on page 23
        expect(find.byType(QuranScreen), findsOneWidget);
        expect(find.textContaining('٢٣'), findsWidgets);
      },
    );
  });
}
