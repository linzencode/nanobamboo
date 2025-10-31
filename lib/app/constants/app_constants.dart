/// 应用常量
class AppConstants {
  AppConstants._();

  /// 应用名称
  static const String appName = 'NanoBanana';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 应用描述
  static const String appDescription = 'AI 图像处理平台';

  /// 图片路径
  static const String imagePath = 'assets/images';

  /// 响应式断点
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1280.0;

  /// 图片上传限制
  static const int maxImageSizeMB = 10;
  static const List<String> supportedImageFormats = [
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
  ];

  /// 动画时长
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

