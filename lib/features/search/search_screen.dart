import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/notes/note_model.dart';
import '../../features/quran/data/quran_models.dart';
import '../../features/quran/data/quran_repository.dart';
import '../notes/notes_screen.dart';
import '../quran/screens/quran_screen.dart';

/// Instant offline search across both Quranic verses and user reflection notes.
///
/// EDUCATIONAL NOTE:
/// Search Architecture:
/// 1. Arabic text is normalized (removing diacritics, unifying Alef/Taa Marbuta variants)
///    strictly for substring index matching.
/// 2. Original Uthmani Quranic text is NEVER modified.
/// 3. Returns dual categorized results: verified Quranic ayahs and user notes.
class SearchScreen extends StatefulWidget {
  final bool returnToCaller;

  const SearchScreen({super.key, this.returnToCaller = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Ayah> _ayahResults = [];
  List<NoteItem> _noteResults = [];
  String _currentQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed == _currentQuery) return;
    _currentQuery = trimmed;

    if (trimmed.isEmpty) {
      setState(() {
        _ayahResults = [];
        _noteResults = [];
      });
      return;
    }

    final repo = QuranRepository.instance;
    final ayahs = repo.searchAyahs(trimmed, limit: 40);

    final normalizedQuery = ArabicSearchNormalizer.normalize(trimmed);
    final notes = UserDataStore.instance.notes.where((note) {
      final title = ArabicSearchNormalizer.normalize(note.title ?? '');
      final content = ArabicSearchNormalizer.normalize(note.content);
      final verse = ArabicSearchNormalizer.normalize(note.ayahText ?? '');
      return title.contains(normalizedQuery) ||
          content.contains(normalizedQuery) ||
          verse.contains(normalizedQuery);
    }).toList();

    setState(() {
      _ayahResults = ayahs;
      _noteResults = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasQuery = _currentQuery.isNotEmpty;
    final hasResults = _ayahResults.isNotEmpty || _noteResults.isNotEmpty;

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
            // Search Input Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchPlaceholder,
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
                            _onSearchChanged('');
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

            // Search Results Body
            Expanded(
              child: !hasQuery
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppColors.border(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.searchPlaceholder,
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
                  : !hasResults
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
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Verses Group
                        if (_ayahResults.isNotEmpty) ...[
                          _buildGroupHeader(
                            title: l10n.quranResults,
                            count: _ayahResults.length,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          ..._ayahResults.map(
                            (ayah) =>
                                _buildAyahResultCard(context, ayah, isDark),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Notes Group
                        if (_noteResults.isNotEmpty) ...[
                          _buildGroupHeader(
                            title: l10n.noteResults,
                            count: _noteResults.length,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          ..._noteResults.map(
                            (note) =>
                                _buildNoteResultCard(context, note, isDark),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader({
    required String title,
    required int count,
    required bool isDark,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
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

  Widget _buildAyahResultCard(BuildContext context, Ayah ayah, bool isDark) {
    final surah = QuranRepository.instance.getSurah(ayah.surahNumber);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? AppColors.darkSurface : AppColors.comsilk,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (widget.returnToCaller) {
            Navigator.pop(context, ayah);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranScreen(
                  initialPage: ayah.page,
                  targetSurahNumber: ayah.surahNumber,
                  targetAyahNumber: ayah.ayahNumber,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(ayah.ayahNumber)}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightPrimaryDark,
                    ),
                  ),
                  Text(
                    'ص ${ArabicSearchNormalizer.toArabicDigits(ayah.page)} · ج ${ArabicSearchNormalizer.toArabicDigits(ayah.juz)}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '﴿ ${ayah.text} ﴾',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 16,
                  height: 1.8,
                  color: isDark
                      ? AppColors.nightQuranText
                      : AppColors.dayQuranText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteResultCard(
    BuildContext context,
    NoteItem note,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? AppColors.darkSurface : AppColors.comsilk,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotesScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.isAyahNote
                        ? 'تدبر سورة ${note.surahNumber != null ? QuranRepository.instance.getSurah(note.surahNumber!).name : ""} · آية ${note.ayahNumber != null ? ArabicSearchNormalizer.toArabicDigits(note.ayahNumber!) : ""}'
                        : (note.title?.isNotEmpty == true
                              ? note.title!
                              : 'ملاحظة حرة'),
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightPrimaryDark,
                    ),
                  ),
                  Text(
                    '${note.createdAt.year}/${note.createdAt.month}/${note.createdAt.day}',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.nightSubtitle
                          : AppColors.daySubtitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.nightQuranText
                      : AppColors.dayQuranText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
