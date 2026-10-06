import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/storage/user_data_store.dart';
import '../../../core/utils/arabic_search_normalizer.dart';
import '../../../data/quran/quran_models.dart';
import '../../../data/quran/quran_repository.dart';
import '../../../data/quran/tadabbur_model.dart';

/// Modal sheet for "🌿 وقفة تدبر" (Tadabbur Pause).
///
/// EDUCATIONAL NOTE:
/// Offers a focused, contemplative pause directly on an Ayah:
/// - 4 authentic, sequential reflection questions shown ONE at a time.
/// - The user can skip, write, or save at any point without obligation to finish all questions.
/// - Empty answers are never stored.
/// - Preserves answers across sessions via stable Ayah ID.
class TadabburPauseSheet extends StatefulWidget {
  final Ayah ayah;

  const TadabburPauseSheet({super.key, required this.ayah});

  /// Displays the Tadabbur Pause sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, Ayah ayah) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TadabburPauseSheet(ayah: ayah),
    );
  }

  @override
  State<TadabburPauseSheet> createState() => _TadabburPauseSheetState();
}

class _TadabburPauseSheetState extends State<TadabburPauseSheet> {
  int _currentQuestionIndex = 0; // 0..3 for questions 1..4
  final Map<int, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load existing answers if user previously reflected on this ayah
    final existingTadabbur = UserDataStore.instance.getTadabbur(
      widget.ayah.surahNumber,
      widget.ayah.ayahNumber,
    );

    for (int i = 1; i <= TadabburItem.questions.length; i++) {
      final initialText = existingTadabbur?.answers[i] ?? '';
      _controllers[i] = TextEditingController(text: initialText);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAndClose() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final answers = <int, String>{};
    _controllers.forEach((index, controller) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        answers[index] = text;
      }
    });

    await UserDataStore.instance.saveTadabbur(
      surahNumber: widget.ayah.surahNumber,
      ayahNumber: widget.ayah.ayahNumber,
      ayahId: widget.ayah.id,
      answers: answers,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            answers.isEmpty
                ? 'تم مسح الإجابات الفارغة بنجاح'
                : 'تم حفظ وقفة التدبر بنجاح',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.olive,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < TadabburItem.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _saveAndClose();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surah = QuranRepository.instance.getSurah(widget.ayah.surahNumber);
    final questionNumber = _currentQuestionIndex + 1;
    final currentQuestion = TadabburItem.questions[_currentQuestionIndex];
    final activeController = _controllers[questionNumber]!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.comsilkLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightBorder,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Sheet Title & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.olive.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_outlined,
                            size: 18,
                            color: AppColors.olive,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'وقفة تدبر',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.comsilk
                                : AppColors.oliveDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Ayah Header & Snippet
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.comsilk,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : const Color(0xFFE2DDD0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'سورة ${surah.name} · الآية ${ArabicSearchNormalizer.toArabicDigits(widget.ayah.ayahNumber)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.olive,
                            ),
                          ),
                          Text(
                            'ص ${ArabicSearchNormalizer.toArabicDigits(widget.ayah.page)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.nightSubtitle
                                  : AppColors.daySubtitle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '﴿ ${widget.ayah.text} ﴾',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: 15,
                          height: 1.6,
                          color: isDark
                              ? AppColors.nightQuranText
                              : AppColors.dayQuranText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Question Stepper indicator: dots and label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السؤال ${ArabicSearchNormalizer.toArabicDigits(questionNumber)} من ٤',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.olive,
                      ),
                    ),
                    Row(
                      children: List.generate(TadabburItem.questions.length, (
                        idx,
                      ) {
                        final isCurrent = idx == _currentQuestionIndex;
                        final isFilled =
                            (_controllers[idx + 1]?.text.trim().isNotEmpty ??
                            false);

                        return Container(
                          width: isCurrent ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.olive
                                : isFilled
                                ? AppColors.olive.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.olive.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.olive.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    currentQuestion,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Reflection Input
                TextField(
                  controller: activeController,
                  maxLines: 4,
                  textDirection: TextDirection.rtl,
                  autofocus: false,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark
                        ? AppColors.nightQuranText
                        : AppColors.dayQuranText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب ما خطر ببالك...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.nightSubtitle
                          : AppColors.daySubtitle,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.comsilk,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : const Color(0xFFDDD7C8),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.olive,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stepper Action Buttons
                Row(
                  children: [
                    // Previous button (if > 0)
                    if (_currentQuestionIndex > 0) ...[
                      OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.comsilk
                              : AppColors.oliveDark,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('السابق'),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Next button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.olive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          _currentQuestionIndex <
                                  TadabburItem.questions.length - 1
                              ? Icons.arrow_back
                              : Icons.check,
                          size: 16,
                        ),
                        label: Text(
                          _currentQuestionIndex <
                                  TadabburItem.questions.length - 1
                              ? 'التالي'
                              : 'تم وحفظ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Save & finish at any stage button
                if (_currentQuestionIndex < TadabburItem.questions.length - 1)
                  Center(
                    child: TextButton.icon(
                      onPressed: _saveAndClose,
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('حفظ ما كتبت الآن وإنهاء'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.oliveSoft
                            : AppColors.olive,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
