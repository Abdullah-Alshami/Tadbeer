# 📖 Development & Maintenance Guide for Tadbeer (تَدْبِير)

> **Comprehensive, practical technical reference for developers maintaining and extending the Tadbeer (Flutter) application.**  
> This guide details the architectural philosophy, data flow, Quran rendering engine, database schema, backup cryptography, and feature development practices, derived strictly from the actual codebase.

---

## 📑 Table of Contents

1. [Project Overview](#1-project-overview)
2. [File Map & Directory Architecture](#2-file-map--directory-architecture)
3. [Quick Reference: Where to Start Modifying](#3-quick-reference-where-to-start-modifying)
4. [Architecture & Data Flow](#4-architecture--data-flow)
5. [Responsive Quran Engine & Typography](#5-responsive-quran-engine--typography)
6. [Database & Local Storage](#6-database--local-storage)
7. [Backup & Cryptography](#7-backup--cryptography)
8. [Build, Run & Testing](#8-build-run--testing)
9. [Practical Code Modification Examples](#9-practical-code-modification-examples)
10. [Data Sources & Licenses](#10-data-sources--licenses)
11. [Technical Decisions & Known Constraints (ADR)](#11-technical-decisions--known-constraints-adr)
12. [Pre-Commit Checklist](#12-pre-commit-checklist)

---

## 1. Project Overview

### Application Mission
**Tadbeer** is an open-source, offline-first Islamic application built with **Flutter**. Its fundamental goal is to shift the user's relationship with the Holy Quran from mere rapid recitation to **deep contemplation (*Tadabbur*), comprehension of divine guidance, thematic connection of verses, and active application** in daily life.

### Core Technical Principles
- **Offline-First Operation:** Reading, contemplation, local database storage, and reminder management function autonomously without requiring an internet connection. The application does not declare the `android.permission.INTERNET` permission in `AndroidManifest.xml`, nor does it rely on external web APIs or intermediary servers for its core functionality.
- **Privacy Protections:** Zero advertisements, zero third-party telemetry, and zero tracking SDKs. All user reflections, notes, reading progress, and custom links remain stored locally on the device. When sharing content (via `share_plus`), the operating system hands off data to user-selected third-party applications.
- **Pragmatic Architecture:** Avoids unnecessary theoretical abstractions and intermediary layers. The application follows a clear, direct data path connecting the UI widgets to the reactive cache and local SQLite persistence.
- **Sanctity and Precision of Quranic Text:** Exclusive reliance on verified Uthmani script from the Tanzil Project, rendered using the authentic `AmiriQuran` font with responsive Medinan layout, decorative Surah banners, Bismillah headings, verse rosettes `﴿1﴾`, and dynamic font sizing (16–32pt) without QCF V2 binary dependencies.

### Environment & Requirements
- **Flutter SDK:** `>=3.22.0`
- **Dart SDK:** `^3.4.0` (as defined in `pubspec.yaml`)
- **Primary Target:** Android (Linux, macOS, and Windows supported for local development and headless test automation via `sqflite_common_ffi`)
- **Package Manager:** `flutter pub`

### Boundaries of Inference
All file paths, class names, database schemas, cryptographic parameters, and component relationships in this guide are verified directly against the production source tree. Behaviors without explicit backing code have been excluded or noted as unverified.

---

## 2. File Map & Directory Architecture

The Dart source tree under `lib/` consists of **58 files**, logically organized by functional domains:

```text
lib/
├── app/                  # Application bootstrap, theming, and internationalization (3 files)
│   ├── app.dart          # Root widget (TadbeerApp) and global navigator key
│   ├── localization.dart # Dual-language string tables (Arabic & English)
│   └── theme.dart        # Color palette (AppColors), typography, and theme definitions
│
├── core/                 # Core infrastructure and shared services (8 files)
│   ├── services/         # Standalone system services (2 files)
│   │   ├── backup_crypto_service.dart # AES-256 backup encryption, compression, and verification
│   │   └── local_reminder_service.dart # Offline scheduled notification service
│   ├── storage/          # Data persistence layer (2 files)
│   │   ├── user_database.dart         # Local SQLite manager (tadbeer_user_data.db)
│   │   └── user_data_store.dart       # Reactive unified in-memory cache (ChangeNotifier)
│   └── utils/            # Helper utilities (4 files)
│       ├── arabic_root_search_helper.dart # Root extraction, morphological patterns, and root matching
│       ├── arabic_search_normalizer.dart # Diacritic stripping and Quranic search normalization
│       ├── note_pdf_exporter.dart        # Formatted PDF document generator for notes
│       └── tadbeer_journal_exporter.dart # Periodic reflection journal exporter (PDF & Markdown with statistics)
│
├── features/             # Domain-specific feature modules (46 files)
│   ├── ayah_links/       # Thematic verse relationship graph (11 files)
│   │   ├── ayah_link_detail_screen.dart # Verse link detail viewer and manager
│   │   ├── ayah_link_model.dart         # Domain models (AyahLinkItem)
│   │   ├── ayah_link_repository.dart    # Verse link business logic and persistence
│   │   ├── ayah_links_screen.dart       # Main verse links catalog screen
│   │   ├── curated_pathways.dart        # Predefined thematic pathways registry and one-tap import
│   │   ├── views/                       # Alternate graph visualizations (2 files)
│   │   │   ├── ayah_link_network_view.dart # Interactive topological network canvas
│   │   │   └── ayah_link_ordered_view.dart # Sequential vertical list representation
│   │   └── widgets/                     # Creation, selection, and QR sharing dialogs (4 files)
│   │       ├── add_verse_to_link_dialog.dart
│   │       ├── ayah_link_picker_dialog.dart
│   │       ├── ayah_link_qr_dialog.dart     # Zero-network QR code export & import dialog
│   │       └── create_link_dialog.dart
│   ├── backup/           # Backup export and restore UI (1 file)
│   │   └── backup_screen.dart           # Encrypted .quranbackup file management screen
│   ├── bookmarks/        # Reading bookmarks (3 files)
│   │   ├── bookmark_model.dart          # Domain model (BookmarkItem)
│   │   ├── bookmark_repository.dart     # Bookmark operations repository
│   │   └── bookmarks_screen.dart        # Saved bookmarks listing and jump screen
│   ├── duas/             # Quranic Duas module (flattened structure - 5 files)
│   │   ├── duas_screen.dart             # Unified entrypoint for the supplications feature
│   │   ├── quran_dua_card.dart          # Dua card widget with direct Mushaf jump action
│   │   ├── quran_dua.dart               # Domain model (QuranDua)
│   │   ├── quran_duas_repository.dart   # Repository of 88 verified direct Quranic supplications across 12 categories
│   │   └── quran_duas_screen.dart       # Searchable list of Quranic supplications
│   ├── highlights/       # Verse highlights (3 files)
│   │   ├── highlight_model.dart         # Domain model and color indices (HighlightItem)
│   │   ├── highlight_repository.dart    # Highlight management repository
│   │   └── highlights_screen.dart       # Screen listing all highlighted verses
│   ├── home/             # Home dashboard (1 file)
│   │   └── home_screen.dart             # Dashboard, reading resume banner, feature quick-access
│   ├── notes/            # Contemplation notes (4 files)
│   │   ├── note_editor_screen.dart      # Rich note editor with verse association
│   │   ├── note_model.dart              # Domain model and note types (NoteItem, NoteType)
│   │   ├── note_repository.dart         # Note persistence repository
│   │   └── notes_screen.dart            # Notes catalog with PDF export action
│   ├── quran/            # Mushaf rendering engine & page data (8 files)
│   │   ├── data/                        # Quran models and repository (2 files)
│   │   │   ├── quran_models.dart         # Surah, Ayah, Page, Word Meaning, and Sajdah models
│   │   │   └── quran_repository.dart     # Central provider for Tanzil text and Word Meanings
│   │   ├── screens/                     # Reading screens (2 files)
│   │   │   ├── quran_page_view.dart      # 604-page PageView builder & custom highlight painter
│   │   │   └── quran_screen.dart         # Full reading screen with synchronized WordMeaningsPanel
│   │   └── widgets/                     # Reading UI widgets (4 files)
│   │       ├── ayah_action_sheet.dart    # Modal sheet for ayah actions (tadbeer, highlight, bookmark)
│   │       ├── quran_side_menu.dart      # Side navigation drawer for surahs and juzs
│   │       ├── surah_header_banner.dart  # Ornamental surah title banner
│   │       └── word_meanings_panel.dart  # Collapsible synchronized margin meanings panel
│   ├── reminders/        # Offline scheduled reminders (2 files)
│   │   ├── reminder_model.dart          # Domain model and recurrence rules (ReminderItem)
│   │   └── reminders_screen.dart        # Reminder configuration and scheduling screen
│   ├── search/           # Unified search system (SearchRegistry, providers & UI - 3 files)
│   │   ├── search_provider.dart         # SearchResultItem, SearchProvider contract, SearchRegistry
│   │   ├── search_providers.dart        # 9 built-in domain SearchProviders (including WordMeaningsSearchProvider)
│   │   └── search_screen.dart           # Global search screen with filter chips and grouped results
│   ├── settings/         # App settings and attribution (2 files)
│   │   ├── settings_screen.dart         # Theme, language, font settings, and project about section
│   │   └── user_settings_model.dart     # Settings domain model (UserSettings, QuranFontFamily)
│   ├── tadbeer/          # Core contemplation module (3 files)
│   │   ├── tadbeer_intro_screen.dart    # Onboarding intro and methodology guide
│   │   ├── tadbeer_model.dart           # Contemplation model with four core prompts (TadbeerItem)
│   │   └── tadbeer_pause_sheet.dart     # Modal reflection worksheet anchored to a specific verse
│   └── word_meanings/    # Quranic word meanings feature (1 file)
│       └── word_meanings_screen.dart    # Standalone lexicon browser, surah filter, search, and sources screen
│
└── main.dart             # App entrypoint, database initialization, and bootstrap

assets/                   # Static binary and text assets
├── fonts/                # UI & 5 Quran fonts: Amiri, AmiriQuran, ScheherazadeNew, NotoNaskhArabic, Lateef, Harmattan
├── icons/                # Application launcher icons
└── quran/                # Verified Quranic datasets
    ├── quran_data.json   # Verified Quranpedia & Tanzil Uthmani text (114 surahs, 6,236 verses)
    └── word_meanings.json# Curated single-word lexicon (6,465 entries across all 604 pages)
```

---

## 3. Quick Reference: Where to Start Modifying

The following reference table maps routine maintenance and enhancement tasks to their primary entrypoint files, related components, automated tests, and critical cautions:

| Task | Starting File | Related Files | Relevant Automated Tests | Critical Cautions |
| :--- | :--- | :--- | :--- | :--- |
| **1. Home Dashboard & Reading Resume** | `lib/features/home/home_screen.dart` | `lib/core/storage/user_data_store.dart` | `flutter test test/ui/tadbeer_ui_test.dart` | Do not alter the resume reading card key logic; it provides the primary navigational route. |
| **2. Settings & About Tadbeer** | `lib/features/settings/settings_screen.dart` | `lib/features/settings/user_settings_model.dart`<br>`lib/app/localization.dart`<br>`lib/core/storage/user_data_store.dart` | `flutter test test/settings/quran_font_size_test.dart`<br>`flutter test test/quran/quran_fonts_test.dart` | Font size (16–32pt) and font family (5 Quranic fonts) update live across the reading view. |
| **3. Quran Screen & Toolbars** | `lib/features/quran/screens/quran_screen.dart` | `lib/features/quran/screens/quran_page_view.dart`<br>`lib/features/quran/widgets/quran_side_menu.dart` | `flutter test test/quran/quran_screen_toolbar_test.dart` | Top toolbar is hidden by default and toggles on tap; quick font size and font family modal slider is accessible directly. |
| **4. Responsive Mushaf Rendering** | `lib/features/quran/screens/quran_page_view.dart` | `lib/features/quran/widgets/surah_header_banner.dart` | `flutter test test/quran/responsive_mushaf_viewports_test.dart`<br>`flutter test test/quran/mushaf_visual_layout_test.dart` | **CRITICAL:** Built with `LayoutBuilder` and `SingleChildScrollView` to prevent any `RenderFlex` overflow. Opening pages 1–2 center inside gold border; pages 3–604 justify text; wide viewports (>=900) switch to dual-page. |
| **5. Quran Typography & Fonts** | `lib/features/settings/user_settings_model.dart` | `lib/features/quran/screens/quran_page_view.dart`<br>`pubspec.yaml` | `flutter test test/quran/quran_fonts_test.dart`<br>`flutter test test/quran/quran_mushaf_layout_test.dart` | Text renders natively via 5 selectable SIL OFL-1.1 fonts (`AmiriQuran`, `ScheherazadeNew`, `NotoNaskhArabic`, `Lateef`, `Harmattan`). |
| **6. Tadbeer Pause & Intro Worksheet** | `lib/features/tadbeer/tadbeer_pause_sheet.dart` | `lib/features/tadbeer/tadbeer_intro_screen.dart`<br>`lib/features/tadbeer/tadbeer_model.dart` | `flutter test test/quran/tadbeer_pause_test.dart` | Preserve the structure of the four contemplative questions; they form the core ethos of the app. |
| **7. Notes, Reflections & PDF Export** | `lib/features/notes/notes_screen.dart` | `lib/features/notes/note_editor_screen.dart`<br>`lib/features/notes/note_repository.dart`<br>`lib/core/utils/note_pdf_exporter.dart` | `flutter test test/notes/note_repository_test.dart` | Ensure Arabic font embedding is properly handled when modifying PDF document generation. |
| **8. Bookmarks Management** | `lib/features/bookmarks/bookmarks_screen.dart` | `lib/features/bookmarks/bookmark_repository.dart`<br>`lib/features/bookmarks/bookmark_model.dart` | `flutter test test/bookmarks/bookmark_repository_test.dart` | Bookmarks are keyed by ayah; creating a new bookmark for an existing verse replaces the prior one. |
| **9. Verse Highlighting** | `lib/features/highlights/highlights_screen.dart` | `lib/features/highlights/highlight_repository.dart`<br>`lib/features/highlights/highlight_model.dart` | `flutter test test/highlights/highlight_repository_test.dart`<br>`flutter test test/quran/ayah_highlight_painter_test.dart` | Highlights are rendered cleanly behind text via `AyahHighlightPainter`. |
| **10. Thematic Verse Links Graph** | `lib/features/ayah_links/ayah_links_screen.dart` | `lib/features/ayah_links/ayah_link_detail_screen.dart`<br>`lib/features/ayah_links/views/ayah_link_network_view.dart`<br>`lib/features/ayah_links/ayah_link_repository.dart` | `flutter test test/ayah_links/ayah_link_repository_test.dart`<br>`flutter test test/ui/ayah_links_ui_test.dart` | Detail screen supports two view modes (Network and Ordered) and offline QR export/import. |
| **11. Quranic Duas Catalog** | `lib/features/duas/duas_screen.dart` | `lib/features/duas/quran_duas_screen.dart`<br>`lib/features/duas/quran_duas_repository.dart`<br>`lib/features/duas/quran_dua_card.dart` | `flutter test test/duas/duas_screen_test.dart`<br>`flutter test test/duas/quran_duas_test.dart` | All 88 direct Duas are verified against Uthmani text; categorized into 12 themes with multi-verse rosette markers. |
| **12. Offline Scheduled Reminders** | `lib/features/reminders/reminders_screen.dart` | `lib/core/services/local_reminder_service.dart`<br>`lib/features/reminders/reminder_model.dart` | `flutter test test/reminders/reminder_sound_test.dart` | Notification IDs use `(id.hashCode.abs() % 100000) + dayOfWeek`. |
| **13. Encrypted Backup & Restore** | `lib/features/backup/backup_screen.dart` | `lib/core/services/backup_crypto_service.dart`<br>`lib/core/storage/user_data_store.dart` | `flutter test test/backup/backup_restore_test.dart` | Pre-flight validation protects existing data before restoring `.quranbackup` files. |
| **14. App Colors, Theme & Localization** | `lib/app/theme.dart` | `lib/app/localization.dart`<br>`lib/app/app.dart` | `flutter test test/ui/tadbeer_ui_test.dart` | Every new localization string must be added in both Arabic and English dictionaries. |
| **15. Unified & Sectional Search System** | `lib/features/search/search_screen.dart` | `lib/features/search/search_provider.dart`<br>`lib/features/search/search_providers.dart`<br>`lib/core/utils/arabic_search_normalizer.dart` | `flutter test test/search/unified_search_test.dart`<br>`flutter test test/search/arabic_search_normalizer_test.dart` | Extensible `SearchRegistry` queries 9 domains concurrently with error isolation. |
| **16. Quranic Word Meanings (معاني الكلمات)** | `lib/features/word_meanings/word_meanings_screen.dart` | `lib/features/quran/widgets/word_meanings_panel.dart`<br>`lib/features/quran/data/quran_repository.dart`<br>`assets/quran/word_meanings.json` | `flutter test test/word_meanings/word_meanings_test.dart` | Every entry strictly satisfies the single-word rule across all 604 pages, sourced from *Quranpedia.net (2026-10-10)* under CC0-1.0. |

---

## 4. Architecture & Data Flow

Tadbeer follows a **Single Source of Truth** reactive architecture anchored by `UserDataStore`:

```text
[UI Presentation Widgets]
        │
        ▼ Repository Operations
[Domain Repositories]
        │
        ▼ Forward to central singleton
[UserDataStore (ChangeNotifier - Singleton)]
   ├── 1. Update in-memory O(1) Lookup Maps immediately
   ├── 2. Broadcast UI state change via notifyListeners()
   └── 3. Persist asynchronously:
            ├── SQLite Database (tadbeer_user_data.db)
            └── JSON Snapshot File (tadbeer_user_data.json)
```

### 1. Bootstrap Lifecycle (`lib/main.dart`)
1. `WidgetsFlutterBinding.ensureInitialized()` locks the binding.
2. `UserDataStore.instance.init()` initializes SQLite via `UserDatabase` and loads initial cache.
3. `QuranRepository.instance.init()` decodes Tanzil data into immutable memory structures.
4. `LocalReminderService.instance.init()` configures notification channels and timezones.
5. The widget tree mounts `TadbeerApp`.

### 2. UI Reactivity
- State propagation requires no third-party state managers (no Bloc, Riverpod, or Redux).
- `UserDataStore.instance` extends Flutter's native `ChangeNotifier`.
- Consumer widgets wrap reactive subsections with `ListenableBuilder(listenable: UserDataStore.instance, builder: ...)`.
- Modifications (e.g. adding a highlight or updating a note) execute immediate memory map updates and invoke `notifyListeners()`, triggering instantaneous repaints.

### 3. High-Performance Page Rendering Pipeline
- Quran text records in `QuranRepository` are wrapped in `List.unmodifiable`.
- During page flipping, word and line widgets query verse states using $O(1)$ average in-memory hash maps:
  - `_bookmarkLookup['$surah:$ayah']`
  - `_highlightLookup['$surah:$ayah']`
  - `_tadbeerLookup['$surah:$ayah']`
- No SQLite queries occur during page scrolling, preventing database bottlenecks during rapid swipe transitions.

### 4. Unified Search System Architecture & Registry
Tadbeer features an extensible, decentralized search architecture driven by `SearchRegistry`:

```text
[Home Global Search Bar / SearchScreen]
                 │
                 ▼
          [SearchRegistry]
                 │  (Concurrent Future.wait with try/catch error isolation)
   ┌─────────────┼─────────────┬─────────────┬─────────────┐
   ▼             ▼             ▼             ▼             ▼
[Quran]       [Notes]      [Tadbeer]    [Bookmarks]  [Highlights]
   │             │             │             │             │
   ▼             ▼             ▼             ▼             ▼
[Links]       [Duas]      [Reminders]   [Custom Providers...]
                 │
                 ▼ Returns List<SearchResultItem>
          [Aggregated & Filtered UI with Section Chips]
```

- **`SearchProvider` Contract (`lib/features/search/search_provider.dart`):**  
  An abstract interface defining `id`, `getSectionTitle(BuildContext)`, `IconData get icon`, and `Future<List<SearchResultItem>> search(String query, BuildContext context)`. Any module can participate in global search without coupling to `SearchScreen`.
- **`SearchRegistry` Singleton:**  
  Maintains active providers, registers the 9 standard built-ins upon initialization, and executes concurrent queries via `Future.wait`.
- **Graceful Error Isolation:**  
  Each provider search invocation is encapsulated within its own `try/catch` block. If an individual provider throws an exception, the failure is logged while other providers complete successfully without aborting the overall search.
- **Unified Result Model (`SearchResultItem`):**  
  Standardized entity encapsulating `id`, `providerId`, `sectionTitle`, `title`, `snippet`, optional Quranic coordinates (`surahNumber`, `ayahNumber`, `page`), metadata badges, icon, and an `onTap(BuildContext)` navigation callback.
- **9 Built-in Domain Providers (`lib/features/search/search_providers.dart`):**
  1. `QuranSearchProvider`: Searches verified Uthmani ayahs via `QuranRepository.searchAyahs` and navigates to the exact Mushaf page.
  2. `NotesSearchProvider`: Matches title, content, or verse text in `UserDataStore.notes` and opens `NoteEditorScreen`.
  3. `TadbeerSearchProvider`: Matches guided contemplation answers or surah/ayah references and navigates to the verse in `QuranScreen`.
  4. `BookmarksSearchProvider`: Matches surah name, ayah number, or verse text in `UserDataStore.bookmarks`.
  5. `HighlightsSearchProvider`: Matches surah name, ayah number, or verse text in `UserDataStore.highlights`.
  6. `AyahLinksSearchProvider`: Matches link title, description, or connected verses in `AyahLinkRepository.searchLinks`.
  7. `DuasSearchProvider`: Searches canonical Quranic supplications via `QuranDuasRepository.search`.
  8. `RemindersSearchProvider`: Matches reading reminder titles in `UserDataStore.reminders`.
  9. `WordMeaningsSearchProvider`: Matches difficult Quranic words and classical definitions via `QuranRepository.searchWordMeanings` and navigates to `QuranScreen`.
- **Section-Specific Local Searches:**  
  In addition to global search, individual domain screens (`BookmarksScreen`, `HighlightsScreen`, `RemindersScreen`, `NotesScreen`, `AyahLinksScreen`, `QuranDuasScreen`, and `WordMeaningsScreen`) provide independent, in-place search bars for scoped browsing.
- **Normalization Invariant:**  
  All query matching strictly utilizes `ArabicSearchNormalizer.normalize(text)` (stripping diacritics, tatweel, and normalizing Alef/Taa Marbuta variants) without modifying displayed Uthmani text.

---

## 5. Responsive Quran Engine & Typography

The Quran rendering engine renders authentic Quranpedia & Tanzil Uthmani text within a responsive, overflow-free layout system engineered for all device form factors.

### 1. Data Assets & Open-Source Fonts
- **Quranic Text (`assets/quran/quran_data.json`):**  
  Verified Uthmani text from Quranpedia.net (2026-10-10) and the Tanzil Project containing 114 surahs and 6,236 verses, including structural metadata (Juz, Hizb, Page, Sajdah).
- **5 Selectable Quranic Font Families (`assets/fonts/` — all SIL OFL-1.1):**  
  - `AmiriQuran` (`AmiriQuran.ttf` — Dr. Khaled Hosny)
  - `ScheherazadeNew` (`ScheherazadeNew-Regular.ttf` — SIL International)
  - `NotoNaskhArabic` (`NotoNaskhArabic-Regular.ttf` — Google / Monotype)
  - `Lateef` (`Lateef-Regular.ttf` — SIL International)
  - `Harmattan` (`Harmattan-Regular.ttf` — SIL International)
  - Plus `Amiri` (`Amiri.ttf`) for headings, banners, and general UI typography.
- **Zero Proprietary Font Dependencies:**  
  All 604 page-specific `QCF V2` TTF binaries and compatibility shims have been completely removed.

### 2. Architecture
- `QuranRepository` synthesizes page and surah contents directly from verified `_pages` at initialization.
- `QuranPageView` directly serves as the unified responsive page renderer, drawing smooth multi-word highlight backgrounds behind text via `AyahHighlightPainter`.

### 3. Widget Hierarchy & Responsive Page View
```text
QuranScreen
 └── QuranPageView (PageView.builder 1..604)
      └── LayoutBuilder (captures constraints)
           └── SingleChildScrollView (prevents RenderFlex overflow)
                └── ConstrainedBox (minHeight: constraints.maxHeight)
                     └── IntrinsicHeight
                          └── Container (Medinah double-rule border, gold headers & footers)
                               ├── Page Header (Surah name & Juz number)
                               ├── Opening Frame (Centered gold border for pages 1 and 2)
                               ├── SurahHeaderBanner (ornamental header when surah starts)
                               ├── BismillahBanner (when surah begins, excluding Surah 1 & 9)
                               ├── CustomPaint (AyahHighlightPainter) + RichText
                               │    ├── Ayah Words & Interactive Long-Press Spans
                               │    └── Ayah End Rosette: ﴿${ayahNumber}﴾
                               └── Page Footer (Eastern Arabic-Indic page number)
```

### 4. Layout Engineering & Overflow Prevention
> [!IMPORTANT]
> **Key Rendering Principles:**
> 1. **Zero-Overflow Layout Engine:**  
>    All page rendering uses `LayoutBuilder` combined with `SingleChildScrollView`, `ConstrainedBox(minHeight: constraints.maxHeight)`, and `IntrinsicHeight`. When content fits comfortably, it naturally expands to fill the page container; when font sizes are enlarged (up to 32pt) or the device is rotated to landscape, text smoothly flows and scrolls vertically without triggering `RenderFlex overflow`.
> 2. **Opening Pages vs Standard Pages:**  
>    - Pages 1 (Al-Fatihah) and 2 (Al-Baqarah 1–5) render centered within an authentic decorative gold frame (`_buildOpeningFrame`).
>    - Standard pages (3 to 604) render justified text (`TextAlign.justify`) with standard top/bottom headers and footers.
> 3. **Interactive Ayah Spans & Gesture Recognition:**  
>    Individual verses are linked to `AyahGestureRecognizer` (subclassing Flutter's `LongPressGestureRecognizer` with a 1.1-second duration / 1100ms). Touching down immediately displays a visual highlight (`onPointerDown`); lifting before 1.1s clears the highlight without opening the action sheet (`onPointerUpEarly`). Only holding for the full 1.1s triggers `onLongPress` which opens `AyahActionSheet` with haptic feedback. Quick tapping dismisses toolbars without invoking the modal.
> 4. **Dual-Page Spread Layout:**  
>    On wide viewports (`constraints.maxWidth >= 900`), `QuranScreen` automatically switches to a two-page spread, rendering two adjacent `QuranPageView` instances side-by-side with an elegant central gutter divider.

### 5. Font Family & Size Customization
- **Range & Defaults:** Configurable from `minQuranFontSize = 16.0` to `maxQuranFontSize = 32.0` (default: `20.0`), with 5 selectable `QuranFontFamily` options.
- **Reactive State:** Managed via `UserDataStore.instance.setQuranFontSize(size)` and `setQuranFontFamily(family)`.
- **UI Access Points:**
  1. **Settings Screen:** Live font family selector and size slider with Arabic verse preview and a reset-to-default button.
  2. **Quran Reader Toolbar:** Quick-access font button (`Icons.format_size_rounded`) opening an immediate modal sheet for font family and size.

---

## 6. Database & Local Storage

User-generated data is stored locally using SQLite via `sqflite`, isolated from the immutable Quran text.

### 1. Database Schema (`tadbeer_user_data.db`)
Managed by `UserDatabase` at schema version `databaseVersion = 1`, with `_onCreate` creating exactly **9 tables**:

1. **`reading_position`** (Last read position):
   - `id`: INTEGER PRIMARY KEY CHECK (id = 1) — enforces single-row invariant.
   - `page`: INTEGER NOT NULL
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL (Full serialized JSON)
   - `updated_at`: TEXT NOT NULL

2. **`notes`** (Reflections and notes):
   - `id`: TEXT PRIMARY KEY (UUID)
   - `type`: TEXT NOT NULL (`verse` or `general`)
   - `surah_number`: INTEGER (optional)
   - `ayah_number`: INTEGER (optional)
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL

3. **`bookmarks`** (Bookmarks):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

4. **`highlights`** (Color highlights):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `color_index`: INTEGER NOT NULL (0..3)
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

5. **`reminders`** (Scheduled notifications):
   - `id`: TEXT PRIMARY KEY
   - `is_enabled`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL

6. **`ayah_links`** (Thematic verse links):
   - `id`: TEXT PRIMARY KEY
   - `data`: TEXT NOT NULL
   - `created_at`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL

7. **`tadbeer_items`** (Contemplation worksheet answers):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL

8. **`tadabbur_items`** (Legacy compatibility table):
   - `id`: TEXT PRIMARY KEY
   - `surah_number`: INTEGER NOT NULL
   - `ayah_number`: INTEGER NOT NULL
   - `data`: TEXT NOT NULL
   - `updated_at`: TEXT NOT NULL  
   *(Retained as a dual-write and fallback table for backward compatibility with previous versions).*

9. **`user_settings`** (Application preferences):
   - `key`: TEXT PRIMARY KEY
   - `value`: TEXT NOT NULL

### 2. Schema Evolution & Migrations
- The current database version is `1`.
- Currently, `openDatabase` initializes via `_onCreate` with no `onUpgrade` callback registered, and no automated migration tests exist in the test suite.
- **Future Migration Guideline:** When modifying or adding tables, increment `databaseVersion` to `2` and provide an explicit `onUpgrade` handler with `ALTER TABLE` or `CREATE TABLE IF NOT EXISTS` statements to prevent user data loss.

---

## 7. Backup & Cryptography

Backup generation and recovery are handled by `BackupCryptoService` in conjunction with `UserDataStore`.

### 1. Backup Container Format (`.quranbackup`)
The exported file is a self-contained JSON package structured as follows:
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

### 2. Cryptographic Architecture
- **Export Scope:** Full user snapshot aggregated via `UserDataStore.instance.exportSnapshot()`.
- **Integrity Checksum:** A `SHA-256` hash is computed over the raw UTF-8 JSON bytes **before** compression and encryption.
- **Compression:** The raw payload is compressed using `Gzip` (`gzip.encode`), reducing file size significantly.
- **Key Derivation:**  
  A 16-byte cryptographically secure random salt and a 16-byte IV are generated (`Random.secure()`).  
  The 256-bit encryption key is derived using direct SHA-256:
  ```dart
  final input = utf8.encode(password) + salt;
  final digest = sha256.convert(input);
  final key = enc.Key(Uint8List.fromList(digest.bytes));
  ```
  *(Technical note: The implementation uses direct `SHA-256(password + salt)` key derivation rather than a key-stretching function like PBKDF2 or Argon2).*
- **Symmetric Cipher:** The compressed payload is encrypted using **AES-256** in **CBC Mode** (`enc.AESMode.cbc`).

### 3. Cryptographic Limitations & Restoration Semantics
- **Integrity & Authenticity Limits:** An unkeyed `SHA-256` checksum is not an HMAC, and AES-CBC is not an authenticated encryption mode (AEAD like AES-GCM). The checksum detects accidental bit rot and decompression issues, but does not provide mathematical protection against deliberate file tampering.
- **Pre-Flight Validation:**  
  When importing an archive, the code validates `magic == 'TADBEER_BACKUP'`, schemaVersion compatibility, decrypts, decompresses, verifies the pre-compression `SHA-256` checksum, and verifies `app == 'Tadbeer'`. If any pre-flight check fails, the operation aborts **without touching existing user data**.
- **Database Replacement Behavior:**  
  Once pre-flight checks pass, `UserDataStore.instance.replaceAllUserData()` clears existing tables via `clearAllUserData()` and inserts the new dataset sequentially via `_persistAllToSQLite()`. This replacement is **not wrapped in a single atomic SQLite transaction**, and no automated rollback mechanism exists if an exception occurs during the database write stage.

---

## 8. Build, Run & Testing

### 1. Toolchain & Code Hygiene
```bash
# Fetch dependencies
flutter pub get

# Check formatting compliance without applying changes
dart format --output=none --set-exit-if-changed lib/ test/

# Run static analysis
dart analyze
```
*(Note: Running `dart format --output=none --set-exit-if-changed` may exit with code 1 if existing files like `settings_screen.dart` have minor formatting differences. Automated formatters should not be run when source code modifications are restricted).*

### 2. Running Automated Tests
The repository contains **23 test files** totaling **174 passing tests (100% pass rate)**:

```bash
# Run complete test suite
flutter test

# Run responsive Mushaf viewport tests (small phones, foldables, tablets, dual-page)
flutter test test/quran/responsive_mushaf_viewports_test.dart

# Run font customization tests
flutter test test/settings/quran_font_size_test.dart
flutter test test/quran/quran_fonts_test.dart

# Run word meanings lexicon tests
flutter test test/word_meanings/word_meanings_test.dart

# Run search tests (registry, providers, error isolation & UI)
flutter test test/search/unified_search_test.dart
flutter test test/search/arabic_search_normalizer_test.dart

# Run Mushaf engine and layout tests
flutter test test/quran/mushaf_visual_layout_test.dart
flutter test test/quran/quran_mushaf_layout_test.dart
flutter test test/quran/quran_screen_toolbar_test.dart

# Run storage & database tests
flutter test test/storage/user_database_test.dart
flutter test test/storage/user_data_store_test.dart

# Run backup & cryptography tests
flutter test test/backup/backup_restore_test.dart

# Run UI flow tests
flutter test test/ui/tadbeer_ui_test.dart
flutter test test/ui/ayah_links_ui_test.dart
```

### 3. Production Release Builds
```bash
# Run application in debug mode
flutter run

# Build release APK
flutter build apk --release

# Build release Android App Bundle (AAB)
flutter build appbundle --release
```

---

## 9. Practical Code Modification Examples

### Example 1: Adding a Localized String (`lib/app/localization.dart`)
Add entries to both Arabic and English dictionaries:
```dart
static const Map<String, String> _ar = {
  // ...
  'custom_feature_title': 'عنوان الميزة الجديدة',
};

static const Map<String, String> _en = {
  // ...
  'custom_feature_title': 'New Feature Title',
};
```
Reference in UI: `context.tr('custom_feature_title')`.

### Example 2: Adding a User Preference (`lib/features/settings/`)
1. Extend `UserSettings` in `user_settings_model.dart`:
```dart
class UserSettings {
  final bool enableHapticFeedback;
  // Update constructor, copyWith, fromJson, and toJson
}
```
2. Update SQLite persistence in `UserDatabase` and `UserDataStore`.
3. Add a `SwitchListTile` to `SettingsScreen`.

### Example 3: Writing a Repository Unit Test with Isolated Local Storage
Initialize storage by passing a temporary `File` to `UserDataStore.instance.init(testFile)`. The store will reset its in-memory cache and open an ephemeral SQLite database via `inMemoryDatabasePath`:
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
    // Passing testFile resets the cache and initializes inMemoryDatabasePath
    await UserDataStore.instance.init(testFile);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Repository persists and retrieves entities accurately', () async {
    // Perform assertions using UserDataStore or domain repositories...
  });
}
```

### Example 4: Adding a New Search Provider to `SearchRegistry`
To make a new section or module searchable in global search without modifying `SearchScreen`:

1. **Implement `SearchProvider` (`lib/features/search/search_provider.dart`):**
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
    // Execute search matching on normalized text...
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

2. **Register the Provider:**
```dart
SearchRegistry.instance.register(const MyCustomSearchProvider());
```

3. **Automatic UI Integration:**  
   `SearchScreen` dynamically generates a filter chip for `"ميزتي الجديدة"` and aggregates results under its own section header with an Arabic-Indic numeral count badge.

---

## 10. Data Sources & Licenses

Tadbeer incorporates verified open Quranic resources documented in `ATTRIBUTION.md` and `THIRD_PARTY_NOTICES.md`:

1. **Quranic Uthmani Text & Word Meanings (`assets/quran/quran_data.json` & `assets/quran/word_meanings.json`):**
   - **Sources:** [Quranpedia.net](https://quranpedia.net/) (2026-10-10 — CC0 1.0 Public Domain) and [Tanzil Project](https://tanzil.net/) (CC-BY 3.0).
   - **Role:** Authoritative Uthmani text across all 114 surahs and 6,236 verses, plus 6,465 approved single-word lexical definitions covering all 604 pages.

2. **Quranic & Interface Typography (5 Open-Source Fonts — SIL OFL-1.1):**
   - **Fonts:** `AmiriQuran` & `Amiri` (Dr. Khaled Hosny), `ScheherazadeNew` (SIL International), `NotoNaskhArabic` (Google / Monotype), `Lateef` (SIL International), and `Harmattan` (SIL International).
   - **License:** SIL Open Font License 1.1 (OFL-1.1).

3. **Application Source Code:**
   - **License:** MIT License (`LICENSE`).

---

## 11. Technical Decisions & Known Constraints (ADR)

### 1. Consolidation of Contemplation Module (`lib/features/tadbeer/`)
- **Decision:** Relocated `tadbeer_intro_screen.dart`, `tadbeer_model.dart`, and `tadbeer_pause_sheet.dart` into a single module, deprecating the legacy `tadabbur` folder.
- **Rationale:** Eliminated naming confusion and unified the four contemplation questions under one domain.

### 2. Flattening the Duas Module (`lib/features/duas/`)
- **Decision:** Flattened the 5 duas files directly under `lib/features/duas/`, deleting 4 single-file subfolders (`data`, `models`, `screens`, `widgets`).
- **Rationale:** Eliminated nested boilerplate where each folder contained exactly one file.

### 3. Centralized `UserDataStore` with Decoupled Repositories
- **Decision:** Separated domain models from repository classes while maintaining `UserDataStore` as the single `ChangeNotifier` state source.
- **Rationale:** Enabled clean dependency injection in repository tests while giving the Quran canvas instantaneous $O(1)$ memory queries without querying SQLite per frame.

### 4. Interactive Font Family & Sizing in `SettingsScreen` and Reader Toolbar
- **Decision:** Added Section 2 "الخط والقراءة" to Settings with 5 selectable Quranic font families, a live font slider (16.0–32.0pt), reset button, and live preview verse, plus a quick modal sheet on `QuranScreen`.
- **Rationale:** Empowers users to customize reading ergonomics across different device sizes and vision preferences while maintaining full reactive updates.

### 5. Technical Accuracy for Backup Cryptography and Restoration
- **Decision:** Documented that key derivation uses direct `SHA-256(password + salt)` rather than PBKDF2, and clarified that database replacement after pre-flight checks is sequential and not wrapped in an atomic transaction.
- **Rationale:** Preserved complete factual accuracy aligned with `BackupCryptoService` and `UserDataStore`.

### 6. Reminder Notification IDs Formula
- **Decision:** Scheduled repeating notification IDs use `(id.hashCode.abs() % 100000) + dayOfWeek`.
- **Rationale:** Differentiates weekdays for a given reminder, while acknowledging that hash collisions between different reminders remain theoretically possible in the $[0, 99999]$ integer space.

### 7. Unified Extensible Search Registry Architecture
- **Decision:** Built a decentralized `SearchRegistry` supporting independent `SearchProvider` implementations, rather than hardcoding search queries in `SearchScreen`.
- **Rationale:** Decoupled search logic across domains (Quran, Notes, Tadbeer, Bookmarks, Highlights, Ayah Links, Duas, Reminders, Word Meanings), enabled concurrent `Future.wait` queries with per-provider `try/catch` error isolation, and provided automatic filter chip generation without requiring UI edits when adding future modules.

### 8. Lexicographical Word Meanings & Single-Word Constraint
- **Decision:** All entries in `assets/quran/word_meanings.json` strictly adhere to the single-word rule (0 multi-word entries). Multi-word compounds (such as `الصِّرَاطَ المُستَقِيمَ`) were decomposed into independent single-word entries with their own distinct lexical definitions.
- **Rationale:** Prevents blending lexical definitions with contextual tafsir, complies with classic Quranic margin lexicons, ensures 100% Mushaf page coverage across all 604 pages, and enables fast, precise $O(1)$ token matching.

### 9. Migration to Responsive Multi-Font Engine & Asset Footprint Optimization
- **Decision:** Phased out 604 page-specific `QCF V2` TTF fonts (~202MB) and fixed-coordinate `mushaf_layout.json` (~6.2MB). Rebuilt `QuranPageView` using 5 open-source SIL OFL-1.1 fonts with a responsive `LayoutBuilder` + `SingleChildScrollView` architecture.
- **Rationale:** Eliminates proprietary font dependencies and guarantees zero `RenderFlex` overflows across small phones (320px width), foldables, tablets in portrait & landscape, and dual-page spreads, while supporting user-customizable font sizing (16–32pt) and preserving all reflection, bookmarking, and word meaning interactions.

---

## 12. Pre-Commit Checklist

Before committing or submitting changes, verify this checklist:

- [ ] **Quranic Integrity:** Ensure no files in `assets/quran/` were edited without verified justification.
- [ ] **Responsive Invariants:** Ensure `QuranPageView` layout maintains zero `RenderFlex` overflow across all test viewports.
- [ ] **Static Analysis:** Run `dart analyze` and confirm `No issues found!`.
- [ ] **Automated Tests:** Run `flutter test` and confirm all 174 tests pass without failure.
- [ ] **Localization Sync:** Verify any new UI string is registered in both Arabic and English within `lib/app/localization.dart`.
- [ ] **Git Cleanliness:** Inspect `git diff --check` to confirm no whitespace errors and verify changes are strictly confined to intended files.
