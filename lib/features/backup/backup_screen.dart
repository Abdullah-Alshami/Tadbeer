import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/security/backup_crypto_service.dart';

/// Screen for creating and restoring encrypted user backups (.quranbackup).
///
/// EDUCATIONAL NOTE:
/// Backup Architecture:
/// - Offline export with user-selected password using AES-256-CBC and SHA-256 payload checksum.
/// - Gzip compression reduces size.
/// - RESTORE CONTRACT: Restore strictly REPLACES current local data after verifying checksum.
///   It never merges to ensure data integrity and avoid orphaned or duplicated records.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _includeNotes = true;
  bool _includeBookmarks = true;
  bool _includeHighlights = true;
  bool _includeSettings = true;
  bool _includeReminders = true;
  final TextEditingController _passwordController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    setState(() => _isProcessing = true);
    final l10n = context.l10n;

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filePath = '${tempDir.path}/tadbeer_backup_$timestamp.quranbackup';

      final result = await BackupCryptoService.createBackupFile(
        targetPath: filePath,
        password: _passwordController.text,
        notes: _includeNotes,
        bookmarks: _includeBookmarks,
        highlights: _includeHighlights,
        settings: _includeSettings,
        reminders: _includeReminders,
      );

      if (!result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ?? 'فشل إنشاء النسخة الاحتياطية',
              ),
            ),
          );
        }
        return;
      }

      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], subject: 'Tadbeer Backup'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.backupSuccess,
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
            backgroundColor: AppColors.olive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickAndRestore() async {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final files = await FilePicker.pickFiles(type: FileType.any);

    if (files.isEmpty) return;
    final path = files.first.path;
    if (path == null) return;

    final file = File(path);

    if (!mounted) return;

    // Show Warning Dialog before restore
    final passwordRestoreController = TextEditingController();
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Text(
              l10n.restoreWarningTitle,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.restoreWarningMessage,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                color: isDark
                    ? AppColors.nightQuranText
                    : AppColors.dayQuranText,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordRestoreController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.enterBackupPassword,
                labelStyle: const TextStyle(fontFamily: 'Amiri'),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontFamily: 'Amiri'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.confirmRestore,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    setState(() => _isProcessing = true);
    final result = await BackupCryptoService.restoreFromFile(
      file: file,
      password: passwordRestoreController.text,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.restoreSuccess,
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          backgroundColor: AppColors.olive,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.comsilkLight,
          title: const Text(
            'فشلت الاستعادة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            result.errorMessage ?? l10n.corruptBackupError,
            style: const TextStyle(fontFamily: 'Amiri'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.close,
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.backup,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Export Section Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.upload_file_outlined,
                          color: AppColors.olive,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.exportBackup,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.comsilk
                                : AppColors.oliveDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'اختر البيانات التي ترغب بتضمينها في النسخة المشفرة (.quranbackup):',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.olive,
                      title: Text(
                        l10n.notes,
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      value: _includeNotes,
                      onChanged: (val) =>
                          setState(() => _includeNotes = val ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.olive,
                      title: Text(
                        l10n.bookmarks,
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      value: _includeBookmarks,
                      onChanged: (val) =>
                          setState(() => _includeBookmarks = val ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.olive,
                      title: Text(
                        l10n.highlights,
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      value: _includeHighlights,
                      onChanged: (val) =>
                          setState(() => _includeHighlights = val ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.olive,
                      title: Text(
                        l10n.reminders,
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      value: _includeReminders,
                      onChanged: (val) =>
                          setState(() => _includeReminders = val ?? true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      activeColor: AppColors.olive,
                      title: Text(
                        l10n.settings,
                        style: const TextStyle(fontFamily: 'Amiri'),
                      ),
                      value: _includeSettings,
                      onChanged: (val) =>
                          setState(() => _includeSettings = val ?? true),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.enterBackupPassword,
                        labelStyle: const TextStyle(fontFamily: 'Amiri'),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : AppColors.comsilkLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _exportBackup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(
                        l10n.exportBackup,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Restore Section Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.download_for_offline_outlined,
                          color: AppColors.olive,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.restoreBackup,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.comsilk
                                : AppColors.oliveDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'استعادة البيانات من ملف .quranbackup محفوظ سابقًا. تُستبدل البيانات الحالية بالكامل بعد التحقق من سلامة التشفير وصحة الملف.',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _pickAndRestore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.comsilk
                            : AppColors.oliveDark,
                        side: const BorderSide(
                          color: AppColors.olive,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.folder_open),
                      label: Text(
                        l10n.restoreBackup,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
