class Surah {
  final int number;
  final String name;
  final String transliteration;
  final String translation;
  final String type;
  final int ayahCount;
  final int order;
  final int rukus;
  final int pageStart;
  final int pageEnd;

  const Surah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.translation,
    required this.type,
    required this.ayahCount,
    required this.order,
    required this.rukus,
    required this.pageStart,
    required this.pageEnd,
  });

  bool get isMeccan => type == 'Meccan';

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      type: json['type'] as String,
      ayahCount: json['ayahCount'] as int,
      order: json['order'] as int,
      rukus: json['rukus'] as int,
      pageStart: json['pageStart'] as int,
      pageEnd: json['pageEnd'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'transliteration': transliteration,
    'translation': translation,
    'type': type,
    'ayahCount': ayahCount,
    'order': order,
    'rukus': rukus,
    'pageStart': pageStart,
    'pageEnd': pageEnd,
  };
}

class Ayah {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String rawText;
  final int page;
  final int juz;
  final int hizb;
  final int quarter;
  final bool isSajdah;
  final String? sajdaType;

  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.rawText,
    required this.page,
    required this.juz,
    required this.hizb,
    required this.quarter,
    this.isSajdah = false,
    this.sajdaType,
  });

  String get key => '$surahNumber:$ayahNumber';

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      id: json['id'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      text: json['text'] as String,
      rawText: json['rawText'] as String? ?? json['text'] as String,
      page: json['page'] as int,
      juz: json['juz'] as int,
      hizb: json['hizb'] as int,
      quarter: json['quarter'] as int,
      isSajdah: json['isSajdah'] as bool? ?? false,
      sajdaType: json['sajdaType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'text': text,
    'rawText': rawText,
    'page': page,
    'juz': juz,
    'hizb': hizb,
    'quarter': quarter,
    'isSajdah': isSajdah,
    if (sajdaType != null) 'sajdaType': sajdaType,
  };
}

class QuranPage {
  final int pageNumber;
  final int juzNumber;
  final int hizbNumber;
  final List<int> surahNumbers;
  final List<Ayah> ayahs;

  const QuranPage({
    required this.pageNumber,
    required this.juzNumber,
    required this.hizbNumber,
    required this.surahNumbers,
    required this.ayahs,
  });

  factory QuranPage.fromJson(Map<String, dynamic> json) {
    return QuranPage(
      pageNumber: json['pageNumber'] as int,
      juzNumber: json['juzNumber'] as int,
      hizbNumber: json['hizbNumber'] as int,
      surahNumbers: (json['surahNumbers'] as List).cast<int>(),
      ayahs: (json['ayahs'] as List)
          .map((a) => Ayah.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
