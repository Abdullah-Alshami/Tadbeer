import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/utils/utils.dart' as sqflite_utils;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../features/ayah_links/ayah_link_model.dart';
import '../../features/bookmarks/bookmark_model.dart';
import '../../features/highlights/highlight_model.dart';
import '../../features/notes/note_model.dart';
import '../../features/tadabbur/tadbeer_model.dart';
import '../../features/quran/data/reading_position_model.dart';
import '../../features/reminders/reminder_model.dart';
import '../../features/settings/user_settings_model.dart';

/// SQLite Database Manager for all user-generated data in Tadbeer.
///
/// NOTE:
/// Strictly stores only user-generated data:
/// - Notes
/// - Bookmarks
/// - Highlights
/// - Reading Position
/// - Tadbeer Answers
/// - Verse Links
/// - Reminders
/// - Settings
///
/// Neither the Quran dataset nor the Mushaf Layout is stored in this database.
class UserDatabase {
  static final UserDatabase instance = UserDatabase._internal();
  UserDatabase._internal();

  static const String databaseFileName = 'tadbeer_user_data.db';
  static const int databaseVersion = 1;

  Database? _database;

  Database get db {
    if (_database == null) {
      throw StateError(
        'UserDatabase has not been initialized. Call init() first.',
      );
    }
    return _database!;
  }

  bool get isOpen => _database != null && _database!.isOpen;

  /// Initializes the SQLite engine and opens the database.
  /// If [customPath] is provided (or in-memory path), it will be used.
  Future<void> init([String? customPath]) async {
    if (_database != null && _database!.isOpen) return;

    // Disable watchdog timer to prevent fake_async pending timer leaks during widget tests
    // ignore: deprecated_member_use
    sqflite_utils.lockWarningCallback = null;
    // ignore: deprecated_member_use
    sqflite_utils.lockWarningDuration = null;

    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (customPath != null) {
      path = customPath;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      path = p.join(docDir.path, databaseFileName);
    }

    _database = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Reading Position Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reading_position (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        page INTEGER NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Notes Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        surah_number INTEGER,
        ayah_number INTEGER,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Bookmarks Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Highlights Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        color_index INTEGER NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. Reminders Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        is_enabled INTEGER NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. Verse Links (Ayah Links) Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ayah_links (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 7. Tadbeer Answers Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tadbeer_items (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tadabbur_items (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 8. User Settings Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ==================== READING POSITION ====================

  Future<ReadingPosition?> loadReadingPosition() async {
    if (!isOpen) return null;
    try {
      final rows = await db.query('reading_position', where: 'id = 1');
      if (rows.isEmpty) return null;
      final data =
          jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
      return ReadingPosition.fromJson(data);
    } catch (e) {
      debugPrint('UserDatabase.loadReadingPosition: $e');
      return null;
    }
  }

  Future<void> saveReadingPosition(ReadingPosition position) async {
    if (!isOpen) return;
    try {
      await db.insert('reading_position', {
        'id': 1,
        'page': position.page,
        'surah_number': position.surahNumber,
        'ayah_number': position.ayahNumber,
        'data': jsonEncode(position.toJson()),
        'updated_at': position.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.saveReadingPosition: $e');
    }
  }

  // ==================== NOTES ====================

  Future<List<NoteItem>> loadNotes() async {
    if (!isOpen) return [];
    try {
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return NoteItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadNotes: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateNote(NoteItem note) async {
    if (!isOpen) return;
    try {
      await db.insert('notes', {
        'id': note.id,
        'type': note.type.name,
        'surah_number': note.surahNumber,
        'ayah_number': note.ayahNumber,
        'data': jsonEncode(note.toJson()),
        'created_at': note.createdAt.toIso8601String(),
        'updated_at': note.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.insertOrUpdateNote: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('UserDatabase.deleteNote: $e');
    }
  }

  // ==================== BOOKMARKS ====================

  Future<List<BookmarkItem>> loadBookmarks() async {
    if (!isOpen) return [];
    try {
      final rows = await db.query('bookmarks', orderBy: 'created_at DESC');
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return BookmarkItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadBookmarks: $e');
      return [];
    }
  }

  Future<void> insertBookmark(BookmarkItem bookmark) async {
    if (!isOpen) return;
    try {
      await db.insert('bookmarks', {
        'id': bookmark.id,
        'surah_number': bookmark.surahNumber,
        'ayah_number': bookmark.ayahNumber,
        'data': jsonEncode(bookmark.toJson()),
        'created_at': bookmark.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.insertBookmark: $e');
    }
  }

  Future<void> deleteBookmark(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('UserDatabase.deleteBookmark: $e');
    }
  }

  // ==================== HIGHLIGHTS ====================

  Future<List<HighlightItem>> loadHighlights() async {
    if (!isOpen) return [];
    try {
      final rows = await db.query('highlights', orderBy: 'created_at DESC');
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return HighlightItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadHighlights: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateHighlight(HighlightItem highlight) async {
    if (!isOpen) return;
    try {
      await db.insert('highlights', {
        'id': highlight.id,
        'surah_number': highlight.surahNumber,
        'ayah_number': highlight.ayahNumber,
        'color_index': highlight.colorIndex,
        'data': jsonEncode(highlight.toJson()),
        'created_at': highlight.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.insertOrUpdateHighlight: $e');
    }
  }

  Future<void> deleteHighlight(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('highlights', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('UserDatabase.deleteHighlight: $e');
    }
  }

  // ==================== REMINDERS ====================

  Future<List<ReminderItem>> loadReminders() async {
    if (!isOpen) return [];
    try {
      final rows = await db.query('reminders', orderBy: 'created_at ASC');
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return ReminderItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadReminders: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateReminder(ReminderItem reminder) async {
    if (!isOpen) return;
    try {
      await db.insert('reminders', {
        'id': reminder.id,
        'is_enabled': reminder.isEnabled ? 1 : 0,
        'data': jsonEncode(reminder.toJson()),
        'created_at': reminder.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.insertOrUpdateReminder: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('UserDatabase.deleteReminder: $e');
    }
  }

  // ==================== AYAH LINKS ====================

  Future<List<AyahLinkItem>> loadAyahLinks() async {
    if (!isOpen) return [];
    try {
      final rows = await db.query('ayah_links', orderBy: 'updated_at DESC');
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return AyahLinkItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadAyahLinks: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateAyahLink(AyahLinkItem link) async {
    if (!isOpen) return;
    try {
      await db.insert('ayah_links', {
        'id': link.id,
        'data': jsonEncode(link.toJson()),
        'created_at': link.createdAt.toIso8601String(),
        'updated_at': link.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('UserDatabase.insertOrUpdateAyahLink: $e');
    }
  }

  Future<void> deleteAyahLink(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('ayah_links', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('UserDatabase.deleteAyahLink: $e');
    }
  }

  // ==================== TADBEER ANSWERS ====================

  Future<List<TadbeerItem>> loadTadbeerItems() async {
    if (!isOpen) return [];
    try {
      var rows = await db.query('tadbeer_items', orderBy: 'updated_at DESC');
      if (rows.isEmpty) {
        final legacyRows = await db.query(
          'tadabbur_items',
          orderBy: 'updated_at DESC',
        );
        if (legacyRows.isNotEmpty) {
          rows = legacyRows;
        }
      }
      return rows.map((r) {
        final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
        return TadbeerItem.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('UserDatabase.loadTadbeerItems: $e');
      return [];
    }
  }

  /// Backward compatibility alias
  Future<List<TadbeerItem>> loadTadabburItems() => loadTadbeerItems();

  Future<void> insertOrUpdateTadbeer(TadbeerItem item) async {
    if (!isOpen) return;
    try {
      final values = {
        'id': item.id,
        'surah_number': item.surahNumber,
        'ayah_number': item.ayahNumber,
        'data': jsonEncode(item.toJson()),
        'updated_at': item.updatedAt.toIso8601String(),
      };
      await db.insert(
        'tadbeer_items',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      try {
        await db.insert(
          'tadabbur_items',
          values,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('UserDatabase.insertOrUpdateTadbeer: $e');
    }
  }

  /// Backward compatibility alias
  Future<void> insertOrUpdateTadabbur(TadbeerItem item) =>
      insertOrUpdateTadbeer(item);

  Future<void> deleteTadbeer(String id) async {
    if (!isOpen) return;
    try {
      await db.delete('tadbeer_items', where: 'id = ?', whereArgs: [id]);
      try {
        await db.delete('tadabbur_items', where: 'id = ?', whereArgs: [id]);
      } catch (_) {}
    } catch (e) {
      debugPrint('UserDatabase.deleteTadbeer: $e');
    }
  }

  /// Backward compatibility alias
  Future<void> deleteTadabbur(String id) => deleteTadbeer(id);

  // ==================== USER SETTINGS ====================

  Future<UserSettings?> loadSettings() async {
    if (!isOpen) return null;
    try {
      final rows = await db.query('user_settings');
      if (rows.isEmpty) return null;
      final map = <String, dynamic>{};
      for (final r in rows) {
        final key = r['key'] as String;
        final val = r['value'] as String;
        try {
          map[key] = jsonDecode(val);
        } catch (_) {
          map[key] = val;
        }
      }
      return UserSettings.fromJson(map);
    } catch (e) {
      debugPrint('UserDatabase.loadSettings: $e');
      return null;
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    if (!isOpen) return;
    try {
      for (final entry in settings.toJson().entries) {
        await db.insert('user_settings', {
          'key': entry.key,
          'value': jsonEncode(entry.value),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      debugPrint('UserDatabase.saveSettings: $e');
    }
  }

  // ==================== FULL REPLACEMENT / RESTORE ====================

  Future<void> clearAllUserData() async {
    if (!isOpen) return;
    try {
      await db.delete('reading_position');
      await db.delete('notes');
      await db.delete('bookmarks');
      await db.delete('highlights');
      await db.delete('reminders');
      await db.delete('ayah_links');
      await db.delete('tadbeer_items');
      try {
        await db.delete('tadabbur_items');
      } catch (_) {}
      await db.delete('user_settings');
    } catch (e) {
      debugPrint('UserDatabase.clearAllUserData: $e');
    }
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
