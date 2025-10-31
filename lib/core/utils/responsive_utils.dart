import 'package:flutter/material.dart';
import 'package:nanobamboo/app/constants/app_constants.dart';

/// 响应式工具类
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 判断是否为移动端
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// 判断是否为平板
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  /// 判断是否为桌面端
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  /// 获取响应式值
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// 获取响应式列数
  static int getResponsiveColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return 24;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 12;
    }
  }
}

