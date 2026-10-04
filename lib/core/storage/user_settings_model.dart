import 'package:flutter/material.dart';

/// User settings and preferences in Tadbeer.
class UserSettings {
  final ThemeMode themeMode;
  final String languageCode;

  /// Whether the user has chosen to permanently dismiss the Tadabbur Intro.
  /// IMPORTANT:
  /// Once set to true, the introduction is NEVER shown again, and no option
  /// is provided to re-enable it, as specified in the Tadbeer requirements.
  final bool hideTadabburIntroPermanently;

  final double quranFontSize;

  const UserSettings({
    this.themeMode = ThemeMode.light,
    this.languageCode = 'ar',
    this.hideTadabburIntroPermanently = false,
    this.quranFontSize = 24.0,
  });

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'hideTadabburIntroPermanently': hideTadabburIntroPermanently,
    'quranFontSize': quranFontSize,
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

    return UserSettings(
      themeMode: mode,
      languageCode: json['languageCode'] as String? ?? 'ar',
      hideTadabburIntroPermanently:
          json['hideTadabburIntroPermanently'] as bool? ?? false,
      quranFontSize: (json['quranFontSize'] as num?)?.toDouble() ?? 24.0,
    );
  }

  UserSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? hideTadabburIntroPermanently,
    double? quranFontSize,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      hideTadabburIntroPermanently:
          hideTadabburIntroPermanently ?? this.hideTadabburIntroPermanently,
      quranFontSize: quranFontSize ?? this.quranFontSize,
    );
  }
}
