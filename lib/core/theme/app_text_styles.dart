import 'package:flutter/material.dart';
import 'package:software_engineering_project/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static const TextStyle nodeTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
}
