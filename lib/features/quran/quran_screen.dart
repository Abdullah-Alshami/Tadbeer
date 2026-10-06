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

/// Fullscreen Medina Mushaf reading experience for Tadbeer (1421H layout, 604 pages).
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
  late int _currentPageIndex;
  Ayah? _activeSelectedAyah;

  @override
  void initState() {
    super.initState();
    final repo = QuranRepository.instance;
    final saved = UserDataStore.instance.readingPosition;

    int startPage = widget.initialPage ?? saved.page;
    if (widget.targetSurahNumber != null && widget.targetAyahNumber != null) {
      final targetAyah = repo.getAyah(
        widget.targetSurahNumber!,
        widget.targetAyahNumber!,
      );
      if (targetAyah != null) {
        startPage = targetAyah.page;
        _activeSelectedAyah = targetAyah;
      }
    }

    startPage = startPage.clamp(1, 604);
    _currentPageIndex = startPage - 1;
    _pageController = PageController(initialPage: _currentPageIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _persistCurrentPagePosition(startPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index < 0 || index >= 604) return;
    setState(() {
      _currentPageIndex = index;
      _activeSelectedAyah = null;
    });
    _persistCurrentPagePosition(index + 1);
  }

  void _persistCurrentPagePosition(int pageNumber) {
    final repo = QuranRepository.instance;
    final layout = repo.getMushafPage(pageNumber);
    final firstWord = layout.firstWord;

    int surahNum = 1;
    int ayahNum = 1;
    if (firstWord != null) {
      surahNum = firstWord.surah;
      ayahNum = firstWord.ayah;
    } else if (layout.lines.isNotEmpty &&
        layout.lines.first.surahNumber != null) {
      surahNum = layout.lines.first.surahNumber!;
      ayahNum = 1;
    }

    UserDataStore.instance.saveReadingPosition(
      page: pageNumber,
      surahNumber: surahNum,
      ayahNumber: ayahNum,
    );
  }

  void _jumpToMushafPage(int mushafPage) {
    final target = mushafPage.clamp(1, 604);
    _pageController.jumpToPage(target - 1);
  }

  void _jumpToAyah(Ayah ayah) {
    _pageController.jumpToPage(ayah.page - 1);
    setState(() {
      _activeSelectedAyah = ayah;
    });
  }

  Future<void> _handleAyahTap(Ayah ayah) async {
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
    final selectedAyah = await Navigator.of(context).push<Ayah>(
      MaterialPageRoute(
        builder: (_) => const SearchScreen(returnToCaller: true),
      ),
    );
    if (selectedAyah != null && mounted) {
      _jumpToAyah(selectedAyah);
    }
  }

  void _showJumpToPageDialog() {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: '${_currentPageIndex + 1}');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
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
              'أدخل رقم الصفحة بين ١ و ٦٠٤',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.nightSubtitle : AppColors.oliveDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '1 - 604',
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
                _jumpToMushafPage(val);
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
    final currentPageNumber = _currentPageIndex + 1;
    final pageLayout = repo.getMushafPage(currentPageNumber);

    final surahs = pageLayout.surahNumbers;
    final firstSurahNumber = surahs.isNotEmpty
        ? surahs.first
        : (pageLayout.firstWord?.surah ?? 1);
    final surah = repo.getSurah(firstSurahNumber);
    final surahTitle = 'سورة ${surah.name}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: QuranSideMenu(
          currentPage: currentPageNumber,
          onPageSelected: _jumpToMushafPage,
        ),
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            '$surahTitle · ص ${ArabicSearchNormalizer.toArabicDigits(currentPageNumber)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Side menu / index
            IconButton(
              icon: const Icon(Icons.menu_book),
              tooltip: 'فهرس المصحف',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            // Quran Search Action
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: _openSearch,
            ),
            // Popup menu for secondary actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: l10n.more,
              onSelected: (val) {
                if (val == 'jump') {
                  _showJumpToPageDialog();
                } else if (val == 'home') {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'jump',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.jumpToPage),
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
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 604,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return QuranPageView(
                pageNumber: index + 1,
                selectedAyah: _activeSelectedAyah,
                onAyahTap: _handleAyahTap,
                onAyahLongPress: _handleAyahLongPress,
              );
            },
          ),
        ),
      ),
    );
  }
}
