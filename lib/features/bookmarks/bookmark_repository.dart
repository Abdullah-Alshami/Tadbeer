import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../quran/data/quran_models.dart';
import 'bookmark_model.dart';

/// مستودع إدارة الإشارات المرجعية (الفواصل) في التطبيق.
///
/// يوفر واجهة لإضافة وحذف وفحص حالة الفاصل للآية بالاعتماد على [UserDataStore].
class BookmarkRepository {
  final UserDataStore _store;

  /// ينشئ مستودع الفواصل المرجعية بالاعتماد على مخزن بيانات المستخدم.
  BookmarkRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  /// يعيد قائمة جميع الإشارات المرجعية المحفوظة.
  List<BookmarkItem> get allBookmarks => _store.bookmarks;

  /// يتحقق مما إذا كانت الآية المحددة محفوظة في الفواصل المرجعية.
  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _store.hasBookmark(surahNumber, ayahNumber);
  }

  /// تبديل حالة الفاصل للآية (إضافة إذا لم تكن موجودة، وحذف إذا كانت مضافة).
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

  /// يحذف إشارة مرجعية محددة بواسطة معرّفها.
  Future<void> removeBookmark(String id) async {
    await _store.removeBookmark(id);
  }
}
