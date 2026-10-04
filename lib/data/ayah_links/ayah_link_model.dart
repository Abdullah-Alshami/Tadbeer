/// Position of a node within the Ayah Link canvas.
class LinkNodePosition {
  final double dx;
  final double dy;

  const LinkNodePosition({required this.dx, required this.dy});

  Map<String, dynamic> toJson() => {'dx': dx, 'dy': dy};

  factory LinkNodePosition.fromJson(Map<String, dynamic> json) {
    return LinkNodePosition(
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
    );
  }

  LinkNodePosition copyWith({double? dx, double? dy}) {
    return LinkNodePosition(dx: dx ?? this.dx, dy: dy ?? this.dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkNodePosition &&
          runtimeType == other.runtimeType &&
          dx == other.dx &&
          dy == other.dy;

  @override
  int get hashCode => Object.hash(dx, dy);
}

/// Represents a single verse participating in an Ayah Link.
///
/// Uses stable ayah linkage (surahNumber, ayahNumber, page, ayahId)
/// so that Quran text is never duplicated into the user's storage.
class AyahLinkVerse {
  final int ayahId;
  final int surahNumber;
  final int ayahNumber;
  final int page;
  final String? note;
  final DateTime addedAt;

  const AyahLinkVerse({
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    this.note,
    required this.addedAt,
  });

  String get ayahKey => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
    'ayahId': ayahId,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'page': page,
    if (note != null && note!.isNotEmpty) 'note': note,
    'addedAt': addedAt.toIso8601String(),
  };

  factory AyahLinkVerse.fromJson(Map<String, dynamic> json) {
    return AyahLinkVerse(
      ayahId: json['ayahId'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      page: json['page'] as int,
      note: json['note'] as String?,
      addedAt: json.containsKey('addedAt')
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  AyahLinkVerse copyWith({String? note}) {
    return AyahLinkVerse(
      ayahId: ayahId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      note: note ?? this.note,
      addedAt: addedAt,
    );
  }
}

/// Optional future-proof representation of an explicit relationship edge
/// between two ayahs in the link network.
class AyahLinkRelationship {
  final String fromAyahKey;
  final String toAyahKey;
  final String? label;
  final String? note;

  const AyahLinkRelationship({
    required this.fromAyahKey,
    required this.toAyahKey,
    this.label,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'from': fromAyahKey,
    'to': toAyahKey,
    if (label != null) 'label': label,
    if (note != null) 'note': note,
  };

  factory AyahLinkRelationship.fromJson(Map<String, dynamic> json) {
    return AyahLinkRelationship(
      fromAyahKey: json['from'] as String,
      toAyahKey: json['to'] as String,
      label: json['label'] as String?,
      note: json['note'] as String?,
    );
  }
}

/// Represents an Ayah Link (روابط الآيات) collection entity.
///
/// Holds the theme/title, optional personal description, member ayahs,
/// canvas node positions, view preferences, and layout state.
class AyahLinkItem {
  final String id;
  final String title;
  final String? description;
  final List<AyahLinkVerse> verses;
  final Map<String, LinkNodePosition> positions;
  final List<AyahLinkRelationship> relationships;
  final bool isManualLayout;
  final String lastViewMode; // 'network', 'ordered', 'cards'
  final double? panX;
  final double? panY;
  final double? zoomScale;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AyahLinkItem({
    required this.id,
    required this.title,
    this.description,
    this.verses = const [],
    this.positions = const {},
    this.relationships = const [],
    this.isManualLayout = false,
    this.lastViewMode = 'network',
    this.panX,
    this.panY,
    this.zoomScale,
    required this.createdAt,
    required this.updatedAt,
  });

  bool containsAyah(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return verses.any((v) => v.ayahKey == key);
  }

  AyahLinkVerse? getVerse(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return verses.where((v) => v.ayahKey == key).firstOrNull;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'verses': verses.map((v) => v.toJson()).toList(),
    'positions': positions.map((k, v) => MapEntry(k, v.toJson())),
    if (relationships.isNotEmpty)
      'relationships': relationships.map((r) => r.toJson()).toList(),
    'isManualLayout': isManualLayout,
    'lastViewMode': lastViewMode,
    if (panX != null) 'panX': panX,
    if (panY != null) 'panY': panY,
    if (zoomScale != null) 'zoomScale': zoomScale,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AyahLinkItem.fromJson(Map<String, dynamic> json) {
    final versesList = <AyahLinkVerse>[];
    if (json.containsKey('verses')) {
      final raw = json['verses'] as List;
      for (final v in raw) {
        versesList.add(AyahLinkVerse.fromJson(v as Map<String, dynamic>));
      }
    }

    final positionsMap = <String, LinkNodePosition>{};
    if (json.containsKey('positions')) {
      final rawPos = json['positions'] as Map<String, dynamic>;
      for (final entry in rawPos.entries) {
        positionsMap[entry.key] = LinkNodePosition.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    final relationshipsList = <AyahLinkRelationship>[];
    if (json.containsKey('relationships')) {
      final rawRel = json['relationships'] as List;
      for (final r in rawRel) {
        relationshipsList.add(
          AyahLinkRelationship.fromJson(r as Map<String, dynamic>),
        );
      }
    }

    return AyahLinkItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      verses: versesList,
      positions: positionsMap,
      relationships: relationshipsList,
      isManualLayout: json['isManualLayout'] as bool? ?? false,
      lastViewMode: json['lastViewMode'] as String? ?? 'network',
      panX: (json['panX'] as num?)?.toDouble(),
      panY: (json['panY'] as num?)?.toDouble(),
      zoomScale: (json['zoomScale'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  AyahLinkItem copyWith({
    String? title,
    String? description,
    List<AyahLinkVerse>? verses,
    Map<String, LinkNodePosition>? positions,
    List<AyahLinkRelationship>? relationships,
    bool? isManualLayout,
    String? lastViewMode,
    double? panX,
    double? panY,
    double? zoomScale,
    DateTime? updatedAt,
  }) {
    return AyahLinkItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      verses: verses ?? this.verses,
      positions: positions ?? this.positions,
      relationships: relationships ?? this.relationships,
      isManualLayout: isManualLayout ?? this.isManualLayout,
      lastViewMode: lastViewMode ?? this.lastViewMode,
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      zoomScale: zoomScale ?? this.zoomScale,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
