import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  AppColors._();

  // 主色调
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // 次要色
  static const Color secondary = Color(0xFFFBBF24);
  static const Color secondaryLight = Color(0xFFFCD34D);
  static const Color secondaryDark = Color(0xFFF59E0B);

  // 中性色 - 亮色主题
  static const Color lightBackground = Color(0xFFFFFBF0); // 暖白色背景
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightCard = Color(0xFFFFFAEB); // 更淡的黄色卡片
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightMuted = Color(0xFFFFF8E7);
  static const Color lightMutedForeground = Color(0xFF64748B);

  // 中性色 - 暗色主题
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkMuted = Color(0xFF1E293B);
  static const Color darkMutedForeground = Color(0xFF94A3B8);

  // 语义化颜色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

