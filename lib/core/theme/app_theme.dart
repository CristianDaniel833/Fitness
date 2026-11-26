import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Colores extraídos del logotipo de Fitness
  static const Color coral = Color(0xFFF45436);
  static const Color navy = Color(0xFF10375C);
  static const Color emerald = Color(0xFF0B945B);
  static const Color amber = Color(0xFFF7C66D);
  static const Color sky = Color(0xFFB8E3EE);
  static const Color deepTeal = Color(0xFF16748B);

  // Superficies claras
  static const Color lightBackground = Color(0xFFF7FBFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFDCE8EE);

  // Superficies oscuras (accesibilidad / modo oscuro desde Ajustes)
  static const Color darkBackground = Color(0xFF0B1926);
  static const Color darkSurface = Color(0xFF13273A);
  static const Color darkCardBorder = Color(0xFF213F5B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.coral,
      onPrimary: Colors.white,
      secondary: AppColors.navy,
      onSecondary: Colors.white,
      tertiary: AppColors.emerald,
      onTertiary: Colors.white,
      error: Color(0xFFC62828),
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.navy,
      surfaceContainerHighest: AppColors.sky,
      outline: AppColors.lightCardBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.coral,
      onPrimary: Colors.white,
      secondary: AppColors.sky,
      onSecondary: AppColors.navy,
      tertiary: AppColors.emerald,
      onTertiary: Colors.white,
      error: Color(0xFFEF5350),
      onError: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: AppColors.navy,
      outline: AppColors.darkCardBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}