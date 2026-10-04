import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../storage/user_data_store.dart';

/// Represents the outcome of a backup export or restore operation.
class BackupResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;

  const BackupResult.success(this.filePath)
    : success = true,
      errorMessage = null;

  const BackupResult.failure(this.errorMessage)
    : success = false,
      filePath = null;
}

/// Service handling encrypted, compressed, and checksum-verified backups (.quranbackup).
///
/// EDUCATIONAL NOTE:
/// Why encryption and checksums?
/// 1. Backups are entirely offline and user-managed (no cloud, no server).
/// 2. User reflections and notes are personal. AES-256 encryption protects user reflections
///    when files are exported, emailed, or stored on external media.
/// 3. The SHA-256 checksum is calculated on the raw JSON payload BEFORE compression and encryption.
///    Upon restoration, after decryption and decompression, the payload's checksum is verified
///    against the header. If even a single byte was corrupted or tampered with, the entire
///    operation is aborted and NOTHING is imported.
///
/// IMPORTANT INVARIANT:
/// Restore intentionally replaces the existing user dataset. It must NEVER merge with
/// existing data. If the backup is invalid, current user data remains 100% untouched.
class BackupCryptoService {
  BackupCryptoService._();

  static const String magicHeader = 'TADBEER_BACKUP';
  static const int formatVersion = 1;
  static const String backupExtension = '.quranbackup';

  static Uint8List _generateRandomBytes(int length) {
    final rand = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rand.nextInt(256);
    }
    return bytes;
  }

  static enc.Key _deriveKey(String password, Uint8List salt) {
    // Key derivation using SHA-256(password + salt)
    final input = utf8.encode(password) + salt;
    final digest = sha256.convert(input);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Exports an encrypted, compressed, versioned, and checksummed backup file.
  static Future<BackupResult> createBackupFile({
    required String targetPath,
    String password = '',
    bool notes = true,
    bool bookmarks = true,
    bool highlights = true,
    bool settings = true,
    bool reminders = true,
    bool ayahLinks = true,
  }) async {
    try {
      final snapshot = UserDataStore.instance.exportSnapshot(
        notes: notes,
        bookmarks: bookmarks,
        highlights: highlights,
        settings: settings,
        reminders: reminders,
        ayahLinks: ayahLinks,
      );

      final rawPayloadBytes = utf8.encode(jsonEncode(snapshot));
      final checksum = sha256.convert(rawPayloadBytes).toString();

      // 1. Gzip compression (reduces backup file size significantly)
      final compressedBytes = gzip.encode(rawPayloadBytes);

      // 2. Encryption (AES-256 in CBC mode with randomized IV and Salt)
      final salt = _generateRandomBytes(16);
      final ivBytes = _generateRandomBytes(16);
      final key = _deriveKey(password, salt);
      final iv = enc.IV(ivBytes);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(compressedBytes, iv: iv);

      // 3. Assemble container package
      final package = {
        'magic': magicHeader,
        'version': formatVersion,
        'schemaVersion': UserDataStore.currentSchemaVersion,
        'salt': enc.Encrypted(salt).base64,
        'iv': iv.base64,
        'checksum': checksum,
        'createdAt': DateTime.now().toIso8601String(),
        'cipher': encrypted.base64,
      };

      final file = File(targetPath);
      await file.writeAsString(jsonEncode(package), flush: true);

      return BackupResult.success(file.path);
    } catch (e) {
      return BackupResult.failure(e.toString());
    }
  }

  /// Validates and restores user data from a .quranbackup file.
  ///
  /// IMPORTANT:
  /// If file is invalid or corrupt, NO data is touched.
  /// Upon success, current data is COMPLETELY REPLACED.
  static Future<BackupResult> restoreFromFile({
    required File file,
    String password = '',
  }) async {
    try {
      if (!await file.exists()) {
        return const BackupResult.failure('Backup file not found');
      }

      final content = await file.readAsString();
      final package = jsonDecode(content) as Map<String, dynamic>;

      // 1. Verify magic header
      if (package['magic'] != magicHeader) {
        return const BackupResult.failure('Invalid backup file format');
      }

      // 2. Verify schema version compatibility
      final schemaVersion = package['schemaVersion'] as int? ?? 0;
      if (schemaVersion > UserDataStore.currentSchemaVersion) {
        return const BackupResult.failure(
          'Backup file was created with a newer version of Tadbeer',
        );
      }

      final salt = enc.Encrypted.fromBase64(package['salt'] as String).bytes;
      final iv = enc.IV.fromBase64(package['iv'] as String);
      final expectedChecksum = package['checksum'] as String;
      final cipher = enc.Encrypted.fromBase64(package['cipher'] as String);

      // 3. Decrypt
      final key = _deriveKey(password, salt);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      List<int> decryptedCompressed;
      try {
        decryptedCompressed = encrypter.decryptBytes(cipher, iv: iv);
      } catch (e) {
        return const BackupResult.failure('Incorrect password or corrupt file');
      }

      // 4. Decompress
      List<int> decompressedBytes;
      try {
        decompressedBytes = gzip.decode(decryptedCompressed);
      } catch (e) {
        return const BackupResult.failure(
          'Incorrect password or corrupt backup data (decompression failed)',
        );
      }

      // 5. Integrity Checksum Verification
      final actualChecksum = sha256.convert(decompressedBytes).toString();
      if (actualChecksum != expectedChecksum) {
        return const BackupResult.failure(
          'Checksum mismatch: backup file data is corrupted',
        );
      }

      // 6. Parse and Validate JSON structure
      final payloadJson =
          jsonDecode(utf8.decode(decompressedBytes)) as Map<String, dynamic>;
      if (payloadJson['app'] != 'Tadbeer') {
        return const BackupResult.failure('Invalid app identifier in backup');
      }

      // 7. Atomic complete replacement
      await UserDataStore.instance.replaceAllUserData(payloadJson);

      return BackupResult.success(file.path);
    } catch (e) {
      return BackupResult.failure('Failed to restore backup: $e');
    }
  }
}
