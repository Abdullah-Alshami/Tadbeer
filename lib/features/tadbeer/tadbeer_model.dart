/// يمثل جلسة "وقفة تدبر" تأملية للمستخدم حول آية قرآنية محددة.
///
/// Represents a user's reflective Tadbeer Pause session for an individual Ayah.
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
class TadbeerItem {
  /// المعرّف الفريد لوقفة التدبر.
  final String id;

  /// رقم السورة التي تنتمي إليها الآية.
  final int surahNumber;

  /// رقم الآية داخل السورة.
  final int ayahNumber;

  /// المعرّف الموحد للآية (إن وجد).
  final int? ayahId;

  /// خريطة إجابات المستخدم مربوطة برقم السؤال (من 1 إلى 4).
  final Map<int, String> answers; // Question index (1..4) -> user answer

  /// تاريخ ووقت إنشاء وقفة التدبر.
  final DateTime createdAt;

  /// تاريخ ووقت آخر تحديث لوقفة التدبر.
  final DateTime updatedAt;

  /// ينشئ كائن وقفة تدبر جديد.
  const TadbeerItem({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.ayahId,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
  });

  /// المفتاح المركب للآية بصيغة (رقم السورة:رقم الآية).
  String get ayahKey => '$surahNumber:$ayahNumber';

  /// الأسئلة التوجيهية الأربعة المعتمدة في وقفة التدبر.
  ///
  /// The 4 authentic guiding questions for Tadbeer
  static const List<String> questions = [
    'ما الذي لفت انتباهك في هذه الآية؟',
    'ماذا فهمت من الآية؟',
    'هل هناك شيء تريد تطبيقه؟',
    'ما العلاقة التي تراها بين هذه الآية وما قبلها؟',
  ];

  /// ما إذا كانت جميع إجابات وقفة التدبر فارغة.
  bool get isEmpty => answers.values.every((v) => v.trim().isEmpty);

  /// يجمع جميع الإجابات غير الفارغة في ملخص نصي منسق.
  ///
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

  /// يحول كائن وقفة التدبر إلى خريطة بيانات JSON للحفظ المحلي.
  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    if (ayahId != null) 'ayahId': ayahId,
    'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// ينشئ كائن وقفة تدبر من خريطة بيانات JSON المحفوظة.
  factory TadbeerItem.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    final parsedAnswers = <int, String>{};
    for (final entry in rawAnswers.entries) {
      final key = int.tryParse(entry.key);
      if (key != null && entry.value is String) {
        parsedAnswers[key] = entry.value as String;
      }
    }
    return TadbeerItem(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      ayahId: json['ayahId'] as int?,
      answers: parsedAnswers,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// ينشئ نسخة محدثة من وقفة التدبر مع تعديل الإجابات أو تاريخ التحديث.
  TadbeerItem copyWith({Map<int, String>? answers, DateTime? updatedAt}) {
    return TadbeerItem(
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

/// اسم بديل متوافق مع الإصدارات السابقة لنموذج وقفة التدبر.
///
/// Backward compatibility typedef
typedef TadabburItem = TadbeerItem;
