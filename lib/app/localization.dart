import 'package:flutter/material.dart';

enum AppLanguage {
  arabic('ar', 'العربية', TextDirection.rtl),
  english('en', 'English', TextDirection.ltr);

  final String code;
  final String label;
  final TextDirection direction;

  const AppLanguage(this.code, this.label, this.direction);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.arabic,
    );
  }
}

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  bool get isArabic => language == AppLanguage.arabic;

  // App Identity
  String get appName => isArabic ? 'تَدْبِير' : 'Tadbeer';
  String get appTagline =>
      isArabic ? 'قراءة وتدبّر القرآن الكريم' : 'Quran Reading & Reflection';

  // Navigation / Main Sections
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get quran => isArabic ? 'المصحف' : 'Quran';
  String get notes => isArabic ? 'الملاحظات' : 'Notes';
  String get bookmarks => isArabic ? 'المحفوظات' : 'Bookmarks';
  String get highlights => isArabic ? 'المميزة' : 'Highlights';
  String get search => isArabic ? 'البحث' : 'Search';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get reminders => isArabic ? 'التنبيهات' : 'Reminders';
  String get ayahLinks => isArabic ? 'روابط الآيات' : 'Ayah Links';
  String get backup => isArabic ? 'النسخ الاحتياطي' : 'Backup & Restore';
  String get about => isArabic ? 'عن تَدْبِير' : 'About Tadbeer';
  String get more => isArabic ? 'المزيد' : 'More';

  // Home Screen
  String get lastReading => isArabic ? 'آخر قراءة' : 'Last Reading';
  String get startFromBeginning =>
      isArabic ? 'ابدأ القراءة من الصفحة الأولى' : 'Start reading from page 1';
  String surahAndPage(String surahName, int page) =>
      isArabic ? 'سورة $surahName · ص $page' : 'Surah $surahName · p. $page';
  String get quickActions => isArabic ? 'الأقسام الرئيسية' : 'Main Sections';

  // Tadabbur Intro
  String get tadabburVerse =>
      'أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ أَمْ عَلَىٰ قُلُوبٍ أَقْفَالُهَا';
  String get tadabburVerseRef =>
      isArabic ? 'سورة محمد · آية ٢٤' : 'Surah Muhammad · Verse 24';
  String get tadabburMessage => isArabic
      ? 'تَدْبِير هو رفيقك الهادئ لقراءة كتاب الله وتأمّل آياته، بدون إعلانات أو اتّصال بالإنترنت، وتبقى بياناتك على جهازك فقط.'
      : 'Tadbeer is your calm companion for reading and reflecting upon the Quran, offline and private on your device.';
  String get continueToApp =>
      isArabic ? 'متابعة إلى التطبيق' : 'Continue to Tadbeer';
  String get hideIntroPermanently => isArabic
      ? 'إخفاء هذه الرسائل نهائيًا'
      : 'Never show this introduction again';

  // Quran Reader & Side Menu
  String pageNumber(int page) => isArabic ? 'صفحة $page' : 'Page $page';
  String juzNumber(int juz) => isArabic ? 'الجزء $juz' : 'Juz $juz';
  String hizbNumber(int hizb) => isArabic ? 'الحزب $hizb' : 'Hizb $hizb';
  String get surahs => isArabic ? 'السور' : 'Surahs';
  String get juzs => isArabic ? 'الأجزاء' : 'Juzs';
  String get jumpToPage => isArabic ? 'الانتقال إلى صفحة' : 'Jump to Page';
  String get enterPageNumber =>
      isArabic ? 'أدخل رقم الصفحة (١-٦٠٤)' : 'Enter page number (1-604)';
  String get go => isArabic ? 'انتقال' : 'Go';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get sajdah => isArabic ? 'سجدة تلاوة' : 'Sajdah';
  String get meccan => isArabic ? 'مكية' : 'Meccan';
  String get medinan => isArabic ? 'مدنية' : 'Medinan';
  String ayahCount(int count) => isArabic ? '$count آية' : '$count Verses';

  // Ayah Action Modal
  String get addNote => isArabic ? 'ملاحظة' : 'Note';
  String get saveBookmark => isArabic ? 'حفظ' : 'Bookmark';
  String get removeBookmark => isArabic ? 'إزالة الحفظ' : 'Remove Bookmark';
  String get highlight => isArabic ? 'تمييز' : 'Highlight';
  String get removeHighlight => isArabic ? 'إزالة التمييز' : 'Remove Highlight';
  String get copy => isArabic ? 'نسخ' : 'Copy';
  String get copiedToClipboard =>
      isArabic ? 'تم نسخ الآية إلى الحافظة' : 'Ayah copied to clipboard';

  // Notes
  String get newNote => isArabic ? 'ملاحظة جديدة' : 'New Note';
  String get newFreeNote => isArabic ? 'ملاحظة حرة' : 'Free Note';
  String get noteTitle => isArabic ? 'عنوان الملاحظة' : 'Note Title';
  String get noteContent => isArabic
      ? 'اكتب تدبرك أو ملاحظتك هنا...'
      : 'Write your reflection or note here...';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get deleteConfirmTitle => isArabic ? 'تأكيد الحذف' : 'Confirm Delete';
  String get deleteConfirmMessage => isArabic
      ? 'هل أنت متأكد من رغبتك في الحذف؟ لا يمكن التراجع عن هذا الإجراء.'
      : 'Are you sure you want to delete this item? This action cannot be undone.';
  String get exportPdf => isArabic ? 'تصدير PDF' : 'Export PDF';
  String get noNotesYet => isArabic ? 'لا توجد ملاحظات بعد' : 'No notes yet';
  String get freeNoteLabel => isArabic ? 'ملاحظة حرة' : 'Free Note';
  String get ayahNoteLabel => isArabic ? 'تدبر آية' : 'Ayah Reflection';
  String get goToAyah => isArabic ? 'الذهاب إلى الآية' : 'Go to Ayah';

  // Bookmarks & Highlights
  String get noBookmarksYet =>
      isArabic ? 'لا توجد آيات محفوظة بعد' : 'No bookmarks yet';
  String get noHighlightsYet =>
      isArabic ? 'لا توجد آيات مميزة بعد' : 'No highlights yet';

  // Search
  String get searchPlaceholder =>
      isArabic ? 'ابحث في الآيات أو الملاحظات...' : 'Search ayahs or notes...';
  String get quranResults => isArabic ? 'الآيات' : 'Quran Verses';
  String get noteResults => isArabic ? 'الملاحظات' : 'Notes';
  String get noSearchResults =>
      isArabic ? 'لا توجد نتائج مطابقة' : 'No matching results found';
  String searchResultsCount(int count) =>
      isArabic ? '$count نتيجة' : '$count results';

  // Reminders
  String get addReminder => isArabic ? 'إضافة تنبيه' : 'Add Reminder';
  String get editReminder => isArabic ? 'تعديل التنبيه' : 'Edit Reminder';
  String get reminderTitle =>
      isArabic ? 'عنوان التنبيه (اختياري)' : 'Reminder Title (optional)';
  String get defaultReminderTitle =>
      isArabic ? 'ورد القرآن الكريم' : 'Daily Quran Reading';
  String get defaultReminderBody => isArabic
      ? 'حان وقت تلاوة وتدبّر القرآن الكريم'
      : 'Time for your Quran reading and reflection';
  String get reminderTime => isArabic ? 'وقت التنبيه' : 'Time';
  String get repeatDaily => isArabic ? 'تكرار يومي' : 'Repeat Daily';
  String get repeatOnce => isArabic ? 'مرة واحدة' : 'Once';
  String get selectDays => isArabic ? 'أيام التكرار' : 'Repeat Days';
  String get noRemindersYet =>
      isArabic ? 'لا توجد تنبيهات قراءة مضافة' : 'No reading reminders added';
  String get enableNotifications => isArabic
      ? 'يرجى تفعيل إذن الإشعارات'
      : 'Please enable notification permissions';

  // Ayah Links (روابط الآيات)
  String get newAyahLink => isArabic ? 'إنشاء رابط آيات' : 'New Ayah Link';
  String get addToAyahLink =>
      isArabic ? 'إضافة إلى رابط آيات' : 'Add to Ayah Links';
  String get chooseAyahLink => isArabic ? 'اختر رابط آيات' : 'Choose Ayah Link';
  String get createAndAdd => isArabic ? 'إنشاء وإضافة' : 'Create & Add';
  String get networkView => isArabic ? 'شبكة' : 'Network';
  String get orderedView => isArabic ? 'مرتب' : 'Ordered';
  String get cardsView => isArabic ? 'بطاقات' : 'Cards';
  String get autoLayout => isArabic ? 'إعادة الترتيب تلقائيًا' : 'Auto Layout';
  String get linkTitle =>
      isArabic ? 'عنوان الرابط / الفكرة' : 'Link Title / Theme';
  String get linkTitleHint =>
      isArabic ? 'مثال: الصبر عند الشدة' : 'e.g., Patience in Adversity';
  String get linkDescription => isArabic
      ? 'الملاحظة العامة / الفكرة (اختيارية)'
      : 'General Note / Idea (optional)';
  String get linkDescriptionHint => isArabic
      ? 'سجل تأملك أو الفكرة التي تجمع هذه الآيات...'
      : 'Record your reflection connecting these verses...';
  String get addVerse => isArabic ? 'إضافة آية' : 'Add Verse';
  String get removeVerse => isArabic ? 'إزالة الآية' : 'Remove Verse';
  String get openInQuran => isArabic ? 'فتح في المصحف' : 'Open in Quran';
  String get noAyahLinksYet =>
      isArabic ? 'لا توجد روابط آيات بعد' : 'No ayah links yet';
  String get noVersesInLink => isArabic
      ? 'لم تتم إضافة أي آيات لهذا الرابط بعد'
      : 'No ayahs added to this link yet';
  String get ayahLinksSubtitle => isArabic
      ? 'خريطة شخصية لربط الآيات واستكشاف العلاقات التدبرية'
      : 'Personal maps connecting verses explored during Tadabbur';
  String versesCount(int count) => isArabic ? '$count آيات' : '$count Verses';
  String linksCount(int count) => isArabic ? '$count روابط' : '$count Links';

  // Backup & Restore
  String get fullBackup => isArabic ? 'نسخة احتياطية كاملة' : 'Full Backup';
  String get customBackup => isArabic ? 'نسخة مخصصة' : 'Custom Backup';
  String get exportBackup =>
      isArabic ? 'تصدير نسخة احتياطية' : 'Export Backup File';
  String get restoreBackup =>
      isArabic ? 'استعادة نسخة احتياطية' : 'Restore from Backup';
  String get restoreWarningTitle =>
      isArabic ? 'تنبيه هام قبل الاستعادة' : 'Important Restore Notice';
  String get restoreWarningMessage => isArabic
      ? 'استعادة النسخة الاحتياطية ستستبدل بياناتك الحالية بالكامل ولن تدمجها. هل ترغب بالاستمرار؟'
      : 'Restoring a backup will completely replace your current user data. It will not merge. Do you want to proceed?';
  String get confirmRestore =>
      isArabic ? 'استبدال واستعادة' : 'Replace & Restore';
  String get backupSuccess => isArabic
      ? 'تم تصدير النسخة الاحتياطية بنجاح'
      : 'Backup exported successfully';
  String get restoreSuccess =>
      isArabic ? 'تمت استعادة البيانات بنجاح' : 'Data restored successfully';
  String get corruptBackupError => isArabic
      ? 'الملف غير صالح أو كلمة المرور غير صحيحة. تم إلغاء الاستعادة لحماية بياناتك.'
      : 'Invalid or corrupt backup file. Restore cancelled to protect your data.';
  String get enterBackupPassword => isArabic
      ? 'كلمة مرور التشفير (اختيارية)'
      : 'Encryption Password (optional)';

  // Settings
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get themeMode => isArabic ? 'السمة' : 'Theme';
  String get light => isArabic ? 'فاتح' : 'Light';
  String get dark => isArabic ? 'داكن' : 'Dark';
  String get system => isArabic ? 'تلقائي (حسب النظام)' : 'System Default';
  String get languageTitle => isArabic ? 'اللغة' : 'Language';
  String get readingSettings =>
      isArabic ? 'إعدادات القراءة' : 'Reading Settings';
  String get fontSize => isArabic ? 'حجم خط المصحف' : 'Quran Font Size';
  String get aboutContent => isArabic
      ? 'تَدْبِير هو تطبيق قرآني هادف تم بناؤه لخدمة تلاوة وتدبّر القرآن الكريم.\nيعمل محليًا دون إنترنت وبخصوصية تامة بدون إعلانات أو تتبع.\nالنص القرآني معتمد وموثق من مشروع تنزيل (Tanzil Project).'
      : 'Tadbeer is an offline-first Quran reading and tadabbur application.\nBuilt with complete privacy, no internet required, no ads, and no tracking.\nQuran text is verified from the Tanzil Project under CC-BY 3.0.';
}

class AppLocalizationScope extends InheritedWidget {
  final AppLanguage currentLanguage;
  final AppStrings strings;
  final void Function(AppLanguage) onLanguageChanged;

  const AppLocalizationScope({
    super.key,
    required this.currentLanguage,
    required this.strings,
    required this.onLanguageChanged,
    required super.child,
  });

  static AppLocalizationScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(scope != null, 'No AppLocalizationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocalizationScope oldWidget) {
    return currentLanguage != oldWidget.currentLanguage;
  }
}

extension AppLocalizationExtension on BuildContext {
  AppStrings get l10n => AppLocalizationScope.of(this).strings;
  AppLanguage get currentLanguage =>
      AppLocalizationScope.of(this).currentLanguage;
}
