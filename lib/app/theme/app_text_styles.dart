import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 应用文本样式
class AppTextStyles {
  AppTextStyles._();

  // 基础字体
  static TextStyle get baseTextStyle => GoogleFonts.inter();

  // 标题样式
  static TextStyle get h1 => baseTextStyle.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.5,
      );

  static TextStyle get h3 => baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get h4 => baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get h5 => baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get h6 => baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // 正文样式
  static TextStyle get bodyLarge => baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 1.6,
      );

  static TextStyle get bodyMedium => baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
      );

  static TextStyle get bodySmall => baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.6,
      );

  // 按钮样式
  static TextStyle get button => baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // 标签样式
  static TextStyle get label => baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        textBaseline: TextBaseline.alphabetic,
      );

  // 说明文本
  static TextStyle get caption => baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );
}

