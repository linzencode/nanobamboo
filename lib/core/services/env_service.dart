import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 环境变量服务
class EnvService {
  // ✅ 未命名构造函数放在最前面（Dart 规范要求）
  factory EnvService() => _instance;
  
  // 命名构造函数放在后面
  EnvService._internal();
  
  /// 单例实例
  static final EnvService _instance = EnvService._internal();

  /// 初始化环境变量
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  /// Supabase URL
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase 匿名密钥
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// GitHub OAuth Client ID
  String get githubClientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';

  /// Google OAuth Web Client ID
  String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// Google OAuth iOS Client ID
  String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  /// 检查配置是否完整
  bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}

