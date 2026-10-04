import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/utils/arabic_search_normalizer.dart';
import 'quran_models.dart';

/// Repository providing verified, authentic Uthmani Quran data for Tadbeer.
///
/// EDUCATIONAL NOTE:
/// Quran Data Architecture & Integrity:
/// 1. Data Source: Bundled Tanzil Uthmani text (`assets/quran/quran_data.json`).
///    - 114 Surahs (Surah names, revelation type, ayah counts, page ranges)
///    - 6,236 Ayahs (global stable 1-based sequential ID, surah number, ayah number, page, juz, hizb, quarter, sajdah)
///    - 604 standard Madani Mushaf pages
/// 2. Immutability: Quranic text is immutable and strictly read-only.
/// 3. Instant Search Optimization: An in-memory cache of pre-normalized ayah strings
///    (`_normalizedAyahTexts`) is built during [init]. Substring search operates directly
///    on this cache in sub-millisecond time without on-the-fly normalization.
class QuranRepository {
  static final QuranRepository instance = QuranRepository._internal();
  QuranRepository._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  final List<Surah> _surahs = [];
  final List<QuranPage> _pages = [];
  final List<Ayah> _allAyahs = [];
  final Map<int, Ayah> _ayahsById = {};
  final Map<String, Ayah> _ayahsByKey = {};
  final List<String> _normalizedAyahTexts = [];

  List<Surah> get surahs => List.unmodifiable(_surahs);
  List<QuranPage> get pages => List.unmodifiable(_pages);
  List<Ayah> get allAyahs => List.unmodifiable(_allAyahs);

  Future<void> init() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString(
      'assets/quran/quran_data.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final rawSurahs = (data['surahs'] as List).cast<Map<String, dynamic>>();
    _surahs.clear();
    for (final s in rawSurahs) {
      _surahs.add(Surah.fromJson(s));
    }

    final rawPages = (data['pages'] as List).cast<Map<String, dynamic>>();
    _pages.clear();
    _allAyahs.clear();
    _ayahsById.clear();
    _ayahsByKey.clear();
    _normalizedAyahTexts.clear();

    for (final p in rawPages) {
      final page = QuranPage.fromJson(p);
      _pages.add(page);
      for (final ayah in page.ayahs) {
        _allAyahs.add(ayah);
        _ayahsById[ayah.id] = ayah;
        _ayahsByKey[ayah.key] = ayah;
        _normalizedAyahTexts.add(ArabicSearchNormalizer.normalize(ayah.text));
      }
    }

    _isLoaded = true;
  }

  QuranPage getPage(int pageNumber) {
    assert(_isLoaded, 'QuranRepository must be initialized before use');
    if (pageNumber < 1 || pageNumber > 604) {
      pageNumber = pageNumber.clamp(1, 604);
    }
    return _pages[pageNumber - 1];
  }

  Surah getSurah(int surahNumber) {
    assert(_isLoaded, 'QuranRepository must be initialized before use');
    if (surahNumber < 1 || surahNumber > 114) {
      surahNumber = surahNumber.clamp(1, 114);
    }
    return _surahs[surahNumber - 1];
  }

  Ayah? getAyah(int surahNumber, int ayahNumber) {
    assert(_isLoaded, 'QuranRepository must be initialized before use');
    return _ayahsByKey['$surahNumber:$ayahNumber'];
  }

  Ayah? getAyahById(int id) {
    assert(_isLoaded, 'QuranRepository must be initialized before use');
    return _ayahsById[id];
  }

  /// Instant offline Arabic search across all 6,236 ayahs using pre-normalized cache.
  List<Ayah> searchAyahs(String query, {int limit = 50}) {
    if (!_isLoaded || query.trim().isEmpty) return const [];

    final normalizedQuery = ArabicSearchNormalizer.normalize(query);
    if (normalizedQuery.isEmpty) return const [];

    final results = <Ayah>[];
    for (int i = 0; i < _allAyahs.length; i++) {
      if (_normalizedAyahTexts[i].contains(normalizedQuery)) {
        results.add(_allAyahs[i]);
        if (results.length >= limit) break;
      }
    }
    return results;
  }
}
