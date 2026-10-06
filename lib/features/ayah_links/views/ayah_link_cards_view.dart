import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../ayah_link_model.dart';
import '../ayah_link_repository.dart';
import '../../quran/data/quran_repository.dart';
import '../../quran/screens/quran_screen.dart';

/// Cards View presenting each linked verse in an elegant, mobile-friendly card.
class AyahLinkCardsView extends StatelessWidget {
  final AyahLinkItem link;
  final VoidCallback onAddVerse;

  const AyahLinkCardsView({
    super.key,
    required this.link,
    required this.onAddVerse,
  });

  Future<void> _editNote(
    BuildContext context,
    AyahLinkVerse verse,
    bool isDark,
  ) async {
    final controller = TextEditingController(text: verse.note ?? '');
    final updatedNote = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,
        title: const Text('ملاحظة التدبر على الآية'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'سجل تأملك أو وجه الارتباط في هذه الآية...',
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (updatedNote != null) {
      await AyahLinkRepository().updateVerseNote(
        link.id,
        verse.surahNumber,
        verse.ayahNumber,
        updatedNote.isEmpty ? null : updatedNote,
      );
    }
  }

  Future<void> _confirmRemove(BuildContext context, AyahLinkVerse verse) async {
    final surah = QuranRepository.instance.getSurah(verse.surahNumber);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إزالة الآية من الرابط'),
        content: Text(
          'هل تريد إزالة الآية ${verse.ayahNumber} من سورة ${surah.name} من هذا الرابط؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AyahLinkRepository().removeVerseFromLink(
        link.id,
        verse.surahNumber,
        verse.ayahNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verses = link.verses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: verses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_agenda_outlined,
                    size: 44,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لم تتم إضافة أي آيات لهذا الرابط بعد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: onAddVerse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة آية'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: verses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final verse = verses[index];
                final surah = QuranRepository.instance.getSurah(
                  verse.surahNumber,
                );
                final ayah = QuranRepository.instance.getAyah(
                  verse.surahNumber,
                  verse.ayahNumber,
                );
                final effectiveNote = verse.getEffectiveNote();
                final hasNote =
                    effectiveNote != null && effectiveNote.isNotEmpty;
                final fontSize =
                    UserDataStore.instance.settings.ayahLinkFontSize;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Top Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(verse.ayahNumber)}',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ص ${ArabicSearchNormalizer.toArabicDigits(verse.page)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.nightSubtitle
                                        : AppColors.daySubtitle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onSelected: (val) {
                                    if (val == 'quran') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QuranScreen(
                                            initialPage: verse.page,
                                            targetSurahNumber:
                                                verse.surahNumber,
                                            targetAyahNumber: verse.ayahNumber,
                                          ),
                                        ),
                                      );
                                    } else if (val == 'note') {
                                      _editNote(context, verse, isDark);
                                    } else if (val == 'delete') {
                                      _confirmRemove(context, verse);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'quran',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text('فتح في المصحف'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'note',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text('تعديل الملاحظة'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'إزالة من الرابط',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Verse Content Box
                      if (ayah != null)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuranScreen(
                                  initialPage: verse.page,
                                  targetSurahNumber: verse.surahNumber,
                                  targetAyahNumber: verse.ayahNumber,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text(
                              '﴿ ${ayah.text} ﴾',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: fontSize,
                                height: 1.8,
                                color: isDark
                                    ? AppColors.nightQuranText
                                    : AppColors.dayQuranText,
                              ),
                            ),
                          ),
                        ),

                      // Note or Add Note Prompt
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: hasNote
                            ? Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      _editNote(context, verse, isDark),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.sticky_note_2_outlined,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          effectiveNote,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.5,
                                            color: isDark
                                                ? AppColors.nightSubtitle
                                                : AppColors.daySubtitle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: () =>
                                    _editNote(context, verse, isDark),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.border(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.edit_note,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                label: Text(
                                  'إضافة تدبر أو ملاحظة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
