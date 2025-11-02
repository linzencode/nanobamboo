import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/main.dart' as main_app;
import 'package:supabase_flutter/supabase_flutter.dart';
// ✅ 使用条件导入，只在 web 平台导入
import 'package:nanobamboo/core/utils/url_helper_stub.dart'
    if (dart.library.html) 'package:nanobamboo/core/utils/url_helper_web.dart';

/// 全局用户控制器
class UserController extends GetxController {
  late final SupabaseService _supabaseService;
  
  /// 认证状态变化订阅
  StreamSubscription<AuthState>? _authSubscription;

  /// 当前用户
  final Rx<User?> currentUser = Rx<User?>(null);

  /// 是否已登录
  bool get isLoggedIn => currentUser.value != null;
  
  /// 上次登录成功处理的时间（用于防抖）
  DateTime? _lastLoginHandledTime;

  /// 用户显示名称
  String get displayName {
    final user = currentUser.value;
    if (user == null) return '';

    // 优先使用 GitHub 用户名
    final metadata = user.userMetadata;
    if (metadata != null) {
      // GitHub 用户名
      if (metadata['user_name'] != null) {
        return metadata['user_name'] as String;
      }
      // GitHub 全名
      if (metadata['full_name'] != null) {
        return metadata['full_name'] as String;
      }
      // 其他平台的名称
      if (metadata['name'] != null) {
        return metadata['name'] as String;
      }
    }

    // 最后使用邮箱的用户名部分
    if (user.email != null) {
      return user.email!.split('@').first;
    }

    return 'User';
  }

  /// 用户头像 URL
  String? get avatarUrl {
    final user = currentUser.value;
    if (user == null) return null;

    final metadata = user.userMetadata;
    if (metadata != null) {
      // GitHub 头像
      if (metadata['avatar_url'] != null) {
        return metadata['avatar_url'] as String;
      }
      // 其他平台的头像
      if (metadata['picture'] != null) {
        return metadata['picture'] as String;
      }
    }

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _initUser();
  }

  /// 初始化用户状态
  void _initUser() {
    try {
      _supabaseService = Get.find<SupabaseService>();

      // ✅ 先清除 URL 中的 OAuth 参数（防止刷新页面时重复处理）
      if (kIsWeb) {
        _cleanupUrlIfNeeded();
      }

      // ⏰ 等待一小段时间，让 Supabase 处理 URL fragment 中的 token
      // 这对于 OAuth 回调很重要
      Future.delayed(const Duration(milliseconds: 100), () {
        // 获取当前用户（可能已经通过 OAuth 回调创建了 session）
        final user = _supabaseService.currentUser;
        if (user != null) {
          currentUser.value = user;
          debugPrint('✅ 检测到已登录用户: $displayName');
          debugPrint('   邮箱: ${user.email}');
          debugPrint('   ID: ${user.id}');
        } else {
          currentUser.value = null;
          debugPrint('ℹ️ 当前用户未登录');
        }
      });

      // 取消之前的订阅（如果存在）
      _authSubscription?.cancel();

      // 监听认证状态变化
      _authSubscription = _supabaseService.authStateChanges.listen((data) {
        final event = data.event;
        debugPrint('👤 用户状态变化: $event');

        if (event == AuthChangeEvent.signedIn) {
          currentUser.value = data.session?.user;
          debugPrint('✅ 用户已登录: $displayName');
          
          // 登录成功后，如果当前在认证页面，则关闭它
          _handleSuccessfulLogin();
        } else if (event == AuthChangeEvent.signedOut) {
          currentUser.value = null;
          debugPrint('👋 用户已登出');
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          currentUser.value = data.session?.user;
          debugPrint('🔄 Token 已刷新');
        } else if (event == AuthChangeEvent.initialSession) {
          // ✅ 处理初始 session（OAuth 回调后）
          if (data.session?.user != null) {
            currentUser.value = data.session?.user;
            debugPrint('🎯 初始 session 恢复成功: $displayName');
          }
        }
      });

    } catch (e) {
      debugPrint('⚠️ 初始化用户状态失败: $e');
    }
  }
  
  /// 清除 URL 中的 OAuth 参数（如果存在）
  void _cleanupUrlIfNeeded() {
    try {
      final currentUrl = Uri.base.toString();
      
      // 如果 URL 中包含 access_token，说明是 OAuth 回调
      if (currentUrl.contains('#access_token=') || currentUrl.contains('?access_token=')) {
        debugPrint('🧹 检测到 URL 中的 OAuth 参数，准备清除...');
        
        // 延迟清除，确保 Supabase 先处理完 token
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            final cleanUrl = Uri.base.replace(fragment: '', queryParameters: {}).toString();
            // ✅ 使用条件导入的辅助函数清理 URL
            cleanUrlParameters(cleanUrl);
            debugPrint('✅ URL 已清理');
          } catch (e) {
            debugPrint('⚠️ 清理 URL 失败: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ 检查 URL 失败: $e');
    }
  }

  /// 处理登录成功
  void _handleSuccessfulLogin() {
    // ✅ 防抖：避免短时间内重复处理
    final now = DateTime.now();
    if (_lastLoginHandledTime != null) {
      final diff = now.difference(_lastLoginHandledTime!);
      if (diff.inSeconds < 5) {
        debugPrint('⏭️ 跳过重复的登录成功处理（距离上次 ${diff.inSeconds} 秒）');
        return;
      }
    }
    _lastLoginHandledTime = now;
    
    debugPrint('✅ 登录成功！用户信息已更新');
    
    // ⚠️ 不显示 Snackbar，避免 GlobalKey 冲突
    // 用户信息已经显示在右上角，足够了
    // 
    // 之前的问题：
    // 1. OAuth 回调后，UserController 可能被多次初始化
    // 2. 每次初始化都会触发 signedIn 事件
    // 3. 多次调用 Get.snackbar 导致 GlobalKey 冲突
    // 
    // 解决方案：
    // 1. 添加防抖逻辑（5秒内不重复处理）
    // 2. 完全移除 Snackbar（用户信息显示在页面上更好）
    
    debugPrint('💡 用户信息已显示在右上角');
  }

  /// 登出
  Future<void> signOut() async {
    try {
      debugPrint('🔓 开始退出登录...');
      
      // 1. 先清除本地用户状态
      currentUser.value = null;
      _lastLoginHandledTime = null; // 重置防抖时间
      debugPrint('🧹 已清除本地用户状态');
      
      // 2. 调用 Supabase 退出登录（清除 localStorage）
      await _supabaseService.signOut();
      debugPrint('✅ Supabase 退出登录成功');
      
      // 3. 清除 URL 中的 OAuth 回调参数（关键！）
      if (kIsWeb) {
        // 清除 URL fragment（#access_token=...）
        final cleanUrl = Uri.base.replace(fragment: '').toString();
        // ✅ 使用条件导入的辅助函数清理 URL
        cleanUrlParameters(cleanUrl);
        debugPrint('🧹 已清除 URL 中的 OAuth 参数');
      }
      
      // 4. ⚠️ 不显示 Snackbar，避免 MaterialLocalizations 错误
      // 退出登录的反馈已经足够了（右上角的"注册/登录"按钮会重新出现）
      debugPrint('✅ 退出登录完成');
      
      // 5. 检查当前路由，只有在非首页时才跳转
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            final navigator = main_app.navigatorKey.currentState;
            // ✅ 检查 navigator 是否有效且已挂载
            if (navigator != null && navigator.mounted) {
              // 获取当前路由（异步安全检查）
              final context = navigator.context;
              if (context.mounted) {
                final currentRoute = ModalRoute.of(context);
                final currentRouteName = currentRoute?.settings.name;
                
                debugPrint('📍 当前路由: $currentRouteName');
                
                // 只有在非首页时才跳转
                if (currentRouteName != '/home' && currentRouteName != null) {
                  navigator.pushNamedAndRemoveUntil('/home', (route) => false);
                  debugPrint('✅ 已跳转到首页并清理路由栈');
                } else {
                  debugPrint('ℹ️ 已在首页，无需跳转');
                }
              }
            }
          } catch (e) {
            debugPrint('❌ 检查路由失败: $e');
          }
        });
      });
      
    } catch (e) {
      debugPrint('❌ 登出失败: $e');
      Get.snackbar(
        '登出失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    // 取消认证状态监听
    _authSubscription?.cancel();
    debugPrint('🧹 UserController 已清理资源');
    super.onClose();
  }
}

