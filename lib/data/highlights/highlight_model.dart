/// Represents an ayah highlight in Tadbeer.
///
/// Stores the stable ayah reference and the highlight color index (0..3).
/// Highlights are designed to be subtle and never obscure Quranic text.
class HighlightItem {
  final String id;

  // IMPORTANT:
  // Stable Quran ayah ID (1..6236) to link highlights cleanly
  // without relying on fragile string offsets.
  final int ayahId;
  final int surahNumber;
  final int ayahNumber;
  final int page;
  final int colorIndex;
  final DateTime createdAt;

  const HighlightItem({
    required this.id,
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.colorIndex,
    required this.createdAt,
  });

  String get ayahKey => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
    'id': id,
    'ayahId': ayahId,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'page': page,
    'colorIndex': colorIndex,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HighlightItem.fromJson(Map<String, dynamic> json) {
    return HighlightItem(
      id: json['id'] as String,
      ayahId: json['ayahId'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      page: json['page'] as int,
      colorIndex: json['colorIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
