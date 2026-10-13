import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import 'quran_duas_repository.dart';
import 'quran_duas_screen.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

/// الشاشة الرئيسية لقسم الأدعية والأذكار في تطبيق تدبير.
///
/// Main Hub Screen for the "الأدعية" (Duas) section in Tadbeer.
///
/// EDUCATIONAL NOTE:
/// Hierarchy & Organization:
/// الأدعية
/// ├── أدعية من القرآن (Fully implemented sub-section linking to 88 verified Quranic Duas)
/// └── الأقسام الإضافية (أدعية السنة، أذكار الصباح والمساء، جوامع الدعاء)
class DuasScreen extends StatelessWidget {
  /// ينشئ الشاشة الرئيسية للأدعية.
  const DuasScreen({super.key});

  /// يبني واجهة قسم الأدعية مع بطاقات التصنيفات الفرعية.
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalQuranDuas = QuranDuasRepository.instance.getDuas().length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          title: Text(
            l10n.duas,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Spiritual Ayah Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '﴿ وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ ﴾',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AmiriQuran',
                      fontSize: 18,
                      height: 1.8,
                      color: isDark
                          ? AppColors.darkAccentGold
                          : AppColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'سورة غافر · الآية ٦٠',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: "أدعية من القرآن" (Featured & Clickable Sub-section)
            _DuaCategoryCard(
              icon: FlutterIslamicIcons.quran,
              title: 'أدعية من القرآن',
              subtitle: 'أدعية الأنبياء والصالحين وخواتيم السور المأثورة في كتاب الله',
              countBadge:
                  '${ArabicSearchNormalizer.toArabicDigits(totalQuranDuas)} دعاء',
              isAvailable: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuranDuasScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Section 2: "أدعية من السنة النبوية"
            _DuaCategoryCard(
              icon: Icons.auto_awesome_outlined,
              title: 'أدعية من السنة النبوية',
              subtitle: 'أدعية مأثورة وصحيحة عن النبي ﷺ',
              countBadge: 'قريبًا بإذن الله',
              isAvailable: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    content: Text(
                      'أدعية السنة النبوية قيد الإعداد قريبًا بإذن الله',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Section 3: "أذكار الصباح والمساء"
            _DuaCategoryCard(
              icon: Icons.wb_sunny_outlined,
              title: 'أذكار الصباح والمساء',
              subtitle: 'حصن المسلم وأذكار اليوم والليلة',
              countBadge: 'قريبًا بإذن الله',
              isAvailable: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    content: Text(
                      'أذكار الصباح والمساء قيد الإعداد قريبًا بإذن الله',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Section 4: "جوامع الدعاء والرجاء"
            _DuaCategoryCard(
              icon: FlutterIslamicIcons.prayer,
              title: 'جوامع الدعاء والرجاء',
              subtitle: 'أدعية جامعة لخيري الدنيا والآخرة',
              countBadge: 'قريبًا بإذن الله',
              isAvailable: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    content: Text(
                      'جوامع الدعاء قيد الإعداد قريبًا بإذن الله',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة عرض قسم فرعي من أقسام الأدعية مع الأيقونة وشارة العدد.
class _DuaCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String countBadge;
  final bool isAvailable;
  final VoidCallback onTap;

  /// ينشئ بطاقة قسم الأدعية الفرعي.
  const _DuaCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.countBadge,
    required this.isAvailable,
    required this.onTap,
  });

  /// يبني واجهة بطاقة تصنيف الأدعية.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAvailable
                  ? (isDark
                        ? AppColors.darkAccentGold.withValues(alpha: 0.5)
                        : AppColors.lightAccentGold.withValues(alpha: 0.5))
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isAvailable ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? (isDark
                            ? AppColors.darkPrimary.withValues(alpha: 0.35)
                            : AppColors.lightPrimary.withValues(alpha: 0.12))
                      : (isDark
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 24,
                  color: isAvailable
                      ? (isDark
                            ? AppColors.darkAccentGold
                            : AppColors.lightPrimary)
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                ),
              ),

              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? (isDark
                                      ? AppColors.darkPrimary.withValues(
                                          alpha: 0.3,
                                        )
                                      : AppColors.lightPrimary.withValues(
                                          alpha: 0.08,
                                        ))
                                : (isDark ? Colors.black26 : Colors.black12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            countBadge,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? (isDark
                                        ? AppColors.darkAccentGold
                                        : AppColors.lightPrimary)
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow Forward Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isAvailable
                    ? (isDark
                          ? AppColors.darkAccentGold
                          : AppColors.lightPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                          : AppColors.lightTextSecondary.withValues(
                              alpha: 0.5,
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
