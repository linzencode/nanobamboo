// URL 辅助工具 - Web 平台实现

// 此文件仅在 Web 平台使用

import 'package:web/web.dart' as web;

/// 清理 URL 中的参数（Web 平台）
void cleanUrlParameters(String cleanUrl) {
  try {
    web.window.history.replaceState(null, '', cleanUrl);
  } catch (e) {
    // 忽略错误（某些浏览器可能不支持）
  }
}
