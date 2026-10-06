enum MushafLineType {
  header,
  bismillah,
  text;

  bool get isSurahName => this == header;
  bool get isBasmallah => this == bismillah;
  bool get isAyah => this == text;
}

class MushafWord {
  final int id;
  final int surah;
  final int ayah;
  final int position;
  final String text;
  final bool isAyahEnd;
  final int? ayahNumber;
  final int pageNumber;
  final int lineNumber;
  final String glyph;
  final int? glyphCode;
  final int ayahId;

  const MushafWord({
    this.id = 0,
    required this.surah,
    required this.ayah,
    required this.position,
    required this.text,
    required this.isAyahEnd,
    this.ayahNumber,
    this.pageNumber = 1,
    this.lineNumber = 1,
    this.glyph = '',
    this.glyphCode,
    this.ayahId = 0,
  });

  String get ayahKey => '$surah:$ayah';

  MushafWord copyWith({
    int? id,
    int? surah,
    int? ayah,
    int? position,
    String? text,
    bool? isAyahEnd,
    int? ayahNumber,
    int? pageNumber,
    int? lineNumber,
    String? glyph,
    int? glyphCode,
    int? ayahId,
  }) {
    return MushafWord(
      id: id ?? this.id,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      position: position ?? this.position,
      text: text ?? this.text,
      isAyahEnd: isAyahEnd ?? this.isAyahEnd,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      lineNumber: lineNumber ?? this.lineNumber,
      glyph: glyph ?? this.glyph,
      glyphCode: glyphCode ?? this.glyphCode,
      ayahId: ayahId ?? this.ayahId,
    );
  }

  factory MushafWord.fromJson(
    Map<String, dynamic> json, {
    int pageNumber = 1,
    int lineNumber = 1,
    String glyph = '',
    int? glyphCode,
    int ayahId = 0,
  }) {
    final g = (json['glyph'] as String?) ?? glyph;
    final code =
        json['glyph_code'] as int? ??
        (g.isNotEmpty ? g.codeUnitAt(0) : glyphCode);

    return MushafWord(
      id: json['id'] as int? ?? 0,
      surah: json['s'] as int,
      ayah: json['a'] as int,
      position: json['p'] as int,
      text: json['t'] as String,
      isAyahEnd: json['e'] as bool? ?? false,
      ayahNumber: json['n'] as int?,
      pageNumber: json['page'] as int? ?? pageNumber,
      lineNumber: json['line'] as int? ?? lineNumber,
      glyph: g,
      glyphCode: code,
      ayahId: json['ayah_id'] as int? ?? ayahId,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id > 0) 'id': id,
    's': surah,
    'a': ayah,
    'p': position,
    't': text,
    'e': isAyahEnd,
    if (ayahNumber != null) 'n': ayahNumber,
    'page': pageNumber,
    'line': lineNumber,
    if (glyph.isNotEmpty) 'glyph': glyph,
    if (glyphCode != null) 'glyph_code': glyphCode,
    if (ayahId > 0) 'ayah_id': ayahId,
  };
}

class MushafLine {
  final int lineNumber;
  final MushafLineType type;
  final int? surahNumber;
  final bool isCentered;
  final int? firstWordId;
  final int? lastWordId;
  final List<MushafWord> words;

  const MushafLine({
    required this.lineNumber,
    required this.type,
    this.surahNumber,
    this.isCentered = false,
    this.firstWordId,
    this.lastWordId,
    this.words = const [],
  });

  MushafLine copyWith({
    int? lineNumber,
    MushafLineType? type,
    int? surahNumber,
    bool? isCentered,
    int? firstWordId,
    int? lastWordId,
    List<MushafWord>? words,
  }) {
    return MushafLine(
      lineNumber: lineNumber ?? this.lineNumber,
      type: type ?? this.type,
      surahNumber: surahNumber ?? this.surahNumber,
      isCentered: isCentered ?? this.isCentered,
      firstWordId: firstWordId ?? this.firstWordId,
      lastWordId: lastWordId ?? this.lastWordId,
      words: words ?? this.words,
    );
  }

  factory MushafLine.fromJson(Map<String, dynamic> json, {int pageNumber = 1}) {
    final typeStr = (json['line_type'] ?? json['type']) as String;
    final type = switch (typeStr) {
      'surah_name' || 'header' => MushafLineType.header,
      'basmallah' || 'bismillah' => MushafLineType.bismillah,
      _ => MushafLineType.text,
    };

    final lineNum = (json['line_number'] ?? json['line']) as int;
    final rawWords = json['words'] as List<dynamic>?;
    final words = rawWords != null
        ? rawWords
              .map(
                (w) => MushafWord.fromJson(
                  w as Map<String, dynamic>,
                  pageNumber: pageNumber,
                  lineNumber: lineNum,
                ),
              )
              .toList(growable: false)
        : const <MushafWord>[];

    final firstId =
        json['first_word_id'] as int? ??
        (words.isNotEmpty && words.first.id > 0 ? words.first.id : null);
    final lastId =
        json['last_word_id'] as int? ??
        (words.isNotEmpty && words.last.id > 0 ? words.last.id : null);

    final isCent = (json['is_centered'] ?? json['centered']) as bool? ?? false;

    return MushafLine(
      lineNumber: lineNum,
      type: type,
      surahNumber: (json['surah_number'] ?? json['surah']) as int?,
      isCentered: isCent,
      firstWordId: firstId,
      lastWordId: lastId,
      words: words,
    );
  }

  Map<String, dynamic> toJson() => {
    'line': lineNumber,
    'type': switch (type) {
      MushafLineType.header => 'header',
      MushafLineType.bismillah => 'bismillah',
      MushafLineType.text => 'text',
    },
    'is_centered': isCentered,
    if (surahNumber != null) 'surah': surahNumber,
    if (firstWordId != null) 'first_word_id': firstWordId,
    if (lastWordId != null) 'last_word_id': lastWordId,
    if (words.isNotEmpty) 'words': words.map((w) => w.toJson()).toList(),
  };
}

class MushafPageLayout {
  final int pageNumber;
  final int juzNumber;
  final int totalLines;
  final List<MushafLine> lines;

  const MushafPageLayout({
    required this.pageNumber,
    required this.juzNumber,
    required this.totalLines,
    required this.lines,
  });

  MushafPageLayout copyWith({
    int? pageNumber,
    int? juzNumber,
    int? totalLines,
    List<MushafLine>? lines,
  }) {
    return MushafPageLayout(
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      totalLines: totalLines ?? this.totalLines,
      lines: lines ?? this.lines,
    );
  }

  factory MushafPageLayout.fromJson(Map<String, dynamic> json) {
    final pageNum = json['page'] as int;
    final rawLines = json['lines'] as List<dynamic>;
    final lines = rawLines
        .map(
          (l) => MushafLine.fromJson(
            l as Map<String, dynamic>,
            pageNumber: pageNum,
          ),
        )
        .toList(growable: false);

    return MushafPageLayout(
      pageNumber: pageNum,
      juzNumber: json['juz'] as int,
      totalLines: json['totalLines'] as int,
      lines: lines,
    );
  }

  /// Returns the first text word of this page, if any.
  MushafWord? get firstWord {
    for (final line in lines) {
      if (line.words.isNotEmpty) return line.words.first;
    }
    return null;
  }

  /// Returns the set of Surah numbers present on this page (headers, bismillah, or text).
  Set<int> get surahNumbers {
    final set = <int>{};
    for (final line in lines) {
      if (line.surahNumber != null) set.add(line.surahNumber!);
      for (final w in line.words) {
        set.add(w.surah);
      }
    }
    return set;
  }
}
