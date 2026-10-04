/// Represents a saved Quran bookmark.
///
/// Bookmarks are strictly per-ayah and independent of notes or highlights.
/// Each bookmark preserves the stable ayah identifier, surah, ayah number,
/// and Mushaf page for rapid one-tap navigation.
class BookmarkItem {
  final String id;

  // IMPORTANT:
  // Stable Quran ayah ID (1..6236) to guarantee deterministic
  // cross-platform reference.
  final int ayahId;
  final int surahNumber;
  final int ayahNumber;
  final int page;
  final DateTime createdAt;

  const BookmarkItem({
    required this.id,
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.createdAt,
  });

  String get ayahKey => '$surahNumber:$ayahNumber';

  Map<String, dynamic> toJson() => {
    'id': id,
    'ayahId': ayahId,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'page': page,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'] as String,
      ayahId: json['ayahId'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      page: json['page'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
