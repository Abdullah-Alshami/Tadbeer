enum NoteType {
  /// Note attached directly to a verified Quran ayah.
  ayah,

  /// Independent reflection or general Quran study note.
  free,
}

/// Represents a user note in Tadbeer.
///
/// Can either be an Ayah Note (linked to a stable Quran ayah ID)
/// or a Free Note (with custom title and content).
class NoteItem {
  final String id;
  final NoteType type;
  final String? title;
  final String content;

  // Ayah linkage fields (populated when type == NoteType.ayah)
  // IMPORTANT:
  // This ayahId must remain stable (1..6236) because user reflections
  // link directly to verified Quran ayahs across app sessions.
  final int? ayahId;
  final int? surahNumber;
  final int? ayahNumber;
  final int? page;
  final String? ayahText;

  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteItem({
    required this.id,
    required this.type,
    this.title,
    required this.content,
    this.ayahId,
    this.surahNumber,
    this.ayahNumber,
    this.page,
    this.ayahText,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAyahNote => type == NoteType.ayah;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    if (title != null) 'title': title,
    'content': content,
    if (ayahId != null) 'ayahId': ayahId,
    if (surahNumber != null) 'surahNumber': surahNumber,
    if (ayahNumber != null) 'ayahNumber': ayahNumber,
    if (page != null) 'page': page,
    if (ayahText != null) 'ayahText': ayahText,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      type: (json['type'] as String?) == 'free' ? NoteType.free : NoteType.ayah,
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      ayahId: json['ayahId'] as int?,
      surahNumber: json['surahNumber'] as int?,
      ayahNumber: json['ayahNumber'] as int?,
      page: json['page'] as int?,
      ayahText: json['ayahText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  NoteItem copyWith({String? title, String? content, DateTime? updatedAt}) {
    return NoteItem(
      id: id,
      type: type,
      title: title ?? this.title,
      content: content ?? this.content,
      ayahId: ayahId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      ayahText: ayahText,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
