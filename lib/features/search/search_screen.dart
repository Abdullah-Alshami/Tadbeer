import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/quran/data/quran_repository.dart';
import 'search_provider.dart';

/// شاشة البحث الشامل والفوري بدون إنترنت عبر جميع أقسام تطبيق تدبير.
///
/// Instant, offline unified search across all searchable sections in Tadbeer.
///
/// Features:
/// - Extensible [SearchRegistry] querying all registered [SearchProvider]s concurrently.
/// - Section filter chips ("الكل", "المصحف", "الملاحظات", "التدبر", etc.).
/// - Graceful error isolation per provider.
/// - Deep linking and navigation into Quran pages, notes, links, and reminders.
/// - Direct Ayah selection support when [returnToCaller] is true.
class SearchScreen extends StatefulWidget {
  /// ما إذا كان يجب إرجاع الآية المختارة إلى الشاشة المستدعية بدلاً من فتح المصحف.
  final bool returnToCaller;

  /// ينشئ شاشة البحث الشامل.
  const SearchScreen({super.key, this.returnToCaller = false});

  /// ينشئ حالة شاشة البحث الشامل.
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/// الحالة الداخلية لشاشة البحث الشامل وإدارة التصفية وتنفيذ الاستعلامات.
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  String _currentQuery = '';
  String? _selectedProviderId;
  bool _isLoading = false;
  List<SearchResultItem> _results = [];

  /// يلغي مؤقت الانتظار ويحرر متحكم النص عند إغلاق الشاشة.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// يتعامل مع تغير نص البحث مع تأخير زمني قصير لمنع الاستعلامات المتكررة أثناء الكتابة.
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 180), () {
      _executeSearch(query);
    });
  }

  /// ينفذ عملية البحث في السجل المركزي ويحدث قائمة النتائج المعروضة.
  Future<void> _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed == _currentQuery && _results.isNotEmpty) return;

    setState(() {
      _currentQuery = trimmed;
    });

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await SearchRegistry.instance.searchAll(
      trimmed,
      context,
      providerId: _selectedProviderId,
    );

    if (!mounted) return;

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  /// يغير فلتر القسم المحدد ويعيد تنفيذ البحث عند وجود نص استعلام.
  void _onSelectFilter(String? providerId) {
    if (_selectedProviderId == providerId) return;
    setState(() {
      _selectedProviderId = providerId;
    });
    if (_currentQuery.isNotEmpty) {
      _executeSearch(_currentQuery);
    }
  }

  /// يعالج النقر على نتيجة البحث إما بإرجاع الآية للمستدعي أو فتح الوجهة المرتبطة.
  void _handleItemTap(SearchResultItem item) {
    if (widget.returnToCaller &&
        item.surahNumber != null &&
        item.ayahNumber != null) {
      final ayah = QuranRepository.instance.getAyah(
        item.surahNumber!,
        item.ayahNumber!,
      );
      if (ayah != null) {
        Navigator.pop(context, ayah);
        return;
      }
    }

    item.onTap?.call(context);
  }

  /// يبني واجهة شاشة البحث الشامل مع شرائح التصفية وقائمة النتائج.
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasQuery = _currentQuery.isNotEmpty;
    final providers = SearchRegistry.instance.providers;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.search,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchGlobalPlaceholder,
                  hintStyle: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: isDark
                        ? AppColors.nightSubtitle
                        : AppColors.daySubtitle,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.olive),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _controller.clear();
                            _executeSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Filter Chips Carousel
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  // "الكل" Filter Chip
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilterChip(
                      label: Text(
                        l10n.searchAll,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          fontWeight: _selectedProviderId == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: _selectedProviderId == null,
                      selectedColor: AppColors.olive.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.oliveDark,
                      onSelected: (_) => _onSelectFilter(null),
                    ),
                  ),

                  // Per-section filter chips
                  ...providers.map((p) {
                    final isSelected = _selectedProviderId == p.id;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(
                        avatar: Icon(
                          p.icon,
                          size: 16,
                          color: isSelected ? AppColors.oliveDark : null,
                        ),
                        label: Text(
                          p.getSectionTitle(context),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.olive.withValues(alpha: 0.25),
                        checkmarkColor: AppColors.oliveDark,
                        onSelected: (_) => _onSelectFilter(p.id),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const Divider(height: 1),

            // Search Content / Results Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.olive,
                        ),
                      ),
                    )
                  : !hasQuery
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 64,
                            color: AppColors.border(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.searchGlobalPlaceholder,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.nightSubtitle
                                  : AppColors.daySubtitle,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noSearchResults,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          color: isDark
                              ? AppColors.nightSubtitle
                              : AppColors.daySubtitle,
                        ),
                      ),
                    )
                  : _buildResultsList(context, isDark, providers),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني قائمة نتائج البحث مجمعة حسب القسم أو لقسم واحد محدد.
  Widget _buildResultsList(
    BuildContext context,
    bool isDark,
    List<SearchProvider> providers,
  ) {
    if (_selectedProviderId != null) {
      // Single section results
      final provider = providers.firstWhere(
        (p) => p.id == _selectedProviderId,
        orElse: () => providers.first,
      );

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGroupHeader(
            title: provider.getSectionTitle(context),
            count: _results.length,
            icon: provider.icon,
          ),
          const SizedBox(height: 10),
          ..._results.map(
            (item) => _buildResultCard(context, item, isDark),
          ),
        ],
      );
    }

    // Grouped results by provider
    final Map<String, List<SearchResultItem>> grouped = {};
    for (final item in _results) {
      grouped.putIfAbsent(item.providerId, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final provider in providers)
          if (grouped.containsKey(provider.id) &&
              grouped[provider.id]!.isNotEmpty) ...[
            _buildGroupHeader(
              title: provider.getSectionTitle(context),
              count: grouped[provider.id]!.length,
              icon: provider.icon,
            ),
            const SizedBox(height: 8),
            ...grouped[provider.id]!.map(
              (item) => _buildResultCard(context, item, isDark),
            ),
            const SizedBox(height: 16),
          ],
      ],
    );
  }

  /// يبني ترويسة مجموعة نتائج لقسم معين مع عداد النتائج.
  Widget _buildGroupHeader({
    required String title,
    required int count,
    IconData? icon,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            ArabicSearchNormalizer.toArabicDigits(count),
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  /// يبني بطاقة عرض لنتيجة بحث مفردة قابلة للنقر.
  Widget _buildResultCard(
    BuildContext context,
    SearchResultItem item,
    bool isDark,
  ) {
    final isQuranAyah = item.providerId == 'quran';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? AppColors.darkSurface : AppColors.comsilk,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleItemTap(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badge != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.badge!,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              if (item.snippet.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.snippet,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: isQuranAyah ? 'AmiriQuran' : 'Amiri',
                    fontSize: isQuranAyah ? 16 : 13,
                    height: isQuranAyah ? 1.8 : 1.4,
                    color: isDark
                        ? (isQuranAyah
                            ? AppColors.nightQuranText
                            : AppColors.darkTextSecondary)
                        : (isQuranAyah
                            ? AppColors.dayQuranText
                            : AppColors.lightTextSecondary),
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
