import 'package:flutter/material.dart';

import '../../../app/localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../../../data/ayah_links/ayah_link_repository.dart';
import '../../../data/quran/quran_models.dart';
import '../../../data/quran/quran_repository.dart';

/// Dialog allowing user to select a verified Quran Ayah and add it to an Ayah Link.
class AddVerseToLinkDialog extends StatefulWidget {
  final String linkId;
  final List<int> existingAyahIds;

  const AddVerseToLinkDialog({
    super.key,
    required this.linkId,
    this.existingAyahIds = const [],
  });

  static Future<bool?> show(
    BuildContext context, {
    required String linkId,
    List<int> existingAyahIds = const [],
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AddVerseToLinkDialog(
        linkId: linkId,
        existingAyahIds: existingAyahIds,
      ),
    );
  }

  @override
  State<AddVerseToLinkDialog> createState() => _AddVerseToLinkDialogState();
}

class _AddVerseToLinkDialogState extends State<AddVerseToLinkDialog> {
  late int _selectedSurahNumber;
  late int _selectedAyahNumber;
  final TextEditingController _noteController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selectedSurahNumber = 1;
    _selectedAyahNumber = 1;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Surah get _currentSurah =>
      QuranRepository.instance.getSurah(_selectedSurahNumber);

  Ayah? get _currentAyah => QuranRepository.instance.getAyah(
    _selectedSurahNumber,
    _selectedAyahNumber,
  );

  bool get _isAlreadyAdded {
    final ayah = _currentAyah;
    if (ayah == null) return false;
    return widget.existingAyahIds.contains(ayah.id);
  }

  Future<void> _submit() async {
    final ayah = _currentAyah;
    if (ayah == null || _isAlreadyAdded) return;

    setState(() => _isAdding = true);
    try {
      final repo = AyahLinkRepository();
      final note = _noteController.text.trim();
      await repo.addVerseToLink(
        widget.linkId,
        ayahId: ayah.id,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        page: ayah.page,
        note: note.isEmpty ? null : note,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahs = QuranRepository.instance.surahs;
    final ayah = _currentAyah;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_add_outlined, color: AppColors.olive),
            const SizedBox(width: 8),
            Text(
              l10n.addVerse,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Surah & Ayah Pickers
              Row(
                children: [
                  // Surah dropdown
                  Expanded(
                    flex: 3,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'السورة',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.comsilk,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightBorder,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedSurahNumber,
                          isExpanded: true,
                          items: surahs.map((s) {
                            return DropdownMenuItem<int>(
                              value: s.number,
                              child: Text(
                                '${s.number}. ${s.name}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newSurah) {
                            if (newSurah != null) {
                              setState(() {
                                _selectedSurahNumber = newSurah;
                                _selectedAyahNumber = 1;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Ayah Number dropdown
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'الآية',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.comsilk,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightBorder,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedAyahNumber,
                          isExpanded: true,
                          items:
                              List.generate(
                                _currentSurah.ayahCount,
                                (i) => i + 1,
                              ).map((n) {
                                return DropdownMenuItem<int>(
                                  value: n,
                                  child: Text(
                                    ArabicSearchNormalizer.toArabicDigits(n),
                                  ),
                                );
                              }).toList(),
                          onChanged: (n) {
                            if (n != null) {
                              setState(() => _selectedAyahNumber = n);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Live Verse Preview
              if (ayah != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.comsilk,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '﴿ ${ayah.text} ﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: 15,
                          height: 1.8,
                          color: isDark
                              ? AppColors.nightQuranText
                              : AppColors.dayQuranText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'سورة ${_currentSurah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(ayah.ayahNumber)} · ص ${ArabicSearchNormalizer.toArabicDigits(ayah.page)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.nightSubtitle
                              : AppColors.daySubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAlreadyAdded) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'هذه الآية مضافة بالفعل لهذا الرابط',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
                const SizedBox(height: 14),
              ],

              // Note field
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ملاحظتك على هذه الآية في هذا الرابط (اختيارية)',
                  hintText: 'سجل ما لفت نظرك في ربط هذه الآية...',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.comsilk,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: (_isAlreadyAdded || _isAdding) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.olive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'إضافة إلى الرابط',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
