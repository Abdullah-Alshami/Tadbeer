import 'package:flutter/material.dart';

/// Exactly three Quran font-size options as required by Tadbeer typography specifications:
/// 1. صغير (Small: 19.0pt, fewer pages than 604)
/// 2. متوسط (Medium: 23.0pt, baseline reproducing 604 Medina Mushaf pages)
/// 3. كبير (Large: 28.0pt, more pages than 604)
enum QuranFontSizeOption {
  small,
  medium,
  large;

  double get fontSize {
    switch (this) {
      case QuranFontSizeOption.small:
        return 15.5;
      case QuranFontSizeOption.medium:
        return 18.5; // Reference Medina Mushaf layout
      case QuranFontSizeOption.large:
        return 22.0;
    }
  }

  String get labelArabic {
    switch (this) {
      case QuranFontSizeOption.small:
        return 'صغير';
      case QuranFontSizeOption.medium:
        return 'متوسط';
      case QuranFontSizeOption.large:
        return 'كبير';
    }
  }
}

class UserSettings {
  static const double defaultQuranFontSize = 20.0;
  static const double minQuranFontSize = 18.0;
  static const double maxQuranFontSize = 28.0;

  final ThemeMode themeMode;
  final String languageCode;

  /// Whether the user has chosen to permanently dismiss the Tadbeer Intro.
  /// IMPORTANT:
  /// Once set to true, the introduction is NEVER shown again, and no option
  /// is provided to re-enable it, as specified in the Tadbeer requirements.
  final bool hideTadbeerIntroPermanently;

  /// Backward compatibility getter
  bool get hideTadabburIntroPermanently => hideTadbeerIntroPermanently;

  final QuranFontSizeOption quranFontOption;
  final double quranFontSize;
  final double ayahLinkFontSize;

  const UserSettings({
    this.themeMode = ThemeMode.light,
    this.languageCode = 'ar',
    bool hideTadbeerIntroPermanently = false,
    bool? hideTadabburIntroPermanently,
    this.quranFontOption = QuranFontSizeOption.medium,
    this.quranFontSize = defaultQuranFontSize,
    this.ayahLinkFontSize = 18.0,
  }) : hideTadbeerIntroPermanently =
           hideTadabburIntroPermanently ?? hideTadbeerIntroPermanently;

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'hideTadbeerIntroPermanently': hideTadbeerIntroPermanently,
    'hideTadabburIntroPermanently': hideTadbeerIntroPermanently,
    'quranFontOption': quranFontOption.name,
    'quranFontSize': quranFontSize,
    'ayahLinkFontSize': ayahLinkFontSize,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    ThemeMode mode;
    switch (json['themeMode'] as String?) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    QuranFontSizeOption fontOpt = QuranFontSizeOption.medium;
    final optionStr = json['quranFontOption'] as String?;
    if (optionStr != null) {
      fontOpt = QuranFontSizeOption.values.firstWhere(
        (e) => e.name == optionStr,
        orElse: () => QuranFontSizeOption.medium,
      );
    }

    double quranSize = UserSettings.defaultQuranFontSize;
    if (json['quranFontSize'] != null) {
      final fs = (json['quranFontSize'] as num).toDouble();
      quranSize = fs.clamp(
        UserSettings.minQuranFontSize,
        UserSettings.maxQuranFontSize,
      );
    }

    return UserSettings(
      themeMode: mode,
      languageCode: json['languageCode'] as String? ?? 'ar',
      hideTadbeerIntroPermanently:
          json['hideTadbeerIntroPermanently'] as bool? ??
          json['hideTadabburIntroPermanently'] as bool? ??
          false,
      quranFontOption: fontOpt,
      quranFontSize: quranSize,
      ayahLinkFontSize: (json['ayahLinkFontSize'] as num?)?.toDouble() ?? 18.0,
    );
  }

  UserSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? hideTadbeerIntroPermanently,
    bool? hideTadabburIntroPermanently,
    QuranFontSizeOption? quranFontOption,
    double? quranFontSize,
    double? ayahLinkFontSize,
  }) {
    final newQuranFontSize = quranFontSize != null
        ? quranFontSize.clamp(minQuranFontSize, maxQuranFontSize)
        : this.quranFontSize;

    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      hideTadbeerIntroPermanently:
          hideTadbeerIntroPermanently ??
          hideTadabburIntroPermanently ??
          this.hideTadbeerIntroPermanently,
      quranFontOption: quranFontOption ?? this.quranFontOption,
      quranFontSize: newQuranFontSize,
      ayahLinkFontSize: ayahLinkFontSize ?? this.ayahLinkFontSize,
    );
  }
}
