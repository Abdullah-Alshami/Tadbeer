import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbeer/core/services/backup_crypto_service.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';
import 'package:tadbeer/features/notes/note_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late File dataFile;
  late File backupFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadbeer_backup_test_');
    dataFile = File('${tempDir.path}/user_data.json');
    backupFile = File('${tempDir.path}/test.quranbackup');
    await UserDataStore.instance.init(dataFile);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Encrypted Backup & Restore Tests', () {
    test(
      'Export, Encrypt, and Successful Restore with Full Replacement',
      () async {
        final store = UserDataStore.instance;

        // Seed initial data
        await store.saveReadingPosition(
          page: 50,
          surahNumber: 2,
          ayahNumber: 286,
        );
        await store.saveNote(
          id: 'backup-note-1',
          type: NoteType.free,
          title: 'ملاحظة النسخ الاحتياطي',
          content: 'محتوى النسخ الاحتياطي السري',
        );
        await store.updateSettings(
          store.settings.copyWith(themeMode: ThemeMode.dark),
        );

        // 1. Create encrypted backup
        const password = 'SecretPassword123';
        final exportRes = await BackupCryptoService.createBackupFile(
          targetPath: backupFile.path,
          password: password,
        );
        expect(exportRes.success, isTrue);
        expect(backupFile.existsSync(), isTrue);

        // Verify backup is encrypted and contains required metadata
        final backupContent =
            jsonDecode(backupFile.readAsStringSync()) as Map<String, dynamic>;
        expect(backupContent['magic'], equals(BackupCryptoService.magicHeader));
        expect(backupContent['checksum'], isNotNull);
        expect(backupContent['cipher'], isNotNull);

        // 2. Modify local storage to different values (to test complete replacement)
        await store.saveReadingPosition(page: 1, surahNumber: 1, ayahNumber: 1);
        await store.saveNote(
          id: 'new-unrelated-note',
          type: NoteType.free,
          title: 'ملاحظة جديدة يجب أن تُستبدل بالكامل',
          content: 'محتوى جديد',
        );
        await store.updateSettings(
          store.settings.copyWith(themeMode: ThemeMode.light),
        );

        expect(store.notes.length, equals(2));
        expect(store.readingPosition.page, equals(1));
        expect(store.settings.themeMode, equals(ThemeMode.light));

        // 3. Restore from backup
        final restoreRes = await BackupCryptoService.restoreFromFile(
          file: backupFile,
          password: password,
        );
        expect(restoreRes.success, isTrue);

        // Verify that local data was COMPLETELY REPLACED (not merged!)
        expect(store.readingPosition.page, equals(50));
        expect(store.notes.length, equals(1));
        expect(store.notes.first.id, equals('backup-note-1'));
        expect(store.notes.first.title, equals('ملاحظة النسخ الاحتياطي'));
        expect(store.settings.themeMode, equals(ThemeMode.dark));
      },
    );

    test('Incorrect Password Rejects Restore and Imports Nothing', () async {
      final store = UserDataStore.instance;
      await store.saveReadingPosition(page: 10, surahNumber: 2, ayahNumber: 1);

      await BackupCryptoService.createBackupFile(
        targetPath: backupFile.path,
        password: 'CorrectPassword',
      );

      // Try restore with wrong password
      final restoreRes = await BackupCryptoService.restoreFromFile(
        file: backupFile,
        password: 'WrongPassword',
      );

      expect(restoreRes.success, isFalse);
      expect(restoreRes.errorMessage, contains('password'));
    });

    test('Corrupted Backup Rejects Restore and Imports Nothing', () async {
      await BackupCryptoService.createBackupFile(
        targetPath: backupFile.path,
        password: 'Password',
      );

      // Corrupt the cipher text in the backup file
      final json =
          jsonDecode(backupFile.readAsStringSync()) as Map<String, dynamic>;
      json['cipher'] = base64Encode(utf8.encode('corrupted data'));
      backupFile.writeAsStringSync(jsonEncode(json));

      final restoreRes = await BackupCryptoService.restoreFromFile(
        file: backupFile,
        password: 'Password',
      );

      expect(restoreRes.success, isFalse);
    });
  });
}
