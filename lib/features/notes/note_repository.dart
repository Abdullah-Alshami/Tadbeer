import 'package:uuid/uuid.dart';

import '../../core/storage/user_data_store.dart';
import 'note_model.dart';

/// Repository for managing user notes (Ayah Notes and Free Notes).
///
/// EDUCATIONAL NOTE:
/// Notes are displayed in a single unified stream, newest first,
/// preserving stable ayah links for Ayah Notes.
class NoteRepository {
  final UserDataStore _store;

  NoteRepository([UserDataStore? store])
    : _store = store ?? UserDataStore.instance;

  List<NoteItem> get allNotes => _store.notes;

  List<NoteItem> getNotesForAyah(int surahNumber, int ayahNumber) {
    return _store.findNotesForAyah(surahNumber, ayahNumber);
  }

  /// Saves a new note or updates an existing note.
  Future<NoteItem> saveNote({
    String? id,
    required NoteType type,
    String? title,
    required String content,
    int? ayahId,
    int? surahNumber,
    int? ayahNumber,
    int? page,
    String? ayahText,
  }) async {
    final now = DateTime.now();

    if (id != null) {
      final existing = _store.notes.where((n) => n.id == id).firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          title: title,
          content: content,
          updatedAt: now,
        );
        await _store.putNote(updated);
        return updated;
      }
    }

    final newNote = NoteItem(
      id: id ?? const Uuid().v4(),
      type: type,
      title: title,
      content: content,
      ayahId: ayahId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      ayahText: ayahText,
      createdAt: now,
      updatedAt: now,
    );
    await _store.putNote(newNote);
    return newNote;
  }

  /// Deletes a note by its identifier.
  Future<void> deleteNote(String id) async {
    await _store.removeNote(id);
  }
}
