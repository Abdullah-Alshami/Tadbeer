import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../data/mushaf_layout_models.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import '../widgets/ayah_action_sheet.dart';
import '../../notes/note_editor_screen.dart';

/// Renders a single discrete Quran word token or Ayah end marker
/// strictly according to authentic Madinah Mushaf layout specifications.
class MushafWordWidget extends StatelessWidget {
  final MushafWord word;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;

  /// Fixed, standard Quran typography font size uniform across all 604 pages.
  static const double quranFontSize = 18.0;

  const MushafWordWidget({
    super.key,
    required this.word,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository.instance;
    final ayah = repo.getAyah(word.surah, word.ayah);
    if (ayah == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = UserDataStore.instance;

    // Handle end-of-ayah marker
    if (word.isAyahEnd) {
      return _buildAyahEndMarker(
        context: context,
        ayah: ayah,
        isDark: isDark,
        storage: storage,
      );
    }

    // Handle regular Quran word token
    return _buildWordToken(
      context: context,
      ayah: ayah,
      isDark: isDark,
      storage: storage,
    );
  }

  Widget _buildWordToken({
    required BuildContext context,
    required Ayah ayah,
    required bool isDark,
    required UserDataStore storage,
  }) {
    final isSelected = selectedAyah?.id == ayah.id;
    final highlight = storage.getHighlight(ayah.surahNumber, ayah.ayahNumber);

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = isDark
          ? AppColors.darkSelectedAyah
          : AppColors.lightSelectedAyah;
    } else if (highlight != null) {
      backgroundColor = AppColors.highlightColors[highlight.colorIndex];
    }

    final textColor = (isSelected && isDark)
        ? Colors.white
        : AppColors.mushafQuranText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onAyahTap != null) {
          onAyahTap!(ayah);
        } else {
          AyahActionSheet.show(context, ayah);
        }
      },
      onLongPress: () {
        if (onAyahLongPress != null) {
          onAyahLongPress!(ayah);
        } else {
          AyahActionSheet.show(context, ayah);
        }
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Text(
          word.text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontFamilyFallback: const ['DigitalKhatt', 'Amiri'],
            fontSize: quranFontSize,
            color: textColor,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahEndMarker({
    required BuildContext context,
    required Ayah ayah,
    required bool isDark,
    required UserDataStore storage,
  }) {
    final isBookmarked = storage.isBookmarked(
      ayah.surahNumber,
      ayah.ayahNumber,
    );
    final notes = storage.getNotesForAyah(ayah.surahNumber, ayah.ayahNumber);

    final ayahNumberText = ArabicSearchNormalizer.toArabicDigits(
      word.ayahNumber ?? ayah.ayahNumber,
    );

    final glyphColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentGold;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onAyahTap != null) {
          onAyahTap!(ayah);
        } else {
          AyahActionSheet.show(context, ayah);
        }
      },
      onLongPress: () {
        if (onAyahLongPress != null) {
          onAyahLongPress!(ayah);
        } else {
          AyahActionSheet.show(context, ayah);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bookmark indicator icon if bookmarked
          if (isBookmarked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Icon(Icons.bookmark, size: 11, color: AppColors.olive),
            ),

          // Note indicator icon if note exists
          if (notes.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorScreen(existingNote: notes.first),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: AppColors.olive.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 10,
                    color: isDark ? AppColors.oliveSoft : AppColors.olive,
                  ),
                ),
              ),
            ),

          // Authentic ornate Ayah end glyph ﴿١﴾
          Text(
            ' ﴿$ayahNumberText﴾ ',
            textDirection: TextDirection.rtl,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontFamilyFallback: const ['DigitalKhatt', 'Amiri'],
              fontSize: quranFontSize,
              fontWeight: FontWeight.bold,
              color: glyphColor,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
