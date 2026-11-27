import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF1E6B52);
  static const greenSoft = Color(0xFFE3F0EA);
  static const heart = Color(0xFFE5484D);
  static const bg = Color(0xFFF5F6F3);
  static const ink = Color(0xFF17201C);
  static const muted = Color(0xFF6F7873);
  static const line = Color(0xFFE3E6E1);
  static const skeleton = Color(0xFFE6E9E4);

  static const heroTop = Color(0xFF14503E);
  static const heroBottom = Color(0xFF2E9A78);

  static const orange = Color(0xFFF2994A);
  static const blue = Color(0xFF3B82C4);
  static const purple = Color(0xFF7C5CD6);
  static const teal = Color(0xFF14A38B);
  static const yellow = Color(0xFFE9A92B);
  static const rose = Color(0xFFD9638A);

  static const accents = [orange, blue, purple, teal, heart, yellow, green, rose];

  /// Warna latar lembut dari sebuah warna aksen.
  static Color tint(Color c) => Color.alphaBlend(c.withAlpha(34), Colors.white);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.green,
      surface: Colors.white,
      onSurface: AppColors.ink,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.green),
    ),
  );
}
