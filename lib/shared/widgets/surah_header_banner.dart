import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/quran/quran_models.dart';

/// Decorative banner rendered at the beginning of each Surah in the Quran reader.
class SurahHeaderBanner extends StatelessWidget {
  final Surah surah;

  const SurahHeaderBanner({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.comsilk,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.olive.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Surah Type & Ayahs
          Text(
            '${surah.isMeccan ? "مكية" : "مدنية"} · ${ArabicSearchNormalizer.toArabicDigits(surah.ayahCount)} آيات',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.comsilk : AppColors.oliveDark,
            ),
          ),

          // Surah Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سُورَةُ ${surah.name}',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                ),
              ),
            ],
          ),

          // Surah Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.olive.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ArabicSearchNormalizer.toArabicDigits(surah.number),
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.comsilk : AppColors.oliveDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative Basmalah banner shown between Surahs (except Surah 1 & 9).
class BismillahBanner extends StatelessWidget {
  const BismillahBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 21,
            color: isDark ? AppColors.nightQuranText : AppColors.dayQuranText,
          ),
        ),
      ),
    );
  }
}
