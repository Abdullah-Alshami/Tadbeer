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

  const MushafWord({
    this.id = 0,
    required this.surah,
    required this.ayah,
    required this.position,
    required this.text,
    required this.isAyahEnd,
    this.ayahNumber,
  });

  String get ayahKey => '$surah:$ayah';

  factory MushafWord.fromJson(Map<String, dynamic> json) {
    return MushafWord(
      id: json['id'] as int? ?? 0,
      surah: json['s'] as int,
      ayah: json['a'] as int,
      position: json['p'] as int,
      text: json['t'] as String,
      isAyahEnd: json['e'] as bool? ?? false,
      ayahNumber: json['n'] as int?,
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

  factory MushafLine.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['line_type'] ?? json['type']) as String;
    final type = switch (typeStr) {
      'surah_name' || 'header' => MushafLineType.header,
      'basmallah' || 'bismillah' => MushafLineType.bismillah,
      _ => MushafLineType.text,
    };

    final rawWords = json['words'] as List<dynamic>?;
    final words = rawWords != null
        ? rawWords
              .map((w) => MushafWord.fromJson(w as Map<String, dynamic>))
              .toList(growable: false)
        : const <MushafWord>[];

    final firstId =
        json['first_word_id'] as int? ??
        (words.isNotEmpty && words.first.id > 0 ? words.first.id : null);
    final lastId =
        json['last_word_id'] as int? ??
        (words.isNotEmpty && words.last.id > 0 ? words.last.id : null);

    final isCent = (json['is_centered'] ?? json['centered']) as bool? ?? false;
    final lineNum = (json['line_number'] ?? json['line']) as int;

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

  factory MushafPageLayout.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>;
    final lines = rawLines
        .map((l) => MushafLine.fromJson(l as Map<String, dynamic>))
        .toList(growable: false);

    return MushafPageLayout(
      pageNumber: json['page'] as int,
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
