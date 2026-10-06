/// Represents the persisted reading position in the Quran.
///
/// Automatically saved as the reader turns pages.
/// Preserved across navigation, app closure, and complete termination.
class ReadingPosition {
  final int page;
  final int surahNumber;
  final int ayahNumber;
  final DateTime updatedAt;

  const ReadingPosition({
    required this.page,
    required this.surahNumber,
    required this.ayahNumber,
    required this.updatedAt,
  });

  /// Default starting position: Page 1, Surah 1 (Al-Fatiha), Ayah 1.
  static ReadingPosition defaultPosition() => ReadingPosition(
    page: 1,
    surahNumber: 1,
    ayahNumber: 1,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'page': page,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    return ReadingPosition(
      page: json['page'] as int? ?? 1,
      surahNumber: json['surahNumber'] as int? ?? 1,
      ayahNumber: json['ayahNumber'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
