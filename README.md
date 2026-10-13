# Tadbeer (تَدْبِير)

> **Tadbeer is a Quranic reflection application designed to help Muslims contemplate the meanings and guidance of the Holy Quran, connect related verses, record personal reflections, and apply Quranic teachings in everyday life.**

Tadbeer is an open, offline-capable application built with **Flutter**. Rather than serving solely as a digital reader for rapid recitation, Tadbeer places contemplation (*Tadabbur*), thematic synthesis, and active practice at its center, providing a serene environment for engaging with the Book of Allah.

---

## Key Features

### 📖 Holy Quran Reader
- **Responsive Authentic Layout:** Digital reproduction of the Holy Quran featuring authentic Medinan layout, ornate Surah header banners, Bismillah headings, and authentic verse rosettes `﴿1﴾` with Tanzil Uthmani text.
- **Universal Amiri Quran Typography:** Pure, elegant Uthmani typography utilizing `AmiriQuran` (with `Amiri` for titles and UI), completely eliminating the heavy 202MB QCF V2 font dependency, slashing app asset footprint by ~96.6% (from 225MB to ~17MB) while ensuring crisp rendering across all screen densities.
- **Customizable Font Sizing:** Fully adjustable Quran font size (16.0pt to 32.0pt) accessible via a live slider in Settings and a quick-access modal button directly in the Quran reading toolbar.
- **Search & Navigation:** Diacritic-insensitive Quranic search, surah index, juz browser, and direct page navigation.

### 🌿 Reflection & Study Tools
- **Tadbeer Pause (وقفة تدبر):** Structured reflection sheet anchored to individual verses with four foundational contemplative prompts.
- **Verse Links (روابط الآيات):** Thematic cross-referencing system linking related ayahs across surahs, viewable in both interactive topological network and sequential ordered list views.
- **Curated Thematic Pathways (المسارات التدبرية المقترحة):** Built-in curated pathways across major Quranic themes (e.g., Divine Names in Surah Al-Hashr, Prophetic Duas in Surah Al-Anbiya, Societal & Personal Transformation, Patience & Conviction) with one-tap import.
- **Zero-Network QR Code Sharing:** Export and import Ayah Links offline via standard QR codes without cloud sync.
- **Reflections & Notes:** Personal contemplative journaling per ayah or general note, with individual note PDF export and **Periodic Reflection Journal Export** (weekly, monthly, or full archive to beautifully formatted PDF and Markdown with reflection statistics).
- **Highlights & Bookmarks:** Four-color verse highlighting with continuous multi-word line segments, plus quick-access reading bookmarks.

### 📿 Duas & Reminders
- **Quranic Duas:** Catalog of 88 direct Quranic supplications extracted directly from verified Uthmani text, complete with 12 thematic categories, multi-verse rosette markers, and direct navigation to their exact page in the Mushaf.
- **Offline Reminders:** Local scheduled notifications with native timezone support (`flutter_timezone`) for daily Quran reading and reflection routines, operating completely on device.

### 📖 Quranic Word Meanings (معاني كلمات القرآن)
- **Extensive Single-Word Lexicon:** Curated dataset of 6,465 authenticated single-word entries covering all 604 pages and 114 surahs of the Holy Quran, ensuring complete 100% coverage without any omitted pages.
- **Pure Lexical Meanings:** Direct, focused presentation of authentic lexical meanings (*المعنى المعجمي*) in concise Arabic, free from extraneous contextual tafsir or speculative commentary.
- **Authoritative Lexicographical Attribution:** Strictly derived from reputable classical and contemporary Arabic lexicons: *Al-Mu'jam Al-Waseet* (Academy of the Arabic Language in Cairo), *Lisan Al-Arab* (Ibn Manzur), *Maqayis Al-Lughah* (Ibn Faris), *Taj Al-Arus* (Al-Zabidi), and *Mufradat Alfadh Al-Quran* (Al-Raghib Al-Asfahani).
- **Synchronized Margin Panel:** Built-in collapsible reader sheet (`WordMeaningsPanel`) on `QuranScreen` updating dynamically on every page turn, with outside-tap dismissal and balanced dimensions.
- **Dedicated Lexicon Explorer:** Standalone `WordMeaningsScreen` accessible from home and side navigation, featuring instant surah filtering, diacritic-insensitive search, and source attribution documentation.

### 🔍 Unified & Sectional Search System
- **Central Search Registry:** Extensible `SearchRegistry` and `SearchProvider` architecture that queries 9 application domains concurrently with per-provider error isolation.
- **Root & Morphological Search:** Instant root search via `جذر:XXX` syntax (e.g. `جذر:صبر` or `جذر:رحم`), matching across rich morphological variations (`فعل`, `فاعل`, `مفعول`, `فعيل`, `تفعيل`, `افتعل`, `استفعل`) across all 6,236 ayahs.
- **Unified Global Search:** Global search entry from the home screen querying verified Quranic ayahs, user reflection notes, guided Tadbeer pauses, bookmarks, highlights, thematic Ayah Links, supplications, recitation reminders, and word meanings.
- **Interactive Section Filter Chips:** Instant toggle between comprehensive results ("All") and targeted domain results with count badges.
- **Independent Local Search:** Scoped, diacritic-insensitive search bars inside Notes, Ayah Links, Duas, Bookmarks, Highlights, and Reminders screens.

### 🖥️ Universal Responsive & Tablet Layout
- **Zero-Overflow Adaptive Geometry:** Adaptive layout engine using `LayoutBuilder` and flexible constraint containers, ensuring zero `RenderFlex` overflow across small phones (320px width), modern large displays, foldables, and tablets.
- **Dual-Page Spread Layout:** Automatic side-by-side two-page spread on tablets, foldables, and desktop displays (`width >= 900dp`), mimicking a physical open Mushaf with center divider.

### 🔒 Privacy & Encrypted Backups
- **Offline-First Storage:** Core reading, notes, reflection, and database storage function entirely on the local device without requiring an active internet connection. No advertising or user telemetry SDKs are included.
- **Encrypted Exports:** Export and import user datasets via password-protected `.quranbackup` files, utilizing AES-256 in CBC mode, Gzip payload compression, and pre-compression SHA-256 checksum verification.

---

## Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (SDK `>=3.22.0`)
- **Language:** [Dart](https://dart.dev/) (SDK `^3.4.0`)
- **Local Storage:** [SQLite](https://www.sqlite.org/) via `sqflite` (with `sqflite_common_ffi` for desktop testing)
- **State Management:** Reactive local cache extending Flutter's native `ChangeNotifier`
- **Typography:** `AmiriQuran` for verified Uthmani script; `Amiri` for headings, supplications, and UI text

---

## Prerequisites & Setup

### Requirements
- Flutter SDK: `3.22.0` or higher
- Dart SDK: `^3.4.0` (as specified in `pubspec.yaml`)
- Target platform: Android (primary release target; Linux, macOS, and Windows supported for local development and test execution)

### Installation

From the project root directory, install dependencies:

```bash
flutter pub get
```

### Running the App

```bash
flutter run
```

---

## Verification & Build Commands

### Code Analysis & Formatting

```bash
# Check code formatting without applying modifications
dart format --output=none --set-exit-if-changed lib/ test/

# Run static analysis
dart analyze
```

### Running Automated Tests

Tadbeer maintains an automated test suite covering repositories, the responsive Mushaf rendering engine, database storage, backup cryptography, and user flows:

```bash
# Run all tests (180 tests across 24 test files - 100% pass rate)
flutter test

# Run specific test suites
flutter test test/quran/responsive_mushaf_viewports_test.dart
flutter test test/word_meanings/word_meanings_test.dart
flutter test test/quran/mushaf_visual_layout_test.dart
flutter test test/backup/backup_restore_test.dart
flutter test test/search/unified_search_test.dart
```

### Building for Release

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (AAB)
flutter build appbundle --release
```

---

## Project Structure

```text
lib/
├── app/          # Application entrypoint, localization (Arabic/English), theme configuration
├── core/         # Core infrastructure:
│   ├── services/ # Backup encryption (AES-256) and local reminder scheduling
│   ├── storage/  # SQLite manager (UserDatabase) and in-memory cache (UserDataStore)
│   └── utils/    # Arabic search normalization and PDF export utilities
├── features/     # Feature-oriented domain modules:
│   ├── ayah_links/    # Thematic verse relationship graph and screens
│   ├── backup/        # Encrypted backup export and restore interface
│   ├── bookmarks/     # Bookmark management and screen
│   ├── duas/          # Catalog of 88 Quranic Duas and cards
│   ├── highlights/    # Verse highlighting repository and screen
│   ├── home/          # Dashboard, reading resume card, quick actions, settings button
│   ├── notes/         # Note editor, reflection repository, and PDF export screen
│   ├── quran/         # Responsive Mushaf engine (QuranPageView, lines, words, word meanings panel)
│   ├── reminders/     # Notification scheduling and settings
│   ├── search/        # Unified search system (SearchRegistry, providers, and UI)
│   ├── settings/      # Appearance, font sizing, theme, verified sources, and about section
│   ├── tadbeer/       # Contemplation pause sheet, intro, and models
│   └── word_meanings/ # Quranic word meanings explorer, filters, and sources screen
└── main.dart     # App bootstrap, engine initialization, and root runner

assets/           # Active bundled assets (~4.1MB total)
├── fonts/        # Amiri.ttf, AmiriQuran.ttf (964KB)
├── icons/        # App launcher icons
└── quran/        # Verified datasets:
    ├── quran_data.json       # Tanzil Uthmani text (optimized: 2.0MB)
    └── word_meanings.json    # 6,465 lexical entries (optimized: 1.1MB)
```

For complete architecture documentation, data flow diagrams, database schemas, and step-by-step modification guides, refer to:
**[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**

---

## Attribution & Data Sources

Tadbeer relies on verified open Quranic resources and typography:

- **Quranic Text:** [Tanzil Project](https://tanzil.net/) — Uthmani script (`Creative Commons Attribution 3.0 Unported`).
- **Mushaf & Interface Typography (`SIL Open Font License 1.1`):**
  - `Scheherazade New`, `Harmattan`, and `Lateef` by [SIL Global](https://software.sil.org/).
  - `Noto Naskh Arabic` by the [Google Noto Project](https://github.com/notofonts/arabic).
  - `Amiri Quran` and `Amiri` by [Khaled Hosny / Alif Type](https://github.com/aliftype/amiri).
- **Quranic Word Meanings:** Structured dataset derived from [Quranpedia.net](https://quranpedia.net) (`Version 2026-10-10` — [Quranpedia Data License](https://quranpedia.net/dumps/LICENSE.md)), cross-referenced with classical Arabic lexicons in the Public Domain (*Lisan Al-Arab*, *Maqayis Al-Lughah*, *Taj Al-Arus*, *Mufradat Al-Raghib*, *Al-Tibyan* by Ibn Al-Ha'im, *Tadhkirat Al-Arib* by Ibn Al-Jawzi) and contemporary references (*Al-Mu'jam Al-Waseet*, *Al-Siraj*).

For detailed licensing statements and attributions, see [ATTRIBUTION.md](ATTRIBUTION.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

## Project Status

- **Status:** Active development.
- **Primary Platforms:** Android & iOS (with Linux, macOS, and Windows desktop support).
- **Architecture Philosophy:** Simple, pragmatic, offline-first. Avoid unnecessary abstractions, preserve user data integrity, and protect the sanctity of the Quranic text.


## License

This project's source code is licensed under the **MIT License** (`MIT`).
Bundled Quranic text, lexical datasets, and fonts are governed by their respective licenses as documented in [LICENSE](LICENSE), [ATTRIBUTION.md](ATTRIBUTION.md), and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).