# 📖 دليل التطوير والصيانة لمشروع تَدْبِير (Tadbeer)

> **وثيقة مرجعية تقنية شاملة وعملية للمطورين والقائمين على صيانة وتطوير تطبيق «تَدْبِير» (Flutter).**  
> يوفّر هذا الدليل كافة التفاصيل المعمارية، وتدفق البيانات، ومحرك المصحف، ومخطط قاعدة البيانات، والتشفير، وإرشادات تعديل الميزات، مستندًا بصورة دقيقة ومباشرة إلى الكود الفعلي للمشروع.

---

## 📑 فهرس المحتويات

1. [نظرة عامة على المشروع](#1-نظرة-عامة-على-المشروع)
2. [خريطة الملفات والمجلدات](#2-خريطة-الملفات-والمجلدات)
3. [دليل سريع — أريد تعديل شيء، من أين أبدأ؟](#3-دليل-سريع--أريد-تعديل-شيء-من-أين-أبدأ)
4. [البنية المعمارية وتدفق البيانات](#4-البنية-المعمارية-وتدفق-البيانات)
5. [محرك المصحف المتجاوب وخط Amiri Quran](#5-محرك-المصحف-المتجاوب-وخط-amiri-quran)
6. [قاعدة البيانات والتخزين المحلي](#6-قاعدة-البيانات-والتخزين-المحلي)
7. [النسخ الاحتياطي والتشفير](#7-النسخ-الاحتياطي-والتشفير)
8. [التشغيل والبناء والاختبارات](#8-التشغيل-والبناء-والاختبارات)
9. [أمثلة عملية للتعديلات الشائعة](#9-أمثلة-عملية-للتعديلات-الشائعة)
10. [المصادر والتراخيص](#10-المصادر-والتراخيص)
11. [القرارات التقنية والقيود المعروفة (ADR)](#11-القرارات-التقنية-والقيود-المعروفة-adr)
12. [قائمة تحقق قبل اعتماد التعديل](#12-قائمة-تحقق-قبل-اعتماد-التعديل)

---

## 1. نظرة عامة على المشروع

### رسالة التطبيق
مشروع **تَدْبِير** هو تطبيق قرآني مبني باستخدام إطار العمل **Flutter**. هدفه الجوهري هو نقل العلاقة مع القرآن الكريم من مجرد القراءة والتلاوة السريعة إلى **التدبّر، والفهم، واستحضار الهدايات، والعمل بالآيات** في تفاصيل الحياة اليومية.

### المبادئ التقنية الأساسية
- **العمل المحلي دون اتصال (Offline-First):** تعمل وظائف القراءة، والتخزين، والتدبّر، والتنبيهات محليًا دون اشتراط وجود اتصال بالإنترنت. لا يطلب التطبيق إذن الإنترنت في ملف `AndroidManifest.xml`، ولا يعتمد على خوادم وسيطة أو واجهات API خارجية لخدمة وظائفه الأساسية.
- **حماية الخصوصية:** خلو تام من الإعلانات، وحزم التحليل، ومنصات تتبع سلوك المستخدمين. تظل بيانات المستخدم، وخواطره، ووقفاته التدبرية محفوظة محليًا على جهازه، وعند استخدام ميزة المشاركة (عبر `share_plus`) يتولى نظام التشغيل تمرير المحتوى للتطبيقات الخارجية التي يختارها المستخدم يدويًا.
- **البساطة المعمارية والعملية (Pragmatic Architecture):** الابتعاد عن التعقيد المعماري النظري وتجنب الطبقات الوسيطة غير المبررة. يتبع المشروع تدفقًا بيانيًا مباشرًا يربط واجهة المستخدم بطبقة الكاش التفاعلية وقاعدة البيانات المحلية.
- **قدسية النص القرآني وانضباط التخطيط المتجاوب:** الاعتماد الحصري على البيانات الموثقة لنص تنزيل العثماني، وتصيير الآيات بخط `AmiriQuran` الأصيل بتخطيط متجاوب مرن مع إطارات مذهبة وتيجان مزخرفة للسور، وإتاحة التحكم بحجم الخط (16–32 نقطة)، والاستغناء الكامل عن حزمة خطوط QCF V2 الثقيلة.

### المتطلبات وبيئة التشغيل
- **Flutter SDK:** الإصدار `3.22.0` أو أحدث.
- **Dart SDK:** الإصدار `^3.4.0` (كما هو معرّف في `pubspec.yaml`).
- **المنصة الأساسية:** Android (المنصة الأساسية للإصدار؛ مع دعم بيئات Linux وmacOS وWindows لتشغيل الاختبارات والتطوير المكتبي عبر `sqflite_common_ffi`).
- **أداة إدارة الحزم:** `flutter pub`.

### حدود الاستنتاج والتحقق
كافة المسارات، وأسماء الكلاسات، ومخططات قواعد البيانات، وتفاصيل التشفير في هذا الدليل مستخرجة مباشرة من الكود الفعلي للمشروع. أي قيود أو نواقص فنية تم توثيقها كما هي دون تجميل أو ادعاء اكتمال غير موجود.

---

## 2. خريطة الملفات والمجلدات

يتألف الكود المصدري للتطبيق تحت مجلد `lib/` من **58 ملفًا** موزعة وظيفيًا بدقة كالتالي:

```text
lib/
├── app/                  # إعدادات التطبيق العامة، والسمات، واللغات (3 ملفات)
│   ├── app.dart          # جذر ويدجت التطبيق (TadbeerApp) ومفتاح التنقل العام
│   ├── localization.dart # إدارة النصوص والترجمة باللغتين العربية والإنجليزية
│   └── theme.dart        # ألوان التطبيق (AppColors) وأنماط الخطوط والسمات
│
├── core/                 # البنية التحتية والخدمات المشتركة (8 ملفات)
│   ├── services/         # الخدمات المستقلة (ملفان)
│   │   ├── backup_crypto_service.dart # خدمة تشفير النسخ الاحتياطية (AES-256) والتحقق
│   │   └── local_reminder_service.dart # خدمة التنبيهات المجدولة دون إنترنت
│   ├── storage/          # إدارة التخزين وقواعد البيانات (ملفان)
│   │   ├── user_database.dart         # مدير SQLite المحلي (tadbeer_user_data.db)
│   │   └── user_data_store.dart       # مخزن الكاش التفاعلي الموحد (ChangeNotifier)
│   └── utils/            # الأدوات المساعدة (4 ملفات)
│       ├── arabic_root_search_helper.dart # استخراج الجذور اللغوية وتوليد المشتقات الصرفية
│       ├── arabic_search_normalizer.dart # معالجة وتطبيع الحروف العربية والبحث القرآني
│       ├── note_pdf_exporter.dart        # توليد مستندات PDF للخواطر والملاحظات
│       └── tadbeer_journal_exporter.dart # تصدير دفتر التدبّر والخواطر (PDF وMarkdown مع إحصاءات)
│
├── features/             # أقسام وميزات التطبيق المستقلة (46 ملفًا)
│   ├── ayah_links/       # ميزة روابط الآيات والعلاقات الموضوعية (11 ملفًا)
│   │   ├── ayah_link_detail_screen.dart # شاشة تفاصيل الرابط وإدارة الآيات
│   │   ├── ayah_link_model.dart         # كائنات روابط الآيات (AyahLinkItem)
│   │   ├── ayah_link_repository.dart    # مستودع إدارة روابط الآيات
│   │   ├── ayah_links_screen.dart       # شاشة القائمة الرئيسية للروابط
│   │   ├── curated_pathways.dart        # مكتبة المسارات التدبرية المقترحة والاستيراد بنقرة واحدة
│   │   ├── views/                       # طرق العرض (ملفان)
│   │   │   ├── ayah_link_network_view.dart # المخطط الشبكي التفاعلي للآيات
│   │   │   └── ayah_link_ordered_view.dart # العرض الترتيبي المتسلسل للآيات
│   │   └── widgets/                     # حوارات الإضافة والمشاركة (4 ملفات)
│   │       ├── add_verse_to_link_dialog.dart
│   │       ├── ayah_link_picker_dialog.dart
│   │       ├── ayah_link_qr_dialog.dart     # تصدير واستيراد الروابط دون إنترنت عبر رمز QR
│   │       └── create_link_dialog.dart
│   ├── backup/           # النسخ الاحتياطي والاستعادة (ملف واحد)
│   │   └── backup_screen.dart           # شاشة تصدير واستيراد ملفات .quranbackup
│   ├── bookmarks/        # الفواصل المرجعية (3 ملفات)
│   │   ├── bookmark_model.dart          # كائن الفاصل المرجعي (BookmarkItem)
│   │   ├── bookmark_repository.dart     # مستودع الفواصل المرجعية
│   │   └── bookmarks_screen.dart        # شاشة قائمة الفواصل واستئناف القراءة
│   ├── duas/             # الأدعية القرآنية (هيكل مسطح واضح - 5 ملفات)
│   │   ├── duas_screen.dart             # الواجهة المجمعة لقسم الأدعية
│   │   ├── quran_dua_card.dart          # بطاقة عرض نص الدعاء وزر الانتقال للمصحف
│   │   ├── quran_dua.dart               # نموذج كائن الدعاء القرآني (QuranDua)
│   │   ├── quran_duas_repository.dart   # مستودع الأدعية القرآنية المباشرة الـ 88 الموثقة ضمن 12 تصنيفًا
│   │   └── quran_duas_screen.dart       # شاشة قائمة الأدعية مع شريط البحث
│   ├── highlights/       # تظليل الآيات (3 ملفات)
│   │   ├── highlight_model.dart         # كائن التظليل وألوانه (HighlightItem)
│   │   ├── highlight_repository.dart    # مستودع التظليلات
│   │   └── highlights_screen.dart       # شاشة استعراض الآيات المظللة
│   ├── home/             # الشاشة الرئيسية (ملف واحد)
│   │   └── home_screen.dart             # لوحة التحكم، استئناف القراءة، وبطاقات الميزات
│   ├── notes/            # الخواطر والملاحظات (4 ملفات)
│   │   ├── note_editor_screen.dart      # محرر كتابة وتعديل الخاطرة
│   │   ├── note_model.dart              # كائنات الخاطرة ونوعها (NoteItem, NoteType)
│   │   ├── note_repository.dart         # مستودع إدارة الخواطر
│   │   └── notes_screen.dart            # شاشة استعراض الخواطر وخيار تصدير PDF
│   ├── quran/            # محرك المصحف الشريف وتصيير الصفحات (8 ملفات)
│   │   ├── data/                        # نماذج ومستودع المصحف (ملفان)
│   │   │   ├── quran_models.dart         # كائنات السورة والآية والصفحة والسجدة
│   │   │   └── quran_repository.dart     # المستودع المركزي للنص القرآني ومعاني الكلمات
│   │   ├── screens/                     # شاشات القراءة (ملفان)
│   │   │   ├── quran_page_view.dart      # التقليب بين الصفحات الـ 604 وتصيير التظليل المخصص
│   │   │   └── quran_screen.dart         # شاشة القراءة الكاملة والشريط العلوي مع لوحة المعاني المتزامنة
│   │   └── widgets/                     # المكونات التفاعلية (4 ملفات)
│   │       ├── ayah_action_sheet.dart    # نافذة خيارات الآية (تدبر، تظليل، فاصل)
│   │       ├── quran_side_menu.dart      # قائمة السور والأجزاء الجانبية
│   │       ├── surah_header_banner.dart  # إطار وبانر رأس السورة القرآني
│   │       └── word_meanings_panel.dart  # لوحة معاني كلمات الصفحة الهامشية المتزامنة
│   ├── reminders/        # التنبيهات المجدولة (ملفان)
│   │   ├── reminder_model.dart          # كائن التنبيه وتكرار الأيام (ReminderItem)
│   │   └── reminders_screen.dart        # شاشة جدولة وإدارة مواعيد التذكير
│   ├── search/           # نظام البحث الموحد (سجل SearchRegistry، المزوّدات والواجهة - 3 ملفات)
│   │   ├── search_provider.dart         # نموذج SearchResultItem وعقد SearchProvider وسجل SearchRegistry
│   │   ├── search_providers.dart        # 9 مزوّدات بحث قطاعية مدمجة (شاملة مزوّد معاني الكلمات)
│   │   └── search_screen.dart           # شاشة البحث العام بشرائح التصفية وتجميع النتائج
│   ├── settings/         # الإعدادات وقسم عن تدبير (ملفان)
│   │   ├── settings_screen.dart         # شاشة إعدادات المظهر واللغة والخط وتوثيق المشروع
│   │   └── user_settings_model.dart     # كائن إعدادات المستخدم (UserSettings, QuranFontFamily)
│   ├── tadbeer/          # ميزة التدبّر الأساسية (3 ملفات)
│   │   ├── tadbeer_intro_screen.dart    # شاشة الترحيب ومقدمة التدبّر
│   │   ├── tadbeer_model.dart           # كائن وقفة تدبر والأسئلة الأربعة (TadbeerItem)
│   │   └── tadbeer_pause_sheet.dart     # نافذة وقفة تدبر التفاعلية المثبتة بالآية
│   └── word_meanings/    # ميزة معاني الكلمات القرآنية المفردة (ملف واحد)
│       └── word_meanings_screen.dart    # شاشة معجم الكلمات المستقلة، وتصفية السور، والبحث
│
└── main.dart             # نقطة الانطلاق، وتهيئة المحركات، وتشغيل التطبيق

assets/                   # أصول التطبيق المعتمدة
├── fonts/                # 5 خطوط قرآنية وخط الواجهة: Amiri, AmiriQuran, ScheherazadeNew, NotoNaskhArabic, Lateef, Harmattan
├── icons/                # أيقونات التطبيق
└── quran/                # البيانات القرآنية المعتمدة
    ├── quran_data.json   # النص القرآني الموثق من Quranpedia و Tanzil (114 سورة، 6,236 آية)
    └── word_meanings.json# 6,465 معنى لغوي معجمي مفرد يغطي كامل الـ 604 صفحات
```

---

## 3. دليل سريع — أريد تعديل شيء، من أين أبدأ؟

يوفر هذا الجدول دليلك العملي المباشر لتحديد الملف المناسب للبدء، والملفات ذات الصلة، والاختبارات الآلية التي يجب تشغيلها، مع التحذيرات الحساسة لكل مهمة:

| المهمة المطلوبة | ملف البداية | الملفات المرتبطة | الاختبارات الواجب تشغيلها | تحذيرات مهمة قبل التعديل |
| :--- | :--- | :--- | :--- | :--- |
| **1. الشاشة الرئيسية واستئناف القراءة** | `lib/features/home/home_screen.dart` | `lib/core/storage/user_data_store.dart` | `flutter test test/ui/tadbeer_ui_test.dart` | لا تقم بإزالة بطاقة موضع القراءة الأخير؛ فهي المسار الأساسي للمستخدم. |
| **2. شاشة الإعدادات وعن تدبير** | `lib/features/settings/settings_screen.dart` | `lib/features/settings/user_settings_model.dart`<br>`lib/app/localization.dart`<br>`lib/core/storage/user_data_store.dart` | `flutter test test/settings/quran_font_size_test.dart`<br>`flutter test test/quran/quran_fonts_test.dart` | حجم خط المصحف (16–32 نقطة) وعائلة الخط (5 خطوط قرآنية) قابلة للتخصيص وتنعكس فوريًا على المصحف. |
| **3. واجهة شاشة قراءة المصحف والشرائط** | `lib/features/quran/screens/quran_screen.dart` | `lib/features/quran/screens/quran_page_view.dart`<br>`lib/features/quran/widgets/quran_side_menu.dart` | `flutter test test/quran/quran_screen_toolbar_test.dart` | الشريط العلوي مخفي افتراضيًا بالنقر؛ ويتيح زر الخط نافذة تحكم سريعة لنوع وحجم الخط. |
| **4. محرك عرض وتصيير صفحات المصحف المتجاوب** | `lib/features/quran/screens/quran_page_view.dart` | `lib/features/quran/widgets/surah_header_banner.dart` | `flutter test test/quran/responsive_mushaf_viewports_test.dart`<br>`flutter test test/quran/mushaf_visual_layout_test.dart` | **حرج:** مبني باستخدام `LayoutBuilder` و `SingleChildScrollView` لمنع أي تجاوز للحدود (`RenderFlex overflow`). الصفحتان 1 و 2 داخل إطار مذهب؛ والصفحات 3–604 بمحاذاة تامة؛ والشاشات العريضة (>=900) تتحول للمصحف المزدوج. |
| **5. خطوط المصحف وتخطيط الصفحات** | `lib/features/settings/user_settings_model.dart` | `lib/features/quran/screens/quran_page_view.dart`<br>`pubspec.yaml` | `flutter test test/quran/quran_fonts_test.dart`<br>`flutter test test/quran/quran_mushaf_layout_test.dart` | النص القرآني يُصيّر مباشرة بـ 5 خطوط مفتوحة المصدر (SIL OFL-1.1): `AmiriQuran`، `ScheherazadeNew`، `NotoNaskhArabic`، `Lateef`، `Harmattan`. |
| **6. وقفة تدبّر وشاشة الترحيب** | `lib/features/tadbeer/tadbeer_pause_sheet.dart` | `lib/features/tadbeer/tadbeer_intro_screen.dart`<br>`lib/features/tadbeer/tadbeer_model.dart` | `flutter test test/quran/tadbeer_pause_test.dart` | حافظ على هيكل الأسئلة التدبرية الأربعة؛ فهي الركيزة الأساسية للتدبر في التطبيق. |
| **7. الخواطر والملاحظات وتصدير PDF** | `lib/features/notes/notes_screen.dart` | `lib/features/notes/note_editor_screen.dart`<br>`lib/features/notes/note_repository.dart`<br>`lib/core/utils/note_pdf_exporter.dart` | `flutter test test/notes/note_repository_test.dart` | تأكد من دعم خطوط اللغة العربية في مكتبة PDF عند تعديل التصدير. |
| **8. الفواصل المرجعية** | `lib/features/bookmarks/bookmarks_screen.dart` | `lib/features/bookmarks/bookmark_repository.dart`<br>`lib/features/bookmarks/bookmark_model.dart` | `flutter test test/bookmarks/bookmark_repository_test.dart` | الفاصل المرجعي فريد لكل آية؛ تحديث فاصل لنفس الآية يستبدل السابق. |
| **9. تظليل الآيات** | `lib/features/highlights/highlights_screen.dart` | `lib/features/highlights/highlight_repository.dart`<br>`lib/features/highlights/highlight_model.dart` | `flutter test test/highlights/highlight_repository_test.dart`<br>`flutter test test/quran/ayah_highlight_painter_test.dart` | التظليل يُرسم خلف النص عبر `AyahHighlightPainter` دون تقطيع الكلمات. |
| **10. شبكة روابط الآيات** | `lib/features/ayah_links/ayah_links_screen.dart` | `lib/features/ayah_links/ayah_link_detail_screen.dart`<br>`lib/features/ayah_links/views/ayah_link_network_view.dart`<br>`lib/features/ayah_links/ayah_link_repository.dart` | `flutter test test/ayah_links/ayah_link_repository_test.dart`<br>`flutter test test/ui/ayah_links_ui_test.dart` | شاشة التفاصيل تدعم وضعين (Network و Ordered) وتصدير واستيراد الروابط عبر QR دون إنترنت. |
| **11. الأدعية القرآنية** | `lib/features/duas/duas_screen.dart` | `lib/features/duas/quran_duas_screen.dart`<br>`lib/features/duas/quran_duas_repository.dart`<br>`lib/features/duas/quran_dua_card.dart` | `flutter test test/duas/duas_screen_test.dart`<br>`flutter test test/duas/quran_duas_test.dart` | الأدعية الـ 88 المباشرة موثقة بالرسم العثماني ومصنفة ضمن 12 تصنيفًا مع علامات الآيات الممتدة. |
| **12. التنبيهات المجدولة** | `lib/features/reminders/reminders_screen.dart` | `lib/core/services/local_reminder_service.dart`<br>`lib/features/reminders/reminder_model.dart` | `flutter test test/reminders/reminder_sound_test.dart` | تعتمد التنبيهات معرّف مشتق من `(id.hashCode.abs() % 100000) + dayOfWeek`. |
| **13. النسخ الاحتياطي والتشفير** | `lib/features/backup/backup_screen.dart` | `lib/core/services/backup_crypto_service.dart`<br>`lib/core/storage/user_data_store.dart` | `flutter test test/backup/backup_restore_test.dart` | فحص البيانات يتم مسبقًا قبل استعادة ملفات `.quranbackup`. |
| **14. المظهر، الألوان، والترجمة** | `lib/app/theme.dart` | `lib/app/localization.dart`<br>`lib/app/app.dart` | `flutter test test/ui/tadbeer_ui_test.dart` | أي مفتاح نصي جديد يضاف في `Localization` يجب إضافته باللغتين العربية والإنجليزية معًا. |
| **15. نظام البحث الموحد والقطاعي** | `lib/features/search/search_screen.dart` | `lib/features/search/search_provider.dart`<br>`lib/features/search/search_providers.dart`<br>`lib/core/utils/arabic_search_normalizer.dart` | `flutter test test/search/unified_search_test.dart`<br>`flutter test test/search/arabic_search_normalizer_test.dart` | يستعلم سجل `SearchRegistry` القابل للتوسع 9 قطاعات بالتوازي مع عزل الأخطاء. |
| **16. معاني كلمات القرآن المفردة** | `lib/features/word_meanings/word_meanings_screen.dart` | `lib/features/quran/widgets/word_meanings_panel.dart`<br>`lib/features/quran/data/quran_repository.dart`<br>`assets/quran/word_meanings.json` | `flutter test test/word_meanings/word_meanings_test.dart` | الالتزام الصارم بقاعدة اللفظ المفرد عبر كافة صفحات المصحف الـ 604، من قاعدة بيانات *Quranpedia.net (2026-10-10)* بترخيص CC0-1.0. |

---

## 4. البنية المعمارية وتدفق البيانات

يتبع تطبيق «تدبير» معمارية عملية مركزية تعتمد على مخزن موحد للحالة:

```text
[شاشات واجهة المستخدم (UI Widgets)]
        │ 
        ▼ استدعاء دوال الحفظ / الحذف
[مستودعات الميزات (Repositories)]
        │
        ▼ تمرير العمليات إلى المخزن الموحد
[UserDataStore (ChangeNotifier - Singleton)]
   ├── 1. تحديث فهارس الكاش بالذاكرة فورًا (Lookups بزمن O(1) وسطيًا)
   ├── 2. إرسال إشعار فوري للواجهات (notifyListeners())
   └── 3. كتابة غير متزامنة على القرص:
            ├── SQLite Database (tadbeer_user_data.db)
            └── JSON Snapshot File (tadbeer_user_data.json)
```

### 1. نقطة الدخول والتهيئة (`lib/main.dart`)
1. استدعاء `WidgetsFlutterBinding.ensureInitialized()`.
2. تهيئة محرك قاعدة البيانات ومخزن البيانات الموحد عبر `UserDataStore.instance.init()`.
3. تهيئة مستودع القرآن الكريم الموحد عبر `QuranRepository.instance.init()`.
4. تهيئة خدمة التنبيهات المحلية `LocalReminderService.instance.init()`.
5. تشغيل ويدجت التطبيق `TadbeerApp`.

### 2. التفاعل وإدارة الحالة (Reactivity)
- لا يعتمد التطبيق على مكتبات إدارة حالة خارجية مثل Bloc أو Riverpod.
- يُستخدم `UserDataStore.instance` كوريث من `ChangeNotifier`.
- ترتبط شاشات التطبيق التفاعلية بالمخزن عبر `ListenableBuilder(listenable: UserDataStore.instance, builder: ...)`.
- عند حدوث أي تعديل في البيانات (إضافة تظليل، حفظ فاصل، كتابة خاطرة)، يُحدّث الكاش المحلي في الذاكرة فورًا، ويُستدعى `notifyListeners()`، مما يعيد بناء الأجزاء المتأثرة من الشاشة دون تأخير.

### 3. تدفق قراءة ورسم المصحف
- نصوص المصحف في `QuranRepository` غير قابلة للتعديل (`List.unmodifiable`).
- تستعلم ويدجت المصحف عن حالة الآية (هل هي مظللة؟ هل عليها فاصل؟ هل لها تدبر؟) من فهارس الذاكرة السريعة:
  - `_bookmarkLookup['$surah:$ayah']`
  - `_highlightLookup['$surah:$ayah']`
  - `_tadbeerLookup['$surah:$ayah']`
- هذه الاستعلامات تعمل بزمن وسطي قدره $O(1)$ دون فتح استعلامات SQLite أثناء تقليب وتمرير الصفحات، مما يحافظ على استقرار حركة الصفحة وسلاستها.

### 4. معمارية نظام البحث الموحد وسجل SearchRegistry
يمتلك تطبيق «تدبير» معمارية بحث لامركزية وقابلة للتوسع يقودها سجل `SearchRegistry`:

```text
[شريط البحث العام بالرئيسية / SearchScreen]
                 │
                 ▼
          [SearchRegistry]
                 │  (استعلام متزامن عبر Future.wait مع عزل الأخطاء بـ try/catch)
   ┌─────────────┼─────────────┬─────────────┬─────────────┐
   ▼             ▼             ▼             ▼             ▼
[القرآن]       [الخواطر]     [التدبر]      [الفواصل]     [التظليلات]
   │             │             │             │             │
   ▼             ▼             ▼             ▼             ▼
[الروابط]      [الأدعية]     [التنبيهات]   [مزوّدات مخصصة مستقبلية...]
                 │
                 ▼ إرجاع List<SearchResultItem>
          [واجهة مجمعة ومفلترة بشرائح الأقسام وشارات الأعداد]
```

- **عقد مزوّد البحث (`SearchProvider` في `lib/features/search/search_provider.dart`):**  
  واجهة تجريدية تعرّف: المعرّف `id`، عنوان القسم `getSectionTitle(BuildContext)`، أيقونة القسم `IconData get icon`، ودالة البحث `Future<List<SearchResultItem>> search(String query, BuildContext context)`. يمكن لأي قسم الانضمام لمنظومة البحث دون أي تعديل على كود شاشة البحث.
- **النمط الفردي المركزي (`SearchRegistry` Singleton):**  
  يدير مزوّدات البحث النشطة، ويسجل المزوّدات التسعة الافتراضية تلقائيًا عند بدء التشغيل، وينفذ الاستعلام بالتوازي عبر `Future.wait`.
- **عزل الأخطاء البرمجية (Graceful Error Isolation):**  
  يُحاط استدعاء كل مزوّد بكتلة `try/catch` مستقلة؛ فلو فشل أو استثنى أي مزوّد أثناء الاستعلام، يتم تسجيل الخطأ وتستمر نتائج باقي المزوّدات بنجاح دون إيقاف البحث العام.
- **النموذج الموحد لنتيجة البحث (`SearchResultItem`):**  
  كائن معياري يجمع: `id`، و`providerId`، و`sectionTitle`، والعنوان الرئيسي `title`، والمقتطف `snippet`، وإحداثيات الآية إن وجدت (`surahNumber`، `ayahNumber`، `page`)، والشارات الإيضاحية، والأيقونة، ودالة التنقل السريع `onTap(BuildContext)`.
- **مزوّدات الأقسام التسعة المدمجة (`lib/features/search/search_providers.dart`):**
  1. `QuranSearchProvider`: يبحث في آيات القرآن الكريم برسمها العثماني عبر `QuranRepository.searchAyahs` وينتقل لصفحة المصحف المحددة.
  2. `NotesSearchProvider`: يطابق العنوان والمحتوى ونص الآية في خواطر وملاحظات `UserDataStore.notes` ويفتح `NoteEditorScreen`.
  3. `TadbeerSearchProvider`: يطابق إجابات الأسئلة التدبرية أو مرجع السورة/الآية وينتقل إلى الآية في `QuranScreen`.
  4. `BookmarksSearchProvider`: يطابق اسم السورة أو رقم الآية أو نص الآية في فواصل `UserDataStore.bookmarks`.
  5. `HighlightsSearchProvider`: يطابق اسم السورة أو رقم الآية أو نص الآية في تظليلات `UserDataStore.highlights`.
  6. `AyahLinksSearchProvider`: يطابق عنوان الرابط ووصفه والآيات المرتبطة في `AyahLinkRepository.searchLinks`.
  7. `DuasSearchProvider`: يبحث في الأدعية القرآنية الموثقة عبر `QuranDuasRepository.search`.
  8. `RemindersSearchProvider`: يطابق عناوين تنبيهات الورد اليومي في `UserDataStore.reminders`.
  9. `WordMeaningsSearchProvider`: يبحث في مفردات معاني كلمات القرآن والمعاجم اللغوية الموثقة عبر `QuranRepository.searchWordMeanings` وينتقل للآية والصفحة في `QuranScreen`.
- **البحث المحلي المستقل داخل الأقسام:**  
  إلى جانب البحث العام، تتضمن شاشات الأقسام الرئيسية (`BookmarksScreen`، `HighlightsScreen`، `RemindersScreen`، `NotesScreen`، `AyahLinksScreen`، `QuranDuasScreen`، و`WordMeaningsScreen`) أشرطة بحث مدمجة ومستقلة لتصفية عناصر القسم مباشرة في موضعها.
- **انضباط التطبيع وتجريد النصوص:**  
  تعتمد كافة عمليات المطابقة بدقة على أداة `ArabicSearchNormalizer.normalize(text)` (تجريد التشكيل، التطويل، وتوحيد الهمزات والتاء المربوطة) مع الحفاظ التام على النص العثماني الأصلي كما هو دون أي تعديل في التخزين أو العرض.

---

## 5. محرك المصحف المتجاوب والخطوط القرآنية الخمسة

محرك المصحف مصمم لتصيير النص القرآني بالرسم العثماني المعتمد من مشروع Quranpedia و Tanzil ضمن تخطيط هندسي متجاوب ومرن خالٍ تمامًا من تجاوز الحدود (Zero-Overflow Layout) ليلائم كافة الأجهزة والشاشات.

### 1. مصادر البيانات والخطوط مفتوحة المصدر
- **النص القرآني (`assets/quran/quran_data.json`):**  
  النص القرآني بالرسم العثماني المعتمد من Quranpedia.net (2026-10-10) و Tanzil، ويشمل 114 سورة و6,236 آية، ومعلومات أرقام الأجزاء والأحزاب والصفحات والسجدات.
- **5 خطوط قرآنية مفتوحة المصدر (`assets/fonts/` — جميعها بترخيص SIL OFL-1.1):**  
  - خط `AmiriQuran` (`AmiriQuran.ttf` — د. خالد حسني)
  - خط `ScheherazadeNew` (`ScheherazadeNew-Regular.ttf` — SIL International)
  - خط `NotoNaskhArabic` (`NotoNaskhArabic-Regular.ttf` — Google / Monotype)
  - خط `Lateef` (`Lateef-Regular.ttf` — SIL International)
  - خط `Harmattan` (`Harmattan-Regular.ttf` — SIL International)
  - بالإضافة إلى خط `Amiri` (`Amiri.ttf`) لتصيير العناوين والأدعية والواجهات.
- **الاستغناء التام عن الخطوط المقيدة:**  
  تم حذف كافة ملفات خطوط QCF V2 الـ 604 ومحولاتها نهائيًا من المشروع.

### 2. البنية المعمارية
- يبني `QuranRepository` محتوى الصفحات والسور مباشرة من بيانات المصحف المعتمدة عند التهيئة دون الحاجة لملفات تخطيط خارجية.
- يؤدي ويدجت `QuranPageView` دور مصيّر الصفحات المتجاوب الموحد مباشرة، مع رسم التظليلات المتصلة خلف النص عبر `AyahHighlightPainter`.

### 3. تراتبية ويدجت العرض (Widget Hierarchy)
```text
QuranScreen
 └── QuranPageView (PageView.builder من 1 إلى 604)
      └── LayoutBuilder (استشعار حدود الشاشة)
           └── SingleChildScrollView (منع تجاوز الحدود RenderFlex Overflow)
                └── ConstrainedBox (minHeight: constraints.maxHeight)
                     └── IntrinsicHeight
                          └── Container (إطار مصحف المدينة المزدوج والترويسات والتذييلات)
                               ├── ترويسة الصفحة (اسم السورة ورقم الجزء)
                               ├── الإطار الافتتاحي المذهب (خاص بالصفحتين 1 و 2)
                               ├── SurahHeaderBanner (التاج المزخرف عند بداية السورة)
                               ├── BismillahBanner (البسملة عدا الفاتحة والتوبة)
                               ├── CustomPaint (AyahHighlightPainter) + RichText
                               │    ├── كلمات الآية والتفاعل بالضغط المطول
                               │    └── علامة نهاية الآية المزخرفة: ﴿١﴾
                               └── تذييل الصفحة (رقم الصفحة بالأرقام المشرقية)
```

### 4. القواعد الهندسية وتوافق الشاشات
> [!IMPORTANT]
> **محددات التصيير المتجاوب:**
> 1. **منع تجاوز الحدود (Zero-Overflow Layout Engine):**  
>    تعتمد الصفحة على تركيبة `LayoutBuilder` و `SingleChildScrollView` و `ConstrainedBox(minHeight: constraints.maxHeight)` و `IntrinsicHeight`. يضمن هذا تمدد المحتوى ليملأ إطار الصفحة طبيعيًا في الأوضاع العادية، وفي حال تكبير الخط (حتى 32 نقطة) أو تدوير الجهاز للوضع الأفقي، تتدفق النصوص بسلاسة مع التمرير الرأسي دون حدوث أي خطأ تجاوز للمساحة (`RenderFlex overflow`).
> 2. **الصفحتان الافتتاحيتان مقابل الصفحات القياسية:**  
>    - الصفحتان 1 (الفاتحة) و 2 (البقرة 1–5) تُعرضان بنص ممركز داخل إطار هندسي مذهب في المنتصف (`_buildOpeningFrame`).
>    - الصفحات القياسية (3 إلى 604) تُعرض بمحاذاة تامة للنص العربي (`TextAlign.justify`) مع الترويسة والتذييل القياسيين.
> 3. **تفاعل الآيات وتمييز الإيماءات:**  
>    ترتبط كل آية بمتعرف إيماءات مخصص `AyahGestureRecognizer` (الموروث من `LongPressGestureRecognizer` بمدة 1.1 ثانية / 1100ms)؛ يظهر تظليل الآية فور وضع الإصبع عليها (`onPointerDown`)، وإذا رُفع الإصبع قبل انقضاء 1.1 ثانية يُزال التظليل فورًا دون فتح القائمة (`onPointerUpEarly`). وعند استمرار الضغط لكامل المدة (1.1 ثانية) تفتح نافذة إجراءات الآية مع اهتزاز لمسي خفيف (Haptic Feedback)، بينما يؤدي النقر السريع إلى إخفاء الأشرطة والتظليلات فورًا دون فتح القائمة.
> 4. **عرض المصحف المزدوج للشاشات الكبيرة:**  
>    عندما يتجاوز عرض الشاشة 900 بكسل (`constraints.maxWidth >= 900`)، يتحول `QuranScreen` تلقائيًا إلى عرض صفحتين متقابلتين جنباً إلى جنب مع فاصل وسطي جمالي يحاكي المصحف الورقي المفتوح.

### 5. التحكم بنوع وحجم الخط والقراءة
- **نطاق الخط والعائلات:** قابل للضبط من `minQuranFontSize = 16.0` إلى `maxQuranFontSize = 32.0` (الافتراضي: `20.0`)، مع 5 عائلات خطوط قرآنية (`QuranFontFamily`).
- **تحديث تفاعلي لحظي:** محفوظ ومُدار في `UserDataStore.instance.setQuranFontSize(size)` و `setQuranFontFamily(family)`.
- **مداخل التعديل:**
  1. **شاشة الإعدادات:** قسم «الخط والقراءة» لاختيار نوع الخط وشريط التمرير الحي ومعاينة نص قرآني وزر استعادة الافتراضي.
  2. **شريط أدوات المصحف:** زر سريع للخط (`Icons.format_size_rounded`) يفتح نافذة سفلية منزلقة لضبط نوع وحجم الخط مباشرة أثناء التلاوة.

---

## 6. قاعدة البيانات والتخزين المحلي

يعتمد التطبيق على قاعدة بيانات SQLite المحلية لإدارة بيانات المستخدمين بصورة دائمة ومنفصلة عن النص القرآني الثابت.

### 1. مخطط قاعدة البيانات (`tadbeer_user_data.db`)
قاعدة البيانات تدار عبر كلاس `UserDatabase` والإصدار الحالي للمخطط هو `databaseVersion = 1`. تُنشئ دالة `_onCreate` **9 جداول** فعلية:

1. **`reading_position`** (موضع القراءة الأخير):
   - `id`: INTEGER PRIMARY KEY CHECK (id = 1) — يضمن وجود سجل واحد فقط.
   - `page`: INTEGER NOT NULL
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL (حزمة JSON الكاملة)
   - `updated_at`: TEXT NOT NULL

2. **`notes`** (الخواطر والملاحظات):
   - `id`: TEXT PRIMARY KEY (معرّف فريد UUID)
   - `type`: TEXT NOT NULL (نوع الخاطرة: verse أو general)
   - `surah_number`: INTEGER (اختياري)
   - `ayah_number`: INTEGER (اختياري)
   - `data`: TEXT NOT NULL (بيانات الخاطرة والنص)
   - `created_at`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL

3. **`bookmarks`** (الفواصل المرجعية):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

4. **`highlights`** (تظليلات الآيات):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `color_index`: INTEGER NOT NULL (رقم اللون 0 إلى 3)
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

5. **`reminders`** (التنبيهات المجدولة):
   - `id`: TEXT PRIMARY KEY
   - `is_enabled`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

6. **`ayah_links`** (شبكات روابط الآيات الموضوعية):
   - `id`: TEXT PRIMARY KEY
   - `data`: TEXT NOT NULL (تفاصيل الرابط والعنوان والآيات المرتبطة)
   - `created_at`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL

7. **`tadbeer_items`** (إجابات وقفة تدبّر):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL (إجابات الأسئلة الأربعة)
   - `updated_at`: TEXT NOT NULL

8. **`tadabbur_items`** (جدول التوافق القديم):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL  
   *(يُنشأ هذا الجدول كطبقة توافقية للمحافظة على البيانات في حال وجود إصدارات قديمة اعتمدت الاسم السابق، وتتم القراءة منه كاحتياط في حال خلو جدول `tadbeer_items`).*

9. **`user_settings`** (إعدادات المستخدم):
   - `key`: TEXT PRIMARY KEY
   - `value`: TEXT NOT NULL

### 2. آلية الترقية (Schema Migrations)
- الإصدار الحالي لقاعدة البيانات هو `1`.
- في التنفيذ الفعلي الحالي، لا توجد دالة معالجة للترقية `onUpgrade` مسجلة في استدعاء `openDatabase`، ولا توجد اختبارات آلية مخصصة للترقية ضمن حزمة الاختبارات الحالية.
- **تنبيه عند التطوير المستقبلي:** عند إضافة حقول أو جداول جديدة، يجب رفع `databaseVersion` إلى `2` وتمرير معالج `onUpgrade` صريح لتنفيذ أوامر `ALTER TABLE` أو `CREATE TABLE IF NOT EXISTS` دون الإضرار ببيانات المستخدمين السابقة.

---

## 7. النسخ الاحتياطي والتشفير

تدار عمليات النسخ الاحتياطي والاستعادة عبر الكلاس المخصص `BackupCryptoService` بالتعاون مع `UserDataStore`.

### 1. بنية ملف النسخة الاحتياطية (`.quranbackup`)
الملف عبارة عن حزمة JSON مدمجة تحتوي على الحقول التالية:
```json
{
  "magic": "TADBEER_BACKUP",
  "version": 1,
  "schemaVersion": 1,
  "salt": "<Base64 16-byte random salt>",
  "iv": "<Base64 16-byte random IV>",
  "checksum": "<SHA-256 hash of raw pre-compressed JSON>",
  "createdAt": "2026-10-10T00:00:00.000Z",
  "cipher": "<Base64 encrypted payload>"
}
```

### 2. خوارزمية التشفير واشتقاق المفتاح الفعلية
- **البيانات المشمولة:** تجمع كافة سجلات المستخدم عبر `UserDataStore.instance.exportSnapshot()`.
- **بصمة السلامة (Checksum):** تُحسب بصمة `SHA-256` لبيانات الـ JSON الخام المرمزة بـ UTF-8 **قبل** الضغط والتشفير.
- **الضغط (Compression):** تُضغط بيانات JSON الخام باستخدام خوارزمية `Gzip` (`gzip.encode`) لتقليل حجم الحزمة.
- **اشتقاق المفتاح (Key Derivation):**  
  يتم توليد ملح عشوائي آمن (Salt) بحجم 16 بايت، ومتجه ابتدائي (IV) بحجم 16 بايت باستخدام `Random.secure()`.  
  يُشتق مفتاح التشفير ذو الـ 256 بت عبر دمج كلمة المرور والملح وتمريرهما مباشرة إلى دالة التجزئة:
  ```dart
  final input = utf8.encode(password) + salt;
  final digest = sha256.convert(input);
  final key = enc.Key(Uint8List.fromList(digest.bytes));
  ```
  *(ملاحظة تقنية: يعتمد الكود دالة `SHA-256(password + salt)` المباشرة لإنتاج المفتاح، ولا يستخدم دوال إطالة المفاتيح مثل PBKDF2 أو Argon2).*
- **التشفير المتماثل:** تُشفّر البيانات المضغوطة باستخدام خوارزمية **AES-256** في نمط **CBC Mode** (`enc.AESMode.cbc`).

### 3. الاعتبارات الأمنية وآلية الاستعادة
- **محددات التشفير والسلامة:** دالة `SHA-256` العادية هي بصمة تحقق غير موثقة بمفتاح سري (وليست HMAC)، ونمط `AES-CBC` بمفرده ليس تشفيرًا موثقًا ومحصنًا (AEAD مثل AES-GCM). تهدف هذه البصمة إلى كشف التلف غير المتعمد وأخطاء فك التشفير، لكنها لا تمنح ضمانة رياضية ضد التلاعب المتعمد بمحتوى الملف.
- **مرحلة التحقق المسبق (Pre-flight Checks):**  
  عند استيراد ملف `.quranbackup`، يتحقق الكود أولًا من الترويسة السحرية `magic == 'TADBEER_BACKUP'`، وتوافق إصدار المخطط، ثم يفك التشفير، ويفك ضغط Gzip، ويقارن بصمة `SHA-256` مع البصمة المسجلة، ويتأكد من حقل `app == 'Tadbeer'`. إذا فشل أي من هذه الفحوصات، تجهض العملية فورًا **دون المساس ببيانات المستخدم الحالية**.
- **مرحلة استبدال البيانات في قاعدة البيانات:**  
  بعد نجاح كافة الفحوصات السابقة، تستدعى دالة `UserDataStore.instance.replaceAllUserData()`، وتقوم بمسح الجداول عبر `clearAllUserData()` ثم إدخال السجلات الجديدة. تجري هذه العمليات بتسلسل من الاستعلامات المنفصلة **دون تغليفها داخل معاملة SQLite ذرية واحدة (Transaction)**، ولا يتوفر نظام تراجع تلقائي (Rollback) في حال وقوع استثناء أثناء مرحلة الكتابة على القرص.

---

## 8. التشغيل والبناء والاختبارات

### 1. تثبيت الحزم والتحليل
```bash
# تثبيت الحزم والاعتماديات
flutter pub get

# فحص توافق التنسيق دون تعديل الملفات
dart format --output=none --set-exit-if-changed lib/ test/

# تشغيل التحليل الساكن
dart analyze
```
*(ملاحظة: فحص تنسيق Dart عبر الخيار `--set-exit-if-changed` قد يكتشف اختلافات طفيفة في تنسيق بعض أسطر الملفات القائمة مثل `settings_screen.dart`؛ تجنب تطبيق التنسيق التلقائي الذي يغيّر ملفات الكود دون طلب).*

### 2. تشغيل الاختبارات الآلية
يحتوي المشروع على **23 ملف اختبار** تضم **174 اختبارًا آليًا** ناجحًا بنسبة 100%:

```bash
# تشغيل كامل حزمة الاختبارات
flutter test

# تشغيل اختبارات التوافق مع مختلف الشاشات والأجهزة
flutter test test/quran/responsive_mushaf_viewports_test.dart

# تشغيل اختبارات التحكم بنوع وحجم الخط
flutter test test/settings/quran_font_size_test.dart
flutter test test/quran/quran_fonts_test.dart

# تشغيل اختبارات نظام البحث الموحد والتطبيع
flutter test test/search/unified_search_test.dart
flutter test test/search/arabic_search_normalizer_test.dart

# تشغيل اختبارات محرك المصحف وتخطيط الصفحات
flutter test test/quran/mushaf_visual_layout_test.dart
flutter test test/quran/quran_mushaf_layout_test.dart
flutter test test/quran/quran_screen_toolbar_test.dart

# تشغيل اختبارات معاني كلمات القرآن ومعجم الألفاظ
flutter test test/word_meanings/word_meanings_test.dart

# تشغيل اختبارات قاعدة البيانات والتخزين
flutter test test/storage/user_database_test.dart
flutter test test/storage/user_data_store_test.dart

# تشغيل اختبارات التشفير والنسخ الاحتياطي
flutter test test/backup/backup_restore_test.dart

# تشغيل اختبارات واجهة المستخدم
flutter test test/ui/tadbeer_ui_test.dart
flutter test test/ui/ayah_links_ui_test.dart
```

### 3. أوامر التشغيل والبناء للإنتاج
```bash
# تشغيل التطبيق في وضع التطوير
flutter run

# بناء حزمة أندرويد المستقلة (APK)
flutter build apk --release

# بناء حزمة أندرويد لمتجر التطبيقات (App Bundle)
flutter build appbundle --release
```

---

## 9. أمثلة عملية للتعديلات الشائعة

### مثال 1: إضافة نص مترجم جديد (`lib/app/localization.dart`)
عند إضافة نص جديد للواجهة، يجب إضافته في خريطتي اللغتين العربية والإنجليزية:
```dart
// داخل كلاس Localization:
static const Map<String, String> _ar = {
  // ...
  'custom_feature_title': 'عنوان الميزة الجديدة',
};

static const Map<String, String> _en = {
  // ...
  'custom_feature_title': 'New Feature Title',
};
```
ثم استدعاؤه في الواجهة عبر: `context.tr('custom_feature_title')`.

### مثال 2: تعديل خيار في إعدادات المستخدم (`lib/features/settings/`)
1. أضف الحقل في نموذج `user_settings_model.dart`:
```dart
class UserSettings {
  final bool enableHapticFeedback;
  // أضف الحقل إلى الباني و copyWith و fromJson و toJson
}
```
2. حدّث الجدول في `UserDatabase` ودالة الحفظ في `UserDataStore`.
3. اربط مفتاح التبديل (Switch) في `SettingsScreen`.

### مثال 3: إنشاء اختبار وحدة لمستودع مع عزل التخزين المحلي
يُهيأ مخزن البيانات للاختبارات بتمرير ملف مؤقت إلى `UserDataStore.instance.init(testFile)`؛ حيث يقوم الكود داخليًا بتهيئة قاعدة بيانات مؤقتة في الذاكرة عبر `inMemoryDatabasePath`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tadbeer/core/storage/user_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadbeer_test_');
    final testFile = File('${tempDir.path}/test_user_data.json');
    // تهيئة المخزن مع ملف مؤقت يعيد ضبط الكاش ويفتح قاعدة بيانات في الذاكرة
    await UserDataStore.instance.init(testFile);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('مستودع الميزة يحفظ ويسترجع البيانات بنجاح', () async {
    // تنفيذ عمليات الفحص هنا...
  });
}
```

### مثال 4: إضافة مزوّد بحث جديد إلى SearchRegistry
لإتاحة البحث في قسم أو ميزة جديدة داخل شاشة البحث العام دون تعديل كود `SearchScreen`:

1. **تطبيق عقد `SearchProvider` (`lib/features/search/search_provider.dart`):**
```dart
class MyCustomSearchProvider implements SearchProvider {
  const MyCustomSearchProvider();

  @override
  String get id => 'my_feature';

  @override
  String getSectionTitle(BuildContext context) => 'ميزتي الجديدة';

  @override
  IconData get icon => Icons.star_rounded;

  @override
  Future<List<SearchResultItem>> search(String query, BuildContext context) async {
    final normalized = ArabicSearchNormalizer.normalize(query);
    // تنفيذ المطابقة على النصوص المطبعة...
    return [
      SearchResultItem(
        id: 'item_1',
        providerId: id,
        sectionTitle: getSectionTitle(context),
        title: 'نتيجة مطابقة',
        snippet: 'مقتطف النص المطابق...',
        icon: icon,
        onTap: (ctx) => Navigator.push(...),
      ),
    ];
  }
}
```

2. **تسجيل المزوّد في السجل المركزي:**
```dart
SearchRegistry.instance.register(const MyCustomSearchProvider());
```

3. **التكامل التلقائي مع واجهة البحث:**  
   تُنشئ `SearchScreen` شريحة تصفية تفاعلية للمزوّد الجديد تلقائيًا وتُجمّع نتائجه تحت ترويسة قسمه المستقلة مع شارة عدد النتائج بالأرقام العربية-المشرقية.

---

## 10. المصادر والتراخيص

يستند مشروع تدبير إلى بيانات ومصادر مفتوحة المصدر وموثقة بالكامل في `ATTRIBUTION.md` و`THIRD_PARTY_NOTICES.md`:

1. **النص القرآني بالرسم العثماني ومعاني الكلمات (`assets/quran/quran_data.json` و`assets/quran/word_meanings.json`):**
   - **المصادر:** [Quranpedia.net](https://quranpedia.net/) (إصدار 2026-10-10 — ملكية عامة CC0 1.0) و[مشروع تنزيل](https://tanzil.net/) (CC-BY 3.0).
   - **الاستخدام:** نص الآيات المعتمد للبحث والتظليلات والفواصل وعرض المصحف عبر كافة السور الـ 114 والآيات الـ 6,236، بالإضافة إلى 6,465 معنى لغوي معجمي مفرد يغطي كامل الـ 604 صفحات.

2. **خطوط المصحف والواجهة العامة (5 خطوط قرآنية مفتوحة المصدر — SIL OFL-1.1):**
   - **الخطوط:** `AmiriQuran` و `Amiri` (د. خالد حسني)، `ScheherazadeNew` (SIL International)، `NotoNaskhArabic` (Google / Monotype)، `Lateef` (SIL International)، و`Harmattan` (SIL International).
   - **الترخيص:** SIL Open Font License 1.1 (OFL-1.1).

3. **الشيفرة المصدرية للتطبيق:**
   - **الترخيص:** MIT License (`LICENSE`).

---

## 11. القرارات التقنية والقيود المعروفة (ADR)

### 1. توحيد قسم التدبّر في `lib/features/tadbeer/`
- **القرار:** نقل ملفات `tadbeer_intro_screen.dart` و `tadbeer_model.dart` و `tadbeer_pause_sheet.dart` لمجلد موحد وحذف مجلد `tadabbur` القديم.
- **السبب:** القضاء على الازدواجية في التسمية وتجميع منطق وقفة التدبّر والأسئلة الأربعة في موضع واحد واضح.

### 2. تسطيح مجلد الأدعية `lib/features/duas/`
- **القرار:** وضع ملفات قسم الأدعية الخمسة مباشرة داخل المجلد وإلغاء 4 مجلدات فرعية أحادية (`data`, `models`, `screens`, `widgets`).
- **السبب:** إزالة التعقيد الهيكلي غير المبرر؛ حيث كان كل مجلد فرعي يحتوي على ملف واحد فقط.

### 3. مركزية `UserDataStore` وفصل المستودعات
- **القرار:** فصل نماذج البيانات (`*_model.dart`) عن كلاسات المستودعات (`*_repository.dart`)، مع جعل `UserDataStore` مرجعًا وحيدًا للحالة (`ChangeNotifier`).
- **السبب:** تمكين اختبار المستودعات بحقن كاش معزول، مع توفير استعلامات فورية في الذاكرة بزمن $O(1)$ لويدجت المصحف دون استعلام SQLite في كل إطار.

### 4. التحكم التفاعلي بنوع وحجم الخط في `SettingsScreen` وشريط المصحف
- **القرار:** إضافة قسم «الخط والقراءة» في الإعدادات مع 5 عائلات خطوط قرآنية، وشريط تمرير تفاعلي لحجم الخط (16.0–32.0 نقطة)، وزر استعادة الافتراضي، ومعاينة حية للآية الكريمة، وزر سريع مباشر في شريط أدوات القراءة.
- **السبب:** تمكين المستخدم من ملاءمة نوع وحجم الخط لحجم الشاشة وراحته البصرية مع تحديث لحظي لكافة أجزاء التطبيق.

### 5. دقة توثيق تشفير النسخ الاحتياطية وحدود الاستعادة
- **القرار:** توثيق أن اشتقاق المفتاح يتم عبر دمج كلمة المرور والملح وتمريرهما مباشرة إلى `SHA-256` وليس عبر PBKDF2، وتوضيح أن استبدال قاعدة البيانات بعد الفحوصات الأولية لا يعتمد معاملة ذرية واحدة.
- **السبب:** الالتزام بالدقة التامة ومطابقة الكود الفعلي المنفذ في `BackupCryptoService` و`UserDataStore`.

### 6. معرّفات التنبيهات في `LocalReminderService`
- **القرار:** توليد معرّف الإشعار عبر الصيغة `(id.hashCode.abs() % 100000) + dayOfWeek` للتنبيهات الأسبوعية.
- **السبب:** تفريق الأيام المختلفة للتنبيه الواحد، مع ملاحظة أن تصادم التجزئة بين تنبيهات مختلفة يظل ممكنًا نظريًا ضمن فضاء الأرقام المستخدم.

### 7. معمارية سجل البحث الموحد القابل للتوسع
- **القرار:** بناء سجل لامركزي `SearchRegistry` يدعم مزوّدات بحث مستقلة `SearchProvider` بدلًا من كتابة استعلامات ثابتة ومقيدة داخل `SearchScreen`.
- **السبب:** فصل منطق البحث لكل قسم ومجال بيانات (القرآن، الخواطر، التدبر، الفواصل، التظليلات، روابط الآيات، الأدعية، التنبيهات، معاني الكلمات)، وتمكين الاستعلام المتوازي عبر `Future.wait` مع عزل أخطاء كل مزوّد عبر `try/catch`، وتوليد شرائح تصفية النتائج تلقائيًا في الواجهة دون الحاجة لتعديل شاشة البحث عند إضافة ميزات مستقبلية.

### 8. معجم معاني الكلمات وقاعدة اللفظ المفرد وتجريد التفسير السياقي
- **القرار:** الالتزام الصارم بقاعدة اللفظ المفرد في كامل مدخلات `assets/quran/word_meanings.json` (0 عبارات مركبة أو مسافات في حقل `word`)، وتفكيك المركبات (مثل `الصِّرَاطَ المُستَقِيمَ`) إلى ألفاظ مفردة مستقلة لكل منها معناه المعجمي الخاص.
- **السبب:** الفصل التام بين المعنى اللغوي المعجمي المجرد وبين التفسير السياقي للآيات، والالتزام بأسلوب معاجم غريب القرآن الهامشية في المصاحف المطبوعة، وتحقيق تغطية تامة بنسبة 100% لجميع صفحات المصحف الشريف الـ 604، وضمان مطابقة معجمية دقيقة بزمن $O(1)$ لكل لفظ مفرد.

### 9. الانتقال إلى محرك المصحف المتجاوب متعدد الخطوط المفتوحة المصدر
- **القرار:** الاستغناء الكامل عن خطوط QCF V2 الـ 604 (202 ميجابايت) وتخطيط الأسطر الـ 15 الثابت (`mushaf_layout.json`)، وإعادة بناء `QuranPageView` بالاعتماد على 5 خطوط قرآنية مفتوحة المصدر (SIL OFL-1.1) ونظام قيود متجاوب (`LayoutBuilder` + `SingleChildScrollView`).
- **السبب:** ضمان توافق قانوني وتقني مطلق للمشروع كمصدر مفتوح ومتاجر التطبيقات، وتوافق تام مع كافة أبعاد وشاشات الأجهزة مع منع تام لأخطاء تجاوز الحدود (`RenderFlex overflow`)، وتمكين المستخدم من تكبير وتصغير الخط بحرية (16–32 نقطة) دون أي تعارض مع مزايا التطبيق التدبرية.

---

## 12. قائمة تحقق قبل اعتماد التعديل

قبل تسليم أي تعديل برمجي أو اعتماده في المشروع، يُرجى التحقق من القائمة التالية:

- [ ] **فحص سلامة النص القرآني:** التأكد من عدم المساس بأي من ملفات النصوص القرآنية في `assets/quran/`.
- [ ] **انضباط التخطيط المتجاوب:** التأكد من عدم حدوث أي تجاوز للحدود (`RenderFlex overflow`) على مختلف قياسات الشاشات في `QuranPageView`.
- [ ] **التحليل الساكن:** تشغيل `dart analyze` والتأكد من ظهور نتيجة `No issues found!`.
- [ ] **تشغيل الاختبارات:** تشغيل `flutter test` والتأكد من نجاح كافة الاختبارات الـ 174 دون أي فشل.
- [ ] **تزامن الترجمة:** التأكد من إضافة أي نصوص جديدة في كل من نسختي العربية والإنجليزية داخل `lib/app/localization.dart`.
- [ ] **مراجعة فوارق Git:** مراجعة `git diff --check` للتأكد من خلو الملفات من مسافات زائدة وتأكيد اقتصار التعديلات على الملفات المستهدفة فقط.
