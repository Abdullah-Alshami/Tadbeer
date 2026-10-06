import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../../../data/quran/mushaf_layout_models.dart';
import '../../../data/quran/quran_models.dart';
import '../../../data/quran/quran_repository.dart';
import '../../../shared/widgets/ayah_action_sheet.dart';
import '../../../shared/widgets/surah_header_banner.dart';
import '../../notes/note_editor_screen.dart';

/// Authentic Medina Mushaf page renderer based on the King Fahd Complex (1421H)
/// Hafs 604-page layout architecture from QUL (Word -> Line -> Page).
class MadinahPageRenderer extends StatelessWidget {
  final MushafPageLayout pageLayout;
  final Ayah? selectedAyah;
  final void Function(Ayah)? onAyahTap;
  final void Function(Ayah)? onAyahLongPress;

  /// Fixed, standard Quran typography font size uniform across all 604 pages.
  static const double quranFontSize = 21;

  /// Constant line rhythm vertical gap between lines.
  static const double lineRhythmGap = 2.0;

  const MadinahPageRenderer({
    super.key,
    required this.pageLayout,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final storage = UserDataStore.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.comsilkLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.olive.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header: Surah name & Juz number
            _buildPageHeader(context, isDark),
            const SizedBox(height: 6),

            // Page Content: Authentic lines with natural line rhythm and NO FittedBox
            Expanded(
              child: _buildPageLines(
                context: context,
                isDark: isDark,
                storage: storage,
              ),
            ),

            // Page Footer: Page number
            const SizedBox(height: 4),
            _buildPageFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDark) {
    final repo = QuranRepository.instance;
    final surahs = pageLayout.surahNumbers;
    final firstSurahNumber = surahs.isNotEmpty
        ? surahs.first
        : (pageLayout.firstWord?.surah ?? 1);
    final surah = repo.getSurah(firstSurahNumber);

    final headerColor = isDark
        ? AppColors.comsilk.withValues(alpha: 0.7)
        : AppColors.oliveDark.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الجزء ${ArabicSearchNormalizer.toArabicDigits(pageLayout.juzNumber)}',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
          Text(
            'سورة ${surah.name}',
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
    return Center(
      child: Text(
        ArabicSearchNormalizer.toArabicDigits(pageLayout.pageNumber),
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark
              ? AppColors.comsilk.withValues(alpha: 0.7)
              : AppColors.oliveDark.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildPageLines({
    required BuildContext context,
    required bool isDark,
    required UserDataStore storage,
  }) {
    final repo = QuranRepository.instance;
    final lineWidgets = <Widget>[];

    for (final line in pageLayout.lines) {
      switch (line.type) {
        case MushafLineType.header:
          final surah = repo.getSurah(line.surahNumber ?? 1);
          lineWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SurahHeaderBanner(surah: surah),
            ),
          );
          break;

        case MushafLineType.bismillah:
          lineWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: _buildBismillah(context, isDark),
            ),
          );
          break;

        case MushafLineType.text:
          lineWidgets.add(
            _buildTextLine(
              context: context,
              line: line,
              isDark: isDark,
              storage: storage,
            ),
          );
          break;
      }
    }

    // Natural, constant vertical line rhythm across all pages.
    // Short pages (Page 1 & 2) sit naturally at the top with bottom whitespace,
    // without stretching spaces vertically.
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lineWidgets.length; i++) ...[
          if (i > 0) const SizedBox(height: lineRhythmGap),
          lineWidgets[i],
        ],
      ],
    );
  }

  Widget _buildBismillah(BuildContext context, bool isDark) {
    return Center(
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DigitalKhatt',
          fontFamilyFallback: const ['AmiriQuran', 'Amiri'],
          fontSize: quranFontSize,
          color: isDark ? AppColors.comsilk : AppColors.oliveDark,
        ),
      ),
    );
  }

  Widget _buildTextLine({
    required BuildContext context,
    required MushafLine line,
    required bool isDark,
    required UserDataStore storage,
  }) {
    final repo = QuranRepository.instance;
    final textColor = isDark
        ? AppColors.nightQuranText
        : AppColors.dayQuranText;
    final spans = <InlineSpan>[];

    for (final word in line.words) {
      final ayah = repo.getAyah(word.surah, word.ayah);
      if (ayah == null) continue;

      if (word.isAyahEnd) {
        final isBookmarked = storage.isBookmarked(
          ayah.surahNumber,
          ayah.ayahNumber,
        );
        final notes = storage.getNotesForAyah(
          ayah.surahNumber,
          ayah.ayahNumber,
        );

        // Note indicator icon
        if (notes.isNotEmpty) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteEditorScreen(existingNote: notes.first),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: AppColors.olive.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: 11,
                      color: isDark ? AppColors.oliveSoft : AppColors.olive,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Bookmark indicator icon
        if (isBookmarked) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => AyahActionSheet.show(context, ayah),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(Icons.bookmark, size: 12, color: AppColors.olive),
                ),
              ),
            ),
          );
        }

        // Ayah end number glyph with tap action
        final tapRecognizer = TapGestureRecognizer()
          ..onTap = () {
            if (onAyahTap != null) {
              onAyahTap!(ayah);
            } else {
              AyahActionSheet.show(context, ayah);
            }
          };

        final markerText =
            ' ﴿${ArabicSearchNormalizer.toArabicDigits(ayah.ayahNumber)}﴾ ';
        spans.add(
          TextSpan(
            text: markerText,
            recognizer: tapRecognizer,
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontFamilyFallback: const ['Amiri'],
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.comsilk : AppColors.oliveDark,
            ),
          ),
        );
      } else {
        // Regular word token
        final isSelected = selectedAyah?.id == ayah.id;
        final highlight = storage.getHighlight(
          ayah.surahNumber,
          ayah.ayahNumber,
        );

        Color? bgColor;
        if (isSelected) {
          bgColor = isDark ? AppColors.selectionDark : AppColors.selectionLight;
        } else if (highlight != null) {
          bgColor = AppColors.highlightColors[highlight.colorIndex];
        }

        final recognizer = LongPressGestureRecognizer()
          ..onLongPress = () {
            if (onAyahLongPress != null) {
              onAyahLongPress!(ayah);
            } else {
              AyahActionSheet.show(context, ayah);
            }
          };

        final tapRecognizer = TapGestureRecognizer()
          ..onTap = () {
            if (onAyahTap != null) {
              onAyahTap!(ayah);
            }
          };

        spans.add(
          TextSpan(
            text: '${word.text} ',
            recognizer: onAyahTap != null ? tapRecognizer : recognizer,
            style: TextStyle(
              fontFamily: 'DigitalKhatt',
              fontFamilyFallback: const ['AmiriQuran', 'Amiri'],
              fontSize: quranFontSize,
              color: textColor,
              backgroundColor: bgColor,
            ),
          ),
        );
      }
    }

    const baseTextStyle = TextStyle(
      fontFamily: 'DigitalKhatt',
      fontFamilyFallback: ['AmiriQuran', 'Amiri'],
      fontSize: quranFontSize,
      height: 1.4,
    );

    // If line is centered according to QUL layout: center align.
    if (line.isCentered) {
      return Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        maxLines: 1,
        softWrap: false,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        style: baseTextStyle,
      );
    }

    // If line is not centered: fully justified edge-to-edge matching Mushaf print.
    return LayoutBuilder(
      builder: (context, constraints) {
        double extraWordSpacing = 0.0;
        if (line.words.length > 1 && constraints.maxWidth.isFinite) {
          final tp = TextPainter(
            text: TextSpan(children: spans, style: baseTextStyle),
            textDirection: TextDirection.rtl,
            maxLines: 1,
          )..layout();

          final availableWidth = constraints.maxWidth;
          final naturalWidth = tp.width;
          if (availableWidth > naturalWidth) {
            extraWordSpacing =
                (availableWidth - naturalWidth) / (line.words.length - 1);
          }
        }

        return Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          softWrap: false,
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: baseTextStyle.copyWith(
            wordSpacing: extraWordSpacing > 0 ? extraWordSpacing : null,
          ),
        );
      },
    );
  }
}
