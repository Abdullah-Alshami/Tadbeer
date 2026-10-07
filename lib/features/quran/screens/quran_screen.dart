import 'package:flutter/material.dart';

import '../../../app/localization.dart';
import '../../../app/theme.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import '../widgets/ayah_action_sheet.dart';
import '../../search/search_screen.dart';
import 'quran_page_view.dart';
import '../widgets/quran_side_menu.dart';

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
  bool _showTopBar = false;
  bool _suppressNextPageTap = false;

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
    final page = repo.getPage(pageNumber);
    if (page.ayahs.isNotEmpty) {
      final firstAyah = page.ayahs.first;
      UserDataStore.instance.saveReadingPosition(
        page: pageNumber,
        surahNumber: firstAyah.surahNumber,
        ayahNumber: firstAyah.ayahNumber,
      );
    }
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

  void _handleAyahTap(Ayah ayah) {
    // Normal tap toggles top bar via the page-level GestureDetector
  }

  Future<void> _handleAyahLongPress(Ayah ayah) async {
    _suppressNextPageTap = true;
    setState(() {
      _activeSelectedAyah = ayah;
    });

    await AyahActionSheet.show(context, ayah);

    if (mounted) {
      setState(() {
        _activeSelectedAyah = null;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _suppressNextPageTap = false;
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

  void _toggleTopBar() {
    if (_suppressNextPageTap) {
      _suppressNextPageTap = false;
      return;
    }
    setState(() {
      _showTopBar = !_showTopBar;
    });
  }

  Widget _buildTopBar(BuildContext context, int currentPageNumber) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final pageDigits = ArabicSearchNormalizer.toArabicDigits(currentPageNumber);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.comsilkLight)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Drawer menu button (☰) (at the far right corner in RTL)
          IconButton(
            icon: const Icon(Icons.menu, size: 22),
            tooltip: 'القائمة',
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          // 2. Current page number button (to the left of ☰ in RTL)
          InkWell(
            onTap: _showJumpToPageDialog,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                'ص $pageDigits',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 3. Search button (🔍) (to the left of the page number in RTL)
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            tooltip: l10n.search,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            onPressed: _openSearch,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository.instance;
    final currentPageNumber = _currentPageIndex + 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: QuranSideMenu(
          currentPage: currentPageNumber,
          onPageSelected: _jumpToMushafPage,
        ),
        body: Stack(
          children: [
            // Fullscreen Mushaf page area (maximum space, no reserved bar space)
            Positioned.fill(
              child: SafeArea(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleTopBar,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 604,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final page = repo.getPage(index + 1);
                      return QuranPageView(
                        page: page,
                        pageNumber: index + 1,
                        selectedAyah: _activeSelectedAyah,
                        onAyahTap: _handleAyahTap,
                        onAyahLongPress: _handleAyahLongPress,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Smooth floating top bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: IgnorePointer(
                  ignoring: !_showTopBar,
                  child: AnimatedOpacity(
                    opacity: _showTopBar ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _buildTopBar(context, currentPageNumber),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
