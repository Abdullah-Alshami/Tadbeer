import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  /// System-safe modern Arabic and Latin UI font fallbacks
  static const List<String> uiFontFallbacks = [
    'Noto Sans Arabic',
    'Segoe UI',
    'Roboto',
    'Cairo',
    'sans-serif',
  ];

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.comsilkLight,
      hoverColor: AppColors.olive.withValues(alpha: 0.06),
      focusColor: AppColors.olive.withValues(alpha: 0.10),
      splashColor: AppColors.olive.withValues(alpha: 0.12),
      highlightColor: AppColors.olive.withValues(alpha: 0.05),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.olive,
        onPrimary: Colors.white,
        secondary: AppColors.oliveDark,
        onSecondary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: AppColors.comsilkLight,
        onSurface: AppColors.dayQuranText,
        surfaceContainerHighest: AppColors.comsilk,
        onSurfaceVariant: AppColors.daySubtitle,
        outline: AppColors.lightBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.comsilk,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.comsilkLight,
        foregroundColor: AppColors.oliveDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.comsilkLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.comsilkLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.olive,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.olive,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.olive,
          side: const BorderSide(color: AppColors.olive),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.comsilk,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.olive, width: 1.5),
        ),
      ),
      textTheme: _buildTextTheme(
        base.textTheme,
        AppColors.dayQuranText,
        AppColors.daySubtitle,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      hoverColor: AppColors.oliveSoft.withValues(alpha: 0.08),
      focusColor: AppColors.oliveSoft.withValues(alpha: 0.12),
      splashColor: AppColors.oliveSoft.withValues(alpha: 0.12),
      highlightColor: AppColors.oliveSoft.withValues(alpha: 0.06),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.oliveSoft,
        onPrimary: Colors.black,
        secondary: AppColors.olive,
        onSecondary: Colors.white,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: AppColors.darkBackground,
        onSurface: AppColors.nightQuranText,
        surfaceContainerHighest: AppColors.darkSurface,
        onSurfaceVariant: AppColors.nightSubtitle,
        outline: AppColors.darkSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkSurfaceVariant, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.nightQuranText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkSurfaceVariant, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.olive,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.oliveSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.oliveSoft,
          side: const BorderSide(color: AppColors.oliveSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.oliveSoft, width: 1.5),
        ),
      ),
      textTheme: _buildTextTheme(
        base.textTheme,
        AppColors.nightQuranText,
        AppColors.nightSubtitle,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color textColor,
    Color subtitleColor,
  ) {
    return base.copyWith(
      headlineLarge: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 26,
      ),
      headlineMedium: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 19,
      ),
      titleMedium: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.w600,
        color: subtitleColor,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        color: textColor,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        color: textColor,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        color: subtitleColor,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontFamilyFallback: uiFontFallbacks,
        color: subtitleColor,
        fontSize: 12,
      ),
    );
  }
}
