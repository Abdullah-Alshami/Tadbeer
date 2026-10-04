import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Specification Primary Palette
  static const Color olive = Color(0xFF606C38);
  static const Color comsilk = Color(0xFFE8E2D0);
  static const Color oliveDark = Color(0xFF3F4925);
  static const Color comsilkLight = Color(0xFFF4F1E8);
  static const Color oliveSoft = Color(0xFF8FA059);
  static const Color oliveVeryLight = Color(0x18606C38);

  // Warm Dark Neutral Palette (Refined for prolonged night reading)
  static const Color darkBackground = Color(0xFF1B1C17);
  static const Color darkSurface = Color(0xFF262821);
  static const Color darkSurfaceVariant = Color(0xFF33362C);

  // Light Surfaces and borders
  static const Color lightSurface = Color(0xFFEFECE2);
  static const Color lightSurfaceVariant = Color(0xFFE2DDD0);
  static const Color lightBorder = Color(0xFFDDD7C8);

  // Text colors
  static const Color dayQuranText = Color(0xFF22211C);
  static const Color nightQuranText = Color(0xFFEBE7DC);
  static const Color daySubtitle = Color(0xFF5D5A50);
  static const Color nightSubtitle = Color(0xFFA3A094);

  // Temporary Ayah selection color (distinct from saved highlights)
  static const Color selectionLight = Color(0x38606C38);
  static const Color selectionDark = Color(0x458FA059);

  // Ayah Highlight Palette (Calm, subtle, visible in day & night)
  static const List<Color> highlightColors = [
    Color(0x66606C38), // Olive highlight
    Color(0x66D4A373), // Warm Sand highlight
    Color(0x665B8266), // Sage highlight
    Color(0x66B57979), // Dusty Rose highlight
  ];

  static const List<String> highlightColorNames = [
    'زيتوني',
    'رملي',
    'مريمي',
    'وردي',
  ];
}
