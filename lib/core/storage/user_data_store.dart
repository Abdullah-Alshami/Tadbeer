import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/ayah_links/ayah_link_model.dart';
import '../../features/bookmarks/bookmark_model.dart';
import '../../features/highlights/highlight_model.dart';
import '../../features/notes/note_model.dart';
import '../../features/quran/data/quran_models.dart';
import '../../features/tadabbur/tadbeer_model.dart';
import '../../features/quran/data/reading_position_model.dart';
import '../../features/reminders/reminder_model.dart';

import 'package:sqflite/sqflite.dart';

import 'user_database.dart';
import '../../features/settings/user_settings_model.dart';

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
  final List<TadbeerItem> _tadbeerItems = [];
  UserSettings _settings = const UserSettings();

  ReadingPosition get readingPosition => _readingPosition;
  List<NoteItem> get notes => List.unmodifiable(_notes);
  List<BookmarkItem> get bookmarks => List.unmodifiable(_bookmarks);
  List<HighlightItem> get highlights => List.unmodifiable(_highlights);
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);
  List<AyahLinkItem> get ayahLinks => List.unmodifiable(_ayahLinks);
  List<TadbeerItem> get tadbeerItems => List.unmodifiable(_tadbeerItems);
  List<TadbeerItem> get tadabburItems => tadbeerItems;
  UserSettings get settings => _settings;

  // In-memory lookups for O(1) page rendering performance
  final Map<String, BookmarkItem> _bookmarkLookup = {};
  final Map<String, HighlightItem> _highlightLookup = {};
  final Map<String, TadbeerItem> _tadbeerLookup = {};

  File? _dataFile;

  /// Initializes the local storage engine.
  /// Accepts an optional [testFile] for deterministic, isolated unit tests.
  Future<void> init([File? testFile, String? testDbPath]) async {
    if (_isInitialized && testFile == null) return;

    final userDb = UserDatabase.instance;
    if (testFile != null) {
      _dataFile = testFile;
      _readingPosition = ReadingPosition.defaultPosition();
      _notes.clear();
      _bookmarks.clear();
      _bookmarkLookup.clear();
      _highlights.clear();
      _highlightLookup.clear();
      _reminders.clear();
      _ayahLinks.clear();
      _tadbeerItems.clear();
      _tadbeerLookup.clear();
      _settings = const UserSettings();

      final dbPath = testDbPath ?? inMemoryDatabasePath;
      await userDb.close();
      await userDb.init(dbPath);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _dataFile = File('${dir.path}/$fileName');
      await userDb.init();
    }

    if (userDb.isOpen) {
      final savedPos = await userDb.loadReadingPosition();
      if (savedPos != null) _readingPosition = savedPos;

      final dbNotes = await userDb.loadNotes();
      if (dbNotes.isNotEmpty) {
        _notes.clear();
        _notes.addAll(dbNotes);
      }

      final dbBookmarks = await userDb.loadBookmarks();
      if (dbBookmarks.isNotEmpty) {
        _bookmarks.clear();
        _bookmarkLookup.clear();
        for (final b in dbBookmarks) {
          _bookmarks.add(b);
          _bookmarkLookup[b.ayahKey] = b;
        }
      }

      final dbHighlights = await userDb.loadHighlights();
      if (dbHighlights.isNotEmpty) {
        _highlights.clear();
        _highlightLookup.clear();
        for (final h in dbHighlights) {
          _highlights.add(h);
          _highlightLookup[h.ayahKey] = h;
        }
      }

      final dbReminders = await userDb.loadReminders();
      if (dbReminders.isNotEmpty) {
        _reminders.clear();
        _reminders.addAll(dbReminders);
      }

      final dbLinks = await userDb.loadAyahLinks();
      if (dbLinks.isNotEmpty) {
        _ayahLinks.clear();
        _ayahLinks.addAll(dbLinks);
      }

      final dbTadbeer = await userDb.loadTadbeerItems();
      if (dbTadbeer.isNotEmpty) {
        _tadbeerItems.clear();
        _tadbeerLookup.clear();
        for (final t in dbTadbeer) {
          _tadbeerItems.add(t);
          _tadbeerLookup[t.ayahKey] = t;
        }
      }

      final dbSettings = await userDb.loadSettings();
      if (dbSettings != null) _settings = dbSettings;

      // Migrate from JSON file if SQLite was fresh but JSON file already exists
      if (_notes.isEmpty &&
          _bookmarks.isEmpty &&
          _highlights.isEmpty &&
          _dataFile != null &&
          await _dataFile!.exists()) {
        await _loadFromFile();
        await _persistAllToSQLite();
      }
    } else {
      await _loadFromFile();
    }

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

    _tadbeerItems.clear();
    _tadbeerLookup.clear();
    final tadbeerData = data['tadbeer'] ?? data['tadabbur'];
    if (tadbeerData is List) {
      for (final t in tadbeerData) {
        final item = TadbeerItem.fromJson(t as Map<String, dynamic>);
        _tadbeerItems.add(item);
        _tadbeerLookup[item.ayahKey] = item;
      }
    }

    if (data.containsKey('settings')) {
      _settings = UserSettings.fromJson(
        data['settings'] as Map<String, dynamic>,
      );
    }
  }

  /// Persists all in-memory collections into the SQLite user database.
  Future<void> _persistAllToSQLite() async {
    final userDb = UserDatabase.instance;
    if (!userDb.isOpen) return;

    await userDb.saveReadingPosition(_readingPosition);
    for (final note in _notes) {
      await userDb.insertOrUpdateNote(note);
    }
    for (final bookmark in _bookmarks) {
      await userDb.insertBookmark(bookmark);
    }
    for (final highlight in _highlights) {
      await userDb.insertOrUpdateHighlight(highlight);
    }
    for (final reminder in _reminders) {
      await userDb.insertOrUpdateReminder(reminder);
    }
    for (final link in _ayahLinks) {
      await userDb.insertOrUpdateAyahLink(link);
    }
    for (final item in _tadbeerItems) {
      await userDb.insertOrUpdateTadbeer(item);
    }
    await userDb.saveSettings(_settings);
  }

  /// Flushes current state to disk using an atomic JSON file pattern.
  Future<void> saveToDisk() async {
    if (_dataFile == null) return;

    try {
      final data = {
        'schemaVersion': currentSchemaVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'readingPosition': _readingPosition.toJson(),
        'notes': _notes.map((n) => n.toJson()).toList(),
        'bookmarks': _bookmarks.map((b) => b.toJson()).toList(),
        'highlights': _highlights.map((h) => h.toJson()).toList(),
        'reminders': _reminders.map((r) => r.toJson()).toList(),
        'ayahLinks': _ayahLinks.map((l) => l.toJson()).toList(),
        'tadbeer': _tadbeerItems.map((t) => t.toJson()).toList(),
        'tadabbur': _tadbeerItems.map((t) => t.toJson()).toList(),
        'settings': _settings.toJson(),
      };

      final jsonString = jsonEncode(data);

      final tempFile = File('${_dataFile!.path}.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(_dataFile!.path);
    } catch (e) {
      debugPrint('UserDataStore.saveToDisk: $e');
    }
  }

  // ==========================================
  // READING POSITION
  // ==========================================

  Future<void> setReadingPosition(ReadingPosition position) async {
    _readingPosition = position;
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.saveReadingPosition(position);
    }
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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertOrUpdateNote(note);
    }
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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.deleteNote(id);
    }
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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertBookmark(bookmark);
    }
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
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.deleteBookmark(id);
      }
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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertOrUpdateHighlight(highlight);
    }
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
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.deleteHighlight(existing.id);
      }
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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertOrUpdateReminder(reminder);
    }
    await saveToDisk();
  }

  Future<void> toggleReminderActive(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final reminder = _reminders[idx];
      final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
      _reminders[idx] = updated;
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.insertOrUpdateReminder(updated);
      }
      await saveToDisk();
    }
  }

  Future<void> removeReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.deleteReminder(id);
    }
    await saveToDisk();
  }

  // ==========================================
  // SETTINGS
  // ==========================================

  Future<void> putSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.saveSettings(newSettings);
    }
    await saveToDisk();
  }

  Future<void> updateSettings(UserSettings newSettings) =>
      putSettings(newSettings);

  double get quranFontSize => _settings.quranFontSize;

  Future<void> setQuranFontSize(double size) async {
    final clamped = size.clamp(
      UserSettings.minQuranFontSize,
      UserSettings.maxQuranFontSize,
    );
    await updateSettings(_settings.copyWith(quranFontSize: clamped));
  }

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
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertOrUpdateAyahLink(link);
    }
    await saveToDisk();
  }

  Future<void> deleteAyahLink(String id) async {
    _ayahLinks.removeWhere((l) => l.id == id);
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.deleteAyahLink(id);
    }
    await saveToDisk();
  }

  Future<void> addVerseToLink(String linkId, AyahLinkVerse verse) async {
    final idx = _ayahLinks.indexWhere((l) => l.id == linkId);
    if (idx != -1) {
      final existing = _ayahLinks[idx];
      if (!existing.containsAyah(verse.surahNumber, verse.ayahNumber)) {
        final updatedVerses = [...existing.verses, verse];
        final updated = existing.copyWith(
          verses: updatedVerses,
          updatedAt: DateTime.now(),
        );
        _ayahLinks[idx] = updated;
        notifyListeners();
        final userDb = UserDatabase.instance;
        if (userDb.isOpen) {
          await userDb.insertOrUpdateAyahLink(updated);
        }
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
      final updated = existing.copyWith(
        verses: updatedVerses,
        positions: updatedPositions,
        updatedAt: DateTime.now(),
      );
      _ayahLinks[idx] = updated;
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.insertOrUpdateAyahLink(updated);
      }
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
      final updated = existing.copyWith(
        verses: updatedVerses,
        updatedAt: DateTime.now(),
      );
      _ayahLinks[idx] = updated;
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.insertOrUpdateAyahLink(updated);
      }
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
      final updated = existing.copyWith(
        positions: positions,
        isManualLayout: isManual,
        updatedAt: DateTime.now(),
      );
      _ayahLinks[idx] = updated;
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.insertOrUpdateAyahLink(updated);
      }
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
      final updated = existing.copyWith(
        lastViewMode: viewMode ?? existing.lastViewMode,
        panX: panX ?? existing.panX,
        panY: panY ?? existing.panY,
        zoomScale: zoomScale ?? existing.zoomScale,
        updatedAt: DateTime.now(),
      );
      _ayahLinks[idx] = updated;
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen) {
        await userDb.insertOrUpdateAyahLink(updated);
      }
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
    _tadbeerItems.clear();
    _tadbeerLookup.clear();
    _settings = const UserSettings();
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.clearAllUserData();
    }
    await saveToDisk();
  }

  Future<void> resetAllUserData() => resetAllData();

  // ==========================================
  // TADBEER PAUSE (وقفة تدبر)
  // ==========================================

  TadbeerItem? getTadbeer(int surahNumber, int ayahNumber) {
    return _tadbeerLookup['$surahNumber:$ayahNumber'];
  }

  /// Backward compatibility alias
  TadbeerItem? getTadabbur(int surahNumber, int ayahNumber) =>
      getTadbeer(surahNumber, ayahNumber);

  /// Resolves the most relevant reflection note for an ayah across Notes & Tadbeer.
  String? getReflectionForAyah(int surahNumber, int ayahNumber) {
    final notes = findNotesForAyah(surahNumber, ayahNumber);
    if (notes.isNotEmpty && notes.first.content.trim().isNotEmpty) {
      return notes.first.content.trim();
    }
    final tadbeer = getTadbeer(surahNumber, ayahNumber);
    if (tadbeer != null && tadbeer.combinedSummary.isNotEmpty) {
      return tadbeer.combinedSummary;
    }
    return null;
  }

  Future<void> saveTadbeer({
    required int surahNumber,
    required int ayahNumber,
    int? ayahId,
    required Map<int, String> answers,
  }) async {
    final cleanedAnswers = <int, String>{};
    answers.forEach((k, v) {
      final trimmed = v.trim();
      if (trimmed.isNotEmpty) {
        cleanedAnswers[k] = trimmed;
      }
    });

    final key = '$surahNumber:$ayahNumber';
    if (cleanedAnswers.isEmpty) {
      // Do not save empty responses; clean up if all were deleted
      final existing = _tadbeerLookup.remove(key);
      _tadbeerItems.removeWhere((t) => t.ayahKey == key);
      notifyListeners();
      final userDb = UserDatabase.instance;
      if (userDb.isOpen && existing != null) {
        await userDb.deleteTadbeer(existing.id);
      }
      await saveToDisk();
      return;
    }

    final now = DateTime.now();
    final existing = _tadbeerLookup[key];
    final item = TadbeerItem(
      id: existing?.id ?? const Uuid().v4(),
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahId: ayahId ?? existing?.ayahId,
      answers: cleanedAnswers,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final idx = _tadbeerItems.indexWhere((t) => t.ayahKey == key);
    if (idx != -1) {
      _tadbeerItems[idx] = item;
    } else {
      _tadbeerItems.add(item);
    }
    _tadbeerLookup[key] = item;

    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.insertOrUpdateTadbeer(item);
    }
    await saveToDisk();
  }

  /// Backward compatibility alias
  Future<void> saveTadabbur({
    required int surahNumber,
    required int ayahNumber,
    int? ayahId,
    required Map<int, String> answers,
  }) => saveTadbeer(
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    ayahId: ayahId,
    answers: answers,
  );

  Future<void> deleteTadbeer(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    final existing = _tadbeerLookup.remove(key);
    _tadbeerItems.removeWhere((t) => t.ayahKey == key);
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen && existing != null) {
      await userDb.deleteTadbeer(existing.id);
    }
    await saveToDisk();
  }

  /// Backward compatibility alias
  Future<void> deleteTadabbur(int surahNumber, int ayahNumber) =>
      deleteTadbeer(surahNumber, ayahNumber);

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
    bool tadbeer = true,
    bool? tadabbur,
  }) {
    final includeTadbeer = tadabbur ?? tadbeer;
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
      if (includeTadbeer) ...{
        'tadbeer': _tadbeerItems.map((t) => t.toJson()).toList(),
        'tadabbur': _tadbeerItems.map((t) => t.toJson()).toList(),
      },
    };
  }

  /// IMPORTANT:
  /// Restore intentionally replaces the existing user dataset.
  /// It must NEVER merge with existing data, ensuring mathematical consistency.
  Future<void> replaceAllUserData(Map<String, dynamic> data) async {
    _applyData(data);
    notifyListeners();
    final userDb = UserDatabase.instance;
    if (userDb.isOpen) {
      await userDb.clearAllUserData();
      await _persistAllToSQLite();
    }
    await saveToDisk();
  }
}
