import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../../../data/ayah_links/ayah_link_model.dart';
import '../../../data/ayah_links/ayah_link_repository.dart';
import '../../../data/quran/quran_repository.dart';
import '../../quran/quran_screen.dart';

/// Calm, serene ordered list view of an Ayah Link.
///
/// Designed for peaceful reading and linear recitation of connected verses.
class AyahLinkOrderedView extends StatelessWidget {
  final AyahLinkItem link;
  final VoidCallback onAddVerse;

  const AyahLinkOrderedView({
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
            hintText: 'اكتب تدبرك أو وجه الارتباط...',
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
              backgroundColor: AppColors.olive,
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
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Card (Title & Description)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.comsilk,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: AppColors.olive,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        link.title,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.comsilk
                              : AppColors.oliveDark,
                        ),
                      ),
                    ),
                  ],
                ),
                if (link.description != null &&
                    link.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    link.description!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? AppColors.nightSubtitle
                          : AppColors.daySubtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Verses Stream
          if (verses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 44,
                      color: AppColors.olive,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لم تتم إضافة أي آيات لهذا الرابط بعد',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: onAddVerse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.olive,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة آية'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(verses.length, (index) {
              final verse = verses[index];
              final surah = QuranRepository.instance.getSurah(
                verse.surahNumber,
              );
              final ayah = QuranRepository.instance.getAyah(
                verse.surahNumber,
                verse.ayahNumber,
              );
              final effectiveNote = verse.getEffectiveNote();
              final hasNote = effectiveNote != null && effectiveNote.isNotEmpty;
              final fontSize = UserDataStore.instance.settings.ayahLinkFontSize;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.comsilkLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Header: Order Number, Surah info, Actions menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.olive.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  ArabicSearchNormalizer.toArabicDigits(
                                    index + 1,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.olive,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(verse.ayahNumber)}',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.olive,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (val) {
                            if (val == 'quran') {
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
                                  Icon(Icons.menu_book_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('فتح في المصحف'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'note',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 18),
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
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Verse Text
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

                    // Reflection note (if any)
                    if (hasNote) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.olive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.olive.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16,
                              color: AppColors.olive,
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
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
