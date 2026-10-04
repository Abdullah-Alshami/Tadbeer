import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import '../quran/quran_models.dart';
import 'highlight_model.dart';

/// Repository for managing ayah highlights with 4 calm colors.
///
/// EDUCATIONAL NOTE:
/// Highlights store a color index (0..3) linked to a stable ayah.
/// They do not alter the Quran text in any way and remain visually distinct
/// in both light and dark eye-comfort modes.
class HighlightRepository {
  final UserDataStore _store;

  HighlightRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  List<HighlightItem> get allHighlights => _store.highlights;

  HighlightItem? getHighlight(int surahNumber, int ayahNumber) {
    return _store.findHighlight(surahNumber, ayahNumber);
  }

  /// Sets or updates the highlight color for an ayah.
  Future<void> setHighlight(Ayah ayah, int colorIndex) async {
    final existing = getHighlight(ayah.surahNumber, ayah.ayahNumber);
    final item = HighlightItem(
      id: existing?.id ?? const Uuid().v4(),
      ayahId: ayah.id,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      page: ayah.page,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
    );
    await _store.putHighlight(item);
  }

  /// Removes highlight from an ayah.
  Future<void> removeHighlight(int surahNumber, int ayahNumber) async {
    await _store.removeHighlight(surahNumber, ayahNumber);
  }
}
