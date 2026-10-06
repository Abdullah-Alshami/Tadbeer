import 'dart:convert';

import 'package:flutter/services.dart';

import 'mushaf_layout_models.dart';

/// Provides verified King Fahd Complex QCF V2 glyph codes and assigns them
/// accurately to authentic [MushafWord] tokens.
class QcfGlyphService {
  static final QcfGlyphService instance = QcfGlyphService._internal();
  QcfGlyphService._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  /// Cache of (surah, ayah) -> list of raw QCF V2 glyph tokens/characters
  final Map<String, List<String>> _ayahGlyphs = <String, List<String>>{};

  /// Stop marks in Uthmani Quranic text that form discrete glyphs in QCF V2
  static const Set<String> _stopMarks = <String>{
    'ۖ',
    'ۗ',
    'ۘ',
    'ۙ',
    'ۚ',
    'ۛ',
    'ۜ',
    '؞',
  };

  /// Verified authentic glyph codepoint ranges for Muqatta'at and boundary ayat
  /// where external quran-glyphs.json had 'None' or misaligned page chunks.
  static final Map<String, List<String>> _authenticOverrides = {
    // Page 2: Surah Al-Baqarah 1 (الم ١)
    '2:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 151: Surah Al-A'raf 1 (المص ١)
    '7:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 305: Surah Maryam 1 (كهيعص ١)
    '19:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 312: Surah Taha 1 (طه ١)
    '20:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 367: Surah Ash-Shu'ara 1 (طسم ١)
    '26:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 385: Surah Al-Qasas 1 (طسم ١)
    '28:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 396: Surah Al-Ankabut 1 (الم ١)
    '29:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 404: Surah Ar-Rum 1 (الم ١)
    '30:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 411: Surah Luqman 1 (الم ١)
    '31:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 415: Surah As-Sajdah 1 (الم ١)
    '32:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 440: Surah Ya-Sin 1 (يس ١)
    '36:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 467: Surah Ghafir 1 (حم ١)
    '40:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 477: Surah Fussilat 1 (حم ١)
    '41:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 483: Surah Ash-Shura 1 (حم ١) and 2 (عسق ٢)
    '42:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    '42:2': [String.fromCharCode(0xfc43), String.fromCharCode(0xfc44)],
    // Page 489: Surah Az-Zukhruf 1 (حم ١)
    '43:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 496: Surah Ad-Dukhan 1 (حم ١)
    '44:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 499: Surah Al-Jathiyah 1 (حم ١)
    '45:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 502: Surah Al-Ahqaf 1 (حم ١)
    '46:1': [String.fromCharCode(0xfc41), String.fromCharCode(0xfc42)],
    // Page 569: Surah Al-Ma'arij 15 (كَلَّآ ۖ إِنَّهَا لَظَىٰ ١٥)
    '70:15': [for (int c = 0xfc5a; c <= 0xfc5e; c++) String.fromCharCode(c)],
    // Page 590: Surah Al-Buruj 18 (فِرْعَوْنَ وَثَمُودَ ١٨)
    '85:18': [for (int c = 0xfcb9; c <= 0xfcbb; c++) String.fromCharCode(c)],
    // Page 121: Surah Al-Ma'idah 77 (24 glyphs in p121.ttf: 0xfc41..0xfc58)
    '5:77': [for (int c = 0xfc41; c < 0xfc41 + 24; c++) String.fromCharCode(c)],
  };

  /// Loads and indexes glyphs from `assets/quran/qcf_v2/glyphs/quran-glyphs.json`.
  Future<void> init() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString(
      'assets/quran/qcf_v2/glyphs/quran-glyphs.json',
    );
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final ayat = data['ayat'] as List<dynamic>;

    _ayahGlyphs.clear();
    for (final a in ayat) {
      final aMap = a as Map<String, dynamic>;
      final s = aMap['surah'] as int;
      final ay = aMap['ayah'] as int;
      final key = '$s:$ay';

      if (_authenticOverrides.containsKey(key)) {
        _ayahGlyphs[key] = List<String>.from(_authenticOverrides[key]!);
        continue;
      }

      final chunks = aMap['chunks'] as List<dynamic>;
      final chars = <String>[];
      for (final chunk in chunks) {
        final text = (chunk as Map<String, dynamic>)['text'] as String?;
        if (text == null || text.trim().isEmpty) continue;

        final tokens = text.split(' ');
        for (final token in tokens) {
          if (token.isEmpty || token == 'None') continue;
          for (int i = 0; i < token.length; i++) {
            chars.add(token[i]);
          }
        }
      }

      _ayahGlyphs[key] = chars;
    }

    _isLoaded = true;
  }

  /// Returns the raw glyph characters for the given surah and ayah.
  List<String> getGlyphsForAyah(int surah, int ayah) {
    final key = '$surah:$ayah';
    return _ayahGlyphs[key] ?? _authenticOverrides[key] ?? const <String>[];
  }

  /// Transforms and maps raw glyph tokens to the authentic [MushafWord] list of an ayah,
  /// ensuring each word token receives its exact QCF V2 glyph and stable metadata.
  List<MushafWord> enrichAyahWords({
    required List<MushafWord> words,
    required int pageNumber,
    required int lineNumber,
    required int ayahId,
  }) {
    if (words.isEmpty) return words;

    final s = words.first.surah;
    final ay = words.first.ayah;
    final glyphs = getGlyphsForAyah(s, ay);

    if (glyphs.isEmpty) {
      // Fallback: retain text and original page/line metadata
      return words
          .map((w) => w.copyWith(ayahId: ayahId))
          .toList(growable: false);
    }

    if (words.length == 1) {
      final g = glyphs.join();
      final code = g.isNotEmpty ? g.codeUnitAt(0) : null;
      return [words.first.copyWith(glyph: g, glyphCode: code, ayahId: ayahId)];
    }

    // Authentic QCF V2 mapping algorithm:
    // 1. The last word is always the Ayah end marker rosette: consumes the final glyph.
    // 2. Preceding text words consume 1 glyph each; words containing stop marks or
    //    symbols (e.g. ۞ or ۖ) absorb the trailing punctuation glyph.
    final endGlyph = glyphs.last;
    final textGlyphs = glyphs.sublist(0, glyphs.length - 1);
    final textWords = words.sublist(0, words.length - 1);

    final enriched = <MushafWord>[];
    int gIdx = 0;
    int wIdx = 0;

    while (wIdx < textWords.length) {
      final w = textWords[wIdx];
      final hasStop = _stopMarks.any((sm) => w.text.contains(sm));
      final hasRub = w.text.contains('۞');

      int take = 1;
      final remainingWords = textWords.length - wIdx;
      final remainingGlyphs = textGlyphs.length - gIdx;

      if ((hasStop || hasRub) && remainingGlyphs > remainingWords) {
        take = 2;
      } else if (remainingGlyphs > remainingWords &&
          wIdx == textWords.length - 1) {
        take = remainingGlyphs;
      }

      final wordGlyphs = <String>[];
      for (int i = 0; i < take; i++) {
        if (gIdx < textGlyphs.length) {
          wordGlyphs.add(textGlyphs[gIdx]);
          gIdx++;
        }
      }

      final glyphStr = wordGlyphs.isNotEmpty
          ? wordGlyphs.join()
          : (textGlyphs.isNotEmpty ? textGlyphs.last : w.text);
      final code = glyphStr.isNotEmpty ? glyphStr.codeUnitAt(0) : null;

      enriched.add(
        w.copyWith(glyph: glyphStr, glyphCode: code, ayahId: ayahId),
      );
      wIdx++;
    }

    // Attach the authentic rosette glyph to the end-of-ayah marker
    final endWord = words.last;
    final endCode = endGlyph.isNotEmpty ? endGlyph.codeUnitAt(0) : null;
    enriched.add(
      endWord.copyWith(glyph: endGlyph, glyphCode: endCode, ayahId: ayahId),
    );

    return enriched;
  }
}
