/// Arabic text normalizer and numeral formatting utilities for Tadbeer.
///
/// EDUCATIONAL NOTE:
/// IMPORTANT:
/// Quran text itself must NEVER be normalized or modified for display.
/// Normalization is ONLY used for search matching.
///
/// Arabic orthography often contains stylistic variations (such as Alef with hamza
/// above/below/wasla: أ, إ, آ, ٱ, or Taa Marbuta: ة vs Haa: ه).
/// Removing diacritics and collapsing orthographic variants in query matching
/// enables an intuitive, fast search experience while preserving 100% of the
/// verified Uthmani script in the Quran reader.
class ArabicSearchNormalizer {
  ArabicSearchNormalizer._();

  // Arabic Tashkeel (diacritics) and Quranic annotation Unicode characters
  static final RegExp _diacriticsRegex = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]',
  );

  static final RegExp _tatweelRegex = RegExp(r'\u0640');

  /// Normalizes Arabic text for flexible search without modifying original text.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    var result = text;

    // 1. Remove diacritics and Quranic pause/sajdah/stop marks
    result = result.replaceAll(_diacriticsRegex, '');

    // 2. Remove Tatweel (Kashida)
    result = result.replaceAll(_tatweelRegex, '');

    // 3. Normalize all Alef forms (أ, إ, آ, ٱ) to bare Alef (ا)
    result = result.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 4. Normalize Taa Marbuta (ة) to Haa (ه)
    result = result.replaceAll('ة', 'ه');

    // 5. Normalize Alef Maqsura (ى) to Yaa (ي)
    result = result.replaceAll('ى', 'ي');

    // 6. Normalize Hamza on Waw / Yaa
    result = result.replaceAll('ؤ', 'و');
    result = result.replaceAll('ئ', 'ي');

    // 7. Trim and collapse whitespace
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

    return result;
  }

  /// Converts an integer to Arabic-Indic digits with optional minimum digits padding
  /// (e.g. 5 with minDigits: 2 -> "٠٥").
  static String formatDigits(int number, {int minDigits = 1}) {
    final s = number.toString().padLeft(minDigits, '0');
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(arabicDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  /// Converts an integer to Arabic-Indic digits (e.g. 1 -> ١).
  static String toArabicDigits(int number) => formatDigits(number);
}
