import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../data/mushaf_layout_models.dart';
import '../data/qcf_font_manager.dart';
import '../data/quran_models.dart';
import '../data/quran_repository.dart';
import '../widgets/ayah_action_sheet.dart';
import '../../notes/note_editor_screen.dart';

/// Renders a single discrete Quran word token or Ayah end marker
/// strictly according to authentic Madinah Mushaf QCF V2 specifications.
class MushafWordWidget extends StatefulWidget {
  final MushafWord word;
  final Ayah? selectedAyah;
  final ValueChanged<Ayah>? onAyahTap;
  final ValueChanged<Ayah>? onAyahLongPress;
  final double? fontSize;

  /// Default Quran typography font size uniform across all 604 pages.
  static const double defaultQuranFontSize = 20.0;

  /// Backward-compatibility constant.
  static const double quranFontSize = defaultQuranFontSize;

  const MushafWordWidget({
    super.key,
    required this.word,
    this.selectedAyah,
    this.onAyahTap,
    this.onAyahLongPress,
    this.fontSize,
  });

  @override
  State<MushafWordWidget> createState() => _MushafWordWidgetState();
}

class _MushafWordWidgetState extends State<MushafWordWidget> {
  Timer? _longPressTimer;
  Offset? _downPosition;
  bool _longPressTriggered = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event, Ayah ayah) {
    _downPosition = event.position;
    _longPressTriggered = false;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _longPressTriggered = true;
      if (widget.onAyahLongPress != null) {
        widget.onAyahLongPress!(ayah);
      } else {
        AyahActionSheet.show(context, ayah);
      }
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_downPosition != null) {
      final delta = event.position - _downPosition!;
      if (delta.dx.abs() > 8.0 || delta.distance > 12.0) {
        _longPressTimer?.cancel();
        _longPressTimer = null;
      }
    }
  }

  void _onPointerUp(PointerUpEvent event, Ayah ayah) {
    final timerWasActive = _longPressTimer != null && _longPressTimer!.isActive;
    _longPressTimer?.cancel();
    _longPressTimer = null;

    if (!_longPressTriggered && timerWasActive) {
      final distance = _downPosition != null
          ? (event.position - _downPosition!).distance
          : 0.0;
      if (distance <= 12.0) {
        widget.onAyahTap?.call(ayah);
      }
    }
    _downPosition = null;
    _longPressTriggered = false;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _downPosition = null;
    _longPressTriggered = false;
  }

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository.instance;
    final ayah = repo.getAyah(widget.word.surah, widget.word.ayah);
    if (ayah == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = UserDataStore.instance;

    // Handle end-of-ayah marker
    if (widget.word.isAyahEnd) {
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
    final isSelected = widget.selectedAyah?.id == ayah.id;
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

    final displayText = widget.word.glyph.isNotEmpty
        ? widget.word.glyph
        : widget.word.text;
    final fontFamily = QcfFontManager.fontFamilyForPage(widget.word.pageNumber);
    final effectiveFontSize =
        widget.fontSize ?? MushafWordWidget.defaultQuranFontSize;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _onPointerDown(e, ayah),
      onPointerMove: _onPointerMove,
      onPointerUp: (e) => _onPointerUp(e, ayah),
      onPointerCancel: _onPointerCancel,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Text(
          displayText,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: effectiveFontSize,
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
      widget.word.ayahNumber ?? ayah.ayahNumber,
    );

    final glyphColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentGold;

    final displayRosette = widget.word.glyph.isNotEmpty
        ? widget.word.glyph
        : ' ﴿$ayahNumberText﴾ ';
    final fontFamily = QcfFontManager.fontFamilyForPage(widget.word.pageNumber);
    final effectiveFontSize =
        widget.fontSize ?? MushafWordWidget.defaultQuranFontSize;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _onPointerDown(e, ayah),
      onPointerMove: _onPointerMove,
      onPointerUp: (e) => _onPointerUp(e, ayah),
      onPointerCancel: _onPointerCancel,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Authentic QCF V2 Ayah end rosette glyph
          Text(
            displayRosette,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.normal,
              color: glyphColor,
              height: 1.25,
            ),
          ),

          // Bookmark indicator icon placed above rosette without adding line width
          if (isBookmarked)
            Positioned(
              top: -6,
              child: Icon(Icons.bookmark, size: 10, color: AppColors.olive),
            ),

          // Note indicator icon placed below rosette without adding line width
          if (notes.isNotEmpty)
            Positioned(
              bottom: -6,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteEditorScreen(existingNote: notes.first),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: AppColors.olive.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 9,
                    color: isDark ? AppColors.oliveSoft : AppColors.olive,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
