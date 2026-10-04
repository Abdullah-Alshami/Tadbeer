import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/quran/quran_models.dart';
import '../../data/quran/quran_repository.dart';
import '../../shared/widgets/ayah_action_sheet.dart';
import '../search/search_screen.dart';
import 'quran_page_view.dart';
import 'quran_side_menu.dart';

/// Fullscreen Quran reading experience for Tadbeer.
///
/// EDUCATIONAL NOTE:
/// Quran Reading Screen Architecture:
/// 1. Backed by a standard Flutter [PageView.builder] mapped to 604 pages.
/// 2. RTL support is inherent to Arabic text directionality.
/// 3. The current page position is automatically persisted to [UserDataStore]
///    as the user swipes, so exiting the app preserves the exact reading spot.
/// 4. Supports deep navigation to a specific surah and ayah (e.g., from search or bookmarks).
class QuranScreen extends StatefulWidget {
  final int? initialPage;
  final int? targetSurahNumber;
  final int? targetAyahNumber;

  const QuranScreen({
    super.key,
    this.initialPage,
    this.targetSurahNumber,
    this.targetAyahNumber,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late int _currentPage;
  Ayah? _activeSelectedAyah;

  @override
  void initState() {
    super.initState();
    final saved = UserDataStore.instance.readingPosition;
    _currentPage = widget.initialPage ?? saved.page;
    if (_currentPage < 1 || _currentPage > 604) _currentPage = 1;

    // 0-indexed PageView controller
    _pageController = PageController(initialPage: _currentPage - 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _persistCurrentPagePosition(_currentPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final pageNum = index + 1;
    setState(() {
      _currentPage = pageNum;
      _activeSelectedAyah = null;
    });
    _persistCurrentPagePosition(pageNum);
  }

  void _persistCurrentPagePosition(int pageNum) {
    final quranPage = QuranRepository.instance.getPage(pageNum);
    if (quranPage.ayahs.isNotEmpty) {
      final firstAyah = quranPage.ayahs.first;
      UserDataStore.instance.saveReadingPosition(
        page: pageNum,
        surahNumber: firstAyah.surahNumber,
        ayahNumber: firstAyah.ayahNumber,
      );
    }
  }

  void _jumpToPage(int pageNum) {
    if (pageNum < 1 || pageNum > 604) return;
    _pageController.jumpToPage(pageNum - 1);
  }

  Future<void> _handleAyahLongPress(Ayah ayah) async {
    setState(() {
      _activeSelectedAyah = ayah;
    });

    await AyahActionSheet.show(context, ayah);

    if (mounted) {
      setState(() {
        _activeSelectedAyah = null;
      });
    }
  }

  Future<void> _openSearch() async {
    final pickedAyah = await Navigator.push<Ayah>(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(returnToCaller: true),
      ),
    );

    if (pickedAyah != null && mounted) {
      _jumpToPage(pickedAyah.page);
    }
  }

  void _showJumpToPageDialog() {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: '$_currentPage');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,
        title: Text(
          l10n.jumpToPage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.enterPageNumber,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.nightSubtitle : AppColors.daySubtitle,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val >= 1 && val <= 604) {
                Navigator.pop(dialogCtx);
                _jumpToPage(val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.olive,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.go,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = QuranRepository.instance;
    final userSettings = UserDataStore.instance.settings;

    final currentPageData = repo.getPage(_currentPage);
    final firstSurah = repo.getSurah(currentPageData.surahNumbers.first);
    final surahTitle = 'سورة ${firstSurah.name}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: QuranSideMenu(
          currentPage: _currentPage,
          onPageSelected: _jumpToPage,
        ),
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            '$surahTitle · ص ${ArabicSearchNormalizer.toArabicDigits(_currentPage)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Quran Search Action
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: _openSearch,
            ),
            // Popup menu for secondary actions (Jump to page, Index, Home)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: l10n.more,
              onSelected: (val) {
                if (val == 'jump') {
                  _showJumpToPageDialog();
                } else if (val == 'index') {
                  _scaffoldKey.currentState?.openDrawer();
                } else if (val == 'home') {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'jump',
                  child: Row(
                    children: [
                      const Icon(Icons.find_in_page_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.jumpToPage),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'index',
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('فهرس السور والأجزاء'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'home',
                  child: Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.home),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            return PageView.builder(
              controller: _pageController,
              itemCount: 604,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final page = repo.getPage(index + 1);
                return QuranPageView(
                  page: page,
                  fontSize: userSettings.quranFontSize,
                  selectedAyah: _activeSelectedAyah,
                  onAyahLongPress: _handleAyahLongPress,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
