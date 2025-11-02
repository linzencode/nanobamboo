import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/constants/app_constants.dart';
import 'package:nanobamboo/app/controllers/user_controller.dart';
import 'package:nanobamboo/app/theme/app_theme.dart';
import 'package:nanobamboo/app/theme/theme_controller.dart';
import 'package:nanobamboo/core/services/env_service.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/modules/auth/controllers/auth_controller.dart';
import 'package:nanobamboo/modules/auth/views/auth_view.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/modules/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ 全局 NavigatorKey，用于在没有 BuildContext 的地方访问 Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 初始化环境变量
      try {
        await EnvService.init();
        debugPrint('环境变量加载成功');
      } catch (e) {
        debugPrint('环境变量加载失败: $e');
        debugPrint('提示：如果是首次运行，请创建 .env 文件并配置 Supabase 信息');
      }

      // 初始化 Supabase（确保始终注册服务，即使初始化失败）
      try {
        await Get.putAsync(() => SupabaseService().init());
        debugPrint('✅ Supabase 服务初始化成功');
      } catch (e) {
        debugPrint('⚠️ Supabase 服务初始化失败: $e');
        debugPrint('💡 应用将继续运行，但登录功能将不可用');
        debugPrint('📝 请检查 .env 文件配置是否正确');
        // 即使初始化失败，也注册一个空服务，避免应用崩溃
        Get.put(SupabaseService());
      }

      // 全局注册 ThemeController
      Get.put(ThemeController());
      
      // ✅ 全局注册 HomeController（永久单例，避免 GlobalKey 冲突）
      Get.put(HomeController(), permanent: true);
      debugPrint('✅ HomeController 已注册（permanent）');

      // ✅ 延迟注册 UserController，确保 Supabase 已完全初始化
      // 给 Supabase 时间处理 OAuth 回调
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          if (!Get.isRegistered<UserController>()) {
            Get.put(UserController(), permanent: true);
            debugPrint('✅ UserController 已注册（permanent）');
          } else {
            debugPrint('ℹ️ UserController 已存在，跳过注册');
          }
        } catch (e) {
          debugPrint('⚠️ UserController 注册失败: $e');
        }
      });

      runApp(const MyApp());
    },
    (error, stack) {
      // 过滤掉 Refresh Token 失效的错误（这是退出登录后的正常情况）
      if (error is AuthException && 
          error.statusCode == '400' && 
          error.message.contains('Refresh Token')) {
        debugPrint('💡 检测到过期的 Refresh Token（已忽略，这是退出登录后的正常情况）');
        return;
      }
      
      // 其他错误仍然记录
      debugPrint('全局错误捕获: $error');
      debugPrint('堆栈信息: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取 ThemeController 但不监听变化
    final themeController = Get.find<ThemeController>();
    
    // ✅ 使用 Flutter 原生的 MaterialApp，不使用 GetX 路由
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // ✅ 设置全局 navigatorKey
      navigatorKey: navigatorKey,

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,

      // ✅ 本地化配置（修复 MaterialLocalizations 错误）
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ✅ 使用 onGenerateRoute 实现简单路由
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomeView(),
              settings: settings,
            );
          case '/auth':
            // ✅ 在跳转到登录页面时注册 AuthController
            if (!Get.isRegistered<AuthController>()) {
              Get.put(AuthController());
              debugPrint('✅ AuthController 已注册');
            }
            return MaterialPageRoute(
              builder: (_) => const AuthView(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomeView(),
              settings: settings,
            );
        }
      },
    );
  }
}

