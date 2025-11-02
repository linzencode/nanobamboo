import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志工具类
///
/// 用法:
/// ```dart
/// Logger.debug('调试信息');
/// Logger.info('普通信息');
/// Logger.warning('警告信息');
/// Logger.error('错误信息');
/// ```
class Logger {
  /// 是否启用日志
  /// Debug 模式默认启用，Release 模式默认禁用
  static bool _enabled = kDebugMode;

  /// 最小日志级别
  /// 只有大于等于此级别的日志才会输出
  static LogLevel _minLevel = LogLevel.debug;

  /// 启用日志
  static void enable() {
    _enabled = true;
  }

  /// 禁用日志
  static void disable() {
    _enabled = false;
  }

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 输出调试日志
  static void debug(String message) {
    _log(LogLevel.debug, message, '🔍');
  }

  /// 输出信息日志
  static void info(String message) {
    _log(LogLevel.info, message, '✅');
  }

  /// 输出警告日志
  static void warning(String message) {
    _log(LogLevel.warning, message, '⚠️');
  }

  /// 输出错误日志
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, '❌');
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', '  ');
    }
    if (stackTrace != null) {
      _log(LogLevel.error, 'StackTrace:\n$stackTrace', '  ');
    }
  }

  /// 内部日志输出方法
  static void _log(LogLevel level, String message, String icon) {
    // 检查是否启用日志
    if (!_enabled) return;

    // 检查日志级别
    if (level.index < _minLevel.index) return;

    // 格式化日志
    final timestamp = DateTime.now().toString().substring(11, 23);
    final levelName = level.name.toUpperCase().padRight(7);
    final formattedMessage = '$icon [$timestamp] [$levelName] $message';

    // 输出日志
    debugPrint(formattedMessage);

    // TODO: 生产环境可以在这里添加日志上报逻辑
    // if (kReleaseMode && level == LogLevel.error) {
    //   _reportToServer(message, error, stackTrace);
    // }
  }

  /// 上报错误到服务器（生产环境）
  /// TODO: 实现错误上报逻辑
  // static Future<void> _reportToServer(
  //   String message,
  //   Object? error,
  //   StackTrace? stackTrace,
  // ) async {
  //   // 实现错误上报逻辑
  //   // 例如使用 Sentry, Firebase Crashlytics 等
  // }
}

