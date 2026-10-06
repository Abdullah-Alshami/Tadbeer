/// Represents a user's reflective Tadabbur Pause session for an individual Ayah.
///
/// EDUCATIONAL NOTE:
/// Tadbeer encourages contemplation (تدبر) through 4 targeted guiding questions:
/// 1. ما الذي لفت انتباهك في هذه الآية؟
/// 2. ماذا فهمت من الآية؟
/// 3. هل هناك شيء تريد تطبيقه؟
/// 4. ما العلاقة التي تراها بين هذه الآية وما قبلها؟
///
/// Offline-first principles:
/// - Stored locally via stable Ayah ID (`surahNumber:ayahNumber`).
/// - Re-opens with previous answers populated for that Ayah.
/// - Empty answers are never stored.
/// - Unifies seamlessly with the Ayah Links network and notes display.
class TadabburItem {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final int? ayahId;
  final Map<int, String> answers; // Question index (1..4) -> user answer
  final DateTime createdAt;
  final DateTime updatedAt;

  const TadabburItem({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.ayahId,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
  });

  String get ayahKey => '$surahNumber:$ayahNumber';

  /// The 4 authentic guiding questions for Tadabbur
  static const List<String> questions = [
    'ما الذي لفت انتباهك في هذه الآية؟',
    'ماذا فهمت من الآية؟',
    'هل هناك شيء تريد تطبيقه؟',
    'ما العلاقة التي تراها بين هذه الآية وما قبلها؟',
  ];

  bool get isEmpty => answers.values.every((v) => v.trim().isEmpty);

  /// Formats all non-empty answers into a clean, peaceful reflection summary.
  String get combinedSummary {
    final buffer = StringBuffer();
    for (int i = 1; i <= questions.length; i++) {
      final ans = answers[i]?.trim();
      if (ans != null && ans.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.writeln();
        buffer.write(ans);
      }
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    if (ayahId != null) 'ayahId': ayahId,
    'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TadabburItem.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    final parsedAnswers = <int, String>{};
    for (final entry in rawAnswers.entries) {
      final key = int.tryParse(entry.key);
      if (key != null && entry.value is String) {
        parsedAnswers[key] = entry.value as String;
      }
    }
    return TadabburItem(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      ayahId: json['ayahId'] as int?,
      answers: parsedAnswers,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  TadabburItem copyWith({Map<int, String>? answers, DateTime? updatedAt}) {
    return TadabburItem(
      id: id,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahId: ayahId,
      answers: answers ?? this.answers,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
