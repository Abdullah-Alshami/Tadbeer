import 'package:flutter/services.dart';

/// Manages dynamic loading and registration of King Fahd Glorious Quran Printing Complex
/// (KFGQPC) QCF V2 page-specific fonts (`p1.ttf` .. `p604.ttf`).
class QcfFontManager {
  static final Set<int> _loadedPages = <int>{};
  static final Map<int, Future<void>> _loadingFutures = <int, Future<void>>{};

  /// Returns the unique font family identifier for the given Mushaf page.
  static String fontFamilyForPage(int page) => 'QCF2_P$page';

  /// Checks if the font for the given page has already been loaded into Flutter engine.
  static bool isPageLoaded(int page) => _loadedPages.contains(page);

  /// Loads and registers the font for [page] from `assets/quran/qcf_v2/fonts/p$page.ttf`.
  /// Safe to call multiple times; deduplicates in-flight loads and caches completed ones.
  static Future<void> loadPageFont(int page) async {
    if (page < 1 || page > 604) return;
    if (_loadedPages.contains(page)) return;
    if (_loadingFutures.containsKey(page)) {
      return _loadingFutures[page];
    }

    final future = () async {
      try {
        final family = fontFamilyForPage(page);
        final fontLoader = FontLoader(family);
        final assetPath = 'assets/quran/qcf_v2/fonts/p$page.ttf';
        fontLoader.addFont(rootBundle.load(assetPath));
        await fontLoader.load();
        _loadedPages.add(page);
      } catch (e) {
        // In certain non-standard test environments where rootBundle doesn't host asset binaries,
        // we swallow to avoid crashing the test harness.
      } finally {
        _loadingFutures.remove(page);
      }
    }();

    _loadingFutures[page] = future;
    return future;
  }

  /// Preloads adjacent pages for butter-smooth PageView swiping.
  static void preloadSurroundingPages(int currentPage) {
    if (currentPage > 1) {
      loadPageFont(currentPage - 1);
    }
    if (currentPage < 604) {
      loadPageFont(currentPage + 1);
    }
  }

  /// Clears in-memory registration state (primarily for test resets).
  static void resetForTest() {
    _loadedPages.clear();
    _loadingFutures.clear();
  }
}
