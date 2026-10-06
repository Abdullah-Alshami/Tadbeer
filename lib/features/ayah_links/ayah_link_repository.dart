import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/quran/data/quran_repository.dart';
import 'ayah_link_model.dart';

/// Repository for managing Ayah Links (روابط الآيات).
///
/// Encapsulates all operations on links, verse memberships, node layout positions,
/// and search matching without duplicating authentic Quranic data.
class AyahLinkRepository {
  final UserDataStore _store;

  AyahLinkRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  List<AyahLinkItem> get allLinks => _store.ayahLinks;

  AyahLinkItem? getLink(String id) => _store.getAyahLink(id);

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

  /// Updates an existing Ayah Link.
  Future<void> updateLink(AyahLinkItem link) async {
    await _store.saveAyahLink(link.copyWith(updatedAt: DateTime.now()));
  }

  /// Deletes an Ayah Link by id.
  Future<void> deleteLink(String id) async {
    await _store.deleteAyahLink(id);
  }

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

  /// Removes a verse from an Ayah Link.
  Future<void> removeVerseFromLink(
    String linkId,
    int surahNumber,
    int ayahNumber,
  ) async {
    await _store.removeVerseFromLink(linkId, surahNumber, ayahNumber);
  }

  /// Updates personal reflection note on an ayah within a link.
  Future<void> updateVerseNote(
    String linkId,
    int surahNumber,
    int ayahNumber,
    String? note,
  ) async {
    await _store.updateVerseNote(linkId, surahNumber, ayahNumber, note);
  }

  /// Updates positions of nodes in canvas and whether layout is manual.
  Future<void> updatePositions(
    String linkId,
    Map<String, LinkNodePosition> positions,
    bool isManual,
  ) async {
    await _store.updateLinkPositions(linkId, positions, isManual);
  }

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

  /// Finds all Ayah Links that contain a specific ayah.
  List<AyahLinkItem> getLinksForAyah(int surahNumber, int ayahNumber) {
    return _store.getLinksForAyah(surahNumber, ayahNumber);
  }

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
