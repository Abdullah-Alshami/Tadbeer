import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/quran/data/quran_repository.dart';
import '../ayah_links/ayah_links_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../highlights/highlights_screen.dart';
import '../notes/notes_screen.dart';
import '../quran/screens/quran_screen.dart';
import '../search/search_screen.dart';
import '../../shared/widgets/app_drawer.dart';

/// Minimal home dashboard for Tadbeer.
///
/// EDUCATIONAL NOTE:
/// Minimalist layout focusing on uninterrupted Quran access:
/// 1. Top Reading Position Banner allows 1-tap resumption of recitation.
/// 2. 5 Primary Navigation Tiles: Quran (المصحف), Notes (الملاحظات),
///    Bookmarks (المحفوظات), Highlights (المميزة), and Search (البحث).
/// 3. All counters reactively update through [UserDataStore].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = QuranRepository.instance;

    return Directionality(
      textDirection: context.currentLanguage.direction,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'القائمة الجانبية',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(
            l10n.appName,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reading Position Banner
                    ListenableBuilder(
                      listenable: UserDataStore.instance,
                      builder: (context, _) {
                        final pos = UserDataStore.instance.readingPosition;
                        final surah = repo.isLoaded
                            ? repo.getSurah(pos.surahNumber)
                            : null;
                        final hasPosition =
                            pos.page > 1 ||
                            pos.surahNumber > 1 ||
                            pos.ayahNumber > 1;

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.comsilk,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bookmark_added,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.lastReading,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (hasPosition && surah != null)
                                    ? l10n.surahAndPage(surah.name, pos.page)
                                    : l10n.startFromBeginning,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.nightQuranText
                                      : AppColors.dayQuranText,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          QuranScreen(initialPage: pos.page),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.menu_book),
                                label: Text(
                                  hasPosition ? 'متابعة القراءة' : l10n.quran,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Section Title
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Main 5 Navigation Tiles (المصحف، الملاحظات، المحفوظات، المميزة، البحث)
                    _HomeNavigationCard(
                      icon: Icons.menu_book_rounded,
                      title: l10n.quran,
                      subtitle: 'تصفح وقراءة المصحف الشريف كاملاً برواية حفص',
                      onTap: () {
                        final pos = UserDataStore.instance.readingPosition;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuranScreen(initialPage: pos.page),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _HomeNavigationCard(
                      icon: Icons.edit_note_rounded,
                      title: l10n.notes,
                      subtitle: 'ملاحظاتك وتدبراتك على الآيات',
                      trailingCount: UserDataStore.instance.notes.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotesScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _HomeNavigationCard(
                      icon: Icons.bookmark_rounded,
                      title: l10n.bookmarks,
                      subtitle: 'الآيات المحفوظة للرجوع السريع',
                      trailingCount: UserDataStore.instance.bookmarks.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookmarksScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _HomeNavigationCard(
                      icon: Icons.palette_outlined,
                      title: l10n.highlights,
                      subtitle: 'الآيات المميزة بألوان التدبر الهادئة',
                      trailingCount: UserDataStore.instance.highlights.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HighlightsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _HomeNavigationCard(
                      icon: Icons.hub_outlined,
                      title: l10n.ayahLinks,
                      subtitle:
                          'خريطة شخصية لربط الآيات واستكشاف العلاقات التدبرية',
                      trailingCount: UserDataStore.instance.ayahLinks.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AyahLinksScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _HomeNavigationCard(
                      icon: Icons.search_rounded,
                      title: l10n.search,
                      subtitle: 'بحث حي وفوري في القرآن الكريم والملاحظات',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeNavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? trailingCount;
  final VoidCallback onTap;

  const _HomeNavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.comsilk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.08),
        splashColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.nightQuranText
                            : AppColors.dayQuranText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingCount != null && trailingCount! > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ArabicSearchNormalizer.toArabicDigits(trailingCount!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
