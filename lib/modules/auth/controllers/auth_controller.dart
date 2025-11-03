import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:nanobamboo/core/services/google_signin_service.dart';  // 不使用 google_sign_in 插件
import 'package:nanobamboo/core/services/oauth_service.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/main.dart' as main_app;
import 'package:supabase_flutter/supabase_flutter.dart';

/// 认证控制器
class AuthController extends GetxController {
  /// Supabase 服务
  late final SupabaseService _supabaseService;

  /// OAuth 服务（flutter_appauth）
  late final OAuthService _oauthService;

  // /// Google 登录服务（不使用 google_sign_in 插件）
  // late final GoogleSignInService _googleSignInService;

  /// Supabase 是否已正确配置
  bool _isSupabaseConfigured = false;

  /// 当前选中的标签页索引（0:社交登录, 1:密码登录）
  final selectedTabIndex = 0.obs;

  /// 邮箱地址
  final email = ''.obs;

  /// 密码
  final password = ''.obs;

  /// 是否显示密码
  final isPasswordVisible = false.obs;

  /// Google 登录加载状态
  final isGoogleLoading = false.obs;

  /// GitHub 登录加载状态
  final isGitHubLoading = false.obs;

  /// 密码登录加载状态
  final isPasswordLoading = false.obs;

  /// OTP 验证码加载状态
  final isOTPLoading = false.obs;

  /// OTP 验证码倒计时
  final countdown = 0.obs;

  /// 验证码
  final verificationCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _supabaseService = Get.find<SupabaseService>();
      _oauthService = OAuthService();
      // _googleSignInService = GoogleSignInService();  // 不使用 google_sign_in 插件
      
      // 初始化 Google 登录服务（不使用）
      // _googleSignInService.init();
      
      // 检查 Supabase 是否正确配置
      // 尝试访问 auth 服务来验证配置
      _isSupabaseConfigured = true;
      _supabaseService.client.auth.onAuthStateChange.listen((_) {});
    } catch (e) {
      debugPrint('⚠️ 无法获取 Supabase 服务或服务未正确配置: $e');
      _isSupabaseConfigured = false;
    }
  }

  /// 检查 Supabase 配置
  bool _checkSupabaseConfig() {
    if (!_isSupabaseConfigured) {
      Get.snackbar(
        '配置错误',
        '请先配置 Supabase 环境变量（.env 文件）',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
    return true;
  }

  /// 切换标签页
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// GitHub OAuth 登录（跨平台）
  /// 
  /// ✅ Web 平台：使用 Supabase 内置 OAuth（推荐）
  /// - 简单、安全、可靠
  /// - 服务器端处理 token 交换
  /// - PKCE 自动启用
  /// - 回调后由 UserController 监听 auth state 自动更新
  /// 
  /// ✅ 移动平台：使用 flutter_appauth + PKCE（标准）
  /// 1. 使用 flutter_appauth 进行 OAuth 2.0 + PKCE 授权
  /// 2. 获取 GitHub access_token
  /// 3. 将 token 给 Supabase，创建会话
  /// 4. 完成登录并返回主页
  Future<void> signInWithGitHub() async {
    if (!_checkSupabaseConfig()) return;

    // ✅ 检查是否已经登录
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      debugPrint('💡 用户已登录: ${currentUser.email}，无需重复登录');
      debugPrint('💡 如需切换账号，请先退出登录');
      
      // 直接关闭登录页，返回首页
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }
      return;
    }

    try {
      isGitHubLoading.value = true;

      if (kIsWeb) {
        // ==================== Web 平台 ====================
        debugPrint('🚀 [Web] 开始 Supabase GitHub OAuth 流程...');

        final success = await _supabaseService.signInWithGitHub();

        if (success) {
          debugPrint('✅ [Web] GitHub OAuth 请求成功，等待回调...');
          // ⚠️ 注释掉 GetX Snackbar，因为使用 MaterialApp 会导致 null 错误
          // Get.snackbar(
          //   '正在跳转',
          //   '即将打开 GitHub 登录页面...',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 2),
          // );
          
          // ⚠️ 关键：不要在这里关闭登录页或跳转
          // OAuth 会重定向到 /home，UserController 会监听到 auth state 变化并更新 UI
        } else {
          debugPrint('❌ 无法启动 GitHub 登录');
          // Get.snackbar(
          //   '登录失败',
          //   '无法启动 GitHub 登录',
          //   snackPosition: SnackPosition.TOP,
          // );
        }
      } else {
        // ==================== 移动平台 ====================
        debugPrint('🚀 [Mobile] 开始 flutter_appauth GitHub OAuth 流程...');

        // 1. 使用 flutter_appauth 进行 GitHub OAuth
        final result = await _oauthService.signInWithGitHub();

        if (result == null || result.accessToken == null) {
          debugPrint('⚠️ [Mobile] GitHub OAuth 取消或失败');
          Get.snackbar(
            '登录取消',
            '您取消了 GitHub 登录',
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        debugPrint('✅ [Mobile] GitHub OAuth 成功，获取到 access_token');

        // 2. 使用 GitHub token 通过 Supabase 创建会话
        final authResponse = await _supabaseService.signInWithGitHubToken(
          result.accessToken!,
        );

        if (authResponse.user != null) {
          debugPrint('✅ [Mobile] 登录成功: ${authResponse.user!.email}');

          // 3. 显示成功提示
          Get.snackbar(
            '登录成功',
            '欢迎回来，${authResponse.user!.email ?? "用户"}！',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );

          // 4. 返回主页
          final navigator = main_app.navigatorKey.currentState;
          navigator?.pop();

          debugPrint('🎉 [Mobile] GitHub 登录流程完成！');
        } else {
          throw Exception('Supabase session 创建失败');
        }
      }
    } on AuthException catch (e) {
      debugPrint('❌ GitHub 登录失败 (AuthException): ${e.message}');
      Get.snackbar(
        '登录失败',
        e.message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('❌ GitHub 登录失败: $e');
      Get.snackbar(
        '登录失败',
        '请稍后重试：$e',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isGitHubLoading.value = false;
    }
  }

  // /// Google 登录（google_sign_in 插件方式 - 不使用）
  // /// 
  // /// ✅ 使用 google_sign_in 插件配合 Supabase 服务器端认证
  // /// 优势：
  // /// - 跨平台一致体验（Web、iOS、Android）
  // /// - 更好的错误处理和用户体验
  // /// - 支持静默登录
  // /// - 获得更多用户信息
  /* Future<void> signInWithGoogle() async {
    if (!_checkSupabaseConfig()) return;

    // ✅ 检查是否已经登录
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      debugPrint('💡 用户已登录: ${currentUser.email}，无需重复登录');
      debugPrint('💡 如需切换账号，请先退出登录');
      
      // 直接关闭登录页，返回首页
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }
      return;
    }

    try {
      isLoading.value = true;

      debugPrint('🚀 开始 Google 登录流程...');

      // 1. 使用 google_sign_in 插件进行 Google OAuth
      final result = await _googleSignInService.signIn();

      if (result == null) {
        debugPrint('⚠️ Google 登录取消或失败');
        Get.snackbar(
          '登录取消',
          '您取消了 Google 登录',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      debugPrint('✅ Google OAuth 成功，开始创建 Supabase session...');

      // 2. 使用 Google token 通过 Supabase 创建会话（服务器端认证）
      final authResponse = await _supabaseService.signInWithGoogleToken(
        idToken: result.idToken,
        accessToken: result.accessToken,
      );

      if (authResponse.user != null) {
        debugPrint('✅ 登录成功: ${authResponse.user!.email}');

        // 3. 显示成功提示
        Get.snackbar(
          '登录成功',
          '欢迎回来，${authResponse.user!.email ?? "用户"}！',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
        );

        // 4. 关闭登录页，返回首页
        final navigator = main_app.navigatorKey.currentState;
        navigator?.pop();

        debugPrint('🎉 Google 登录流程完成！');
      } else {
        throw Exception('Supabase session 创建失败');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Google 登录失败 (AuthException): ${e.message}');
      Get.snackbar(
        '登录失败',
        e.message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('❌ Google 登录失败: $e');
      Get.snackbar(
        '登录失败',
        '请稍后重试：$e',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  } */

  /// Google OAuth 登录（Supabase 内置方式 - 使用中）
  /// 
  /// ⚠️ 使用 Supabase 内置的 OAuth 流程
  /// 仅用于快速测试或备用方案
  Future<void> signInWithGoogleOAuth() async {
    if (!_checkSupabaseConfig()) return;

    // ✅ 检查是否已经登录
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      debugPrint('💡 用户已登录: ${currentUser.email}，无需重复登录');
      
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }
      return;
    }

    try {
      isGoogleLoading.value = true;

      final success = await _supabaseService.signInWithGoogleOAuth();

      if (success) {
        debugPrint('Google OAuth 请求成功，等待回调...');
        // OAuth 会跳转到浏览器，回调后会自动更新状态
      } else {
        Get.snackbar(
          '登录失败',
          '无法启动 Google 登录',
          snackPosition: SnackPosition.TOP,
        );
      }
    } on AuthException catch (e) {
      Get.snackbar(
        '登录失败',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// 发送 OTP 验证码
  Future<void> sendVerificationCode() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!_checkSupabaseConfig()) return;

    try {
      isOTPLoading.value = true;

      await _supabaseService.signInWithMagicLink(email: email.value);

      Get.snackbar(
        '发送成功',
        '验证码已发送到您的邮箱',
        snackPosition: SnackPosition.TOP,
      );

      // 开始倒计时
      countdown.value = 60;
      _startCountdown();
    } on AuthException catch (e) {
      Get.snackbar(
        '发送失败',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '发送失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isOTPLoading.value = false;
    }
  }

  /// 倒计时
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (countdown.value > 0) {
        countdown.value--;
        _startCountdown();
      }
    });
  }

  /// 验证 OTP 验证码并登录
  Future<void> verifyOTPCode() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (verificationCode.value.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入验证码',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!_checkSupabaseConfig()) return;

    try {
      isOTPLoading.value = true;

      final response = await _supabaseService.verifyOTP(
        email: email.value,
        token: verificationCode.value,
      );

      if (response.user != null) {
        Get.snackbar(
          '登录成功',
          '欢迎回来，${response.user!.email}！',
          snackPosition: SnackPosition.TOP,
        );
        // 使用 Flutter 原生 Navigator
        final navigator = main_app.navigatorKey.currentState;
        navigator?.pop();
      }
    } on AuthException catch (e) {
      Get.snackbar(
        '验证失败',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '验证失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isOTPLoading.value = false;
    }
  }

  /// 密码登录
  Future<void> signInWithPassword() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (password.value.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入密码',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!_checkSupabaseConfig()) return;

    try {
      isPasswordLoading.value = true;

      final response = await _supabaseService.signInWithPassword(
        email: email.value,
        password: password.value,
      );

      if (response.user != null) {
        Get.snackbar(
          '登录成功',
          '欢迎回来，${response.user!.email}！',
          snackPosition: SnackPosition.TOP,
        );
        // 使用 Flutter 原生 Navigator
        final navigator = main_app.navigatorKey.currentState;
        navigator?.pop();

      }
    } on AuthException catch (e) {
      Get.snackbar(
        '登录失败',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isPasswordLoading.value = false;
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      Get.snackbar(
        '已登出',
        '您已成功登出',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '登出失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

