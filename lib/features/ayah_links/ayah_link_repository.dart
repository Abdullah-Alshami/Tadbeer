import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/quran/data/quran_repository.dart';
import 'ayah_link_model.dart';

/// مستودع إدارة روابط الآيات (شبكة التدبر والموضوعات القرآنية المشتركة).
///
/// ملاحظة معمارية:
/// تتيح روابط الآيات للمتدبر ربط آيات متعددة من سور مختلفة بموضوع تدبري واحد،
/// مع حفظ إحداثيات كل عقدة في الخريطة الذهنية التفاعلية دون أي تكرار للنص القرآني في التخزين.
class AyahLinkRepository {
  final UserDataStore _store;

  /// ينشئ مستودع روابط الآيات بالاعتماد على مخزن بيانات المستخدم.
  AyahLinkRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  /// يعيد قائمة جميع روابط الآيات المحفوظة للمستخدم.
  List<AyahLinkItem> get allLinks => _store.ayahLinks;

  /// يجلب رابط آيات محدد بواسطة معرّفه الفريد.
  AyahLinkItem? getLink(String id) => _store.getAyahLink(id);

  /// ينشئ رابط آيات جديد بالعنوان والوصف الاختياري ويحفظه.
  ///
  /// Creates a new Ayah Link with title and optional description.
  Future<AyahLinkItem> createLink({
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();
    final link = AyahLinkItem(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description?.trim().isEmpty ?? true
          ? null
          : description?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _store.saveAyahLink(link);
    return link;
  }

  /// يحدّث بيانات رابط آيات موجود.
  ///
  /// Updates an existing Ayah Link.
  Future<void> updateLink(AyahLinkItem link) async {
    await _store.saveAyahLink(link.copyWith(updatedAt: DateTime.now()));
  }

  /// يحذف رابط آيات بواسطة معرّفه.
  ///
  /// Deletes an Ayah Link by id.
  Future<void> deleteLink(String id) async {
    await _store.deleteAyahLink(id);
  }

  /// يضيف آية قرآنية إلى رابط آيات موجود.
  ///
  /// Adds a verse to an existing Ayah Link.
  Future<void> addVerseToLink(
    String linkId, {
    required int ayahId,
    required int surahNumber,
    required int ayahNumber,
    required int page,
    String? note,
  }) async {
    final verse = AyahLinkVerse(
      ayahId: ayahId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      note: note,
      addedAt: DateTime.now(),
    );
    await _store.addVerseToLink(linkId, verse);
  }

  /// يزيل آية قرآنية من رابط آيات محدد.
  ///
  /// Removes a verse from an Ayah Link.
  Future<void> removeVerseFromLink(
    String linkId,
    int surahNumber,
    int ayahNumber,
  ) async {
    await _store.removeVerseFromLink(linkId, surahNumber, ayahNumber);
  }

  /// يحدّث ملاحظة التدبر الخاصة بآية داخل رابط محدد.
  ///
  /// Updates personal reflection note on an ayah within a link.
  Future<void> updateVerseNote(
    String linkId,
    int surahNumber,
    int ayahNumber,
    String? note,
  ) async {
    await _store.updateVerseNote(linkId, surahNumber, ayahNumber, note);
  }

  /// يحدّث إحداثيات مواضع العقد في لوحة الشبكة وحالة الترتيب اليدوي.
  ///
  /// Updates positions of nodes in canvas and whether layout is manual.
  Future<void> updatePositions(
    String linkId,
    Map<String, LinkNodePosition> positions,
    bool isManual,
  ) async {
    await _store.updateLinkPositions(linkId, positions, isManual);
  }

  /// يحدّث حالة العرض للرابط مثل نمط العرض والإزاحة ومستوى التكبير.
  ///
  /// Updates view state (viewMode, panX, panY, zoomScale).
  Future<void> updateViewState(
    String linkId, {
    String? viewMode,
    double? panX,
    double? panY,
    double? zoomScale,
  }) async {
    await _store.updateLinkViewState(
      linkId,
      viewMode: viewMode,
      panX: panX,
      panY: panY,
      zoomScale: zoomScale,
    );
  }

  /// يعيد جميع روابط الآيات التي تتضمن آية محددة.
  ///
  /// Finds all Ayah Links that contain a specific ayah.
  List<AyahLinkItem> getLinksForAyah(int surahNumber, int ayahNumber) {
    return _store.getLinksForAyah(surahNumber, ayahNumber);
  }

  /// يبحث في روابط الآيات حسب العنوان أو الوصف أو أسماء السور والملاحظات.
  ///
  /// Searches links by title, description, or contained verses/surahs.
  List<AyahLinkItem> searchLinks(String rawQuery) {
    final normalized = ArabicSearchNormalizer.normalize(rawQuery).trim();
    if (normalized.isEmpty) return allLinks;

    return allLinks.where((link) {
      final normTitle = ArabicSearchNormalizer.normalize(link.title);
      if (normTitle.contains(normalized)) return true;

      if (link.description != null) {
        final normDesc = ArabicSearchNormalizer.normalize(link.description!);
        if (normDesc.contains(normalized)) return true;
      }

      // Check contained surah names
      for (final v in link.verses) {
        final surah = QuranRepository.instance.getSurah(v.surahNumber);
        final normSurah = ArabicSearchNormalizer.normalize(surah.name);
        if (normSurah.contains(normalized)) return true;

        if (v.note != null) {
          final normNote = ArabicSearchNormalizer.normalize(v.note!);
          if (normNote.contains(normalized)) return true;
        }
      }

      return false;
    }).toList();
  }
}
