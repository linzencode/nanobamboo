import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题控制器
class ThemeController extends GetxController {
  // 响应式主题模式
  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  static const String _themeModeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeModeKey);

      if (savedThemeMode != null) {
        _themeMode.value = _getThemeModeFromString(savedThemeMode);
      } else {
        // 默认跟随系统
        _themeMode.value = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('加载主题模式失败: $e');
    }
  }

  /// 切换主题
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
      debugPrint('保存主题模式失败: $e');
    }
  }

  /// 从字符串获取主题模式
  ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}

