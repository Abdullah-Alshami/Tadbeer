import 'dart:math';

// مكتبة Flutter الأساسية التي أستخدمها لبناء واجهة الشاشة
import 'package:flutter/material.dart';

// هذه الملفات أرجع لها حسب الوظيفة التي أحتاجها في الشاشة
import '../../app/localization.dart';
import '../../app/theme.dart';
import '../../core/storage/user_data_store.dart';
import '../../core/utils/arabic_search_normalizer.dart';
import '../../features/quran/data/quran_models.dart';
import '../../features/quran/data/quran_repository.dart';
import '../home/home_screen.dart';

/// شاشة الترحيب التي تظهر عند تشغيل التطبيق
///
/// هنا أضع آية مرتبطة بالتدبر، وأعطي المستخدم خيار
/// إخفاء شاشة الترحيب نهائيًا.
class TadbeerIntroScreen extends StatefulWidget {
  const TadbeerIntroScreen({super.key});

  @override
  State<TadbeerIntroScreen> createState() => _TadbeerIntroScreenState();
}

/// Compatibility alias
typedef TadabburIntroScreen = TadbeerIntroScreen;

class _TadbeerIntroScreenState extends State<TadbeerIntroScreen> {
  // هنا خزنت أرقام السور والآيات التي أريد استخدامها في شاشة الترحيب.
  // الرقم الأول = رقم السورة
  // الرقم الثاني = رقم الآية
  static const List<(int, int)> _tadbeerAyahRefs = [
    (47, 24),
    (4, 82),
    (38, 29),
    (23, 68),
    (59, 21),
    (88, 17),
    (50, 6),
    (6, 50),
    (30, 8),
    (10, 24),
  ];

  // هذا المتغير سأضع فيه الآية التي تم اختيارها عند فتح الشاشة.
  // late يعني أنني سأعطيه قيمة قبل استخدامه.
  late final (int, int) _chosenRef;

  // false في البداية لأن الـ Checkbox غير محدد.
  bool _doNotShowAgain = false;

  @override
  void initState() {
    super.initState();

    // أختار آية عشوائية من القائمة عند فتح الشاشة.
    // بعد الاختيار تبقى نفس الآية طالما الشاشة مفتوحة.
    final random = Random();

    _chosenRef = _tadbeerAyahRefs[random.nextInt(_tadbeerAyahRefs.length)];
  }

  // هذه الدالة تعمل عندما أضغط على زر "متابعة".
  Future<void> _handleContinue() async {
    // أحصل على Navigator حتى أستطيع الانتقال إلى الصفحة التالية.
    final navigator = Navigator.of(context);

    // إذا كان المستخدم فعل خيار عدم إظهار الشاشة مرة أخرى...
    if (_doNotShowAgain) {
      // أجيب الإعدادات الحالية حتى لا أمسح باقي الإعدادات.
      final settings = UserDataStore.instance.settings;

      // أحفظ فقط أن شاشة الترحيب لا تظهر مرة أخرى.
      await UserDataStore.instance.updateSettings(
        settings.copyWith(hideTadbeerIntroPermanently: true),
      );
    }

    // بعد الضغط على متابعة أنتقل إلى الصفحة الرئيسية.
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // هذا يعطيني النصوص حسب اللغة الحالية للتطبيق.
    final l10n = context.l10n;

    // أعرف من هنا هل التطبيق حاليًا في الوضع الداكن.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // هذا هو المصدر الذي أجيب منه بيانات القرآن.
    final repo = QuranRepository.instance;

    // سأضع هنا الآية والسورة بعد البحث عنها.
    Ayah? currentAyah;
    Surah? currentSurah;

    // أتأكد أولًا أن بيانات القرآن تم تحميلها.
    if (repo.isLoaded) {
      try {
        // أجيب الآية باستخدام رقم السورة ورقم الآية
        // اللذين اخترتهما سابقًا.
        currentAyah = repo.getAyah(_chosenRef.$1, _chosenRef.$2);

        // أجيب معلومات السورة نفسها.
        currentSurah = repo.getSurah(_chosenRef.$1);
      } catch (_) {
        // إذا حصل خطأ أترك القيم فارغة
        // وسيتم استخدام النص الاحتياطي الموجود أسفل.
      }
    }

    // إذا وجدت الآية أستخدمها، وإذا لم أجدها أستخدم النص الاحتياطي.
    final verseText = currentAyah?.text ?? l10n.tadbeerVerse;

    // أجهز اسم السورة ورقم الآية حتى أعرضهما تحت النص.
    final verseRef = (currentSurah != null && currentAyah != null)
        ? 'سورة ${currentSurah.name} · الآية '
              '${ArabicSearchNormalizer.toArabicDigits(currentAyah.ayahNumber)}'
        : l10n.tadbeerVerseRef;

    return Directionality(
      // اتجاه الشاشة يتغير حسب اللغة.
      textDirection: context.currentLanguage.direction,

      child: Scaffold(
        // أغير لون الخلفية حسب الوضع الداكن أو الفاتح.
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.comsilkLight,

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // هذه المسافة حول محتوى الشاشة.
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),

              child: ConstrainedBox(
                // أحدد عرض المحتوى حتى لا يصبح عريضًا جدًا.
                constraints: const BoxConstraints(maxWidth: 540),

                child: Column(
                  // أجعل العناصر في المنتصف بشكل عام.
                  mainAxisAlignment: MainAxisAlignment.center,

                  // أجعل العناصر تأخذ العرض المتاح.
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // أيقونة التطبيق الموجودة في أعلى الشاشة.
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,

                        decoration: BoxDecoration(
                          // لون خفيف حول الأيقونة.
                          color: AppColors.olive.withValues(alpha: 0.15),

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: AppColors.olive.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),

                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 36,
                          color: AppColors.olive,
                        ),
                      ),
                    ),

                    // أستخدم SizedBox لعمل مسافة بين الأيقونة واسم التطبيق.
                    const SizedBox(height: 24),

                    // اسم التطبيق.
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,

                        color: isDark ? AppColors.comsilk : AppColors.oliveDark,
                      ),
                    ),

                    // الوصف القصير الموجود تحت اسم التطبيق.
                    Text(
                      l10n.appTagline,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 14,

                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),

                    // مسافة قبل صندوق الآية.
                    const SizedBox(height: 36),

                    // صندوق الآية.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),

                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.comsilk,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightBorder,
                          width: 1.5,
                        ),

                        // ظل خفيف أسفل صندوق الآية.
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // هنا أعرض نص الآية.
                          Text(
                            '﴿ $verseText ﴾',
                            textAlign: TextAlign.center,

                            // القرآن نفسه يبقى من اليمين إلى اليسار.
                            textDirection: TextDirection.rtl,

                            style: TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: 22,
                              height: 2.1,

                              color: isDark
                                  ? AppColors.nightQuranText
                                  : AppColors.dayQuranText,
                            ),
                          ),

                          // مسافة بين الآية ومرجعها.
                          const SizedBox(height: 14),

                          // اسم السورة ورقم الآية.
                          Text(
                            verseRef,
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,

                              color: isDark
                                  ? AppColors.oliveSoft
                                  : AppColors.olive,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // مسافة بعد صندوق الآية.
                    const SizedBox(height: 28),

                    // الرسالة التي تشرح فكرة التدبر للمستخدم.
                    Text(
                      l10n.tadbeerMessage,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,

                        color: isDark
                            ? AppColors.nightSubtitle
                            : AppColors.daySubtitle,
                      ),
                    ),

                    // مسافة قبل زر متابعة.
                    const SizedBox(height: 32),

                    // زر الانتقال إلى الصفحة الرئيسية.
                    ElevatedButton(
                      // عند الضغط على الزر أشغل دالة المتابعة.
                      onPressed: _handleContinue,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.olive,
                        foregroundColor: Colors.white,

                        // ارتفاع داخلي للزر.
                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        // لا أريد ظلًا قويًا للزر.
                        elevation: 0,
                      ),

                      child: const Text(
                        'متابعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // هذه المسافة تفصل زر متابعة عن خيار عدم إظهار النافذة.
                    const SizedBox(height: 16),

                    // هذا الجزء كاملًا مسؤول عن خيار:
                    // "لا تظهر لي هذه النافذة مرة أخرى"
                    InkWell(
                      // أستطيع الضغط على المنطقة كلها وليس المربع فقط.
                      onTap: () {
                        setState(() {
                          // أعكس الحالة:
                          // true تصبح false
                          // و false تصبح true
                          _doNotShowAgain = !_doNotShowAgain;
                        });
                      },

                      borderRadius: BorderRadius.circular(8),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),

                        child: Row(
                          // أجعل الـ Checkbox والنص في المنتصف.
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            // مربع الاختيار نفسه.
                            Checkbox(
                              // حالة المربع مرتبطة بالمتغير.
                              value: _doNotShowAgain,

                              activeColor: AppColors.olive,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),

                              // إذا ضغطت على المربع نفسه أغير حالته.
                              onChanged: (val) {
                                setState(() {
                                  _doNotShowAgain = val ?? false;
                                });
                              },
                            ),

                            // مسافة صغيرة بين المربع والنص.
                            const SizedBox(width: 4),

                            // النص بجانب الـ Checkbox.
                            Text(
                              'لا تظهر لي هذه النافذة مرة أخرى',

                              style: TextStyle(
                                fontSize: 14,

                                color: isDark
                                    ? AppColors.nightQuranText
                                    : AppColors.dayQuranText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
