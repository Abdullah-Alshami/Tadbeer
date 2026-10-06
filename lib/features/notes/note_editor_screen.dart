import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../core/utils/note_pdf_exporter.dart';
import '../../data/notes/note_model.dart';
import '../../data/quran/quran_repository.dart';

/// Full-screen, comfortable Arabic note editor for long-form tadbeer reflections.
class NoteEditorScreen extends StatefulWidget {
  final NoteItem? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int _charCount = 0;
  int _wordCount = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );

    _updateCounts(_contentController.text);
    _contentController.addListener(() {
      _updateCounts(_contentController.text);
    });
  }

  void _updateCounts(String text) {
    final trimmed = text.trim();
    final words = trimmed.isEmpty
        ? 0
        : trimmed.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    setState(() {
      _charCount = text.length;
      _wordCount = words;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن حفظ ملاحظة فارغة',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final existing = widget.existingNote;
      if (existing != null && existing.isAyahNote) {
        await UserDataStore.instance.saveNote(
          id: existing.id,
          type: NoteType.ayah,
          content: content,
          title: _titleController.text.trim(),
          ayahId: existing.ayahId,
          surahNumber: existing.surahNumber,
          ayahNumber: existing.ayahNumber,
          page: existing.page,
          ayahText: existing.ayahText,
        );
      } else {
        await UserDataStore.instance.saveNote(
          id: existing?.id,
          type: NoteType.free,
          title: _titleController.text.trim(),
          content: content,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _exportPdf() async {
    final note =
        widget.existingNote ??
        NoteItem(
          id: 'preview',
          type: NoteType.free,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    try {
      await NotePdfExporter.exportAndShareNote(note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر تصدير الملاحظة: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final existing = widget.existingNote;
    final isAyahNote = existing?.isAyahNote == true;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            existing == null
                ? l10n.newFreeNote
                : (isAyahNote ? 'تعديل تدبر الآية' : 'تعديل الملاحظة'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_contentController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: l10n.exportPdf,
                onPressed: _exportPdf,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveNote,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(l10n.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.olive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(60, 36),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Linked Ayah Banner (for Ayah reflection notes)
                      if (isAyahNote && existing?.ayahText != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.comsilk,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.olive.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (existing!.surahNumber != null &&
                                  existing.ayahNumber != null) ...[
                                Builder(
                                  builder: (ctx) {
                                    final surah = QuranRepository.instance
                                        .getSurah(existing.surahNumber!);
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(existing.ayahNumber!)}',
                                          style: TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.comsilk
                                                : AppColors.oliveDark,
                                          ),
                                        ),
                                        Text(
                                          'ص ${ArabicSearchNormalizer.toArabicDigits(existing.page ?? 1)}',
                                          style: const TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.olive,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                '﴿ ${existing.ayahText} ﴾',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: 17,
                                  height: 1.8,
                                  color: isDark
                                      ? AppColors.nightQuranText
                                      : AppColors.dayQuranText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Note Title Field
                      TextField(
                        controller: _titleController,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: isAyahNote
                              ? 'عنوان التدبر (اختياري)...'
                              : l10n.noteTitle,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.comsilk,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightBorder,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Large comfortable editing area
                      TextField(
                        controller: _contentController,
                        minLines: 12,
                        maxLines: null,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.65,
                          color: isDark
                              ? AppColors.nightQuranText
                              : AppColors.dayQuranText,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.noteContent,
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.nightSubtitle
                                : AppColors.daySubtitle,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.comsilk,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                ),
              ),

              // Bottom status bar with word & character counts
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ArabicSearchNormalizer.toArabicDigits(_wordCount)} كلمة · ${ArabicSearchNormalizer.toArabicDigits(_charCount)} حرف',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                    Text(
                      'حفظ محلي فوري وآمن',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
