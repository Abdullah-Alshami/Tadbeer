/// أنواع الخواطر والملاحظات المتاحة في التطبيق.
enum NoteType {
  /// خواطر مرتبطة بآية قرآنية محددة.
  ayah,

  /// خواطر حرة عامة غير مرتبطة بآية بعينها.
  free,
}

/// يمثل خاطرة أو تدوينة للمستخدم في تطبيق تدبّر.
///
/// ملاحظة:
/// الخواطر تدعم نوعين: خواطر مرتبطة بآية محددة (مع حفظ رقم السورة والآية والصفحة)،
/// أو خواطر حرة. يتم حفظها محلياً وعرضها في تدفق موحد مرتب من الأحدث إلى الأقدم.
class NoteItem {
  /// المعرّف الفريد للملاحظة.
  final String id;

  /// نوع الملاحظة (مرتبطة بآية أو حرة).
  final NoteType type;

  /// عنوان الملاحظة الاختياري.
  final String? title;

  /// المحتوى النصي للخاطرة أو الملاحظة.
  final String content;

  /// حقول الربط بالآية (تُملأ عند كون الخاطرة من نوع [NoteType.ayah]).
  final int? ayahId;

  /// رقم السورة المرتبطة بالملاحظة إن وجدت.
  final int? surahNumber;

  /// رقم الآية المرتبطة بالملاحظة إن وجدت.
  final int? ayahNumber;

  /// رقم صفحة المصحف للآية المرتبطة إن وجدت.
  final int? page;

  /// النص القرآني للآية المرتبطة بالملاحظة إن وجد.
  final String? ayahText;

  /// تاريخ ووقت إنشاء الملاحظة.
  final DateTime createdAt;

  /// تاريخ ووقت آخر تحديث للملاحظة.
  final DateTime updatedAt;

  /// ينشئ كائن ملاحظة أو خاطرة جديد.
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

  /// ما إذا كانت هذه الملاحظة مرتبطة بآية قرآنية محددة.
  bool get isAyahNote => type == NoteType.ayah;

  /// يحول بيانات الملاحظة إلى خريطة JSON للتخزين المحلي.
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

  /// ينشئ كائن ملاحظة من خريطة بيانات JSON المحفوظة.
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

  /// ينشئ نسخة محدثة من الملاحظة مع تعديل الحقول الممررة.
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
