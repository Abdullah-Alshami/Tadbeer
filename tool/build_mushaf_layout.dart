// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Builds the authentic Madinah Mushaf V2 (1421H) Word -> Line -> Page layout dataset
/// from the verified King Fahd Complex / Quranic Universal Library (QUL) Hafs pages.
void main() {
  print(
    'Building Madinah Mushaf V2 layout dataset from QUL source of truth...',
  );

  final quranDataFile = File('assets/quran/quran_data.json');
  if (!quranDataFile.existsSync()) {
    print('Error: assets/quran/quran_data.json not found');
    exit(1);
  }

  final quranData =
      jsonDecode(quranDataFile.readAsStringSync()) as Map<String, dynamic>;
  final surahs = quranData['surahs'] as List<dynamic>;
  final surahAyahCount = <int, int>{};
  for (final s in surahs) {
    final sMap = s as Map<String, dynamic>;
    surahAyahCount[sMap['number'] as int] = sMap['ayahCount'] as int;
  }

  // Check pages directory (check /tmp/quran_api_pages first, or local cache)
  final cacheDir = Directory('/tmp/quran_api_pages');
  if (!cacheDir.existsSync()) {
    print('Error: /tmp/quran_api_pages not found.');
    exit(1);
  }

  // Load verified boundary alignments from QUL if available
  final boundaryAlignmentsFile = File('/tmp/boundary_alignments.json');
  final boundaryAlignments = boundaryAlignmentsFile.existsSync()
      ? jsonDecode(boundaryAlignmentsFile.readAsStringSync())
            as Map<String, dynamic>
      : <String, dynamic>{};
  print('Loaded ${boundaryAlignments.length} page alignments from QUL.');

  // 1. Map surah first ayah page & line to accurately place headers and bismillah lines
  final surahFirstAyah = <int, _SurahStart>{};
  for (int p = 1; p <= 604; p++) {
    final pageFile = File('${cacheDir.path}/$p.json');
    if (!pageFile.existsSync()) {
      print('Error: Missing page file $p.json');
      exit(1);
    }
    final data =
        jsonDecode(pageFile.readAsStringSync()) as Map<String, dynamic>;
    final verses = data['verses'] as List<dynamic>;
    for (final v in verses) {
      final vMap = v as Map<String, dynamic>;
      final parts = (vMap['verse_key'] as String).split(':');
      final s = int.parse(parts[0]);
      final a = int.parse(parts[1]);
      if (a == 1 && !surahFirstAyah.containsKey(s)) {
        final words = vMap['words'] as List<dynamic>;
        final firstWordLine =
            (words.first as Map<String, dynamic>)['line_number'] as int;
        surahFirstAyah[s] = _SurahStart(page: p, line: firstWordLine);
      }
    }
  }

  if (surahFirstAyah.length != 114) {
    print('Error: expected 114 surahs, found ${surahFirstAyah.length}');
    exit(1);
  }

  // 2. Identify exact positions for Surah headers and Bismillah lines
  final headerPositions = <String, int>{}; // "page:line" -> surahNumber
  final bismillahPositions = <String, int>{}; // "page:line" -> surahNumber

  for (int s = 1; s <= 114; s++) {
    final start = surahFirstAyah[s]!;
    final p = start.page;
    final l = start.line;

    if (s == 1) {
      // Surah 1: Line 1 = Header, Line 2 = Verse 1 (Bismillah text line)
      headerPositions['$p:1'] = s;
    } else if (s == 9) {
      // Surah 9 (At-Tawbah): Line 1 = Header, no Bismillah line
      headerPositions['$p:1'] = s;
    } else if (l == 2) {
      // Surah start split across pages (e.g. Surah 4: Header on p-1 line 15, Bismillah on p line 1)
      headerPositions['${p - 1}:15'] = s;
      bismillahPositions['$p:1'] = s;
    } else if (l >= 3) {
      // Standard in-page start: Header at l-2, Bismillah at l-1
      headerPositions['$p:${l - 2}'] = s;
      bismillahPositions['$p:${l - 1}'] = s;
    } else {
      print('Error: Unexpected start position for surah $s: page $p, line $l');
      exit(1);
    }
  }

  print('Surah headers mapped: ${headerPositions.length} (expected 114)');
  print('Bismillah lines mapped: ${bismillahPositions.length} (expected 112)');

  // 3. Build structured pages
  final pagesOutput = <Map<String, dynamic>>[];
  int totalWordCount = 0;
  int centeredLineCount = 0;

  for (int p = 1; p <= 604; p++) {
    final pageFile = File('${cacheDir.path}/$p.json');
    final data =
        jsonDecode(pageFile.readAsStringSync()) as Map<String, dynamic>;
    final verses = data['verses'] as List<dynamic>;

    final totalLines = (p == 1 || p == 2) ? 8 : 15;
    final juzNumber =
        (verses.first as Map<String, dynamic>)['juz_number'] as int;

    final textWordsByLine = <int, List<Map<String, dynamic>>>{};
    for (final v in verses) {
      final vMap = v as Map<String, dynamic>;
      final parts = (vMap['verse_key'] as String).split(':');
      final s = int.parse(parts[0]);
      final a = int.parse(parts[1]);
      final words = vMap['words'] as List<dynamic>;

      for (final w in words) {
        final wMap = w as Map<String, dynamic>;
        final lineNum = wMap['line_number'] as int;
        final isEnd = wMap['char_type_name'] == 'end';

        textWordsByLine.putIfAbsent(lineNum, () => []).add({
          'id': wMap['id'] as int,
          's': s,
          'a': a,
          'p': wMap['position'] as int,
          't': wMap['text_uthmani'] as String,
          'e': isEnd,
          if (isEnd) 'n': a,
        });
        totalWordCount++;
      }
    }

    final linesOutput = <Map<String, dynamic>>[];
    for (int l = 1; l <= totalLines; l++) {
      final key = '$p:$l';
      if (headerPositions.containsKey(key)) {
        linesOutput.add({
          'line': l,
          'type': 'header',
          'surah': headerPositions[key],
          'is_centered': true,
        });
        centeredLineCount++;
      } else if (bismillahPositions.containsKey(key)) {
        linesOutput.add({
          'line': l,
          'type': 'bismillah',
          'surah': bismillahPositions[key],
          'is_centered': true,
        });
        centeredLineCount++;
      } else if (textWordsByLine.containsKey(l)) {
        final words = textWordsByLine[l]!;

        bool isCentered = false;
        if (p == 1 || p == 2) {
          isCentered = true;
        } else if (boundaryAlignments.containsKey('$p')) {
          final pMap = boundaryAlignments['$p'] as Map<String, dynamic>;
          if (pMap.containsKey('$l')) {
            isCentered =
                (pMap['$l'] as Map<String, dynamic>)['centered'] as bool? ??
                false;
          }
        }

        if (isCentered) {
          centeredLineCount++;
        }

        final firstWordId = words.first['id'] as int;
        final lastWordId = words.last['id'] as int;

        linesOutput.add({
          'line': l,
          'type': 'text',
          'is_centered': isCentered,
          'first_word_id': firstWordId,
          'last_word_id': lastWordId,
          'words': words,
        });
      } else {
        print('Error: Unassigned line $l on page $p');
        exit(1);
      }
    }

    pagesOutput.add({
      'page': p,
      'juz': juzNumber,
      'totalLines': totalLines,
      'lines': linesOutput,
    });
  }

  print('Total pages built: ${pagesOutput.length}');
  print('Total word tokens: $totalWordCount');
  print('Total centered lines: $centeredLineCount');

  final outputDataset = {
    'version': '1.0',
    'mushaf': 'Madinah V2 1421H',
    'source': 'Quranic Universal Library (QUL) / KFGQPC Hafs',
    'totalPages': 604,
    'pages': pagesOutput,
  };

  final targetFile = File('assets/quran/mushaf_layout.json');
  targetFile.writeAsStringSync(jsonEncode(outputDataset));
  final sizeMb = targetFile.lengthSync() / (1024 * 1024);
  print(
    'Successfully generated assets/quran/mushaf_layout.json (${sizeMb.toStringAsFixed(2)} MB)',
  );
}

class _SurahStart {
  final int page;
  final int line;
  _SurahStart({required this.page, required this.line});
}
