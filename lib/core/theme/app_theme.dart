import 'package:flutter/material.dart';
import 'package:software_engineering_project/core/theme/app_colors.dart';
import 'package:software_engineering_project/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        bodyLarge: AppTextStyles.bodyText,
        titleMedium: AppTextStyles.heading1,
      ),
    );
  }
}
