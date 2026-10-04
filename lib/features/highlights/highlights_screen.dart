import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/quran/quran_repository.dart';
import '../quran/quran_screen.dart';

/// Screen displaying all user-highlighted ayahs.
class HighlightsScreen extends StatelessWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.highlights,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: UserDataStore.instance,
          builder: (context, _) {
            final highlights = UserDataStore.instance.highlights;

            if (highlights.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : const Color(0xFFDDD7C8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noHighlightsYet,
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
              itemCount: highlights.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = highlights[index];
                final surah = QuranRepository.instance.getSurah(
                  item.surahNumber,
                );
                final ayah = QuranRepository.instance.getAyah(
                  item.surahNumber,
                  item.ayahNumber,
                );
                final color =
                    AppColors.highlightColors[item.colorIndex.clamp(
                      0,
                      AppColors.highlightColors.length - 1,
                    )];

                return InkWell(
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.oliveDark.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(item.ayahNumber)}',
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
                              if (ayah != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '﴿ ${ayah.text} ﴾',
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
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          tooltip: 'خيارات التمييز',
                          onSelected: (val) {
                            if (val == 'delete') {
                              UserDataStore.instance.removeHighlight(
                                item.surahNumber,
                                item.ayahNumber,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'إزالة التمييز',
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
              },
            );
          },
        ),
      ),
    );
  }
}
