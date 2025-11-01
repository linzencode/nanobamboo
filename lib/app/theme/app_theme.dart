import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/app_text_styles.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightForeground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground.withValues(alpha: 0.8),
        foregroundColor: AppColors.lightForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h6.copyWith(
          color: AppColors.lightForeground,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.lightForeground),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.lightForeground),
        displaySmall: AppTextStyles.h3.copyWith(color: AppColors.lightForeground),
        headlineLarge: AppTextStyles.h4.copyWith(color: AppColors.lightForeground),
        headlineMedium: AppTextStyles.h5.copyWith(color: AppColors.lightForeground),
        headlineSmall: AppTextStyles.h6.copyWith(color: AppColors.lightForeground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightForeground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightForeground),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightMutedForeground),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.lightForeground),
        labelMedium: AppTextStyles.label.copyWith(color: AppColors.lightMutedForeground),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.lightMutedForeground),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkForeground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground.withValues(alpha: 0.8),
        foregroundColor: AppColors.darkForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h6.copyWith(
          color: AppColors.darkForeground,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkForeground),
        displayMedium: AppTextStyles.h2.copyWith(color: AppColors.darkForeground),
        displaySmall: AppTextStyles.h3.copyWith(color: AppColors.darkForeground),
        headlineLarge: AppTextStyles.h4.copyWith(color: AppColors.darkForeground),
        headlineMedium: AppTextStyles.h5.copyWith(color: AppColors.darkForeground),
        headlineSmall: AppTextStyles.h6.copyWith(color: AppColors.darkForeground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkForeground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkForeground),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkMutedForeground),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.darkForeground),
        labelMedium: AppTextStyles.label.copyWith(color: AppColors.darkMutedForeground),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkMutedForeground),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

