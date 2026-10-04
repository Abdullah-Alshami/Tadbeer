import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../data/quran/quran_repository.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../highlights/highlights_screen.dart';
import '../notes/notes_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

/// Side drawer menu providing direct jump navigation across Surahs and Juzs,
/// as well as fast access to Home, Settings, Notes, Bookmarks, and Search.
class QuranSideMenu extends StatefulWidget {
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  const QuranSideMenu({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  State<QuranSideMenu> createState() => _QuranSideMenuState();
}

class _QuranSideMenuState extends State<QuranSideMenu>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = QuranRepository.instance;
    final savedPosition = UserDataStore.instance.readingPosition;
    final savedSurah = repo.getSurah(savedPosition.surahNumber);

    return Drawer(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.comsilkLight,
      child: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Drawer Header
            _buildDrawerHeader(context, isDark, l10n),

            // Top Saved Reading Position Bar
            _buildReadingPositionBar(
              context,
              isDark,
              l10n,
              savedSurah,
              savedPosition,
            ),

            // Tab bar: Surahs / Juzs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightBorder,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.nightSubtitle
                    : AppColors.daySubtitle,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.olive,
                  borderRadius: BorderRadius.circular(10),
                ),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: l10n.surahs),
                  Tab(text: l10n.juzs),
                ],
              ),
            ),

            // Search filter for surahs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _filter = val.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث في السور...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.nightSubtitle
                        : AppColors.daySubtitle,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.olive,
                  ),
                  suffixIcon: _filter.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _filter = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSurahsList(context, repo, isDark),
                  _buildJuzsList(context, repo, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    bool isDark,
    AppStrings l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.comsilk,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.olive.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.olive,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                      ),
                    ),
                    Text(
                      'مصحف وتدبّر بدون إنترنت',
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
              // Home Button
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: l10n.home,
                color: AppColors.olive,
                onPressed: () => _navigateToHome(context),
              ),
              // Settings Button
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.settings,
                color: AppColors.olive,
                onPressed: () => _navigateToSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick navigation pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionChip(
                  icon: Icons.edit_note,
                  label: l10n.notes,
                  isDark: isDark,
                  onTap: () => _navigateToScreen(context, const NotesScreen()),
                ),
                const SizedBox(width: 6),
                _buildQuickActionChip(
                  icon: Icons.bookmark_outline,
                  label: l10n.bookmarks,
                  isDark: isDark,
                  onTap: () =>
                      _navigateToScreen(context, const BookmarksScreen()),
                ),
                const SizedBox(width: 6),
                _buildQuickActionChip(
                  icon: Icons.palette_outlined,
                  label: l10n.highlights,
                  isDark: isDark,
                  onTap: () =>
                      _navigateToScreen(context, const HighlightsScreen()),
                ),
                const SizedBox(width: 6),
                _buildQuickActionChip(
                  icon: Icons.search,
                  label: l10n.search,
                  isDark: isDark,
                  onTap: () => _navigateToScreen(context, const SearchScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.comsilkLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.olive),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
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

  Widget _buildReadingPositionBar(
    BuildContext context,
    bool isDark,
    AppStrings l10n,
    dynamic savedSurah,
    dynamic savedPosition,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.comsilk,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.olive.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added, color: AppColors.olive, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lastReading,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.nightSubtitle
                        : AppColors.daySubtitle,
                  ),
                ),
                Text(
                  l10n.surahAndPage(savedSurah.name, savedPosition.page),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPageSelected(savedPosition.page);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.olive,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(40, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.go,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahsList(
    BuildContext context,
    QuranRepository repo,
    bool isDark,
  ) {
    final filteredSurahs = repo.surahs.where((s) {
      if (_filter.isEmpty) return true;
      final query = ArabicSearchNormalizer.normalize(_filter);
      final normName = ArabicSearchNormalizer.normalize(s.name);
      return normName.contains(query) || s.number.toString() == _filter;
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filteredSurahs.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
      ),
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        final isCurrent =
            widget.currentPage >= surah.pageStart &&
            widget.currentPage <= surah.pageEnd;

        return ListTile(
          dense: true,
          selected: isCurrent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          selectedTileColor: AppColors.olive.withValues(alpha: 0.12),
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.olive
                  : (isDark ? AppColors.darkSurface : AppColors.comsilk),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? AppColors.olive
                    : AppColors.olive.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              ArabicSearchNormalizer.toArabicDigits(surah.number),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isCurrent
                    ? Colors.white
                    : (isDark ? AppColors.comsilk : AppColors.oliveDark),
              ),
            ),
          ),
          title: Text(
            surah.name,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.nightQuranText : AppColors.dayQuranText,
            ),
          ),
          subtitle: Text(
            '${surah.isMeccan ? "مكية" : "مدنية"} · ${ArabicSearchNormalizer.toArabicDigits(surah.ayahCount)} آية',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.nightSubtitle : AppColors.daySubtitle,
            ),
          ),
          trailing: Text(
            'ص ${ArabicSearchNormalizer.toArabicDigits(surah.pageStart)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.olive,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            widget.onPageSelected(surah.pageStart);
          },
        );
      },
    );
  }

  Widget _buildJuzsList(
    BuildContext context,
    QuranRepository repo,
    bool isDark,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: 30,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
      ),
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final startPage = repo.pages.firstWhere(
          (p) => p.juzNumber == juzNum,
          orElse: () => repo.pages.first,
        );

        final firstAyah = startPage.ayahs.first;
        final surah = repo.getSurah(firstAyah.surahNumber);
        final isCurrent = repo.getPage(widget.currentPage).juzNumber == juzNum;

        return ListTile(
          dense: true,
          selected: isCurrent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          selectedTileColor: AppColors.olive.withValues(alpha: 0.12),
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.olive
                  : (isDark ? AppColors.darkSurface : AppColors.comsilk),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? AppColors.olive
                    : AppColors.olive.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              ArabicSearchNormalizer.toArabicDigits(juzNum),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isCurrent
                    ? Colors.white
                    : (isDark ? AppColors.comsilk : AppColors.oliveDark),
              ),
            ),
          ),
          title: Text(
            'الجزء ${ArabicSearchNormalizer.toArabicDigits(juzNum)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.nightQuranText : AppColors.dayQuranText,
            ),
          ),
          subtitle: Text(
            'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(firstAyah.ayahNumber)}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.nightSubtitle : AppColors.daySubtitle,
            ),
          ),
          trailing: Text(
            'ص ${ArabicSearchNormalizer.toArabicDigits(startPage.pageNumber)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.olive,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            widget.onPageSelected(startPage.pageNumber);
          },
        );
      },
    );
  }
}
