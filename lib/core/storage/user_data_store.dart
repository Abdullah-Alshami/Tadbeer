import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/ayah_links/ayah_link_model.dart';
import '../../data/bookmarks/bookmark_model.dart';
import '../../data/highlights/highlight_model.dart';
import '../../data/notes/note_model.dart';
import '../../data/quran/quran_models.dart';
import '../../data/reading_position/reading_position_model.dart';
import '../../data/reminders/reminder_model.dart';
import 'user_settings_model.dart';

/// Central local storage coordinator for user-generated data in Tadbeer.
///
/// EDUCATIONAL NOTE:
/// User data (notes, bookmarks, highlights, reading position, reminders, settings)
/// is intentionally kept separate from the static Quran dataset.
///
/// Why JSON with atomic file replacement?
/// 1. Zero native C/FFI compilation issues across Linux, Android, iOS, Windows, and macOS.
/// 2. Deterministic serialization: the disk snapshot maps 1:1 to the encrypted `.quranbackup` container.
/// 3. Atomic file writes (writing to `.tmp` then renaming) ensure the database file is never corrupted
///    even if the OS terminates the app or power is cut mid-write.
///
/// Performance Optimization:
/// In-memory hash maps (`_bookmarkLookup` and `_highlightLookup`) are maintained alongside
/// the collections. When rendering a 15-line Quran page with 10-30 ayahs, lookups are O(1)
/// without scanning entire lists on every frame.
class UserDataStore extends ChangeNotifier {
  static final UserDataStore instance = UserDataStore._internal();
  UserDataStore._internal();

  /// Current schema version for user data and backups.
  static const int currentSchemaVersion = 1;
  static const String fileName = 'tadbeer_user_data.json';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ReadingPosition _readingPosition = ReadingPosition.defaultPosition();
  final List<NoteItem> _notes = [];
  final List<BookmarkItem> _bookmarks = [];
  final List<HighlightItem> _highlights = [];
  final List<ReminderItem> _reminders = [];
  final List<AyahLinkItem> _ayahLinks = [];
  UserSettings _settings = const UserSettings();

  ReadingPosition get readingPosition => _readingPosition;
  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<BookmarkItem> get bookmarks => List.unmodifiable(_bookmarks);
  List<HighlightItem> get highlights => List.unmodifiable(_highlights);
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);
  List<AyahLinkItem> get ayahLinks => List.unmodifiable(_ayahLinks);
  UserSettings get settings => _settings;

  // In-memory lookups for O(1) page rendering performance
  final Map<String, BookmarkItem> _bookmarkLookup = {};
  final Map<String, HighlightItem> _highlightLookup = {};

  File? _dataFile;

  /// Initializes the local storage engine.
  /// Accepts an optional [testFile] for deterministic, isolated unit tests.
  Future<void> init([File? testFile]) async {
    if (_isInitialized && testFile == null) return;

    if (testFile != null) {
      _dataFile = testFile;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _dataFile = File('${dir.path}/$fileName');
    }

    await _loadFromFile();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromFile() async {
    if (_dataFile == null || !await _dataFile!.exists()) {
      return;
    }

    try {
      final content = await _dataFile!.readAsString();
      if (content.trim().isEmpty) return;

      final data = jsonDecode(content) as Map<String, dynamic>;
      _applyData(data);
    } catch (e) {
      debugPrint('Error reading Tadbeer user data file: $e');
    }
  }

  void _applyData(Map<String, dynamic> data) {
    if (data.containsKey('readingPosition')) {
      _readingPosition = ReadingPosition.fromJson(
        data['readingPosition'] as Map<String, dynamic>,
      );
    }

    _notes.clear();
    if (data.containsKey('notes')) {
      final rawNotes = data['notes'] as List;
      for (final n in rawNotes) {
        _notes.add(NoteItem.fromJson(n as Map<String, dynamic>));
      }
      // Sort newest first
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    _bookmarks.clear();
    _bookmarkLookup.clear();
    if (data.containsKey('bookmarks')) {
      final rawBookmarks = data['bookmarks'] as List;
      for (final b in rawBookmarks) {
        final item = BookmarkItem.fromJson(b as Map<String, dynamic>);
        _bookmarks.add(item);
        _bookmarkLookup[item.ayahKey] = item;
      }
    }

    _highlights.clear();
    _highlightLookup.clear();
    if (data.containsKey('highlights')) {
      final rawHighlights = data['highlights'] as List;
      for (final h in rawHighlights) {
        final item = HighlightItem.fromJson(h as Map<String, dynamic>);
        _highlights.add(item);
        _highlightLookup[item.ayahKey] = item;
      }
    }

    _reminders.clear();
    if (data.containsKey('reminders')) {
      final rawReminders = data['reminders'] as List;
      for (final r in rawReminders) {
        _reminders.add(ReminderItem.fromJson(r as Map<String, dynamic>));
      }
    }

    _ayahLinks.clear();
    if (data.containsKey('ayahLinks')) {
      final rawLinks = data['ayahLinks'] as List;
      for (final l in rawLinks) {
        _ayahLinks.add(AyahLinkItem.fromJson(l as Map<String, dynamic>));
      }
      _ayahLinks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    if (data.containsKey('settings')) {
      _settings = UserSettings.fromJson(
        data['settings'] as Map<String, dynamic>,
      );
    }
  }

  /// Flushes current state to disk using an atomic write pattern.
  Future<void> saveToDisk() async {
    if (_dataFile == null) return;

    final data = {
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'readingPosition': _readingPosition.toJson(),
      'notes': _notes.map((n) => n.toJson()).toList(),
      'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      'highlights': _highlights.map((h) => h.toJson()).toList(),
      'reminders': _reminders.map((r) => r.toJson()).toList(),
      'ayahLinks': _ayahLinks.map((l) => l.toJson()).toList(),
      'settings': _settings.toJson(),
    };

    final jsonString = jsonEncode(data);

    // Atomic write pattern:
    // 1. Write fully to temporary file
    // 2. Flush OS buffers
    // 3. Atomically rename temporary file over target file
    final tempFile = File('${_dataFile!.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(_dataFile!.path);
  }

  // ==========================================
  // READING POSITION
  // ==========================================

  Future<void> setReadingPosition(ReadingPosition position) async {
    _readingPosition = position;
    notifyListeners();
    await saveToDisk();
  }

  Future<void> saveReadingPosition({
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
    await setReadingPosition(position);
  }

  // ==========================================
  // NOTES
  // ==========================================

  List<NoteItem> findNotesForAyah(int surahNumber, int ayahNumber) {
    return _notes
        .where(
          (n) => n.surahNumber == surahNumber && n.ayahNumber == ayahNumber,
        )
        .toList();
  }

  List<NoteItem> getNotesForAyah(int surahNumber, int ayahNumber) {
    return findNotesForAyah(surahNumber, ayahNumber);
  }

  Future<void> putNote(NoteItem note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
    } else {
      _notes.insert(0, note);
    }
    notifyListeners();
    await saveToDisk();
  }

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
      final existing = _notes.where((n) => n.id == id).firstOrNull;
      if (existing != null) {
        final updated = existing.copyWith(
          title: title,
          content: content,
          updatedAt: now,
        );
        await putNote(updated);
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
    await putNote(newNote);
    return newNote;
  }

  Future<void> removeNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await saveToDisk();
  }

  Future<void> deleteNote(String id) => removeNote(id);

  // ==========================================
  // BOOKMARKS
  // ==========================================

  bool hasBookmark(int surahNumber, int ayahNumber) {
    return _bookmarkLookup.containsKey('$surahNumber:$ayahNumber');
  }

  bool isBookmarked(int surahNumber, int ayahNumber) =>
      hasBookmark(surahNumber, ayahNumber);

  Future<void> putBookmark(BookmarkItem bookmark) async {
    final idx = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (idx != -1) {
      _bookmarks[idx] = bookmark;
    } else {
      _bookmarks.insert(0, bookmark);
    }
    _bookmarkLookup[bookmark.ayahKey] = bookmark;
    notifyListeners();
    await saveToDisk();
  }

  Future<bool> toggleBookmark(Ayah ayah) async {
    final currentlyBookmarked = hasBookmark(ayah.surahNumber, ayah.ayahNumber);
    if (currentlyBookmarked) {
      final existing = _bookmarks.firstWhere(
        (b) =>
            b.surahNumber == ayah.surahNumber &&
            b.ayahNumber == ayah.ayahNumber,
      );
      await removeBookmark(existing.id);
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
      await putBookmark(item);
      return true;
    }
  }

  Future<void> removeBookmark(String id) async {
    final idx = _bookmarks.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final item = _bookmarks.removeAt(idx);
      _bookmarkLookup.remove(item.ayahKey);
      notifyListeners();
      await saveToDisk();
    }
  }

  // ==========================================
  // HIGHLIGHTS
  // ==========================================

  HighlightItem? findHighlight(int surahNumber, int ayahNumber) {
    return _highlightLookup['$surahNumber:$ayahNumber'];
  }

  HighlightItem? getHighlight(int surahNumber, int ayahNumber) =>
      findHighlight(surahNumber, ayahNumber);

  Future<void> putHighlight(HighlightItem highlight) async {
    final key = highlight.ayahKey;
    final existing = _highlightLookup[key];
    if (existing != null) {
      final idx = _highlights.indexWhere((h) => h.id == existing.id);
      if (idx != -1) {
        _highlights[idx] = highlight;
      }
    } else {
      _highlights.insert(0, highlight);
    }
    _highlightLookup[key] = highlight;
    notifyListeners();
    await saveToDisk();
  }

  Future<void> setHighlight(Ayah ayah, int colorIndex) async {
    final existing = findHighlight(ayah.surahNumber, ayah.ayahNumber);
    final item = HighlightItem(
      id: existing?.id ?? const Uuid().v4(),
      ayahId: ayah.id,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      page: ayah.page,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
    );
    await putHighlight(item);
  }

  Future<void> removeHighlight(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    final existing = _highlightLookup.remove(key);
    if (existing != null) {
      _highlights.removeWhere((h) => h.id == existing.id);
      notifyListeners();
      await saveToDisk();
    }
  }

  // ==========================================
  // REMINDERS
  // ==========================================

  Future<void> putReminder(ReminderItem reminder) async {
    final idx = _reminders.indexWhere((r) => r.id == reminder.id);
    if (idx != -1) {
      _reminders[idx] = reminder;
    } else {
      _reminders.add(reminder);
    }
    notifyListeners();
    await saveToDisk();
  }

  Future<void> toggleReminderActive(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final reminder = _reminders[idx];
      _reminders[idx] = reminder.copyWith(isEnabled: !reminder.isEnabled);
      notifyListeners();
      await saveToDisk();
    }
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await saveToDisk();
  }

  // ==========================================
  // SETTINGS
  // ==========================================

  Future<void> putSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await saveToDisk();
  }

  Future<void> updateSettings(UserSettings newSettings) =>
      putSettings(newSettings);

  // ==========================================
  // AYAH LINKS (روابط الآيات)
  // ==========================================

  AyahLinkItem? getAyahLink(String id) {
    return _ayahLinks.where((l) => l.id == id).firstOrNull;
  }

  List<AyahLinkItem> getLinksForAyah(int surahNumber, int ayahNumber) {
    return _ayahLinks
        .where((l) => l.containsAyah(surahNumber, ayahNumber))
        .toList();
  }

  Future<void> saveAyahLink(AyahLinkItem link) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == link.id);
    if (idx != -1) {
      _ayahLinks[idx] = link;
    } else {
      _ayahLinks.insert(0, link);
    }
    notifyListeners();
    await saveToDisk();
  }

  Future<void> deleteAyahLink(String id) async {
    _ayahLinks.removeWhere((l) => l.id == id);
    notifyListeners();
    await saveToDisk();
  }

  Future<void> addVerseToLink(String linkId, AyahLinkVerse verse) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      if (!existing.containsAyah(verse.surahNumber, verse.ayahNumber)) {
        final updatedVerses = [...existing.verses, verse];
        _ayahLinks[idx] = existing.copyWith(
          verses: updatedVerses,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        await saveToDisk();
      }
    }
  }

  Future<void> removeVerseFromLink(
    String linkId,
    int surahNumber,
    int ayahNumber,
  ) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      final key = '$surahNumber:$ayahNumber';
      final updatedVerses = existing.verses
          .where((v) => v.ayahKey != key)
          .toList();
      final updatedPositions = Map<String, LinkNodePosition>.from(
        existing.positions,
      )..remove(key);
      _ayahLinks[idx] = existing.copyWith(
        verses: updatedVerses,
        positions: updatedPositions,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await saveToDisk();
    }
  }

  Future<void> updateVerseNote(
    String linkId,
    int surahNumber,
    int ayahNumber,
    String? note,
  ) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      final key = '$surahNumber:$ayahNumber';
      final updatedVerses = existing.verses.map((v) {
        if (v.ayahKey == key) {
          return v.copyWith(note: note);
        }
        return v;
      }).toList();
      _ayahLinks[idx] = existing.copyWith(
        verses: updatedVerses,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await saveToDisk();
    }
  }

  Future<void> updateLinkPositions(
    String linkId,
    Map<String, LinkNodePosition> positions,
    bool isManual,
  ) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      _ayahLinks[idx] = existing.copyWith(
        positions: positions,
        isManualLayout: isManual,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await saveToDisk();
    }
  }

  Future<void> updateLinkViewState(
    String linkId, {
    String? viewMode,
    double? panX,
    double? panY,
    double? zoomScale,
  }) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      _ayahLinks[idx] = existing.copyWith(
        lastViewMode: viewMode ?? existing.lastViewMode,
        panX: panX ?? existing.panX,
        panY: panY ?? existing.panY,
        zoomScale: zoomScale ?? existing.zoomScale,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      await saveToDisk();
    }
  }

  // ==========================================
  // DATA INTEGRITY & RESET
  // ==========================================

  Future<void> resetAllData() async {
    _readingPosition = ReadingPosition.defaultPosition();
    _notes.clear();
    _bookmarks.clear();
    _bookmarkLookup.clear();
    _highlights.clear();
    _highlightLookup.clear();
    _reminders.clear();
    _ayahLinks.clear();
    _settings = const UserSettings();
    notifyListeners();
    await saveToDisk();
  }

  Future<void> resetAllUserData() => resetAllData();

  // ==========================================
  // SNAPSHOT EXPORT / RESTORE
  // ==========================================

  Map<String, dynamic> exportSnapshot({
    bool notes = true,
    bool bookmarks = true,
    bool highlights = true,
    bool settings = true,
    bool reminders = true,
    bool ayahLinks = true,
  }) {
    return {
      'app': 'Tadbeer',
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'readingPosition': _readingPosition.toJson(),
      if (notes) 'notes': _notes.map((n) => n.toJson()).toList(),
      if (bookmarks) 'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
      if (highlights) 'highlights': _highlights.map((h) => h.toJson()).toList(),
      if (settings) 'settings': _settings.toJson(),
      if (reminders) 'reminders': _reminders.map((r) => r.toJson()).toList(),
      if (ayahLinks) 'ayahLinks': _ayahLinks.map((l) => l.toJson()).toList(),
    };
  }

  /// IMPORTANT:
  /// Restore intentionally replaces the existing user dataset.
  /// It must NEVER merge with existing data, ensuring mathematical consistency.
  Future<void> replaceAllUserData(Map<String, dynamic> data) async {
    _applyData(data);
    notifyListeners();
    await saveToDisk();
  }
}
