/// يمثل إشارة مرجعية (فاصل قراءة) لآية محددة في المصحف.
///
/// ملاحظة:
/// الإشارات المرجعية مرتبطة بآية محددة ورقم الصفحة لتمكين القارئ من العودة
/// السريعة بلمسة واحدة من شاشة "الفواصل" إلى موضع التلاوة.
class BookmarkItem {
  /// المعرّف الفريد للإشارة المرجعية.
  final String id;

  /// معرّف الآية الموحد (1..6236) لضمان الربط الدقيق.
  final int ayahId;

  /// رقم السورة التي تقع فيها الآية.
  final int surahNumber;

  /// رقم الآية داخل السورة.
  final int ayahNumber;

  /// رقم صفحة المصحف التي تحتوي على الآية.
  final int page;

  /// تاريخ ووقت إنشاء الإشارة المرجعية.
  final DateTime createdAt;

  /// ينشئ كائن إشارة مرجعية لآية قرآنية.
  const BookmarkItem({
    required this.id,
    required this.ayahId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
    required this.createdAt,
  });

  /// المفتاح النصي للآية بصيغة رقم السورة ورقم الآية.
  String get ayahKey => '$surahNumber:$ayahNumber';

  /// يحول بيانات الإشارة المرجعية إلى خريطة JSON للتخزين.
  Map<String, dynamic> toJson() => {
    'id': id,
    'ayahId': ayahId,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'page': page,
    'createdAt': createdAt.toIso8601String(),
  };

  /// ينشئ كائن إشارة مرجعية من خريطة بيانات JSON.
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
