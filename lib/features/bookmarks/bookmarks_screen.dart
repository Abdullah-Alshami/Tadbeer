import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/bookmarks/bookmark_model.dart';
import '../../data/quran/quran_repository.dart';
import '../quran/quran_screen.dart';

/// Screen listing all bookmarked ayahs for quick recitation navigation.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.bookmarks,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            final bookmarks = UserDataStore.instance.bookmarks;

            if (bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : const Color(0xFFDDD7C8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noBookmarksYet,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = bookmarks[index];
                final surah = QuranRepository.instance.getSurah(
                  item.surahNumber,
                );
                final ayah = QuranRepository.instance.getAyah(
                  item.surahNumber,
                  item.ayahNumber,
                );

                return _BookmarkTile(
                  item: item,
                  surahName: surah.name,
                  ayahText: ayah?.text ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuranScreen(
                          initialPage: item.page,
                          targetSurahNumber: item.surahNumber,
                          targetAyahNumber: item.ayahNumber,
                        ),
                      ),
                    );
                  },
                  onDelete: () =>
                      UserDataStore.instance.removeBookmark(item.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final BookmarkItem item;
  final String surahName;
  final String ayahText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkTile({
    required this.item,
    required this.surahName,
    required this.ayahText,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.comsilk,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.bookmark, color: AppColors.olive, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سورة $surahName · الآية ${ArabicSearchNormalizer.toArabicDigits(item.ayahNumber)}',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.comsilk
                              : AppColors.oliveDark,
                        ),
                      ),
                      Text(
                        'ص ${ArabicSearchNormalizer.toArabicDigits(item.page)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.olive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (ayahText.isNotEmpty)
                    Text(
                      '﴿ $ayahText ﴾',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.nightQuranText
                            : AppColors.dayQuranText,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (val) {
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'إزالة الحفظ',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
