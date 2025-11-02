// 本地存储辅助工具 - Web 平台实现
// 
// 此文件仅在 Web 平台使用

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// 清除本地存储（Web 平台）
void clearLocalStorage() {
  try {
    html.window.localStorage.clear();
  } catch (e) {
    // 忽略错误（某些浏览器可能不支持）
  }
}

