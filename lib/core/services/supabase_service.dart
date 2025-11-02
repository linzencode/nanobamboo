import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nanobamboo/core/services/env_service.dart';
// ✅ 使用条件导入，只在 web 平台导入
import 'package:nanobamboo/core/utils/storage_helper_stub.dart'
    if (dart.library.html) 'package:nanobamboo/core/utils/storage_helper_web.dart';

/// Supabase 服务
class SupabaseService extends GetxService {
  late final SupabaseClient _client;

  /// 获取 Supabase 客户端
  SupabaseClient get client => _client;

  /// 获取当前用户
  User? get currentUser => _client.auth.currentUser;

  /// 是否已登录
  bool get isAuthenticated => currentUser != null;

  /// 用户状态流
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// 初始化 Supabase
  Future<SupabaseService> init() async {
    try {
      final envService = EnvService();

      if (!envService.isConfigured) {
        debugPrint('警告：Supabase 未配置，请检查 .env 文件');
        // 使用空配置，避免应用崩溃
        await Supabase.initialize(
          url: 'https://placeholder.supabase.co',
          anonKey: 'placeholder',
        );
      } else {
        await Supabase.initialize(
          url: envService.supabaseUrl,
          anonKey: envService.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            // Web 环境使用 implicit flow，移动端使用 pkce
            authFlowType: AuthFlowType.pkce,
            // 自动刷新 token（默认开启）
            autoRefreshToken: true,
          ),
        );
        
        debugPrint('📱 Session 持久化: 已启用（Supabase 默认）');
        debugPrint('🔄 自动刷新 Token: 已启用');
        debugPrint('⏰ Access Token 有效期: 1 小时');
        debugPrint('🔑 Refresh Token 有效期: 7 天（可在 Supabase Dashboard 配置）');
      }

      _client = Supabase.instance.client;

      debugPrint('Supabase 初始化成功');

      // 监听认证状态变化
      _client.auth.onAuthStateChange.listen(
        (data) {
          final event = data.event;
          debugPrint('认证状态变化: $event');

          if (event == AuthChangeEvent.signedIn) {
            debugPrint('用户已登录: ${data.session?.user.email}');
          } else if (event == AuthChangeEvent.signedOut) {
            debugPrint('用户已登出');
          } else if (event == AuthChangeEvent.tokenRefreshed) {
            debugPrint('Token 已刷新');
          }
        },
        onError: (Object error) {
          // 忽略 Refresh Token 失效的错误（这是退出登录后的正常情况）
          if (error is AuthException && 
              error.statusCode == '400' && 
              error.message.contains('Refresh Token')) {
            debugPrint('💡 检测到过期的 Refresh Token，已自动清除');
            return;
          }
          // 其他错误仍然记录
          debugPrint('⚠️ 认证状态变化错误: $error');
        },
      );
    } catch (e) {
      debugPrint('Supabase 初始化失败: $e');
      rethrow;
    }

    return this;
  }

  /// GitHub OAuth 登录（Web 端推荐）
  /// 
  /// ✅ Web 平台：使用 Supabase 内置的 OAuth（推荐）
  /// - 服务器端处理 token 交换（安全）
  /// - PKCE 自动启用
  /// - 回调到首页，由 UserController 监听 auth state 变化
  /// 
  /// ⚠️ 移动端请使用 signInWithGitHubToken 配合 flutter_appauth
  Future<bool> signInWithGitHub() async {
    try {
      debugPrint('🚀 [Web] 开始 Supabase GitHub OAuth 流程...');
      
      // ✅ 先检查是否有现有 session，如果有就先清除
      // 避免因 localStorage 中残留的 session 导致直接登录（不跳转授权页）
      final currentSession = _client.auth.currentSession;
      if (currentSession != null) {
        debugPrint('⚠️ 检测到现有 session，先清除...');
        await _client.auth.signOut();
        debugPrint('✅ 已清除现有 session');
      }
      
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.github,
        // Web 端回调到首页，让 auth state listener 处理登录后的状态
        redirectTo: kIsWeb 
            ? 'http://localhost:3000/home' 
            : 'io.supabase.nanobamboo://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('✅ [Web] GitHub OAuth 请求已发送');
      return response;
    } catch (e) {
      debugPrint('❌ [Web] GitHub OAuth 失败: $e');
      rethrow;
    }
  }

  /// GitHub OAuth 登录（移动端推荐）
  /// 
  /// ✅ 移动平台：配合 flutter_appauth 使用
  /// 1. 使用 flutter_appauth 进行 OAuth 2.0 + PKCE 授权
  /// 2. 获取 GitHub access_token
  /// 3. 使用此方法将 token 给 Supabase 创建会话
  /// 
  /// [accessToken] GitHub OAuth access_token（从 flutter_appauth 获取）
  /// 返回登录后的用户信息
  Future<AuthResponse> signInWithGitHubToken(String accessToken) async {
    try {
      debugPrint('🔐 [Mobile] 使用 GitHub token 登录 Supabase...');
      
      // 使用 GitHub access_token 通过 Supabase 创建会话
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.github,
        idToken: accessToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        debugPrint('✅ [Mobile] Supabase session 创建成功');
        debugPrint('   用户: ${response.user!.email}');
        debugPrint('   ID: ${response.user!.id}');
      } else {
        debugPrint('⚠️ [Mobile] Supabase session 创建失败，user 为 null');
      }

      return response;
    } catch (e) {
      debugPrint('❌ [Mobile] GitHub token 登录失败: $e');
      rethrow;
    }
  }

  /// Google OAuth 登录（Supabase 内置方式）
  /// 
  /// ⚠️ 此方法使用 Supabase 内置的 OAuth 流程
  /// 适用场景：快速集成，无需额外依赖
  Future<bool> signInWithGoogleOAuth() async {
    try {
      debugPrint('🚀 [Supabase OAuth] 开始 Google OAuth 流程...');
      
      // ✅ 先检查是否有现有 session，如果有就先清除
      final currentSession = _client.auth.currentSession;
      if (currentSession != null) {
        debugPrint('⚠️ 检测到现有 session，先清除...');
        await _client.auth.signOut();
        debugPrint('✅ 已清除现有 session');
      }
      
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Web 端回调到首页，避免路由跳转导致的 GlobalKey 冲突
        redirectTo: kIsWeb 
            ? 'http://localhost:3000/home' 
            : 'io.supabase.nanobamboo://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('✅ [Supabase OAuth] Google OAuth 请求已发送');
      return response;
    } catch (e) {
      debugPrint('❌ [Supabase OAuth] Google OAuth 失败: $e');
      rethrow;
    }
  }

  /// Google 登录（google_sign_in 插件 + 服务器端认证）
  /// 
  /// ✅ 推荐方式：使用 google_sign_in 插件配合 Supabase 服务器端认证
  /// 优势：
  /// - 跨平台一致体验（Web、iOS、Android）
  /// - 更好的错误处理和用户体验
  /// - 支持静默登录
  /// - 获得更多用户信息
  /// 
  /// [idToken] Google ID Token（JWT）
  /// [accessToken] Google Access Token
  /// 返回登录后的用户信息
  Future<AuthResponse> signInWithGoogleToken({
    required String idToken,
    required String accessToken,
  }) async {
    try {
      debugPrint('🔐 使用 Google Token 登录 Supabase...');
      
      // 使用 Google ID Token 和 Access Token 通过 Supabase 创建会话
      // 这是服务器端认证方式，token 会发送到 Supabase 后端验证
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        debugPrint('✅ Supabase session 创建成功');
        debugPrint('   用户: ${response.user!.email}');
        debugPrint('   ID: ${response.user!.id}');
        debugPrint('   名称: ${response.user!.userMetadata?['full_name']}');
      } else {
        debugPrint('⚠️ Supabase session 创建失败，user 为 null');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Google Token 登录失败: $e');
      rethrow;
    }
  }

  /// 邮箱密码登录
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      debugPrint('邮箱密码登录失败: $e');
      rethrow;
    }
  }

  /// 邮箱魔法链接登录
  Future<void> signInWithMagicLink({
    required String email,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.nanobamboo://login-callback/',
      );
    } catch (e) {
      debugPrint('邮箱魔法链接登录失败: $e');
      rethrow;
    }
  }

  /// 验证 OTP 验证码
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      return response;
    } catch (e) {
      debugPrint('验证码验证失败: $e');
      rethrow;
    }
  }

  /// 注册新用户
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      debugPrint('注册失败: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      // Supabase 会自动清除 localStorage 中的 session
      await _client.auth.signOut();
      debugPrint('✅ Supabase session 已清除');
      
      // ✅ Web 端额外清除 localStorage（确保彻底清除）
      if (kIsWeb) {
        try {
          // 使用条件导入的辅助函数清理 localStorage
          clearLocalStorage();
          debugPrint('✅ Web localStorage 已强制清除');
        } catch (e) {
          debugPrint('⚠️ 清除 localStorage 失败: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Supabase 登出失败: $e');
      rethrow;
    }
  }

  /// 刷新会话
  Future<AuthResponse?> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response;
    } catch (e) {
      debugPrint('刷新会话失败: $e');
      return null;
    }
  }

  /// 重置密码
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.nanobamboo://reset-password/',
      );
    } catch (e) {
      debugPrint('重置密码失败: $e');
      rethrow;
    }
  }

  /// 更新密码
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return response;
    } catch (e) {
      debugPrint('更新密码失败: $e');
      rethrow;
    }
  }
}
