import '../../core/storage/user_data_store.dart';
import 'reading_position_model.dart';

/// Repository for reading position persistence.
///
/// EDUCATIONAL NOTE:
/// The reader stores the page separately from the selected ayah.
/// This allows the application to restore the exact Mushaf position
/// even after the application has been completely closed or device restarted.
class ReadingPositionRepository {
  final UserDataStore _store;

  ReadingPositionRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  ReadingPosition get currentPosition => _store.readingPosition;

  /// Persists the user's latest reading position.
  Future<void> savePosition({
    required int page,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final position = ReadingPosition(
      page: page,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      updatedAt: DateTime.now(),
    );
    await _store.setReadingPosition(position);
  }
}
