import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/notes/note_model.dart';
import '../../data/quran/quran_models.dart';
import '../../data/quran/quran_repository.dart';
import '../../features/ayah_links/widgets/ayah_link_picker_dialog.dart';
import '../../features/quran/widgets/tadbeer_pause_sheet.dart';

/// Modal action sheet for interacting with an individual Ayah.
///
/// EDUCATIONAL NOTE:
/// Offers quick actions:
/// 1. Tadbeer reflection note (linked to this ayah via stable ID)
/// 2. Bookmark toggle (pinning verse for recitation)
/// 3. Color highlight (4 calm, non-distracting colors)
/// 4. Copying authentic Quranic verse with reference
class AyahActionSheet extends StatefulWidget {
  final Ayah ayah;

  const AyahActionSheet({super.key, required this.ayah});

  /// Displays the Ayah action sheet as a calm modal dialog with backdrop blur.
  static Future<void> show(BuildContext context, Ayah ayah) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) => AyahActionSheet(ayah: ayah),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 3 * anim1.value,
            sigmaY: 3 * anim1.value,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AyahActionSheet> createState() => _AyahActionSheetState();
}

/// Backward compatibility alias for AyahActionSheet
typedef AyahActionDialog = AyahActionSheet;

class _AyahActionSheetState extends State<AyahActionSheet> {
  bool _isNoteEditorOpen = false;
  bool _isHighlightPickerOpen = false;
  late TextEditingController _noteController;
  String? _existingNoteId;

  @override
  void initState() {
    super.initState();
    final existingNotes = UserDataStore.instance.getNotesForAyah(
      widget.ayah.surahNumber,
      widget.ayah.ayahNumber,
    );
    if (existingNotes.isNotEmpty) {
      _existingNoteId = existingNotes.first.id;
      _noteController = TextEditingController(
        text: existingNotes.first.content,
      );
    } else {
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty && _existingNoteId != null) {
      await UserDataStore.instance.deleteNote(_existingNoteId!);
    } else if (text.isNotEmpty) {
      await UserDataStore.instance.saveNote(
        id: _existingNoteId,
        type: NoteType.ayah,
        content: text,
        ayahId: widget.ayah.id,
        surahNumber: widget.ayah.surahNumber,
        ayahNumber: widget.ayah.ayahNumber,
        page: widget.ayah.page,
        ayahText: widget.ayah.text,
      );
    }
    if (mounted) {
      setState(() => _isNoteEditorOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surah = QuranRepository.instance.getSurah(widget.ayah.surahNumber);
    final storage = UserDataStore.instance;
    final isBookmarked = storage.isBookmarked(
      widget.ayah.surahNumber,
      widget.ayah.ayahNumber,
    );
    final currentHighlight = storage.getHighlight(
      widget.ayah.surahNumber,
      widget.ayah.ayahNumber,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width.clamp(300.0, 520.0),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.comsilkLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : const Color(0xFFDED8CA),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Surah and Ayah reference
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(widget.ayah.ayahNumber)}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                      ),
                    ),
                    Text(
                      'ص ${ArabicSearchNormalizer.toArabicDigits(widget.ayah.page)} · ج ${ArabicSearchNormalizer.toArabicDigits(widget.ayah.juz)}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                  ],
                ),
              ),

              // Selected Ayah text preview
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '﴿ ${widget.ayah.text} ﴾',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 19,
                      height: 1.8,
                      color: isDark
                          ? AppColors.nightQuranText
                          : AppColors.dayQuranText,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Note Editor Mode
              if (_isNoteEditorOpen) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.ayahNoteLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.oliveSoft : AppColors.olive,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark
                              ? AppColors.nightQuranText
                              : AppColors.dayQuranText,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.noteContent,
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.comsilk,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : const Color(0xFFDDD7C8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.olive,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _isNoteEditorOpen = false),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.nightSubtitle
                                    : AppColors.daySubtitle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _saveNote();
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.olive,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 16),
                            label: Text(
                              l10n.save,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (_isHighlightPickerOpen) ...[
                // Highlight Color Picker Mode
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          AppColors.highlightColors.length,
                          (index) {
                            final color = AppColors.highlightColors[index];
                            final isSelected =
                                currentHighlight?.colorIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await storage.setHighlight(
                                    widget.ayah,
                                    index,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.oliveDark
                                          : Colors.transparent,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: AppColors.oliveDark,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (currentHighlight != null) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () async {
                            await storage.removeHighlight(
                              widget.ayah.surahNumber,
                              widget.ayah.ayahNumber,
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          label: Text(
                            l10n.removeHighlight,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                // Main Actions Row: Tadbeer Pause, Ayah Links, Note, Bookmark, Highlight, Copy
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Tadbeer Pause action
                        _ActionButton(
                          icon: Icons.spa_outlined,
                          label: 'وقفة تدبر',
                          hasActiveIndicator:
                              storage.getTadbeer(
                                widget.ayah.surahNumber,
                                widget.ayah.ayahNumber,
                              ) !=
                              null,
                          onTap: () {
                            Navigator.of(context).pop();
                            TadbeerPauseSheet.show(context, widget.ayah);
                          },
                        ),

                        // Ayah Links action
                        _ActionButton(
                          icon: Icons.hub_outlined,
                          label: 'رابط آيات',
                          onTap: () {
                            Navigator.of(context).pop();
                            AyahLinkPickerDialog.show(context, widget.ayah);
                          },
                        ),

                        // Note action
                        _ActionButton(
                          icon: Icons.edit_note,
                          label: l10n.addNote,
                          onTap: () => setState(() => _isNoteEditorOpen = true),
                          hasActiveIndicator: _existingNoteId != null,
                        ),

                        // Bookmark action
                        _ActionButton(
                          icon: isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          label: isBookmarked
                              ? l10n.removeBookmark
                              : l10n.saveBookmark,
                          iconColor: isBookmarked ? AppColors.olive : null,
                          onTap: () async {
                            await storage.toggleBookmark(widget.ayah);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        ),

                        // Highlight action
                        _ActionButton(
                          icon: Icons.palette_outlined,
                          label: l10n.highlight,
                          iconColor: currentHighlight != null
                              ? AppColors.highlightColors[currentHighlight
                                    .colorIndex]
                              : null,
                          onTap: () =>
                              setState(() => _isHighlightPickerOpen = true),
                        ),

                        // Copy action
                        _ActionButton(
                          icon: Icons.copy,
                          label: l10n.copy,
                          onTap: () {
                            final shareText =
                                '﴿${widget.ayah.text}﴾ [سورة ${surah.name}: ${widget.ayah.ayahNumber}]';
                            Clipboard.setData(ClipboardData(text: shareText));
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.copiedToClipboard,
                                  textAlign: TextAlign.center,
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool hasActiveIndicator;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.hasActiveIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        iconColor ?? (isDark ? AppColors.comsilk : AppColors.oliveDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      hoverColor: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.oliveVeryLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (hasActiveIndicator)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.olive,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.nightQuranText
                    : AppColors.dayQuranText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
