import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../data/mushaf_layout_models.dart';
import '../data/qcf_font_manager.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import 'mushaf_line_widget.dart';

/// The authoritative Madinah Mushaf Page Canvas.
///
/// Designed as a self-contained, independent Mushaf Page Canvas following the exact hierarchy:
/// Quran Words → Mushaf Layout → Pages → Lines → Words داخل كل Line.
///
/// Key Architectural Guarantees:
/// - 604 fixed pages.
/// - 15 lines per standard page (8 lines for opening pages 1 & 2).
/// - Vertical distribution: 15 fixed, equal line slots with NO [MainAxisAlignment.spaceBetween],
///   [spaceAround], or [spaceEvenly].
/// - Horizontal distribution: Centered when [is_centered] is true, fully justified at word level
///   when [is_centered] is false.
/// - Zero text scaling, zero [FittedBox], zero [Transform.scale], uniform fixed font size.
class MushafCanvas extends StatefulWidget {
  final MushafPageLayout pageLayout;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;
  final double? fontSize;

  const MushafCanvas({
    super.key,
    required this.pageLayout,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
    this.fontSize,
  });

  @override
  State<MushafCanvas> createState() => _MushafCanvasState();
}

class _MushafCanvasState extends State<MushafCanvas> {
  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  @override
  void didUpdateWidget(covariant MushafCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageLayout.pageNumber != widget.pageLayout.pageNumber) {
      _loadFont();
    }
  }

  void _loadFont() {
    final page = widget.pageLayout.pageNumber;
    if (!QcfFontManager.isPageLoaded(page)) {
      QcfFontManager.loadPageFont(page).then((_) {
        if (mounted) setState(() {});
      });
    }
    QcfFontManager.preloadSurroundingPages(page);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserDataStore.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final effectiveFontSize =
            widget.fontSize ?? UserDataStore.instance.settings.quranFontSize;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: AppColors.mushafBackground,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightBorder, width: 1.0),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mushaf Page Top Header (Surah name & Juz number)
                  _buildPageHeader(context, isDark),
                  const SizedBox(height: 4),

                  // Mushaf Page Text Block (15 authentic lines)
                  Expanded(
                    child: _buildTextCanvas(context, isDark, effectiveFontSize),
                  ),

                  // Mushaf Page Bottom Footer (Arabic page number)
                  const SizedBox(height: 2),
                  _buildPageFooter(context, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDark) {
    final repo = QuranRepository.instance;
    final pageLayout = widget.pageLayout;
    final surahs = pageLayout.surahNumbers;
    final firstSurahNumber = surahs.isNotEmpty
        ? surahs.first
        : (pageLayout.firstWord?.surah ?? 1);
    final surah = repo.getSurah(firstSurahNumber);

    final headerColor = AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.lightBorder, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'سُورَةُ ${surah.name}',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
          Text(
            'الجزء ${ArabicSearchNormalizer.toArabicDigits(pageLayout.juzNumber)}',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.lightBorder, width: 0.8),
        ),
      ),
      child: Center(
        child: Text(
          ArabicSearchNormalizer.toArabicDigits(widget.pageLayout.pageNumber),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextCanvas(
    BuildContext context,
    bool isDark,
    double effectiveFontSize,
  ) {
    final pageLayout = widget.pageLayout;
    final isOpeningPage = pageLayout.lines.length < 15;

    if (isOpeningPage) {
      // Opening pages (Page 1 Al-Fatihah and Page 2 Al-Baqarah 1-5):
      // Rendered inside an authentic decorative frame centered on the canvas
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.lightAccentGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.lightSurface.withValues(alpha: 0.4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in pageLayout.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MushafLineWidget(
                    line: line,
                    selectedAyah: widget.selectedAyah,
                    onAyahTap: widget.onAyahTap,
                    onAyahLongPress: widget.onAyahLongPress,
                    fontSize: effectiveFontSize,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Standard 15-line Madinah Mushaf pages (Pages 3 to 604):
    // Exactly 15 lines, each in an Expanded slot to ensure uniform, fixed vertical rhythm
    // without spaceBetween or dynamic space filling.
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in pageLayout.lines)
          Expanded(
            child: MushafLineWidget(
              line: line,
              selectedAyah: widget.selectedAyah,
              onAyahTap: widget.onAyahTap,
              onAyahLongPress: widget.onAyahLongPress,
              fontSize: effectiveFontSize,
            ),
          ),
      ],
    );
  }
}
