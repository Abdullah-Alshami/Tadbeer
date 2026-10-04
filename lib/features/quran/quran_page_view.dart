import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/quran/quran_models.dart';
import '../../data/quran/quran_repository.dart';
import '../../shared/widgets/ayah_action_sheet.dart';
import '../../shared/widgets/surah_header_banner.dart';
import '../notes/note_editor_screen.dart';

/// Renders a single standard 15-line Mushaf page (1..604).
///
/// EDUCATIONAL NOTE:
/// Quran Page Rendering Architecture:
/// 1. The 604 standard Madani Mushaf pages map deterministically to ayahs.
/// 2. Multiple surahs may appear on one page, or a surah may span multiple pages.
///    Ayahs are grouped by `surahNumber` on the page.
/// 3. If an ayah is ayah 1 of a surah, a decorative `SurahHeaderBanner` is rendered.
///    Except for Surah Al-Fatiha (1, where the Basmalah is ayah 1 itself) and
///    Surah At-Tawbah (9, which has no Basmalah), a `BismillahBanner` is rendered.
/// 4. Page-based non-scrolling layout: each page scales down gracefully via [FittedBox]
///    to always fit the viewport without any vertical scrolling.
/// 5. Highlights (temporary or saved) apply ONLY to the verse text; the end-of-ayah
///    symbol remains unhighlighted outside the highlight background.
/// 6. Ayahs with saved Tadabbur notes display a subtle note indicator icon.
class QuranPageView extends StatelessWidget {
  final QuranPage page;
  final double fontSize;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;

  const QuranPageView({
    super.key,
    required this.page,
    this.fontSize = 23.0,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = UserDataStore.instance;

    // Group ayahs on this page by surahNumber
    final surahGroups = <int, List<Ayah>>{};
    for (final ayah in page.ayahs) {
      surahGroups.putIfAbsent(ayah.surahNumber, () => []).add(ayah);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: isDark ? AppColors.darkBackground : AppColors.comsilkLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Top Header Info
              _buildPageHeader(context, isDark),
              const SizedBox(height: 6),

              // Page Content: Fully page-based, strictly NO vertical scrolling!
              // Scales down gracefully to fit available screen height without clipping.
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: constraints.maxWidth > 32
                          ? constraints.maxWidth - 32
                          : constraints.maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: surahGroups.entries.map((entry) {
                          final surahNum = entry.key;
                          final ayahs = entry.value;
                          final surah = QuranRepository.instance.getSurah(
                            surahNum,
                          );
                          final startsOnThisPage = ayahs.first.ayahNumber == 1;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (startsOnThisPage) ...[
                                SurahHeaderBanner(surah: surah),
                                if (surahNum != 1 && surahNum != 9)
                                  const BismillahBanner(),
                              ],
                              _buildVersesRichText(
                                context: context,
                                ayahs: ayahs,
                                isDark: isDark,
                                storage: storage,
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              // Page Bottom Footer (Page Number)
              _buildPageFooter(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDark) {
    final firstSurah = QuranRepository.instance.getSurah(
      page.surahNumbers.first,
    );
    final lastSurah = QuranRepository.instance.getSurah(page.surahNumbers.last);

    final surahTitle = page.surahNumbers.length == 1
        ? 'سُورَةُ ${firstSurah.name}'
        : 'سُورَةُ ${firstSurah.name} - ${lastSurah.name}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            surahTitle,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.comsilk : AppColors.oliveDark,
            ),
          ),
          Text(
            'الجزء ${ArabicSearchNormalizer.toArabicDigits(page.juzNumber)} · الحزب ${ArabicSearchNormalizer.toArabicDigits(page.hizbNumber)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.nightSubtitle : AppColors.daySubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          ArabicSearchNormalizer.toArabicDigits(page.pageNumber),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.comsilk : AppColors.oliveDark,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesRichText({
    required BuildContext context,
    required List<Ayah> ayahs,
    required bool isDark,
    required UserDataStore storage,
  }) {
    final textColor = isDark
        ? AppColors.nightQuranText
        : AppColors.dayQuranText;
    final spans = <InlineSpan>[];

    for (final ayah in ayahs) {
      final isBookmarked = storage.isBookmarked(
        ayah.surahNumber,
        ayah.ayahNumber,
      );
      final highlight = storage.getHighlight(ayah.surahNumber, ayah.ayahNumber);
      final isSelected = selectedAyah?.id == ayah.id;
      final notes = storage.getNotesForAyah(ayah.surahNumber, ayah.ayahNumber);

      Color? bgColor;
      if (isSelected) {
        bgColor = isDark ? AppColors.selectionDark : AppColors.selectionLight;
      } else if (highlight != null) {
        bgColor = AppColors.highlightColors[highlight.colorIndex];
      }

      // Gesture recognizers for tap and long-press
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

      // 1. Ayah Text Span (highlight background applies ONLY to the Quran text)
      spans.add(
        TextSpan(
          text: ayah.text,
          recognizer: recognizer,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: fontSize,
            height: 2.1,
            color: textColor,
            backgroundColor: bgColor,
          ),
        ),
      );

      // 2. Note indicator (if a reflection note is linked to this ayah)
      if (notes.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorScreen(existingNote: notes.first),
                  ),
                );
              },
              child: Tooltip(
                message:
                    'ملاحظة تدبرية: ${notes.first.title ?? "عرض الملاحظة"}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.olive.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: 13,
                      color: isDark ? AppColors.oliveSoft : AppColors.olive,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // 3. Bookmark small indicator if bookmarked
      if (isBookmarked) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => AyahActionSheet.show(context, ayah),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.bookmark, size: 14, color: AppColors.olive),
              ),
            ),
          ),
        );
      }

      // 4. Verse end sign with Arabic number (highlight background is NOT applied here)
      spans.add(
        TextSpan(
          text: ' ﴿${ArabicSearchNormalizer.toArabicDigits(ayah.ayahNumber)}﴾ ',
          recognizer: tapRecognizer,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: fontSize * 0.88,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.comsilk : AppColors.oliveDark,
            // backgroundColor is intentionally omitted so the ayah number stays unhighlighted
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(children: spans),
      ),
    );
  }
}

/// Backward compatibility alias for QuranPageView
typedef QuranPageWidget = QuranPageView;
