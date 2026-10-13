# إشعارات الأطراف الثالثة وسجل التدقيق القانوني والتراخيص (THIRD_PARTY_NOTICES)

**المشروع:** تَدْبِير (`Tadbeer`) — تطبيق قرآني مفتوح المصدر للقراءة والتدبّر دون إنترنت  
**إصدار التطبيق:** `1.0.0+1`  
**الترخيص الرئيسي للمشروع:** `MIT License (MIT)` ([`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE))  
**تاريخ التدقيق:** `2026-10-13`

---

## 1. ملخص التدقيق (Audit Summary)

### 1.1 نطاق الفحص
أُجري تدقيق شامل ومستقل قائم على الأدلة الفعلية لجميع مكونات مشروع «تدبير» (`tadbeer`) عبر كامل شجرة المستودع وملفات البناء والتوزيع، وشمل الفحص:
1. **الشيفرات المصدرية والملفات التنفيذية والأدوات:** جميع ملفات `lib/`، وملفات الاختبارات `test/`، وأدوات معالجة البيانات في `tool/` (`build_quran_dataset.dart`، `process_quran_meanings.py`، `build_lexicon_meanings.py`، `refine_and_split_meanings.py`).
2. **الاعتماديات المباشرة والمتعدية (Dart & Flutter Packages):** جميع الحزم المسجلة في [`pubspec.yaml`](file:///home/karar1x/Programming/tadbeer/pubspec.yaml) و[`pubspec.lock`](file:///home/karar1x/Programming/tadbeer/pubspec.lock) و`.dart_tool/package_config.json` والبالغ عددها **114 حزمة** (16 اعتمادية تشغيل مباشرة، و3 اعتماديات تطوير مباشرة، و95 اعتمادية متعدية)، بالإضافة إلى فحص ملف الإشعارات المجمّع وقت البناء `build/flutter_assets/NOTICES.Z` (الذي يضم 1,642 كتلة إشعار للمحرك والحزم) وتسجيل الأصول في `LicenseRegistry` داخل [`lib/main.dart`](file:///home/karar1x/Programming/tadbeer/lib/main.dart).
3. **الخطوط المضمّنة (Fonts):** فحص الجداول الثنائية الداخلية (`OpenType name tables`) لجميع ملفات الخطوط السبعة المضمّنة في `assets/fonts/` بالإضافة إلى خط `MaterialIcons-Regular.otf` المضمّن عبر Flutter وخط `IslamicIcons.ttf` المضمّن عبر حزمة `flutter_islamic_icons`.
4. **البيانات القرآنية والمعجمية والمحتوى المضمّن:** فحص ملفات `assets/quran/quran_data.json`، و`assets/quran/word_meanings.json`، والمحتوى المضمّن في الشيفرة المصدرية (`curated_pathways.dart` و`quran_duas_repository.dart`).
5. **الصور والأيقونات والتصميمات:** فحص `assets/icons/app_icon.png`، و`assets/icons/app_icon_foreground.png`، و`assets/icons/app_logo.png`، وملف التصميم المصدري `logo.vectorcraft`، وجميع أيقونات المشغّل المولّدة لمنصات Android وiOS وmacOS وWindows وWeb.
6. **مكونات المنصات المستهدفة والاعتماديات الأصلية (Native & Platform Toolchains):** فحص إعدادات البناء والمكتبات الأصلية في `android/` (Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, `desugar_jdk_libs:2.1.4`, AndroidX, `libflutter.so`, `libsqlite3.so`, `libdartjni.so`)، و`linux/` (CMake, GTK 3, `libflutter_linux_gtk.so`, `icudtl.dat`)، و`windows/` (Win32 C++ Runner, CMake)، و`ios/` و`macos/` (Xcode Runners, Swift/Objective-C bindings, `PrivacyInfo.xcprivacy`)، و`web/`.

### 1.2 تنظيف المكونات المهجورة غير المستخدمة (QCF / QUL & Excluded Dumps Cleanup)
بناءً على مراجعة المصادر الفعلية المستخدمة في التطبيق، تم التحقق من أن التطبيق استغنى بالكامل عن خطوط وتخطيطات `QCF V2` و`QUL` (`Quranic Universal Library`) وخط `DigitalKhatt`، وتم تنظيف وإزالة البقايا المهجورة غير المستخدمة:
- حذف محولات التوافق والمصيّرات القديمة غير المستخدمة: `lib/features/quran/data/qcf_font_manager.dart`، `lib/features/quran/data/qcf_glyph_service.dart`، `lib/features/quran/data/mushaf_layout_models.dart`، `lib/features/quran/renderers/mushaf_line_widget.dart`، `lib/features/quran/renderers/mushaf_word_widget.dart`، وأداة `tool/build_mushaf_layout.dart`.
- حذف ملفي المراجعة غير المستخدمين (`assets/quran/word_meanings_excluded.json` و`tool/manual_reviews.json`) وملف `tadbeer.apk` المؤقت.
- تحديث [`ATTRIBUTION.md`](file:///home/karar1x/Programming/tadbeer/ATTRIBUTION.md) و[`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE) (`MIT License`) ليعكسا المصادر والخطوط الفعلية المستخدمة فقط.

### 1.3 منهجية التدقيق والأدوات المستخدمة وحدود التحقق
- **الأدوات المستخدمة:** فحص مباشر لملفات `LICENSE` المحلية لجميع الـ 114 حزمة في `.pub-cache` وSDK، تحليل ثنائي مباشر لجداول `name` داخل ملفات `.ttf`/`.otf` عبر Python `struct`، فحص `build/flutter_assets/NOTICES.Z`، وفحص ترويسة `license` في `/home/karar1x/Downloads/meanings.json` وسياسات `https://quranpedia.net/dumps/LICENSE.md`.
- **نتيجة التحقق:** تم التحقق يقينًا من تراخيص جميع الحزم البرمجية الـ 114، وجميع خطوط المصحف والواجهة الـ 7 (`SIL OFL 1.1`)، ونص القرآن العثماني (`Tanzil CC BY 3.0`)، ومصدر بيانات معاني الكلمات (`Quranpedia.net Data License — Version 2026-10-10` والمعاجم التراثية في الملكية العامة).

---

## 2. سجل المكونات (Component Registry)

### 2.1 المشروع الأساسي وأطر التشغيل والمحركات (Core Project, SDKs & Engines)

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Tadbeer (`tadbeer`)** — الشيفرة المصدرية لتطبيق تدبير | جذر المستودع (`lib/`, `test/`, `tool/`) | `1.0.0+1` | التطبيق الرئيسي؛ **يدخل في التوزيع** | `MIT` | Copyright (c) 2026 Tadbeer Project Contributors | المستودع المحلي | إرفاق نص MIT License والحفاظ على إشعار حقوق النشر | **مؤكد** — [`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE) |
| **Flutter SDK Framework (`flutter`)** — إطار عمل واجهات المستخدم | Flutter SDK (`packages/flutter`) | Flutter SDK (Dart `^3.13.5`) | يرتبط برمجيًا؛ **يدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | إرفاق إشعار حقوق النشر ونص ترخيص BSD-3-Clause وإخلاء المسؤولية | **مؤكد** — ملف `LICENSE` في جذر Flutter SDK و`NOTICES.Z` |
| **Flutter Engine (`sky_engine` / `libflutter.so` / `Flutter.framework`)** — محرك الرسوميات والتشغيل (Impeller/Skia/HarfBuzz/ICU/BoringSSL) | Flutter SDK (`bin/cache/pkg/sky_engine`) | SDK Engine | يُضمّن كمكتبة أصلية؛ **يدخل في التوزيع** | `BSD-3-Clause` + تراخيص مكونات مضمّنة متعددة (MIT, BSD, Apache-2.0, ICU) | Copyright 2013 The Flutter Authors / Google LLC ومؤلفو المكونات الفرعية | https://github.com/flutter/flutter | تضمين ملف `NOTICES.Z` وإتاحة عرض التراخيص داخل التطبيق (`showLicensePage`) | **مؤكد** — `sky_engine/LICENSE` (84,965 سطرًا) و`build/flutter_assets/NOTICES.Z` |
| **ICU Data (`icudtl.dat`)** — جداول يونيكود واللغات | `linux/flutter/ephemeral/icudtl.dat` ومحرك أندرويد/iOS | ICU (مضمّن في Flutter) | بيانات تدويل المحرك؛ **يدخل في التوزيع** | `Unicode-DFS-2016` / `ICU License` | Copyright © 1991-2024 Unicode, Inc. All rights reserved. | https://icu.unicode.org/ | إرفاق إشعار حقوق نشر Unicode المضمّن بالفعل داخل `NOTICES.Z` | **مؤكد** — مضمّن في `build/flutter_assets/NOTICES.Z` |
| **Flutter Web Plugins (`flutter_web_plugins`)** — تسجيل إضافات الويب | Flutter SDK (`packages/flutter_web_plugins`) | SDK | يُضمّن في بناء الويب؛ **يدخل في توزيع الويب** | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | إرفاق إشعار BSD-3-Clause | **مؤكد** — يتبع ترخيص Flutter SDK الرئيسي |
| **Flutter Test (`flutter_test`)** — إطار الاختبارات الآلية | Flutter SDK (`packages/flutter_test`) | SDK | وقت التطوير والاختبار فقط؛ **لا يدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | لا توجد التزامات عند توزيع التطبيق (أداة اختبار فقط) | **مؤكد** — يتبع ترخيص Flutter SDK الرئيسي |

---

### 2.2 الخطوط المضمّنة (Bundled Fonts)

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Scheherazade New (`ScheherazadeNew`)** — الخط الافتراضي للمصحف الشريف | `assets/fonts/ScheherazadeNew-Regular.ttf` | `Version 4.500` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` (مع الأسماء المحفوظة: `"Scheherazade"`, `"SIL"`) | Copyright (c) 1994-2026, SIL Global (https://www.sil.org/) | https://software.sil.org/scheherazade/ | إرفاق إشعار الحقوق ونص OFL-1.1، عدم بيع الخط منفردًا، عدم استخدام الاسم المحفوظ في نسخ معدلة | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملف `.ttf` |
| **Noto Naskh Arabic (`NotoNaskhArabic`)** — خط النسخ الواضح للمصحف | `assets/fonts/NotoNaskhArabic-Regular.ttf` | `Version 2.021` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` | Copyright 2022 The Noto Project Authors (Monotype Design Team, David Williams, Mohamad Dakak, Nizar Qandah) | https://github.com/notofonts/arabic | إرفاق إشعار الحقوق ونص OFL-1.1، عدم بيع الخط منفردًا | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملف `.ttf` |
| **Harmattan (`Harmattan`)** — خط هرمتان القرآني | `assets/fonts/Harmattan-Regular.ttf` | `Version 4.400` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` (مع الأسماء المحفوظة: `"Harmattan"`, `"Fouta"`, `"Andika"`, `"SIL"`) | Copyright (c) 2007-2008 The C&MA Guinea Fulbe Team; 2011-2012 George W. Nuss; 2004-2025 SIL Global | https://software.sil.org/harmattan/ | إرفاق إشعار الحقوق ونص OFL-1.1، احترام الأسماء المحفوظة | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملف `.ttf` |
| **Lateef (`Lateef`)** — خط لطيف القرآني | `assets/fonts/Lateef-Regular.ttf` | `Version 4.400` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` (مع الأسماء المحفوظة: `"Lateef"`, `"SIL"`) | Copyright (c) 1994-2025, SIL Global (https://www.sil.org/) | https://software.sil.org/lateef/ | إرفاق إشعار الحقوق ونص OFL-1.1، احترام الأسماء المحفوظة | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملف `.ttf` |
| **Amiri Quran (`AmiriQuran`)** — خط أميري للقرآن الكريم | `assets/fonts/AmiriQuran-Regular.ttf` | `Version 1.003` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` | Copyright 2010-2022 The Amiri Project Authors (Khaled Hosny / Alif Type) | https://github.com/aliftype/amiri | إرفاق إشعار الحقوق ونص OFL-1.1 | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملف `.ttf` |
| **Amiri Regular & Bold (`Amiri`)** — خط الواجهة والعناوين والأدعية | `assets/fonts/Amiri-Regular.ttf` و`assets/fonts/Amiri-Bold.ttf` | `Version 1.002` | مضمّن في الأصول؛ **يدخل في التوزيع** | `SIL Open Font License 1.1` | Copyright 2010-2022 The Amiri Project Authors (Khaled Hosny / Alif Type) | https://github.com/aliftype/amiri | إرفاق إشعار الحقوق ونص OFL-1.1 | **مؤكد** — جدول `name` (السجلان 0 و13) داخل ملفي `.ttf` |
| **Material Icons (`MaterialIcons-Regular.otf`)** — خط أيقونات Material Design | يُضمّن تلقائيًا عبر `uses-material-design: true` في `build/flutter_assets/fonts/MaterialIcons-Regular.otf` | `2022-09-07` | مضمّن في الأصول المولّدة؛ **يدخل في التوزيع** | `Apache-2.0` | Copyright 2019 Google LLC. All Rights Reserved. | https://github.com/google/material-design-icons | إرفاق نص Apache-2.0 وإشعار حقوق Google LLC | **مؤكد** — جدول `name` في `MaterialIcons-Regular.otf` و`NOTICES.Z` |
| **IslamicIcons (`IslamicIcons.ttf`)** — خط الأيقونات الإسلامية | داخل حزمة `flutter_islamic_icons` (`assets/fonts/IslamicIcons.ttf`) | `Version 1.0` | يُضمّن كأصل خط من الحزمة؛ **يدخل في التوزيع** | الحزمة مرخصة بـ `BSD-2-Clause` | Copyright 2022, RAMAZAN ERBASARAN / original authors @ fluttericon.com, fontello.com | https://pub.dev/packages/flutter_islamic_icons | إرفاق BSD-2-Clause | **مؤكد لرخصة الحزمة (`BSD-2-Clause`)** |

---

### 2.3 البيانات القرآنية والمعجمية والمحتوى والأيقونات (Datasets, Content & Icons)

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **بيانات القرآن الكريم بالرسم العثماني (`quran_data.json`)** — 114 سورة، 6,236 آية، 604 صفحات، الأجزاء والأحزاب والسجدات | `assets/quran/quran_data.json` (مبني عبر `tool/build_quran_dataset.dart`) | Tanzil `1.1` | مضمّن في `pubspec.yaml`؛ **يدخل في التوزيع** | `CC BY 3.0` (مع شرط عدم التغيير في النص القرآني) | Copyright (C) 2007-2026 Tanzil Project (https://tanzil.net) | https://tanzil.net/download/ | 1. عدم تعديل النص القرآني بأي شكل.<br>2. الإسناد الصريح لمشروع Tanzil.net مع رابط الموقع. | **مؤكد** — موثق في `ATTRIBUTION.md` و`LICENSE` |
| **معجم معاني كلمات القرآن (`word_meanings.json`)** — 6,465 مدخلًا معجميًا مفردًا تغطي الـ 604 صفحات | `assets/quran/word_meanings.json` (مشتق ومحرّر من حزمة بيانات `Quranpedia.net` إصدار `2026-10-10` عبر `tool/process_quran_meanings.py` و`tool/build_lexicon_meanings.py` و`tool/refine_and_split_meanings.py`) | `2026-10-10` | مضمّن في `pubspec.yaml`؛ **يدخل في التوزيع** | `Quranpedia.net Data License (2026-10-10)` + معاجم تراثية في الملكية العامة | الرقمنة والهيكلة: فريق الموسوعة القرآنية (`Quranpedia.net`)؛ التراث: ابن الهائم وابن الجوزي وابن منظور وابن فارس والراغب (ملكية عامة)؛ المعاصرة: د. محمد الخضيري، حسنين مخلوف، مجمع اللغة العربية بالقاهرة | https://quranpedia.net/dumps/LICENSE.md | 1. مجاني للاستخدام داخل التطبيقات.<br>2. عند نشر البيانات كملف قابل للتنزيل يلزم ذكر `Quranpedia.net` مع الرابط ورقم الإصدار (`2026-10-10`). | **مؤكد** — موثق في `ATTRIBUTION.md` والقسم 3.10 |
| **مستودع الأدعية القرآنية (`quran_duas_repository.dart`)** — 88 دعاءً قرآنيًا مصنفًا في 12 بابًا | `lib/features/duas/quran_duas_repository.dart` | `1.0.0` | شيفرة مصدرية وبيانات مضمّنة؛ **يدخل في التوزيع** | النصوص القرآنية: `CC BY 3.0` (Tanzil)؛ التبويب والبرمجة: `MIT` | مشروع تنزيل (للآيات) / مؤلفو مشروع تدبير (للتبويب والبرمجة) | المستودع المحلي | الحفاظ على دقة النص القرآني وإسناد Tanzil | **مؤكد** — مفحوص عبر `test/duas/quran_duas_test.dart` |
| **المسارات التدبرية المقترحة (`curated_pathways.dart`)** — 4 مسارات تدبرية موضوعية مدمجة | `lib/features/ayah_links/curated_pathways.dart` | `1.0.0` | شيفرة مصدرية؛ **يدخل في التوزيع** | `MIT` | مؤلفو مشروع تدبير | المستودع المحلي | يخضع لترخيص المشروع الرئيسي `MIT` | **مؤكد** — تأليف أصلي خاص بالمشروع |
| **أيقونات وشعار تطبيق تدبير (`app_icon.png`, `app_icon_foreground.png`, `app_logo.png`, `logo.vectorcraft`)** + أيقونات المنصات المولّدة | `assets/icons/*`، `logo.vectorcraft`، `android/app/src/main/res/mipmap-*`، `ios/Runner/Assets.xcassets`، `macos/`، `windows/`، `web/icons/` | `1.0.0` | مضمّنة في `pubspec.yaml` وموارد المنصات؛ **تدخل في التوزيع** | `MIT` | مؤلفو مشروع تدبير | المستودع المحلي | موثق في `ATTRIBUTION.md` و`LICENSE` | **مؤكد** — موثق في `ATTRIBUTION.md` |

---
### 2.4 الاعتماديات البرمجية المباشرة (Direct Dependencies — 19 حزمة)

جميع الحزم التالية مصرح بها مباشرة في [`pubspec.yaml`](file:///home/karar1x/Programming/tadbeer/pubspec.yaml) وتم التحقق من ملفات `LICENSE` الخاصة بها في `.pub-cache`:

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`crypto`** — دوال التجزئة التشفيرية (SHA-256, HMAC, MD5) للنسخ الاحتياطي | `hosted` (`pub.dev`) | `3.0.7` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/crypto | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/crypto-3.0.7/LICENSE` |
| **`encrypt`** — واجهة تشفير عالية المستوى (AES/Salsa20/RSA) للنسخ الاحتياطي المشفر | `hosted` (`pub.dev`) | `5.0.3` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright (c) 2018, Leo Cavalcante | https://pub.dev/packages/encrypt | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/encrypt-5.0.3/LICENSE` |
| **`file_picker`** — اختيار الملفات من جهاز المستخدم (لاستيراد النسخ الاحتياطية) | `hosted` (`pub.dev`) | `13.1.0` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/file_picker | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file_picker-13.1.0/LICENSE` |
| **`flutter`** — إطار عمل Flutter الأساسي لبناء واجهات المستخدم | `sdk` (`pub.dev`) | `0.0.0` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/Programming/flutter/packages/flutter/LICENSE` |
| **`flutter_islamic_icons`** — مجموعة أيقونات إسلامية (المصحف، الدعاء، المسجد) | `hosted` (`pub.dev`) | `1.0.2` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-2-Clause` | Copyright 2022, RAMAZAN ERBASARAN | https://pub.dev/packages/flutter_islamic_icons | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_islamic_icons-1.0.2/LICENSE` |
| **`flutter_local_notifications`** — جدولة وعرض الإشعارات والمنبهات المحلية دون إنترنت | `hosted` (`pub.dev`) | `23.0.0-dev.2` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2018 Michael Bui. All rights reserved. | https://pub.dev/packages/flutter_local_notifications | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_local_notifications-23.0.0-dev.2/LICENSE` |
| **`flutter_timezone`** — الحصول على المنطقة الزمنية المحلية للجهاز لضبط أوقات المنبهات | `hosted` (`pub.dev`) | `5.1.1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `Apache-2.0` | flutter_timezone Authors (Apache-2.0) | https://pub.dev/packages/flutter_timezone | إرفاق نص Apache-2.0 وإشعارات حقوق النشر وبيان التغييرات إن وُجدت | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_timezone-5.1.1/LICENSE` |
| **`path`** — معالجة مسارات الملفات عبر أنظمة التشغيل المختلفة | `hosted` (`pub.dev`) | `1.9.1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/path | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path-1.9.1/LICENSE` |
| **`path_provider`** — الوصول إلى مسارات التخزين المحلية للتطبيق على الجهاز | `hosted` (`pub.dev`) | `2.1.6` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/path_provider | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider-2.1.6/LICENSE` |
| **`pdf`** — إنشاء وتصدير مستندات PDF للملاحظات ودفتر التدبّر | `hosted` (`pub.dev`) | `3.13.1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `Apache-2.0` | Copyright (c) 2017, David PHAM-VAN <dev.nfet.net@gmail.com> | https://pub.dev/packages/pdf | إرفاق نص Apache-2.0 وإشعارات حقوق النشر وبيان التغييرات إن وُجدت | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/pdf-3.13.1/LICENSE` |
| **`qr_flutter`** — رسم وعرض رموز QR في واجهة Flutter لمشاركة روابط الآيات | `hosted` (`pub.dev`) | `4.1.0` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright (c) 2020, Luke Freeman. | https://pub.dev/packages/qr_flutter | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/qr_flutter-4.1.0/LICENSE` |
| **`share_plus`** — مشاركة الملفات والنصوص عبر نافذة المشاركة الأصلية للنظام | `hosted` (`pub.dev`) | `13.3.1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2017, the Flutter project authors. All rights reserved. | https://pub.dev/packages/share_plus | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/share_plus-13.3.1/LICENSE` |
| **`sqflite`** — قاعدة بيانات SQLite المحلية لنظامي Android وiOS وسطح المكتب | `hosted` (`pub.dev`) | `2.4.4+1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite-2.4.4+1/LICENSE` |
| **`sqflite_common`** — الطبقة المشتركة لقاعدة بيانات SQLite بلغة Dart | `hosted` (`pub.dev`) | `2.5.13+1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite_common | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite_common-2.5.13+1/LICENSE` |
| **`sqflite_common_ffi`** — تشغيل SQLite عبر FFI على أنظمة سطح المكتب والاختبارات | `hosted` (`pub.dev`) | `2.4.3` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite_common_ffi | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite_common_ffi-2.4.3/LICENSE` |
| **`timezone`** — قاعدة بيانات المناطق الزمنية IANA وحساب التحويلات الزمنية | `hosted` (`pub.dev`) | `0.11.1` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `BSD-2-Clause` | Copyright (c) 2014, timezone project authors. | https://pub.dev/packages/timezone | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/timezone-0.11.1/LICENSE` |
| **`uuid`** — توليد المعرّفات الفريدة عالميًا (UUID v4) للملاحظات والروابط والتنبيهات | `hosted` (`pub.dev`) | `4.6.0` | اعتمادية تشغيل مباشرة؛ **تدخل في التوزيع** | `MIT` | Copyright (c) 2021 Yulian Kuncheff | https://pub.dev/packages/uuid | إرفاق إشعار حقوق النشر ونص الترخيص في التوزيع | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/uuid-4.6.0/LICENSE` |
| **`flutter_launcher_icons`** — أداة توليد أيقونات مشغّل التطبيق لجميع المنصات (وقت التطوير) | `hosted` (`pub.dev`) | `0.14.4` | اعتمادية تطوير واختبار (`dev_dependencies`)؛ **لا تدخل في التوزيع** | `MIT` | Copyright (c) 2019 Mark O'Sullivan | https://pub.dev/packages/flutter_launcher_icons | لا توجد التزامات عند توزيع التطبيق (تُستخدم وقت البناء/الاختبار فقط) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_launcher_icons-0.14.4/LICENSE` |
| **`flutter_lints`** — قواعد التحليل الثابت الموصى بها لمشاريع Flutter (وقت التطوير) | `hosted` (`pub.dev`) | `6.0.0` | اعتمادية تطوير واختبار (`dev_dependencies`)؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2013 The Flutter Authors. All rights reserved. | https://pub.dev/packages/flutter_lints | لا توجد التزامات عند توزيع التطبيق (تُستخدم وقت البناء/الاختبار فقط) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_lints-6.0.0/LICENSE` |
| **`flutter_test`** — إطار اختبارات الوحدات والواجهات لـ Flutter (وقت التطوير) | `sdk` (`pub.dev`) | `0.0.0` | اعتمادية تطوير واختبار (`dev_dependencies`)؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | لا توجد التزامات عند توزيع التطبيق (تُستخدم وقت البناء/الاختبار فقط) | **مؤكد** — يرث `LICENSE` من Flutter SDK |
| **`xml`** — تحليل وبناء مستندات XML (أدوات البناء ومعالجة SVG) | `hosted` (`pub.dev`) | `7.0.1` | اعتمادية تطوير واختبار (`dev_dependencies`)؛ **لا تدخل في التوزيع** | `MIT` | Copyright (c) 2006-2026 Lukas Renggli. | https://pub.dev/packages/xml | لا توجد التزامات عند توزيع التطبيق (تُستخدم وقت البناء/الاختبار فقط) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/xml-7.0.1/LICENSE` |

---

### 2.5 الاعتماديات البرمجية المتعدية (Transitive Dependencies — 95 حزمة)

جميع الحزم التالية تم استخراجها من [`pubspec.lock`](file:///home/karar1x/Programming/tadbeer/pubspec.lock) و`.dart_tool/package_config.json` وفُحصت ملفات تراخيصها الفعلية:

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`android_file_picker`** — تنفيذ اختيار الملفات لمنصة أندرويد (اعتمادية لـ file_picker) | `hosted` | `2.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/android_file_picker | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/android_file_picker-2.0.0/LICENSE` |
| **`archive`** — ضغط وفك ضغط الملفات بصيغ ZIP/TAR/GZip/ZLib | `hosted` | `4.3.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2013-2021 Brendan Duncan. | https://pub.dev/packages/archive | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/archive-4.3.0/LICENSE` |
| **`args`** — تحليل معاملات سطر الأوامر لبرامج وأدوات Dart | `hosted` | `2.7.0` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2013, the Dart project authors. | https://pub.dev/packages/args | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/args-2.7.0/LICENSE` |
| **`asn1lib`** — ترميز وفك ترميز هياكل بيانات ASN.1 (للشهادات والتشفير) | `hosted` | `1.6.5` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright (c) 2015, Warren Strange | https://pub.dev/packages/asn1lib | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/asn1lib-1.6.5/LICENSE` |
| **`async`** — أدوات مساعدة للعمليات غير المتزامنة (Futures / Streams) | `hosted` | `2.13.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/async | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/async-2.13.1/LICENSE` |
| **`barcode`** — توليد الرموز الشريطية ورموز QR (اعتمادية لمكتبة pdf) | `hosted` | `2.2.9` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `Apache-2.0` | Copyright (c) 2020, David PHAM-VAN <dev.nfet.net@gmail.com> | https://pub.dev/packages/barcode | إرفاق نص ترخيص `Apache-2.0` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/barcode-2.2.9/LICENSE` |
| **`bidi`** — خوارزمية يونيكود للنصوص ثنائية الاتجاه (العربية والإنجليزية في PDF) | `hosted` | `2.0.13` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2020 Mahdi K. Fard | https://pub.dev/packages/bidi | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/bidi-2.0.13/LICENSE` |
| **`boolean_selector`** — مُحلل تعبيرات منطقية لاختبارات Dart | `hosted` | `2.1.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2016, the Dart project authors. | https://pub.dev/packages/boolean_selector | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/boolean_selector-2.1.2/LICENSE` |
| **`characters`** — معالجة السلاسل النصية على مستوى العناقيد الحرفية (Grapheme Clusters) | `hosted` | `1.4.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2019, the Dart project authors. | https://pub.dev/packages/characters | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/characters-1.4.1/LICENSE` |
| **`checked_yaml`** — تحليل ملفات YAML مع التحقق من الأنواع (لأدوات البناء) | `hosted` | `2.0.4` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2019, the Dart project authors. All rights reserved. | https://pub.dev/packages/checked_yaml | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/checked_yaml-2.0.4/LICENSE` |
| **`cli_util`** — أدوات مساعدة لبناء تطبيقات سطر الأوامر في Dart | `hosted` | `0.4.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/cli_util | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/cli_util-0.4.2/LICENSE` |
| **`clock`** — تجريد لساعة النظام لتسهيل الاختبارات الزمنية | `hosted` | `1.1.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `Apache-2.0` | Copyright 2013 Google Inc. All Rights Reserved. | https://pub.dev/packages/clock | إرفاق نص ترخيص `Apache-2.0` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/clock-1.1.3/LICENSE` |
| **`code_assets`** — دعم الأصول البرمجية الأصلية (Native Code Assets) في نظام بناء Dart | `hosted` | `1.2.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2025, the Dart project authors. | https://pub.dev/packages/code_assets | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/code_assets-1.2.1/LICENSE` |
| **`collection`** — هياكل بيانات وخوارزميات مجموعات إضافية لـ Dart | `hosted` | `1.19.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/collection | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/collection-1.19.1/LICENSE` |
| **`convert`** — ترميز وفك ترميز البيانات (Hex / Percent / UTF) | `hosted` | `3.1.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/convert | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/convert-3.1.2/LICENSE` |
| **`cross_file`** — تجريد موحد للملفات عبر المنصات (XFile) | `hosted` | `0.3.5+5` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/cross_file | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/cross_file-0.3.5+5/LICENSE` |
| **`dbus`** — عميل بروتوكول D-Bus لنظام لينكس (للإشعارات وفتح الروابط) | `hosted` | `0.8.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MPL-2.0` | Canonical Ltd. (dbus.dart authors) | https://pub.dev/packages/dbus | ترخيص MPL-2.0 على مستوى الملفات؛ إتاحة شيفرة ملفات dbus إن عُدّلت وإرفاق إشعار MPL-2.0 (مضمّن في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/dbus-0.8.0/LICENSE` |
| **`equatable`** — مقارنة الكائنات بالقيمة في Dart | `hosted` | `3.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2026 Felix Angelov | https://pub.dev/packages/equatable | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/equatable-3.0.0/LICENSE` |
| **`fake_async`** — محاكاة الوقت والمؤقتات في الاختبارات الآلية | `hosted` | `1.3.3` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `Apache-2.0` | Copyright 2014 Google Inc. All Rights Reserved. | https://pub.dev/packages/fake_async | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/fake_async-1.3.3/LICENSE` |
| **`ffi`** — أدوات التعامل مع الذاكرة والمؤشرات في لغة C عبر dart:ffi | `hosted` | `2.2.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2019, the Dart project authors. | https://pub.dev/packages/ffi | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/ffi-2.2.0/LICENSE` |
| **`ffi_leak_tracker`** — تتبع تسرب الذاكرة في استدعاءات FFI | `hosted` | `0.1.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright (c) 2026, Halil Durmus | https://pub.dev/packages/ffi_leak_tracker | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/ffi_leak_tracker-0.1.2/LICENSE` |
| **`file`** — نظام ملفات قابل للتبديل والمحاكاة في الذاكرة | `hosted` | `7.0.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2017, the Dart project authors. All rights reserved. | https://pub.dev/packages/file | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file-7.0.1/LICENSE` |
| **`file_picker_darwin`** — تنفيذ اختيار الملفات لنظامي iOS وmacOS | `hosted` | `2.1.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/file_picker_darwin | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file_picker_darwin-2.1.2/LICENSE` |
| **`file_picker_linux`** — تنفيذ اختيار الملفات لنظام Linux | `hosted` | `2.0.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/file_picker_linux | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file_picker_linux-2.0.1/LICENSE` |
| **`file_picker_platform_interface`** — الواجهة المشتركة لمنصات اختيار الملفات | `hosted` | `4.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/file_picker_platform_interface | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file_picker_platform_interface-4.0.0/LICENSE` |
| **`file_picker_web`** — تنفيذ اختيار الملفات لمنصة الويب | `hosted` | `4.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/file_picker_web | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/file_picker_web-4.0.0/LICENSE` |
| **`fixnum`** — أعداد صحيحة ثابتة الطول (32-bit و64-bit) | `hosted` | `1.1.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/fixnum | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/fixnum-1.1.1/LICENSE` |
| **`flutter_local_notifications_linux`** — تنفيذ الإشعارات المحلية لنظام Linux | `hosted` | `9.0.0-dev.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2018 Michael Bui. All rights reserved. | https://pub.dev/packages/flutter_local_notifications_linux | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_local_notifications_linux-9.0.0-dev.2/LICENSE` |
| **`flutter_local_notifications_platform_interface`** — الواجهة المشتركة للإشعارات المحلية | `hosted` | `13.0.0-dev.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2020 Michael Bui. All rights reserved. | https://pub.dev/packages/flutter_local_notifications_platform_interface | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_local_notifications_platform_interface-13.0.0-dev.1/LICENSE` |
| **`flutter_local_notifications_web`** — تنفيذ الإشعارات المحلية لمنصة الويب | `hosted` | `2.0.0-dev.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2020 Michael Bui. All rights reserved. | https://pub.dev/packages/flutter_local_notifications_web | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_local_notifications_web-2.0.0-dev.1/LICENSE` |
| **`flutter_local_notifications_windows`** — تنفيذ الإشعارات المحلية لنظام Windows | `hosted` | `4.0.0-dev.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2024 Michael Bui. All rights reserved. | https://pub.dev/packages/flutter_local_notifications_windows | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/flutter_local_notifications_windows-4.0.0-dev.1/LICENSE` |
| **`flutter_web_plugins`** — دعم إضافات Flutter على منصة الويب | `sdk` | `0.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2014 The Flutter Authors. All rights reserved. | https://github.com/flutter/flutter | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — يرث `LICENSE` من Flutter SDK |
| **`glob`** — مطابقة مسارات الملفات بأنماط Glob | `hosted` | `2.2.0` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/glob | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/glob-2.2.0/LICENSE` |
| **`hooks`** — خطافات البناء والربط (Build & Link Hooks) لحزم Dart الأصلية | `hosted` | `2.0.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2025, the Dart project authors. | https://pub.dev/packages/hooks | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/hooks-2.0.2/LICENSE` |
| **`http`** — عميل طلبات HTTP (اعتمادية متعدية غير مستخدمة شبكيًا في تدبير) | `hosted` | `1.6.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/http | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/http-1.6.0/LICENSE` |
| **`http_parser`** — تحليل ترويسات ورسائل HTTP | `hosted` | `4.1.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/http_parser | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/http_parser-4.1.2/LICENSE` |
| **`image`** — معالجة الصور النقطية (توليد الأيقونات ومعالجة الصور في PDF) | `hosted` | `4.10.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2013-2022 Brendan Duncan. | https://pub.dev/packages/image | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/image-4.10.1/LICENSE` |
| **`jni`** — الربط مع Java Native Interface على أندرويد | `hosted` | `1.1.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2022, the Dart project authors. | https://pub.dev/packages/jni | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/jni-1.1.0/LICENSE` |
| **`jni_flutter`** — تكامل مكتبة JNI مع دورة حياة تطبيقات Flutter | `hosted` | `1.0.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2026, the Dart project authors. | https://pub.dev/packages/jni_flutter | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/jni_flutter-1.0.3/LICENSE` |
| **`jni_util`** — أدوات مساعدة لمكتبة JNI | `hosted` | `1.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2026, the Dart project authors. | https://pub.dev/packages/jni_util | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/jni_util-1.0.0/LICENSE` |
| **`js`** — التكامل بين Dart وJavaScript على منصة الويب | `hosted` | `0.7.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2012, the Dart project authors. | https://pub.dev/packages/js | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/js-0.7.2/LICENSE` |
| **`json_annotation`** — تعليقات توضيحية لتوليد شيفرات JSON | `hosted` | `4.12.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2017, the Dart project authors. All rights reserved. | https://pub.dev/packages/json_annotation | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/json_annotation-4.12.0/LICENSE` |
| **`leak_tracker`** — إطار كشف تسرب الذاكرة في الاختبارات | `hosted` | `11.0.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2022, the Dart project authors. | https://pub.dev/packages/leak_tracker | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/leak_tracker-11.0.2/LICENSE` |
| **`leak_tracker_flutter_testing`** — تكامل كاشف تسرب الذاكرة مع اختبارات Flutter | `hosted` | `3.0.10` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2022, the Dart project authors. | https://pub.dev/packages/leak_tracker_flutter_testing | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/leak_tracker_flutter_testing-3.0.10/LICENSE` |
| **`leak_tracker_testing`** — أدوات اختبار كاشف تسرب الذاكرة | `hosted` | `3.0.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2022, the Dart project authors. | https://pub.dev/packages/leak_tracker_testing | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/leak_tracker_testing-3.0.2/LICENSE` |
| **`lints`** — قواعد التحليل الثابت الأساسية للغة Dart | `hosted` | `6.1.0` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2021, the Dart project authors. | https://pub.dev/packages/lints | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/lints-6.1.0/LICENSE` |
| **`logging`** — واجهة تسجيل الأحداث والرسائل التشخيصية | `hosted` | `1.3.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013, the Dart project authors. | https://pub.dev/packages/logging | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/logging-1.3.0/LICENSE` |
| **`matcher`** — مكتبة المطابقات والتحقق في الاختبارات | `hosted` | `0.12.20` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/matcher | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/matcher-0.12.20/LICENSE` |
| **`material_color_utilities`** — خوارزميات توليد أنظمة ألوان Material Design 3 | `hosted` | `0.13.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `Apache-2.0` | Copyright 2021 Google LLC | https://pub.dev/packages/material_color_utilities | إرفاق نص ترخيص `Apache-2.0` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/material_color_utilities-0.13.0/LICENSE` |
| **`meta`** — تعليقات توضيحية للتحليل الثابت (@immutable, @protected) | `hosted` | `1.18.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2016, the Dart project authors. | https://pub.dev/packages/meta | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/meta-1.18.3/LICENSE` |
| **`mime`** — التعرف على أنواع ملفات MIME | `hosted` | `2.1.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/mime | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/mime-2.1.0/LICENSE` |
| **`native_toolchain_c`** — أدوات ترجمة وربط شيفرات C الأصلية في Dart | `hosted` | `0.19.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2023, the Dart project authors. | https://pub.dev/packages/native_toolchain_c | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/native_toolchain_c-0.19.2/LICENSE` |
| **`objective_c`** — التكامل مع لغة Objective-C وواجهات iOS/macOS | `hosted` | `9.5.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2024, the Dart project authors. | https://pub.dev/packages/objective_c | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/objective_c-9.5.0/LICENSE` |
| **`package_config`** — قراءة وتحليل ملفات تكوين حزم Dart | `hosted` | `3.0.0` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2019, the Dart project authors. | https://pub.dev/packages/package_config | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/package_config-3.0.0/LICENSE` |
| **`path_parsing`** — تحليل ورسم مسارات رسومات SVG (اعتمادية لمكتبة pdf) | `hosted` | `1.1.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Dan Field | https://pub.dev/packages/path_parsing | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_parsing-1.1.0/LICENSE` |
| **`path_provider_android`** — تنفيذ مسارات التخزين لنظام Android | `hosted` | `2.3.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/path_provider_android | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider_android-2.3.1/LICENSE` |
| **`path_provider_foundation`** — تنفيذ مسارات التخزين لنظامي iOS وmacOS | `hosted` | `2.6.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/path_provider_foundation | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider_foundation-2.6.0/LICENSE` |
| **`path_provider_linux`** — تنفيذ مسارات التخزين لنظام Linux | `hosted` | `2.2.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/path_provider_linux | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider_linux-2.2.2/LICENSE` |
| **`path_provider_platform_interface`** — الواجهة المشتركة لمسارات التخزين | `hosted` | `2.1.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/path_provider_platform_interface | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider_platform_interface-2.1.3/LICENSE` |
| **`path_provider_windows`** — تنفيذ مسارات التخزين لنظام Windows | `hosted` | `2.3.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors. All rights reserved. | https://pub.dev/packages/path_provider_windows | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/path_provider_windows-2.3.0/LICENSE` |
| **`petitparser`** — بناء المحللات النحوية (اعتمادية لمكتبتي xml وpdf) | `hosted` | `7.0.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2006-2024 Lukas Renggli. | https://pub.dev/packages/petitparser | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/petitparser-7.0.2/LICENSE` |
| **`platform`** — توفير معلومات نظام التشغيل والبيئة الحالية | `hosted` | `3.2.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2017, the Dart project authors. All rights reserved. | https://pub.dev/packages/platform | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/platform-3.2.0/LICENSE` |
| **`plugin_platform_interface`** — الفئة الأساسية لواجهات إضافات Flutter | `hosted` | `2.1.8` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors. All rights reserved. | https://pub.dev/packages/plugin_platform_interface | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/plugin_platform_interface-2.1.8/LICENSE` |
| **`pointycastle`** — محرك خوارزميات التشفير الأساسي (AES-GCM, PBKDF2, SHA) | `hosted` | `3.9.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2000 - 2019 The Legion of the Bouncy Castle Inc. (https://www.bouncycastle.org) | https://pub.dev/packages/pointycastle | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/pointycastle-3.9.1/LICENSE` |
| **`posix`** — استدعاء دوال نظام التشغيل المتوافقة مع معيار POSIX | `hosted` | `6.5.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2020 Brett Sutton | https://pub.dev/packages/posix | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/posix-6.5.2/LICENSE` |
| **`pub_semver`** — تحليل ومقارنة أرقام الإصدارات الدلالية (SemVer) | `hosted` | `2.2.1` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/pub_semver | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/pub_semver-2.2.1/LICENSE` |
| **`qr`** — محرك حساب مصفوفات رموز الاستجابة السريعة (QR) | `hosted` | `3.0.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2014, the Dart QR project authors. All rights reserved. | https://pub.dev/packages/qr | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/qr-3.0.2/LICENSE` |
| **`record_use`** — تسجيل استخدام الرموز البرمجية لتقليص حجم البناء (Tree-shaking) | `hosted` | `0.6.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2024, the Dart project authors. | https://pub.dev/packages/record_use | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/record_use-0.6.0/LICENSE` |
| **`share_plus_platform_interface`** — الواجهة المشتركة لإضافة المشاركة | `hosted` | `7.2.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2017 The Chromium Authors. All rights reserved. | https://pub.dev/packages/share_plus_platform_interface | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/share_plus_platform_interface-7.2.0/LICENSE` |
| **`sky_engine`** — الربط الأساسي لمحرك Flutter (dart:ui) ومكوناته الأصلية | `sdk` | `0.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause + Multiple Third-Party Notices (Engine)` | Copyright (c) 2017-2022 Advanced Micro Devices, Inc. All rights reserved. | https://pub.dev | إرفاق نص ترخيص `BSD-3-Clause + Multiple Third-Party Notices (Engine)` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/Programming/flutter/bin/cache/pkg/sky_engine/LICENSE` |
| **`source_span`** — تتبع مواقع النصوص والأسطر في الملفات المصدرية | `hosted` | `1.10.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/source_span | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/source_span-1.10.2/LICENSE` |
| **`sqflite_android`** — تنفيذ قاعدة بيانات SQLite الأصلي لنظام Android | `hosted` | `2.4.4` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite_android | إرفاق نص ترخيص `BSD-2-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite_android-2.4.4/LICENSE` |
| **`sqflite_darwin`** — تنفيذ قاعدة بيانات SQLite لنظامي iOS وmacOS | `hosted` | `2.4.4` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite_darwin | إرفاق نص ترخيص `BSD-2-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite_darwin-2.4.4/LICENSE` |
| **`sqflite_platform_interface`** — الواجهة المشتركة لإضافة sqflite | `hosted` | `2.4.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-2-Clause` | Copyright (c) 2019, Alexandre Roux Tekartik | https://pub.dev/packages/sqflite_platform_interface | إرفاق نص ترخيص `BSD-2-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqflite_platform_interface-2.4.2/LICENSE` |
| **`sqlite3`** — ربط مباشر عبر FFI مع مكتبة SQLite3 بلغة C | `hosted` | `3.5.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2020 Simon Binder | https://pub.dev/packages/sqlite3 | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/sqlite3-3.5.2/LICENSE` |
| **`stack_trace`** — تحليل وتنسيق آثار المكدس (Stack Traces) | `hosted` | `1.12.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/stack_trace | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/stack_trace-1.12.2/LICENSE` |
| **`stream_channel`** — قنوات اتصال ثنائية الاتجاه عبر التدفقات (Streams) | `hosted` | `2.1.4` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/stream_channel | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/stream_channel-2.1.4/LICENSE` |
| **`string_scanner`** — مسح وتحليل السلاسل النصية عبر التعبيرات النمطية | `hosted` | `1.4.1` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2014, the Dart project authors. | https://pub.dev/packages/string_scanner | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/string_scanner-1.4.1/LICENSE` |
| **`synchronized`** — أقفال التزامن (Locks/Mutex) لمنع التداخل في العمليات غير المتزامنة | `hosted` | `3.4.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2016, Alexandre Roux Tekartik. | https://pub.dev/packages/synchronized | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/synchronized-3.4.2/LICENSE` |
| **`term_glyph`** — رموز نصية ومحارف طرفية (ASCII/Unicode) | `hosted` | `1.2.2` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2017, the Dart project authors. | https://pub.dev/packages/term_glyph | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/term_glyph-1.2.2/LICENSE` |
| **`test_api`** — الواجهة الأساسية لتشغيل الاختبارات في Dart | `hosted` | `0.7.12` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2018, the Dart project authors. | https://pub.dev/packages/test_api | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/test_api-0.7.12/LICENSE` |
| **`typed_data`** — مخازن بيانات رقمية ومصفوفات بايتات إضافية | `hosted` | `1.4.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/typed_data | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/typed_data-1.4.0/LICENSE` |
| **`url_launcher_linux`** — فتح الروابط الخارجية على نظام Linux | `hosted` | `3.2.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/url_launcher_linux | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/url_launcher_linux-3.2.3/LICENSE` |
| **`url_launcher_platform_interface`** — الواجهة المشتركة لفتح الروابط | `hosted` | `2.3.2` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors. All rights reserved. | https://pub.dev/packages/url_launcher_platform_interface | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/url_launcher_platform_interface-2.3.2/LICENSE` |
| **`url_launcher_web`** — فتح الروابط الخارجية على منصة الويب | `hosted` | `2.4.3` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/url_launcher_web | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/url_launcher_web-2.4.3/LICENSE` |
| **`url_launcher_windows`** — فتح الروابط الخارجية على نظام Windows | `hosted` | `3.1.6` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/url_launcher_windows | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/url_launcher_windows-3.1.6/LICENSE` |
| **`vector_math`** — حسابات المتجهات والمصفوفات للرسوميات ثنائية وثلاثية الأبعاد | `hosted` | `2.4.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors | https://pub.dev/packages/vector_math | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/vector_math-2.4.0/LICENSE` |
| **`vm_service`** — بروتوكول الاتصال بخدمة آلة Dart الافتراضية (وقت التطوير) | `hosted` | `15.3.0` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `BSD-3-Clause` | Copyright 2015, the Dart project authors. | https://pub.dev/packages/vm_service | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/vm_service-15.3.0/LICENSE` |
| **`web`** — واجهات برمجة تطبيقات المتصفح الحديثة (DOM / Web APIs) | `hosted` | `1.1.1` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2023, the Dart project authors. | https://pub.dev/packages/web | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/web-1.1.1/LICENSE` |
| **`win32`** — الربط مع واجهات نظام التشغيل Windows Win32/COM عبر FFI | `hosted` | `6.4.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright (c) 2024, Halil Durmus | https://pub.dev/packages/win32 | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/win32-6.4.0/LICENSE` |
| **`windows_file_picker`** — نافذة اختيار الملفات الأصلية لنظام Windows | `hosted` | `2.0.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `MIT` | Copyright (c) 2018 Miguel Ruivo | https://pub.dev/packages/windows_file_picker | إرفاق نص ترخيص `MIT` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/windows_file_picker-2.0.0/LICENSE` |
| **`xdg_directories`** — قراءة مسارات المستخدم القياسية XDG على نظام Linux | `hosted` | `1.1.0` | اعتمادية تشغيل متعدية؛ **تدخل في التوزيع** (أو حسب المنصة المستهدفة) | `BSD-3-Clause` | Copyright 2013 The Flutter Authors. All rights reserved. | https://pub.dev/packages/xdg_directories | إرفاق نص ترخيص `BSD-3-Clause` وإشعار الحقوق (مضمّن أيضًا في `NOTICES.Z`) | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/xdg_directories-1.1.0/LICENSE` |
| **`yaml`** — محلل ملفات YAML الرسمي للغة Dart | `hosted` | `3.1.4` | اعتمادية متعدية لأدوات الاختبار/التطوير؛ **لا تدخل في التوزيع** | `MIT` | Copyright (c) 2014, the Dart project authors. | https://pub.dev/packages/yaml | لا توجد التزامات عند توزيع التطبيق | **مؤكد** — `/home/karar1x/.pub-cache/hosted/pub.dev/yaml-3.1.4/LICENSE` |

---

### 2.6 الاعتماديات الأصلية ومكونات المنصات المستهدفة (Native & Platform Dependencies)

| اسم المكوّن ووصفه | موقعه أو مصدره | الإصدار | طريقة استخدامه ودخوله في التوزيع | اسم الترخيص وإصداره | صاحب حقوق النشر | رابط المصدر الرسمي | الالتزامات القانونية ذات الصلة | نتيجة التحقق والأدلة المتاحة |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SQLite3 C Library (`libsqlite3.so` / نظام SQLite)** — محرك قاعدة البيانات المدمج | يُترجم ويُربط عبر `sqlite3` / `sqflite` (`build/native_assets` أو مكتبة النظام) | `3.x` (`sqlite3 3.5.2`) | مكتبة أصلية مدمجة؛ **تدخل في التوزيع** | `Public Domain` (ملكية عامة) | D. Richard Hipp / Hipp, Wyrick & Company, Inc. | https://www.sqlite.org/copyright.html | لا توجد التزامات ترخيصية (ملكية عامة بالكامل) | **مؤكد** — توثيق SQLite الرسمي وملف ترخيص حزمة `sqlite3` |
| **Dart JNI Native Bridge (`libdartjni.so`)** — الجسر الأصلي لمكتبة `jni` على أندرويد | حزمة `jni` (`1.1.0`) في بناء أندرويد | `1.1.0` | مكتبة C أصلية مدمجة في أندرويد؛ **تدخل في توزيع Android** | `BSD-3-Clause` | Copyright 2022, the Dart project authors. | https://pub.dev/packages/jni | إرفاق إشعار BSD-3-Clause | **مؤكد** — `jni-1.1.0/LICENSE` |
| **Android Desugar JDK Libs (`com.android.tools:desugar_jdk_libs`)** — دعم واجهات Java الحديثة على إصدارات أندرويد الأقدم | [`android/app/build.gradle.kts`](file:///home/karar1x/Programming/tadbeer/android/app/build.gradle.kts#L46) (Maven Google) | `2.1.4` | يُدمج في DEX عند بناء Android؛ **يدخل في توزيع Android** | `GPL-2.0-with-classpath-exception` (استثناء الربط Classpath Exception) | Copyright (c) Oracle and/or its affiliates / Google LLC | https://github.com/google/desugar_jdk_libs | يسمح استثناء Classpath بربط المكتبة مع أي تطبيق دون فرض شروط GPL-2.0 على بقية المكونات؛ إبقاء إشعارات الحقوق | **مؤكد** — مستودع Google `desugar_jdk_libs` الرسمي |
| **AndroidX Support Libraries (`androidx.core`, `androidx.activity`, `androidx.lifecycle`, `androidx.fragment`, `androidx.media`, `androidx.window`)** — مكتبات Jetpack الأساسية لأندرويد | اعتماديات أصلية لإضافات Flutter (`flutter_local_notifications`, `share_plus`, `file_picker`) | متعددة (وفق AGP 9.1.0) | تُدمج في DEX؛ **تدخل في توزيع Android** | `Apache-2.0` | Copyright (C) The Android Open Source Project (Google LLC) | https://developer.android.com/jetpack/androidx | إرفاق نص Apache-2.0 (تُضمّن ملفات `META-INF/.../LICENSE.txt` تلقائيًا في APK) | **مؤكد** — ملفات `META-INF/androidx.*` |
| **Google GSON (`com.google.code.gson:gson`)** — تسلسل JSON في إضافة `flutter_local_notifications` لأندرويد | اعتمادية أصلية لـ `flutter_local_notifications` على أندرويد | `2.10.x` | تُدمج في DEX؛ **تدخل في توزيع Android** | `Apache-2.0` | Copyright 2008 Google Inc. | https://github.com/google/gson | إرفاق نص Apache-2.0 | **مؤكد** — `flutter_local_notifications` Android build.gradle |
| **Kotlin Standard Library & Coroutines (`org.jetbrains.kotlin`, `kotlinx-coroutines-android`)** — مكتبة لغة Kotlin القياسية | [`android/settings.gradle.kts`](file:///home/karar1x/Programming/tadbeer/android/settings.gradle.kts#L23) | `2.4.0` | تُدمج في DEX؛ **تدخل في توزيع Android** | `Apache-2.0` | Copyright 2010-2024 JetBrains s.r.o. and Kotlin Programming Language contributors | https://github.com/JetBrains/kotlin | إرفاق نص Apache-2.0 | **مؤكد** — رخصة JetBrains القياسية |
| **Gradle Wrapper (`gradle-wrapper.jar` & `gradlew`)** — أداة تشغيل نظام البناء لأندرويد | `android/gradle/wrapper/gradle-wrapper.jar` و`android/gradlew` | `Gradle 9.3.1` / `AGP 9.1.0` | أداة بناء في المستودع؛ **لا تدخل في التطبيق الموزّع** (تُوزّع ضمن المستودع المصدري فقط) | `Apache-2.0` | Copyright 2007-present the original author or authors (Gradle Inc.) | https://gradle.org/ | الحفاظ على ترويسة Apache-2.0 الموجودة في `gradlew` | **مؤكد** — ترويسة ملف `android/gradlew` |
| **Linux GTK3 & GLib Runner (`linux/runner/*`)** — مشغّل سطح المكتب لنظام لينكس | `linux/CMakeLists.txt` و`linux/runner/` | GTK `3.0` | شيفرة المشغّل تُترجم مع التطبيق؛ مكتبات GTK3 تُربط ديناميكيًا من النظام؛ **يدخل المشغّل في توزيع Linux** | شيفرة القالب: `BSD-3-Clause` (Flutter)؛ مكتبات النظام GTK3/GLib: `LGPL-2.1+` (ربط ديناميكي كـ System Libraries) | The Flutter Authors / GNOME Foundation | https://www.gtk.org/ | الربط الديناميكي مع مكتبات النظام (`System Libraries` وفق القسم 1 من GPL-3.0) متوافق تمامًا | **مؤكد** — `linux/CMakeLists.txt` |
| **Windows Win32 C++ Runner (`windows/runner/*`)** — مشغّل سطح المكتب لنظام ويندوز | `windows/CMakeLists.txt` و`windows/runner/` | Win32 API | يُترجم في الملف التنفيذي؛ **يدخل في توزيع Windows** | `BSD-3-Clause` (قالب Flutter الرسمي) | Copyright 2014 The Flutter Authors | https://github.com/flutter/flutter | إرفاق إشعار BSD-3-Clause | **مؤكد** — `windows/CMakeLists.txt` |
| **iOS & macOS Xcode Runners (`ios/Runner/*`, `macos/Runner/*`)** — مشغّلا Apple | `ios/` و`macos/` | Xcode / Swift 5 | يُترجم في حزمة IPA/APP؛ **يدخل في توزيع iOS/macOS** | `BSD-3-Clause` (قالب Flutter الرسمي) | Copyright 2014 The Flutter Authors | https://github.com/flutter/flutter | إرفاق إشعار BSD-3-Clause | **مؤكد** — ملفات `ios/` و`macos/` |

---

## 3. نصوص التراخيص والإشعارات الرسمية الكاملة (Full Verbatim License Texts & Notices)

عملاً بشروط التراخيص مفتوحة المصدر المطبقة على المكونات الداخلة في التوزيع، ترد أدناه النصوص الرسمية الكاملة غير المختصرة لكل ترخيص مع إشعارات حقوق النشر الأصلية وإخلاء المسؤولية:

---

### 3.1 ترخيص المشروع الرئيسي — GNU General Public License v3.0 (`GPL-3.0`)

النص الكامل لترخيص `GNU General Public License Version 3, 29 June 2007` موجود حرفيًا في ملف [`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE) في جذر المشروع (الأسطر 1–675). وفيما يلي الإشعار القانوني القياسي للبرنامج:

```text
Tadbeer (تَدْبِير) — Offline-first Quran Reading & Contemplation Application
Copyright (C) 2026 Tadbeer Project Authors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see the LICENSE file in the root directory).
If not, see <https://www.gnu.org/licenses/>.
```

---

### 3.2 ترخيص الخطوط المفتوحة — SIL Open Font License, Version 1.1 (`OFL-1.1`)

ينطبق هذا الترخيص على جميع ملفات الخطوط السبعة المضمّنة في `assets/fonts/`:

#### إشعارات حقوق النشر والأسماء المحفوظة للخطوط السبعة:
1. **Scheherazade New (`assets/fonts/ScheherazadeNew-Regular.ttf` — Version 4.500):**
   `Copyright (c) 1994-2026, SIL Global (https://www.sil.org/), with Reserved Font Names "Scheherazade" and "SIL".`
2. **Noto Naskh Arabic (`assets/fonts/NotoNaskhArabic-Regular.ttf` — Version 2.021):**
   `Copyright 2022 The Noto Project Authors (https://github.com/notofonts/arabic). Designer: Monotype Design Team, David Williams, Mohamad Dakak and Nizar Qandah.`
3. **Harmattan (`assets/fonts/Harmattan-Regular.ttf` — Version 4.400):**
   `Copyright (c) 2007-2008, The C&MA Guinea Fulbe Team; Copyright renewed 2011-2012, George W. Nuss (http://www.fulbefouta.com), with the Reserved Font Name "Fouta". Copyright (c) 2004-2025, SIL Global (https://www.sil.org), with Reserved Font Names 'Andika' and 'SIL'. Copyright (c) 2014-2025, SIL Global (https://www.sil.org/), with Reserved Font Name "Harmattan".`
4. **Lateef (`assets/fonts/Lateef-Regular.ttf` — Version 4.400):**
   `Copyright (c) 1994-2025, SIL Global (https://www.sil.org/), with Reserved Font Names "Lateef" and "SIL".`
5. **Amiri Quran (`assets/fonts/AmiriQuran-Regular.ttf` — Version 1.003):**
   `Copyright 2010-2022 The Amiri Project Authors (https://github.com/aliftype/amiri). Designer: Khaled Hosny / Alif Type.`
6. **Amiri Regular & Amiri Bold (`assets/fonts/Amiri-Regular.ttf`, `assets/fonts/Amiri-Bold.ttf` — Version 1.002):**
   `Copyright 2010-2022 The Amiri Project Authors (https://github.com/aliftype/amiri). Designer: Khaled Hosny / Alif Type.`

#### النص الرسمي الكامل لترخيص `SIL Open Font License, Version 1.1`:

```text
Copyright (c) 1994-2026, SIL Global (https://www.sil.org/), with Reserved Font Names "Scheherazade" and "SIL".

This Font Software is licensed under the SIL Open Font License, Version 1.1. This license is copied below, and is also available with a FAQ at: https://openfontlicense.org/


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects, to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework in which fonts may be shared and improved in partnership with others.

The OFL allows the licensed fonts to be used, studied, modified and redistributed freely as long as they are not sold by themselves. The fonts, including any derivative works, can be bundled, embedded, redistributed and/or sold with any software provided that any reserved names are not used by derivative works. The fonts and derivatives, however, cannot be released under any other type of license. The requirement for fonts to remain under this license does not apply to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright Holder(s) under this license and clearly marked as such. This may include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the copyright statement(s).

"Original Version" refers to the collection of Font Software components as distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting, or substituting -- in part or in whole -- any of the components of the Original Version, by changing formats or by porting the Font Software to a new environment.

"Author" refers to any designer, engineer, programmer, technical writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining a copy of the Font Software, to use, study, copy, merge, embed, modify, redistribute, and sell modified and unmodified copies of the Font Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components, in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled, redistributed and/or sold with any software, provided that each copy contains the above copyright notice and this license. These can be included either as stand-alone text files, human-readable headers or in the appropriate machine-readable metadata fields within text or binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font Name(s) unless explicit written permission is granted by the corresponding Copyright Holder. This restriction only applies to the primary font name as presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font Software shall not be used to promote, endorse or advertise any Modified Version, except to acknowledge the contribution(s) of the Copyright Holder(s) and the Author(s) or with their explicit written permission.

5) The Font Software, modified or unmodified, in part or in whole, must be distributed entirely under this license, and must not be distributed under any other license. The requirement for fonts to remain under this license does not apply to any document created using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE.
```

---

### 3.3 ترخيص النص القرآني (مشروع تنزيل) — `CC BY 3.0` وشروط استخدام Tanzil

ينطبق على النص القرآني العثماني المضمّن في `assets/quran/quran_data.json` والأدعية القرآنية في `lib/features/duas/quran_duas_repository.dart`:

```text
#====================================================================
#
#  Quran Text (Uthmani Edition)
#  Copyright (C) 2007-2026 Tanzil Project
#  License: Creative Commons Attribution 3.0
#
#  This copy of the Quran text is carefully produced, highly
#  verified and continuously monitored by a group of specialists
#  at Tanzil Project.
#
#  TERMS OF USE:
#
#  - Permission is granted to copy and distribute verbatim copies
#    of this text, but CHANGING IT IS NOT ALLOWED.
#
#  - This Quran text can be used in any website or application,
#    provided that its source (Tanzil Project) is clearly
#    indicated, and a link is made to tanzil.net to enable
#    users to keep track of changes.
#
#  - This copyright notice shall be included in all copies of the
#    text, and shall be reproduced appropriately in all files
#    derived from or containing substantial portion of this text.
#
#  Please check updates at: https://tanzil.net/updates/
#
#====================================================================
```

- رابط النص القانوني الكامل لرخصة `Creative Commons Attribution 3.0 Unported (CC BY 3.0)`: https://creativecommons.org/licenses/by/3.0/legalcode

---

### 3.4 رخصة أباتشي الإصدار 2.0 — `Apache License, Version 2.0`

تنطبق على الحزم والمكونات التالية:
- `pdf` (`3.13.1`) — `Copyright (c) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>`
- `barcode` (`2.2.9`) — `Copyright (c) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>`
- `clock` (`1.1.3`) — `Copyright 2013 Google Inc. All Rights Reserved.`
- `fake_async` (`1.3.3`) — `Copyright 2014 Google Inc. All Rights Reserved.`
- `flutter_timezone` (`5.1.1`) — `Copyright (c) flutter_timezone authors`
- `material_color_utilities` (`0.13.0`) — `Copyright 2021 Google LLC`
- `MaterialIcons-Regular.otf` — `Copyright 2019 Google LLC. All Rights Reserved.`
- مكتبات `AndroidX`، و`Google GSON`، و`Kotlin Standard Library / Coroutines`، و`Gradle Wrapper`.

#### النص الرسمي الكامل لرخصة `Apache License, Version 2.0`:

```text
Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.
```

---

### 3.5 رخصة BSD ثلاثية البنود — `BSD 3-Clause License`

تنطبق على إطار عمل `Flutter` ومحرك `sky_engine` وحزم فريق Dart/Flutter والمكتبات التالية:
- **The Flutter Authors (`Copyright 2013-2026 The Flutter Authors. All rights reserved.`):**
  `flutter`, `flutter_test`, `flutter_web_plugins`, `flutter_lints`, `cross_file`, `path_provider`, `path_provider_android`, `path_provider_foundation`, `path_provider_linux`, `path_provider_platform_interface`, `path_provider_windows`, `plugin_platform_interface`, `share_plus`, `url_launcher_linux`, `url_launcher_platform_interface`, `url_launcher_web`, `url_launcher_windows`, `vector_math`, `xdg_directories`.
- **The Dart Project Authors (`Copyright 2012-2026, the Dart project authors. All rights reserved.`):**
  `args`, `async`, `boolean_selector`, `characters`, `checked_yaml`, `cli_util`, `code_assets`, `collection`, `convert`, `crypto`, `ffi`, `file`, `fixnum`, `glob`, `hooks`, `http`, `http_parser`, `jni`, `jni_flutter`, `jni_util`, `js`, `json_annotation`, `leak_tracker`, `leak_tracker_flutter_testing`, `leak_tracker_testing`, `lints`, `logging`, `matcher`, `meta`, `mime`, `native_toolchain_c`, `objective_c`, `package_config`, `path`, `platform`, `pub_semver`, `record_use`, `source_span`, `stack_trace`, `stream_channel`, `string_scanner`, `term_glyph`, `test_api`, `typed_data`, `vm_service`, `web`.
- **The Chromium Authors (`Copyright 2017 The Chromium Authors. All rights reserved.`):**
  `share_plus_platform_interface`.
- **Michael Bui (`Copyright 2018-2024 Michael Bui. All rights reserved.`):**
  `flutter_local_notifications`, `flutter_local_notifications_linux`, `flutter_local_notifications_platform_interface`, `flutter_local_notifications_web`, `flutter_local_notifications_windows`.
- **Leo Cavalcante (`Copyright (c) 2018, Leo Cavalcante`):** `encrypt` (`5.0.3`).
- **Luke Freeman (`Copyright (c) 2020, Luke Freeman`):** `qr_flutter` (`4.1.0`).
- **The Dart QR Project Authors (`Copyright 2014, the Dart QR project authors`):** `qr` (`3.0.2`).
- **Halil Durmus (`Copyright (c) 2024-2026, Halil Durmus`):** `win32` (`6.4.0`), `ffi_leak_tracker` (`0.1.2`).
- **Warren Strange (`Copyright (c) 2015, Warren Strange`):** `asn1lib` (`1.6.5`).

#### النص الرسمي الكامل لرخصة `BSD 3-Clause License`:

```text
Copyright 2014 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

---

### 3.6 رخصة BSD ثنائية البنود — `BSD 2-Clause License`

تنطبق على الحزم التالية:
- **Alexandre Roux Tekartik (`Copyright (c) 2019, Alexandre Roux Tekartik. All rights reserved.`):**
  `sqflite` (`2.4.4+1`), `sqflite_android` (`2.4.4`), `sqflite_common` (`2.5.13+1`), `sqflite_common_ffi` (`2.4.3`), `sqflite_darwin` (`2.4.4`), `sqflite_platform_interface` (`2.4.2`).
- **Timezone Project Authors (`Copyright (c) 2014, timezone project authors`):**
  `timezone` (`0.11.1`).
- **Ramazan Erbasaran (`Copyright 2022, RAMAZAN ERBASARAN. All rights reserved.`):**
  `flutter_islamic_icons` (`1.0.2`).

#### النص الرسمي الكامل لرخصة `BSD 2-Clause License`:

```text
BSD 2-Clause License

Copyright (c) 2019, Alexandre Roux Tekartik
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

---

### 3.7 رخصة معهد ماساتشوستس للتكنولوجيا — `MIT License`

تنطبق على الحزم التالية:
- **Miguel Ruivo (`Copyright (c) 2018 Miguel Ruivo`):**
  `file_picker` (`13.1.0`), `file_picker_darwin` (`2.1.2`), `file_picker_linux` (`2.0.1`), `file_picker_platform_interface` (`4.0.0`), `file_picker_web` (`4.0.0`), `android_file_picker` (`2.0.0`), `windows_file_picker` (`2.0.0`).
- **Brendan Duncan (`Copyright (c) 2013-2022 Brendan Duncan`):**
  `archive` (`4.3.0`), `image` (`4.10.1`).
- **Lukas Renggli (`Copyright (c) 2006-2026 Lukas Renggli`):**
  `xml` (`7.0.1`), `petitparser` (`7.0.2`).
- **The Legion of the Bouncy Castle Inc. (`Copyright (c) 2000 - 2019 The Legion of the Bouncy Castle Inc.`):**
  `pointycastle` (`3.9.1`).
- **Yulian Kuncheff (`Copyright (c) 2021 Yulian Kuncheff`):**
  `uuid` (`4.6.0`).
- **Simon Binder (`Copyright (c) 2020 Simon Binder`):**
  `sqlite3` (`3.5.2`).
- **Alexandre Roux Tekartik (`Copyright (c) 2016, Alexandre Roux Tekartik`):**
  `synchronized` (`3.4.2`).
- **Mahdi K. Fard (`Copyright (c) 2020 Mahdi K. Fard`):**
  `bidi` (`2.0.13`).
- **Brett Sutton (`Copyright (c) 2020 Brett Sutton`):**
  `posix` (`6.5.2`).
- **Dan Field (`Copyright (c) 2018 Dan Field`):**
  `path_parsing` (`1.1.0`).
- **Felix Angelov (`Copyright (c) 2026 Felix Angelov`):**
  `equatable` (`3.0.0`).
- **Mark O'Sullivan (`Copyright (c) 2019 Mark O'Sullivan`):**
  `flutter_launcher_icons` (`0.14.4`).
- **The Dart Project Authors / Kirill Simonov (`Copyright (c) 2014, the Dart project authors; Copyright (c) 2006, Kirill Simonov`):**
  `yaml` (`3.1.4`).

#### النص الرسمي الكامل لرخصة `MIT License`:

```text
Copyright (c) 2021 Yulian Kuncheff

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

---

### 3.8 رخصة موزيلا العامة الإصدار 2.0 — `Mozilla Public License Version 2.0 (MPL-2.0)`

تنطبق على حزمة `dbus` (`0.8.0` — عميل D-Bus لنظام Linux، من تطوير Canonical Ltd.):

```text
Mozilla Public License Version 2.0
==================================

1. Definitions
--------------

1.1. "Contributor"
    means each individual or legal entity that creates, contributes to
    the creation of, or owns Covered Software.

1.2. "Contributor Version"
    means the combination of the Contributions of others (if any) used
    by a Contributor and that particular Contributor's Contribution.

1.3. "Contribution"
    means Covered Software of a particular Contributor.

1.4. "Covered Software"
    means Source Code Form to which the initial Contributor has attached
    the notice in Exhibit A, the Executable Form of such Source Code
    Form, and Modifications of such Source Code Form, in each case
    including portions thereof.

1.5. "Incompatible With Secondary Licenses"
    means

    (a) that the initial Contributor has attached the notice described
        in Exhibit B to the Covered Software; or

    (b) that the Covered Software was made available under the terms of
        version 1.1 or earlier of the License, but not also under the
        terms of a Secondary License.

1.6. "Executable Form"
    means any form of the work other than Source Code Form.

1.7. "Larger Work"
    means a work that combines Covered Software with other material, in
    a separate file or files, that is not Covered Software.

1.8. "License"
    means this document.

1.9. "Licensable"
    means having the right to grant, to the maximum extent possible,
    whether at the time of the initial grant or subsequently, any and
    all of the rights conveyed by this License.

1.10. "Modifications"
    means any of the following:

    (a) any file in Source Code Form that results from an addition to,
        deletion from, or modification of the contents of Covered
        Software; or

    (b) any new file in Source Code Form that contains any Covered
        Software.

1.11. "Patent Claims" of a Contributor
    means any patent claim(s), including without limitation, method,
    process, and apparatus claims, in any patent Licensable by such
    Contributor that would be infringed, but for the grant of the
    License, by the making, using, selling, offering for sale, having
    made, import, or transfer of either its Contributions or its
    Contributor Version.

1.12. "Secondary License"
    means either the GNU General Public License, Version 2.0, the GNU
    Lesser General Public License, Version 2.1, the GNU Affero General
    Public License, Version 3.0, or any later versions of those
    licenses.

1.13. "Source Code Form"
    means the form of the work preferred for making modifications.

1.14. "You" (or "Your")
    means an individual or a legal entity exercising rights under this
    License. For legal entities, "You" includes any entity that
    controls, is controlled by, or is under common control with You. For
    purposes of this definition, "control" means (a) the power, direct
    or indirect, to cause the direction or management of such entity,
    whether by contract or otherwise, or (b) ownership of more than
    fifty percent (50%) of the outstanding shares or beneficial
    ownership of such entity.

2. License Grants and Conditions
--------------------------------

2.1. Grants

Each Contributor hereby grants You a world-wide, royalty-free,
non-exclusive license:

(a) under intellectual property rights (other than patent or trademark)
    Licensable by such Contributor to use, reproduce, make available,
    modify, display, perform, distribute, and otherwise exploit its
    Contributions, either on an unmodified basis, with Modifications, or
    as part of a Larger Work; and

(b) under Patent Claims of such Contributor to make, use, sell, offer
    for sale, have made, import, and otherwise transfer either its
    Contributions or its Contributor Version.

2.2. Effective Date

The licenses granted in Section 2.1 with respect to any Contribution
become effective for each Contribution on the date the Contributor first
distributes such Contribution.

2.3. Limitations on Grant Scope

The licenses granted in this Section 2 are the only rights granted under
this License. No additional rights or licenses will be implied from the
distribution or licensing of Covered Software under this License.
Notwithstanding Section 2.1(b) above, no patent license is granted by a
Contributor:

(a) for any code that a Contributor has removed from Covered Software;
    or

(b) for infringements caused by: (i) Your and any other third party's
    modifications of Covered Software, or (ii) the combination of its
    Contributions with other software (except as part of its Contributor
    Version); or

(c) under Patent Claims infringed by Covered Software in the absence of
    its Contributions.

This License does not grant any rights in the trademarks, service marks,
or logos of any Contributor (except as may be necessary to comply with
the notice requirements in Section 3.4).

2.4. Subsequent Licenses

No Contributor makes additional grants as a result of Your choice to
distribute the Covered Software under a subsequent version of this
License (see Section 10.2) or under the terms of a Secondary License (if
permitted under the terms of Section 3.3).

2.5. Representation

Each Contributor represents that the Contributor believes its
Contributions are its original creation(s) or it has sufficient rights
to grant the rights to its Contributions conveyed by this License.

2.6. Fair Use

This License is not intended to limit any rights You have under
applicable copyright doctrines of fair use, fair dealing, or other
equivalents.

2.7. Conditions

Sections 3.1, 3.2, 3.3, and 3.4 are conditions of the licenses granted
in Section 2.1.

3. Responsibilities
-------------------

3.1. Distribution of Source Form

All distribution of Covered Software in Source Code Form, including any
Modifications that You create or to which You contribute, must be under
the terms of this License. You must inform recipients that the Source
Code Form of the Covered Software is governed by the terms of this
License, and how they can obtain a copy of this License. You may not
attempt to alter or restrict the recipients' rights in the Source Code
Form.

3.2. Distribution of Executable Form

If You distribute Covered Software in Executable Form then:

(a) such Covered Software must also be made available in Source Code
    Form, as described in Section 3.1, and You must inform recipients of
    the Executable Form how they can obtain a copy of such Source Code
    Form by reasonable means in a timely manner, at a charge no more
    than the cost of distribution to the recipient; and

(b) You may distribute such Executable Form under the terms of this
    License, or sublicense it under different terms, provided that the
    license for the Executable Form does not attempt to limit or alter
    the recipients' rights in the Source Code Form under this License.

3.3. Distribution of a Larger Work

You may create and distribute a Larger Work under terms of Your choice,
provided that You also comply with the requirements of this License for
the Covered Software. If the Larger Work is a combination of Covered
Software with a work governed by one or more Secondary Licenses, and the
Covered Software is not Incompatible With Secondary Licenses, this
License permits You to additionally distribute such Covered Software
under the terms of such Secondary License(s), so that the recipient of
the Larger Work may, at their option, further distribute the Covered
Software under the terms of either this License or such Secondary
License(s).

3.4. Notices

You may not remove or alter the substance of any license notices
(including copyright notices, patent notices, disclaimers of warranty,
or limitations of liability) contained within the Source Code Form of
the Covered Software, except that You may alter any license notices to
the extent required to remedy known factual inaccuracies.

3.5. Application of Additional Terms

You may choose to offer, and to charge a fee for, warranty, support,
indemnity or liability obligations to one or more recipients of Covered
Software. However, You may do so only on Your own behalf, and not on
behalf of any Contributor. You must make it absolutely clear that any
such warranty, support, indemnity, or liability obligation is offered by
You alone, and You hereby agree to indemnify every Contributor for any
liability incurred by such Contributor as a result of warranty, support,
indemnity or liability terms You offer. You may include additional
disclaimers of warranty and limitations of liability specific to any
jurisdiction.

4. Inability to Comply Due to Statute or Regulation
---------------------------------------------------

If it is impossible for You to comply with any of the terms of this
License with respect to some or all of the Covered Software due to
statute, judicial order, or regulation then You must: (a) comply with
the terms of this License to the maximum extent possible; and (b)
describe the limitations and the code they affect. Such description must
be placed in a text file included with all distributions of the Covered
Software under this License. Except to the extent prohibited by statute
or regulation, such description must be sufficiently detailed for a
recipient of ordinary skill to be able to understand it.

5. Termination
--------------

5.1. The rights granted under this License will terminate automatically
if You fail to comply with any of its terms. However, if You become
compliant, then the rights granted under this License from a particular
Contributor are reinstated (a) provisionally, unless and until such
Contributor explicitly and finally terminates Your grants, and (b) on an
ongoing basis, if such Contributor fails to notify You of the
non-compliance by some reasonable means prior to 60 days after You have
come back into compliance. Moreover, Your grants from a particular
Contributor are reinstated on an ongoing basis if such Contributor
notifies You of the non-compliance by some reasonable means, this is the
first time You have received notice of non-compliance with this License
from such Contributor, and You become compliant prior to 30 days after
Your receipt of the notice.

5.2. If You initiate litigation against any entity by asserting a patent
infringement claim (excluding declaratory judgment actions,
counter-claims, and cross-claims) alleging that a Contributor Version
directly or indirectly infringes any patent, then the rights granted to
You by any and all Contributors for the Covered Software under Section
2.1 of this License shall terminate.

5.3. In the event of termination under Sections 5.1 or 5.2 above, all
end user license agreements (excluding distributors and resellers) which
have been validly granted by You or Your distributors under this License
prior to termination shall survive termination.

************************************************************************
*                                                                      *
*  6. Disclaimer of Warranty                                           *
*  -------------------------                                           *
*                                                                      *
*  Covered Software is provided under this License on an "as is"       *
*  basis, without warranty of any kind, either expressed, implied, or  *
*  statutory, including, without limitation, warranties that the       *
*  Covered Software is free of defects, merchantable, fit for a        *
*  particular purpose or non-infringing. The entire risk as to the     *
*  quality and performance of the Covered Software is with You.        *
*  Should any Covered Software prove defective in any respect, You     *
*  (not any Contributor) assume the cost of any necessary servicing,   *
*  repair, or correction. This disclaimer of warranty constitutes an   *
*  essential part of this License. No use of any Covered Software is   *
*  authorized under this License except under this disclaimer.         *
*                                                                      *
************************************************************************

************************************************************************
*                                                                      *
*  7. Limitation of Liability                                          *
*  --------------------------                                          *
*                                                                      *
*  Under no circumstances and under no legal theory, whether tort      *
*  (including negligence), contract, or otherwise, shall any           *
*  Contributor, or anyone who distributes Covered Software as          *
*  permitted above, be liable to You for any direct, indirect,         *
*  special, incidental, or consequential damages of any character      *
*  including, without limitation, damages for lost profits, loss of    *
*  goodwill, work stoppage, computer failure or malfunction, or any    *
*  and all other commercial damages or losses, even if such party      *
*  shall have been informed of the possibility of such damages. This   *
*  limitation of liability shall not apply to liability for death or   *
*  personal injury resulting from such party's negligence to the       *
*  extent applicable law prohibits such limitation. Some               *
*  jurisdictions do not allow the exclusion or limitation of           *
*  incidental or consequential damages, so this exclusion and          *
*  limitation may not apply to You.                                    *
*                                                                      *
************************************************************************

8. Litigation
-------------

Any litigation relating to this License may be brought only in the
courts of a jurisdiction where the defendant maintains its principal
place of business and such litigation shall be governed by laws of that
jurisdiction, without reference to its conflict-of-law provisions.
Nothing in this Section shall prevent a party's ability to bring
cross-claims or counter-claims.

9. Miscellaneous
----------------

This License represents the complete agreement concerning the subject
matter hereof. If any provision of this License is held to be
unenforceable, such provision shall be reformed only to the extent
necessary to make it enforceable. Any law or regulation which provides
that the language of a contract shall be construed against the drafter
shall not be used to construe this License against a Contributor.

10. Versions of the License
---------------------------

10.1. New Versions

Mozilla Foundation is the license steward. Except as provided in Section
10.3, no one other than the license steward has the right to modify or
publish new versions of this License. Each version will be given a
distinguishing version number.

10.2. Effect of New Versions

You may distribute the Covered Software under the terms of the version
of the License under which You originally received the Covered Software,
or under the terms of any subsequent version published by the license
steward.

10.3. Modified Versions

If you create software not governed by this License, and you want to
create a new license for such software, you may create and use a
modified version of this License if you rename the license and remove
any references to the name of the license steward (except to note that
such modified license differs from this License).

10.4. Distributing Source Code Form that is Incompatible With Secondary
Licenses

If You choose to distribute Source Code Form that is Incompatible With
Secondary Licenses under the terms of this version of the License, the
notice described in Exhibit B of this License must be attached.

Exhibit A - Source Code Form License Notice
-------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

If it is not possible or desirable to put the notice in a particular
file, then You may include the notice in a location (such as a LICENSE
file in a relevant directory) where a recipient would be likely to look
for such a notice.

You may add additional accurate notices of copyright ownership.

Exhibit B - "Incompatible With Secondary Licenses" Notice
---------------------------------------------------------

  This Source Code Form is "Incompatible With Secondary Licenses", as
  defined by the Mozilla Public License, v. 2.0.
```

---

### 3.9 إقرار الملكية العامة لمكتبة SQLite — `SQLite Public Domain Dedication`

ينطبق على محرك قاعدة البيانات الأصلي `SQLite` (`libsqlite3.so`):

```text
The author or authors of this code dedicate any and all copyright interest in this
code to the public domain. We make this dedication for the benefit of the public at
large and to the detriment of our heirs and successors. We intend this dedication to
be an overt act of relinquishment in perpetuity of all present and future rights to
this code under copyright law.

May you do good and not evil.
May you find forgiveness for yourself and forgive others.
May you share freely, never taking more than you give.
```

---

### 3.10 رخصة بيانات الموسوعة القرآنية — `Quranpedia.net Data License` (`Version 2026-10-10`)

ينطبق على حزمة البيانات الخام `meanings.json` الصادرة عن **الموسوعة القرآنية (`https://quranpedia.net`)** والتي بُني منها ملف [`assets/quran/word_meanings.json`](file:///home/karar1x/Programming/tadbeer/assets/quran/word_meanings.json):

```text
# Quranpedia.net Data License · رخصة بيانات الموسوعة القرآنية

Version / النسخة: 2026-10-10
Source: https://quranpedia.net
License URL: https://quranpedia.net/dumps/LICENSE.md
Policy URL: https://quranpedia.net/api-docs#usage-policy

## English

### Ownership
The classical works contained in this data — the Quran text in its canonical qira'at, and the classical tafsirs — are the shared heritage of the Muslim ummah; no one claims ownership of them. The digitization, structuring, verification, diacritical correction (dabt), linking, and metadata in this dataset are the work of the Quranpedia.net team, compiled and continuously corrected over years. Translations and contemporary works remain the intellectual property of their respective authors and publishers.

### License
- Free to use inside apps, websites, bots, and research tools — no attribution required (a visible link to https://quranpedia.net is appreciated).
- Republishing this data — in full or in part — as a downloadable database or dataset requires: (1) crediting Quranpedia.net as the source with a link, and (2) stating this dump's version (2026-10-10).
- The content is continuously corrected. Keep any copy current via https://quranpedia.net/api/v1/changes?since=2026-10-10 — distributing outdated Quranic text is the distributor's responsibility.
- Provided as-is, without warranty; verification remains the user's duty.

## العربية

### الملكية
النصوص التراثية المضمَّنة في هذه البيانات — من نصِّ القرآن الكريم بقراءاته المتواترة، وكتبِ التفسير — تراثٌ مشترك للأمة، لا يدَّعي أحدٌ ملكيته. أما الرقمنة والهيكلة والتدقيق وضبط النص وربط البيانات وبياناتها الوصفية فهي عمل فريق «الموسوعة القرآنية»، جُمعت وصُحِّحت على مدى سنوات، وما تزال تُصحَّح باستمرار. وتبقى الترجمات والأعمال المعاصرة ملكًا لأصحابها وناشريها.

### الرخصة
- يجوز استعمال البيانات مجانًا داخل التطبيقات والمواقع والأدوات البحثية من غير اشتراط ذكر المصدر (وذكرُه محلُّ تقدير).
- نشرُها نفسِها — كاملةً أو بعضَها — في صورة قاعدة بيانات أو مجموعة بيانات قابلة للتنزيل يلزم فيه: ذكرُ «الموسوعة القرآنية quranpedia.net» مصدرًا مع الرابط الموقع، وبيانُ تاريخ هذه النسخة (2026-10-10).
- والمحتوى يخضع لتصحيح مستمر؛ فمَن نشر نسخةً، فعليه تحديثها عبر /v1/changes، والعهدة في نشر نصٍّ قديم على ناشره.
- وتُقدَّم البيانات كما هي من غير ضمان، والتثبُّت واجبُ المستفيد.
```

---

## 4. الأصول والمحتوى (Assets & Content Detailed Audit)

| الأصل / ملف المحتوى | الحجم وعدد السجلات | المصدر الفعلي وطريقة البناء | الترخيص وشروط إعادة التوزيع | حالة التوافق |
| :--- | :--- | :--- | :--- | :--- |
| [`assets/quran/quran_data.json`](file:///home/karar1x/Programming/tadbeer/assets/quran/quran_data.json) | `3.4 MB` — 114 سورة، 6,236 آية، 604 صفحات | بُني بواسطة [`tool/build_quran_dataset.dart`](file:///home/karar1x/Programming/tadbeer/tool/build_quran_dataset.dart) بالدمج بين نص `quran-uthmani.txt` وبيانات تقسيم الصفحات والأجزاء والأرباع والسجدات من `quran-data.xml` الصادرين عن مشروع تنزيل (`Tanzil.net`). | `Creative Commons Attribution 3.0 Unported (CC BY 3.0)` مع شرط عدم تعديل النص القرآني وإسناد `Tanzil.net`. | **متوافق ومؤكد** — بشرط الحفاظ على إشعار Tanzil وعدم تعديل النص القرآني. |
| [`assets/quran/word_meanings.json`](file:///home/karar1x/Programming/tadbeer/assets/quran/word_meanings.json) | `1.1 MB` — 6,465 مفردة قرآنية مشروحة | بُني عبر [`tool/process_quran_meanings.py`](file:///home/karar1x/Programming/tadbeer/tool/process_quran_meanings.py) و[`tool/build_lexicon_meanings.py`](file:///home/karar1x/Programming/tadbeer/tool/build_lexicon_meanings.py) و[`tool/refine_and_split_meanings.py`](file:///home/karar1x/Programming/tadbeer/tool/refine_and_split_meanings.py) انطلاقًا من حزمة `meanings.json` الرسمية من **الموسوعة القرآنية (`Quranpedia.net`, الإصدار `2026-10-10`)** مع تهذيب التعريفات إلى معانٍ معجمية مفردة موجزة بالرجوع إلى المعاجم التراثية (لسان العرب، مقاييس اللغة، تاج العروس، مفردات الراغب، التبيان لابن الهائم، تذكرة الأريب لابن الجوزي). | `Quranpedia.net Data License (2026-10-10)`: مجاني للاستخدام داخل التطبيقات؛ وعند نشر البيانات كملف قابل للتنزيل يلزم ذكر `Quranpedia.net` مع الرابط وإصدار النسخة (`2026-10-10`). | **متوافق ومؤكد** — تم حذف ملفي المراجعة غير المستخدمين (`word_meanings_excluded.json` و`manual_reviews.json`) وإثبات الإسناد الرسمي. |
| [`assets/fonts/ScheherazadeNew-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/ScheherazadeNew-Regular.ttf) | `331.5 KB` | SIL Global — الإصدار `4.500` | `SIL Open Font License 1.1` (الأسماء المحفوظة: `Scheherazade`, `SIL`) | **متوافق ومؤكد** |
| [`assets/fonts/NotoNaskhArabic-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/NotoNaskhArabic-Regular.ttf) | `307.6 KB` | Google Noto Fonts — الإصدار `2.021` | `SIL Open Font License 1.1` | **متوافق ومؤكد** |
| [`assets/fonts/Harmattan-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/Harmattan-Regular.ttf) | `573.5 KB` | SIL Global — الإصدار `4.400` | `SIL Open Font License 1.1` (الأسماء المحفوظة: `Harmattan`, `Fouta`, `Andika`, `SIL`) | **متوافق ومؤكد** |
| [`assets/fonts/Lateef-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/Lateef-Regular.ttf) | `241.1 KB` | SIL Global — الإصدار `4.400` | `SIL Open Font License 1.1` (الأسماء المحفوظة: `Lateef`, `SIL`) | **متوافق ومؤكد** |
| [`assets/fonts/AmiriQuran-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/AmiriQuran-Regular.ttf) | `136.9 KB` | Alif Type / د. خالد حسني — الإصدار `1.003` | `SIL Open Font License 1.1` | **متوافق ومؤكد** |
| [`assets/fonts/Amiri-Regular.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/Amiri-Regular.ttf) و[`assets/fonts/Amiri-Bold.ttf`](file:///home/karar1x/Programming/tadbeer/assets/fonts/Amiri-Bold.ttf) | `431.1 KB` + `413.5 KB` | Alif Type / د. خالد حسني — الإصدار `1.002` | `SIL Open Font License 1.1` | **متوافق ومؤكد** |
| [`assets/icons/app_icon.png`](file:///home/karar1x/Programming/tadbeer/assets/icons/app_icon.png)، [`assets/icons/app_icon_foreground.png`](file:///home/karar1x/Programming/tadbeer/assets/icons/app_icon_foreground.png)، [`assets/icons/app_logo.png`](file:///home/karar1x/Programming/tadbeer/assets/icons/app_logo.png)، [`logo.vectorcraft`](file:///home/karar1x/Programming/tadbeer/logo.vectorcraft) | 4 ملفات تصميم وأيقونات + الأيقونات المولّدة للمنصات | تصميم خاص بمشروع «تدبير» ومولّد للأحجام المختلفة عبر `flutter_launcher_icons`. | `MIT License` (تندرج ضمن مستودع المشروع وموثقة في `ATTRIBUTION.md`). | **متوافق ومؤكد** |
| [`lib/features/duas/quran_duas_repository.dart`](file:///home/karar1x/Programming/tadbeer/lib/features/duas/quran_duas_repository.dart) | 88 دعاءً قرآنيًا | آيات قرآنية مقتبسة بالرسم العثماني من بيانات Tanzil مع تبويب موضوعي خاص بمشروع تدبير. | الآيات: `CC BY 3.0` (Tanzil)؛ التبويب والشيفرة: `MIT`. | **متوافق ومؤكد** |
| [`lib/features/ayah_links/curated_pathways.dart`](file:///home/karar1x/Programming/tadbeer/lib/features/ayah_links/curated_pathways.dart) | 4 مسارات تدبرية | محتوى تأملي وتدبري مؤلّف خصيصًا لمشروع تدبير. | `MIT` | **متوافق ومؤكد** |

---

## 5. الحالات التي تمت معالجتها والحالات الفرعية (Resolved & Minor Cases)

### 5.1 بيانات معاني الكلمات (`assets/quran/word_meanings.json`) — **تم الحسم والتوثيق**
- تم التحقق من المصدر الأصلي (`/home/karar1x/Downloads/meanings.json`) الصادر عن **الموسوعة القرآنية (`https://quranpedia.net` — الإصدار `2026-10-10`)** وتوثيق رخصته الرسمية (`https://quranpedia.net/dumps/LICENSE.md`) في القسم 3.10 وفي [`ATTRIBUTION.md`](file:///home/karar1x/Programming/tadbeer/ATTRIBUTION.md) وداخل واجهة التطبيق.
- تم حذف ملفي المراجعة غير المستخدمين (`assets/quran/word_meanings_excluded.json` و`tool/manual_reviews.json`) وإضافتهما إلى `.gitignore` لضمان خلوّ المستودع العام من أي مقتبسات مطولة غير مستخدمة من المؤلفات المعاصرة.

### 5.2 خط الأيقونات داخل حزمة `flutter_islamic_icons` (`1.0.2`)
- حزمة Dart مرخصة رسميًا برخصة **`BSD 2-Clause License`** لصالح `RAMAZAN ERBASARAN (2022)`، وهي متوافقة تمامًا مع النشر مفتوح المصدر ومتجري Google Play وApple App Store.

---

## 6. توافق التراخيص ومتطلبات المتاجر (Store & License Compatibility Matrix)

بعد تحويل ترخيص الشيفرة المصدرية للمشروع إلى **`MIT License`** ([`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE))، أصبح المشروع متوافقًا بنسبة 100% مع جميع قنوات التوزيع:

| ترخيص المكوّن | أمثلة في المشروع | التوافق مع `MIT` و Google Play و Apple App Store |
| :--- | :--- | :--- |
| **`MIT License`** | شيفرة مشروع `tadbeer`، `file_picker`, `pointycastle`, `sqlite3`, `uuid`, `image`, `archive`, `bidi`, `xml` | **متوافق 100%** (لا تعارض مع DRM متجر Apple App Store أو Google Play). |
| **`BSD-3-Clause` / `BSD-2-Clause`** | `flutter`, `sqflite`, `path_provider`, `share_plus`, `qr_flutter`, `flutter_local_notifications`, `encrypt`, `crypto`, `timezone`, `flutter_timezone`, `flutter_islamic_icons` | **متوافق 100%**. |
| **`Apache License 2.0`** | `pdf`, `barcode`, `material_color_utilities`, `AndroidX`, `Kotlin`, `MaterialIcons-Regular.otf` | **متوافق 100%**. |
| **`SIL Open Font License 1.1`** | الخطوط السبعة في `assets/fonts/` (`ScheherazadeNew`, `NotoNaskhArabic`, `Harmattan`, `Lateef`, `AmiriQuran`, `Amiri`) | **متوافق 100%** (تُوزّع كأصول خطوط مرفقة داخل التطبيق دون بيعها منفردة). |
| **`CC BY 3.0` (Tanzil)** | النص القرآني في `assets/quran/quran_data.json` | **متوافق 100%** (مع الالتزام بعدم تعديل النص القرآني وإسناد `Tanzil.net`). |
| **`Quranpedia.net Data License (2026-10-10)`** | `assets/quran/word_meanings.json` | **متوافق 100%** (مجاني للتطبيقات، وموثق الإسناد والإصدار `2026-10-10` في المستودع). |
| **`Public Domain`** | محرك `SQLite` الأصلي (`libsqlite3.so`) والمعاجم التراثية الإسلامية | **متوافق 100%**. |

---

## 7. الإجراءات المنفذة للجاهزية القانونية والتقنية للمتاجر (Completed Store Readiness Checklist)

1. **تحويل ترخيص شيفرة المشروع إلى `MIT License` ([`LICENSE`](file:///home/karar1x/Programming/tadbeer/LICENSE)):** إزالة أي تعارض مع شروط خدمة `Apple App Store` مع الحفاظ على المشروع مفتوح المصدر بالكامل.
2. **تسجيل التراخيص وعرضها داخل التطبيق (`LicenseRegistry` & `showLicensePage`):** تسجيل تراخيص `Tanzil` و`Quranpedia.net (2026-10-10)` والخطوط السبعة (`SIL OFL 1.1`) في [`lib/main.dart`](file:///home/karar1x/Programming/tadbeer/lib/main.dart) وإضافة زر **«تراخيص البرمجيات والمصادر المفتوحة»** في شاشة الإعدادات ([`lib/features/settings/settings_screen.dart`](file:///home/karar1x/Programming/tadbeer/lib/features/settings/settings_screen.dart)).
3. **التوافق مع سياسة أذونات Google Play (`AndroidManifest.xml`):** إزالة صلاحية `USE_EXACT_ALARM` المقيدة من [`android/app/src/main/AndroidManifest.xml`](file:///home/karar1x/Programming/tadbeer/android/app/src/main/AndroidManifest.xml) والإبقاء على `SCHEDULE_EXACT_ALARM` المعتمدة لمنبهات التذكير.
4. **اعتماد معرّف الحزمة الرسمي (`com.tadbeer.app`):** استبدال المعرّف التجريبي `com.example.tadbeer` بمعرّف الإنتاج `com.tadbeer.app` في Android وiOS وmacOS وLinux، ودعم التوقيع الإنتاجي عبر `key.properties` في [`android/app/build.gradle.kts`](file:///home/karar1x/Programming/tadbeer/android/app/build.gradle.kts).
5. **إضافة بيان الخصوصية الإلزامي لمتجر أبل ([`ios/Runner/PrivacyInfo.xcprivacy`](file:///home/karar1x/Programming/tadbeer/ios/Runner/PrivacyInfo.xcprivacy)):** التصريح بعدم تتبع المستخدم (`NSPrivacyTracking = false`) وتوثيق أسباب استخدام واجهات الملفات والنظام المطلوبة في مراجعة App Store Connect.
