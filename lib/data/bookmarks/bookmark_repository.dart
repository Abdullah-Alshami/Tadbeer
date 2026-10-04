import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../quran/quran_models.dart';
import 'bookmark_model.dart';

/// Repository for managing per-ayah bookmarks.
///
/// EDUCATIONAL NOTE:
/// Bookmarks are strictly distinct from notes and highlights.
/// They allow users to quickly pin ayahs for future recitation.
class BookmarkRepository {
  final UserDataStore _store;

  BookmarkRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  List<BookmarkItem> get allBookmarks => _store.bookmarks;

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _store.hasBookmark(surahNumber, ayahNumber);
  }

  /// Toggles bookmark state for the specified ayah.
  Future<bool> toggleBookmark(Ayah ayah) async {
    final currentlyBookmarked = isBookmarked(ayah.surahNumber, ayah.ayahNumber);
    if (currentlyBookmarked) {
      final existing = _store.bookmarks.firstWhere(
        (b) =>
            b.surahNumber == ayah.surahNumber &&
            b.ayahNumber == ayah.ayahNumber,
      );
      await _store.removeBookmark(existing.id);
      return false;
    } else {
      final item = BookmarkItem(
        id: const Uuid().v4(),
        ayahId: ayah.id,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        page: ayah.page,
        createdAt: DateTime.now(),
      );
      await _store.putBookmark(item);
      return true;
    }
  }

  Future<void> removeBookmark(String id) async {
    await _store.removeBookmark(id);
  }
}
