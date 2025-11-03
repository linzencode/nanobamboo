# Google OAuth 登录完整实现指南

> **版本**: 1.0  
> **适用场景**: Flutter Web + Supabase 后端  
> **测试状态**: ✅ 已验证可用  
> **最后更新**: 2025-11-03

---

## 📋 目录

- [技术架构](#技术架构)
- [核心原则](#核心原则)
- [依赖包选择](#依赖包选择)
- [完整实现步骤](#完整实现步骤)
- [关键代码实现](#关键代码实现)
- [配置清单](#配置清单)
- [踩过的坑](#踩过的坑)
- [测试验证](#测试验证)
- [最佳实践](#最佳实践)

---

## 🏗️ 技术架构

### 整体方案

**Flutter Web + Supabase OAuth (内置方式)**

```
用户点击 Google 登录
    ↓
Supabase.signInWithOAuth(Google)
    ↓
跳转到 Google 授权页面
    ↓
用户选择账号并授权
    ↓
Google 回调到: http://localhost:3000/home#access_token=xxx
    ↓
Supabase SDK 自动处理 token → 建立会话
    ↓
UserController 监听 auth state → 更新 UI
    ↓
完成登录（显示用户名和头像）
```

### 关键特性

- ✅ **服务器端 Token 交换**：通过 Supabase 后端处理，安全可靠
- ✅ **自动 PKCE 保护**：Supabase 自动启用 PKCE 防止 CSRF
- ✅ **Session 持久化**：自动保存到 localStorage，刷新页面保持登录
- ✅ **Token 自动刷新**：access_token 过期后自动刷新
- ✅ **完整用户信息**：获取用户名、邮箱、头像等完整 Google 账号信息
- ✅ **跨平台支持**：Web 和移动端使用相同的实现方式

---

## 🎯 核心原则

### ✅ 必须遵守的原则

1. **使用 Supabase 内置 OAuth（推荐）**
   - ✅ 使用 `supabase.auth.signInWithOAuth(OAuthProvider.google)`
   - ✅ 配置简单，只需 Supabase Dashboard 设置
   - ❌ 不使用 google_sign_in 插件（Web 端不稳定）

2. **OAuth 回调直接到首页**
   - ❌ 不要回调到专门的 `/auth/callback` 路由
   - ✅ 直接回调到 `/home` 避免 GetX 路由冲突
   - 原因：避免 GlobalKey 重复和路由处理复杂性

3. **依赖 Supabase SDK 自动处理**
   - ✅ 让 Supabase SDK 自动解析 URL 中的 token
   - ✅ 让 UserController 监听 auth state 变化
   - ❌ 不要手动从 URL 提取 token 并处理

4. **避免路由跳转操作**
   - ❌ 不要在 OAuth 回调后使用 `Get.offAllNamed()` 或 `Navigator.pop()`
   - ✅ 让页面保持在首页，只更新状态

5. **禁用 GetX 过渡动画**
   - ✅ 使用 `Transition.noTransition` 避免 GlobalKey 冲突
   - ✅ 设置 `transitionDuration: Duration.zero`

---

## 📦 依赖包选择

### ✅ 推荐使用（已验证）

```yaml
dependencies:
  # 后端服务和认证
  supabase_flutter: ^2.10.0
  
  # 环境变量管理
  flutter_dotenv: ^5.1.0
  
  # 状态管理（降级版本避免 Web GlobalKey 问题）
  get: ^4.6.5  # ⚠️ 不要升级到 4.6.6+
  
  # 本地化支持
  flutter_localizations:
    sdk: flutter
```

### ❌ 不推荐使用

| 包名 | 原因 | 替代方案 |
|-----|------|---------|
| `google_sign_in` | Web 端不稳定，跨域问题多，配置复杂 | Supabase OAuth |
| `firebase_auth` | 与 Supabase 冲突 | Supabase Auth |
| `flutter_appauth` (Web) | Web 不支持 | Supabase OAuth |

### ⚠️ 版本注意事项

1. **GetX 4.6.5**
   - 更高版本在 Flutter Web 有 GlobalKey 冲突问题
   - 必须固定在 4.6.5 或更低

2. **Supabase Flutter 2.10.0+**
   - 确保使用最新版本获得最佳 OAuth 支持
   - 自动处理 PKCE 和 token 刷新

---

## 🚀 完整实现步骤

### 步骤 1: 安装依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  flutter_localizations:
    sdk: flutter
  
  supabase_flutter: ^2.10.0
  flutter_dotenv: ^5.1.0
  get: ^4.6.5
  
  # 其他必需依赖
  ducafe_ui_core: ^1.0.6  # UI 组件库（可选）

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/
```

### 步骤 2: 配置环境变量

创建 `.env` 文件：

```.env
# Supabase 配置
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Google OAuth 配置（可选，用于其他场景）
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

创建 `env.example` 作为模板：

```.env
# Supabase 配置
# 从 Supabase Dashboard → Settings → API 获取
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Google OAuth 配置（可选）
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

### 步骤 3: Google Cloud Console 配置

#### 3.1 创建项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 记住项目 ID

#### 3.2 配置 OAuth 同意屏幕

1. 进入 **APIs & Services** → **OAuth consent screen**
2. 选择 **External**（外部用户）
3. 填写应用信息：
   - App name: `您的应用名称`
   - User support email: `您的邮箱`
   - Developer contact: `您的邮箱`
4. **Scopes**（权限范围）：
   - `email`
   - `profile`
   - `openid`
5. **Test users**（测试阶段必需）：
   - 添加您的 Google 账号
6. 保存并继续

#### 3.3 创建 OAuth 2.0 Client ID

1. 进入 **APIs & Services** → **Credentials**
2. 点击 **Create Credentials** → **OAuth client ID**
3. 选择 **Web application**
4. 配置：
   - Name: `Your App Name - Web`
   - Authorized JavaScript origins:
     ```
     http://localhost:3000
     https://yourdomain.com
     ```
   - Authorized redirect URIs:
     ```
     https://your-project.supabase.co/auth/v1/callback
     ```
     ⚠️ **重要**：使用 Supabase 提供的回调 URL，不是 localhost

5. 创建后获取：
   - **Client ID**（公开）
   - **Client Secret**（保密，配置在 Supabase）

### 步骤 4: Supabase Dashboard 配置

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择项目 → **Authentication** → **Providers**
3. 启用 **Google**：
   - **Enabled**: 打开开关
   - **Client ID (for OAuth)**: 从 Google Cloud Console 复制
   - **Client Secret (for OAuth)**: 从 Google Cloud Console 复制
   - **Authorize redirect URL**: 自动生成（`https://xxx.supabase.co/auth/v1/callback`）

4. 进入 **URL Configuration**：
   - **Site URL**: `http://localhost:3000`
   - **Redirect URLs**: 添加允许的回调地址
     ```
     http://localhost:3000/home
     http://localhost:3000/*
     https://yourdomain.com/home
     https://yourdomain.com/*
     ```

5. 保存配置

### 步骤 5: 创建环境变量服务

```dart
// lib/core/services/env_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 环境变量服务
class EnvService {
  // 单例模式
  factory EnvService() => _instance;
  EnvService._internal();
  static final EnvService _instance = EnvService._internal();

  /// 初始化环境变量
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  /// Supabase URL
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase 匿名密钥
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Google OAuth Web Client ID（可选）
  String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// 检查配置是否完整
  bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
```

### 步骤 6: 创建 Supabase 服务

```dart
// lib/core/services/supabase_service.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nanobamboo/core/services/env_service.dart';

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
        // 使用占位符配置，避免应用崩溃
        await Supabase.initialize(
          url: 'https://placeholder.supabase.co',
          anonKey: 'placeholder',
        );
      } else {
        await Supabase.initialize(
          url: envService.supabaseUrl,
          anonKey: envService.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,  // 启用 PKCE
            autoRefreshToken: true,            // 自动刷新 token
          ),
        );
        
        debugPrint('📱 Session 持久化: 已启用（Supabase 默认）');
        debugPrint('🔄 自动刷新 Token: 已启用');
        debugPrint('⏰ Access Token 有效期: 1 小时');
        debugPrint('🔑 Refresh Token 有效期: 7 天');
      }

      _client = Supabase.instance.client;
      debugPrint('✅ Supabase 初始化成功');

      // 监听认证状态变化
      _client.auth.onAuthStateChange.listen(
        (data) {
          final event = data.event;
          debugPrint('认证状态变化: $event');

          if (event == AuthChangeEvent.signedIn) {
            debugPrint('✅ 用户已登录: ${data.session?.user.email}');
          } else if (event == AuthChangeEvent.signedOut) {
            debugPrint('👋 用户已登出');
          } else if (event == AuthChangeEvent.tokenRefreshed) {
            debugPrint('🔄 Token 已刷新');
          }
        },
        onError: (Object error) {
          // 忽略 Refresh Token 失效的错误（退出登录后的正常情况）
          if (error is AuthException && 
              error.statusCode == '400' && 
              error.message.contains('Refresh Token')) {
            debugPrint('💡 检测到过期的 Refresh Token，已自动清除');
            return;
          }
          debugPrint('⚠️ 认证状态变化错误: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ Supabase 初始化失败: $e');
      rethrow;
    }

    return this;
  }

  /// Google OAuth 登录（Supabase 内置方式 - 推荐）
  /// 
  /// ✅ Web 平台：使用 Supabase 内置的 OAuth（推荐）
  /// - 服务器端处理 token 交换（安全）
  /// - PKCE 自动启用
  /// - 回调到首页，由 UserController 监听 auth state 变化
  Future<bool> signInWithGoogleOAuth() async {
    try {
      debugPrint('🚀 [Supabase OAuth] 开始 Google OAuth 流程...');
      
      // ✅ 先检查是否有现有 session，如果有就先清除
      // 避免因 localStorage 中残留的 session 导致直接登录（不跳转授权页）
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

  /// 登出
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ 用户已登出');
    } catch (e) {
      debugPrint('❌ 登出失败: $e');
      rethrow;
    }
  }
}
```

### 步骤 7: 创建认证控制器

```dart
// lib/modules/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/main.dart' as main_app;
import 'package:supabase_flutter/supabase_flutter.dart';

/// 认证控制器
class AuthController extends GetxController {
  /// Supabase 服务
  late final SupabaseService _supabaseService;

  /// Supabase 是否已正确配置
  bool _isSupabaseConfigured = false;

  /// 是否正在加载
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _supabaseService = Get.find<SupabaseService>();
      _isSupabaseConfigured = true;
      _supabaseService.client.auth.onAuthStateChange.listen((_) {});
    } catch (e) {
      debugPrint('⚠️ 无法获取 Supabase 服务: $e');
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

  /// Google OAuth 登录（Supabase 内置方式）
  /// 
  /// ✅ 使用 Supabase 内置的 OAuth 流程
  /// - 简单、安全、可靠
  /// - 服务器端处理 token 交换
  /// - PKCE 自动启用
  /// - 回调后由 UserController 监听 auth state 自动更新
  Future<void> signInWithGoogleOAuth() async {
    if (!_checkSupabaseConfig()) return;

    // ✅ 检查是否已经登录
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      debugPrint('💡 用户已登录: ${currentUser.email}，无需重复登录');
      
      // 直接关闭登录页，返回首页
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      }
      return;
    }

    try {
      isLoading.value = true;

      final success = await _supabaseService.signInWithGoogleOAuth();

      if (success) {
        debugPrint('✅ Google OAuth 请求成功，等待回调...');
        // ⚠️ 不要在这里关闭页面或跳转
        // OAuth 会跳转到浏览器，回调后会自动更新状态
      } else {
        Get.snackbar(
          '登录失败',
          '无法启动 Google 登录',
          snackPosition: SnackPosition.TOP,
        );
      }
    } on AuthException catch (e) {
      debugPrint('❌ Google OAuth 失败 (AuthException): ${e.message}');
      Get.snackbar(
        '登录失败',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('❌ Google OAuth 失败: $e');
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 步骤 8: 创建用户控制器（监听认证状态）

```dart
// lib/app/controllers/user_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 用户控制器
/// 
/// 负责：
/// - 监听 Supabase 认证状态变化
/// - 管理用户登录状态
/// - 提供用户信息（邮箱、名称、头像等）
class UserController extends GetxController {
  late final SupabaseService _supabaseService;
  
  /// 当前用户
  final Rx<User?> currentUser = Rx<User?>(null);
  
  /// 是否已登录
  bool get isLoggedIn => currentUser.value != null;
  
  /// 用户邮箱
  String? get email => currentUser.value?.email;
  
  /// 用户名称
  String? get userName => 
      currentUser.value?.userMetadata?['full_name'] ?? 
      currentUser.value?.userMetadata?['name'] ?? 
      email?.split('@')[0];
  
  /// 用户头像 URL
  String? get avatarUrl => 
      currentUser.value?.userMetadata?['avatar_url'] ?? 
      currentUser.value?.userMetadata?['picture'];

  @override
  void onInit() {
    super.onInit();
    
    try {
      _supabaseService = Get.find<SupabaseService>();
      
      // 初始化用户状态
      currentUser.value = _supabaseService.currentUser;
      debugPrint('🔍 初始用户状态: ${isLoggedIn ? "已登录" : "未登录"}');
      
      if (isLoggedIn) {
        debugPrint('✅ 用户已登录: $email');
      }

      // ✅ 监听认证状态变化
      _supabaseService.authStateChanges.listen((AuthState data) {
        final event = data.event;
        
        if (event == AuthChangeEvent.signedIn) {
          currentUser.value = data.session?.user;
          debugPrint('✅ 用户已登录: $email');
          debugPrint('   名称: $userName');
          debugPrint('   头像: $avatarUrl');
        } else if (event == AuthChangeEvent.signedOut) {
          currentUser.value = null;
          debugPrint('👋 用户已登出');
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          currentUser.value = data.session?.user;
          debugPrint('🔄 Token 已刷新');
        }
      });
    } catch (e) {
      debugPrint('⚠️ UserController 初始化失败: $e');
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      currentUser.value = null;
    } catch (e) {
      debugPrint('❌ 登出失败: $e');
      rethrow;
    }
  }
}
```

### 步骤 9: 在首页检测 OAuth 回调

```dart
// lib/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // 检测 OAuth 回调
    _checkOAuthCallback();
  }

  /// 检测 OAuth 回调成功
  void _checkOAuthCallback() {
    // 延迟执行，确保 Widget 树已构建完成
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final uri = Uri.base;
        
        // 检测 URL 中是否包含 OAuth 参数
        final hasOAuthParams = uri.fragment.contains('access_token') || 
                                uri.queryParameters.containsKey('code');
        
        if (hasOAuthParams) {
          debugPrint('✅ 检测到 OAuth 回调成功');
          
          // 显示成功提示（可选）
          // Get.snackbar(
          //   '登录成功！',
          //   '欢迎回来',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 2),
          //   backgroundColor: Colors.green.withValues(alpha: 0.9),
          //   colorText: Colors.white,
          // );
        }
      } catch (e) {
        debugPrint('检测 OAuth 回调失败: $e');
      }
    });
  }
}
```

### 步骤 10: 配置 main.dart

```dart
// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/controllers/user_controller.dart';
import 'package:nanobamboo/core/services/env_service.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/modules/auth/controllers/auth_controller.dart';
import 'package:nanobamboo/modules/auth/views/auth_view.dart';
import 'package:nanobamboo/modules/home/views/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ 全局 NavigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. 初始化环境变量
      try {
        await EnvService.init();
        debugPrint('✅ 环境变量加载成功');
      } catch (e) {
        debugPrint('⚠️ 环境变量加载失败: $e');
      }

      // 2. 初始化 Supabase
      try {
        await Get.putAsync(() => SupabaseService().init());
        debugPrint('✅ Supabase 服务初始化成功');
      } catch (e) {
        debugPrint('⚠️ Supabase 服务初始化失败: $e');
        Get.put(SupabaseService());
      }

      // 3. 延迟注册 UserController，确保 Supabase 已完全初始化
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          if (!Get.isRegistered<UserController>()) {
            Get.put(UserController(), permanent: true);
            debugPrint('✅ UserController 已注册');
          }
        } catch (e) {
          debugPrint('⚠️ UserController 注册失败: $e');
        }
      });

      runApp(const MyApp());
    },
    (error, stack) {
      // 过滤掉 Refresh Token 失效的错误
      if (error is AuthException && 
          error.statusCode == '400' && 
          error.message.contains('Refresh Token')) {
        debugPrint('💡 检测到过期的 Refresh Token（已忽略）');
        return;
      }
      
      debugPrint('全局错误捕获: $error');
      debugPrint('堆栈信息: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NanoBamboo',
      debugShowCheckedModeBanner: false,
      
      // ✅ 设置全局 navigatorKey
      navigatorKey: navigatorKey,

      // ✅ 本地化配置
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
```

---

## 💻 关键代码实现

### UI 层：登录按钮

```dart
// lib/modules/auth/views/auth_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/modules/auth/controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.signInWithGoogleOAuth,
            child: controller.isLoading.value
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login),
                      const SizedBox(width: 8),
                      const Text('使用 Google 继续'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
```

### Header：显示用户信息

```dart
// lib/modules/home/widgets/header_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/controllers/user_controller.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      if (userController.isLoggedIn) {
        return Row(
          children: [
            // 用户头像
            CircleAvatar(
              backgroundImage: userController.avatarUrl != null
                  ? NetworkImage(userController.avatarUrl!)
                  : null,
              child: userController.avatarUrl == null
                  ? Text(userController.userName?[0] ?? 'U')
                  : null,
            ),
            const SizedBox(width: 8),
            // 用户名
            Text(userController.userName ?? 'User'),
            const SizedBox(width: 16),
            // 登出按钮
            TextButton(
              onPressed: () => userController.signOut(),
              child: const Text('登出'),
            ),
          ],
        );
      } else {
        return ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/auth');
          },
          child: const Text('注册/登录'),
        );
      }
    });
  }
}
```

---

## ✅ 配置清单

### 环境变量 (.env)

- [ ] `SUPABASE_URL` 已配置
- [ ] `SUPABASE_ANON_KEY` 已配置
- [ ] `.env` 文件已添加到 `.gitignore`

### Google Cloud Console

- [ ] 项目已创建
- [ ] OAuth 同意屏幕已配置
- [ ] 测试用户已添加
- [ ] Web OAuth Client ID 已创建
- [ ] Authorized JavaScript origins 已添加 `http://localhost:3000`
- [ ] Authorized redirect URIs 已添加 Supabase 回调地址

### Supabase Dashboard

- [ ] Google Provider 已启用
- [ ] Client ID 和 Secret 已配置
- [ ] Redirect URLs 已添加 `http://localhost:3000/home`
- [ ] Site URL 设置为 `http://localhost:3000`

### pubspec.yaml

- [ ] `supabase_flutter: ^2.10.0`
- [ ] `flutter_dotenv: ^5.1.0`
- [ ] `get: ^4.6.5`（不要升级）
- [ ] `flutter_localizations` 已添加

### 代码实现

- [ ] EnvService 已创建
- [ ] SupabaseService 已创建
- [ ] AuthController 已创建
- [ ] UserController 已创建并监听 auth state
- [ ] HomeController 已添加 OAuth 回调检测
- [ ] main.dart 已正确配置
- [ ] AuthController 在路由跳转时注册

---

## 🚨 踩过的坑

### 坑 1: GlobalKey 冲突错误

**问题**：
```
Multiple widgets used the same GlobalKey.
```

**原因**：
- 使用 GetX 路由
- OAuth 回调到专门的 `/auth/callback` 路由
- GetX 在处理外部 URL 变化时创建重复的 Navigator 实例

**解决方案**：
- ✅ 改用 Flutter 原生 MaterialApp + onGenerateRoute
- ✅ OAuth 直接回调到 `/home` 而不是专门的回调路由

### 坑 2: AuthController not found

**问题**：
```
"AuthController" not found. You need to call "Get.put(AuthController())"
```

**原因**：
- AuthView 使用了 `GetView<AuthController>`
- 但 AuthController 没有被注册到 GetX

**解决方案**：
```dart
// 在路由跳转时注册
case '/auth':
  if (!Get.isRegistered<AuthController>()) {
    Get.put(AuthController());
  }
  return MaterialPageRoute(builder: (_) => const AuthView());
```

### 坑 3: OAuth 回调后 context 为 null

**问题**：
```
Null check operator used on a null value
at Get.snackbar()
```

**原因**：
- OAuth 回调处理时 MaterialApp 还未完全初始化
- Get.context 为 null

**解决方案**：
- ✅ 延迟 500ms 后再显示 Snackbar
- ✅ 或使用 Flutter 原生的 ScaffoldMessenger

### 坑 4: 重复登录导致不跳转授权页

**问题**：
- 已登录用户点击 Google 登录，直接成功但没有跳转到 Google 授权页

**原因**：
- localStorage 中有残留的 Supabase session
- Supabase SDK 检测到有效 session 就不跳转

**解决方案**：
```dart
// 在 signInWithGoogleOAuth 前先清除现有 session
final currentSession = _client.auth.currentSession;
if (currentSession != null) {
  await _client.auth.signOut();
}
```

### 坑 5: google_sign_in Web 端不稳定

**问题**：
- 使用 google_sign_in 插件在 Web 端经常出现跨域问题
- 弹窗被浏览器拦截
- 配置复杂

**解决方案**：
- ✅ 改用 Supabase 内置 OAuth
- ✅ 配置简单，只需 Supabase Dashboard 设置
- ✅ 服务器端处理，更安全

### 坑 6: 用户信息获取不完整

**问题**：
- 登录后无法获取用户名和头像

**原因**：
- Google OAuth scopes 配置不正确

**解决方案**：
- ✅ 在 Google Cloud Console 的 OAuth 同意屏幕添加 scopes：
  - `email`
  - `profile`
  - `openid`
- ✅ Supabase 会自动请求这些权限

---

## 🧪 测试验证

### 本地测试步骤

1. **启动应用**
   ```bash
   flutter run -d chrome --web-port=3000
   ```

2. **测试 Google 登录**
   - 打开 http://localhost:3000
   - 点击"注册/登录"
   - 点击"使用 Google 继续"

3. **预期结果**
   - ✅ 浏览器跳转到 Google 账号选择页面
   - ✅ 选择账号并授权后回调到 `http://localhost:3000/home#access_token=...`
   - ✅ Header 显示用户头像和名称
   - ✅ 控制台输出：`✅ 用户已登录: user@gmail.com`
   - ✅ 无任何 GlobalKey 错误
   - ✅ 无任何红色错误

### 调试技巧

1. **查看 Supabase 日志**
   - Supabase Dashboard → Logs → Auth Logs
   - 查看 OAuth 流程是否成功

2. **查看浏览器控制台**
   ```bash
   # 开启 Supabase 调试日志
   localStorage.setItem('supabase.debug', 'true')
   ```

3. **查看 localStorage**
   ```javascript
   // 浏览器控制台
   console.log(localStorage.getItem('sb-xxx-auth-token'))
   ```

4. **清除缓存重新测试**
   ```dart
   // 代码中清除
   await Supabase.instance.client.auth.signOut();
   
   // 或手动清除
   localStorage.clear()
   ```

---

## 🎯 最佳实践

### 1. 安全性

- ❌ 不要在前端代码中硬编码 Client Secret
- ✅ Client Secret 只配置在 Supabase Dashboard
- ✅ 使用 PKCE 保护授权流程（Supabase 自动启用）
- ✅ 生产环境配置正确的 Redirect URLs（不使用 wildcard）

### 2. 用户体验

- ✅ OAuth 回调后显示欢迎提示
- ✅ 登录按钮添加 loading 状态
- ✅ 失败时显示友好的错误信息
- ✅ 已登录时禁用登录按钮或自动关闭登录页

### 3. 错误处理

```dart
Future<void> signInWithGoogleOAuth() async {
  try {
    isLoading.value = true;
    await _supabaseService.signInWithGoogleOAuth();
  } on AuthException catch (e) {
    // Supabase 认证错误
    Get.snackbar('登录失败', e.message);
  } catch (e) {
    // 其他错误
    Get.snackbar('登录失败', '请稍后重试');
  } finally {
    isLoading.value = false;
  }
}
```

### 4. 状态管理

- ✅ 使用 UserController 集中管理用户状态
- ✅ 监听 Supabase auth state 变化自动更新
- ✅ 避免手动调用 setState 或 update
- ✅ 使用 Obx 响应状态变化

### 5. 生产环境配置

**更新 Redirect URLs**：
```
https://yourdomain.com/home
https://yourdomain.com/*
```

**更新 Google OAuth App**：
- Authorized JavaScript origins: `https://yourdomain.com`
- Authorized redirect URIs: `https://your-project.supabase.co/auth/v1/callback`

**更新代码**：
```dart
redirectTo: kIsWeb 
    ? (kReleaseMode 
        ? 'https://yourdomain.com/home' 
        : 'http://localhost:3000/home')
    : 'io.supabase.yourapp://login-callback/',
```

---

## 📚 参考资源

### 官方文档

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [OAuth 2.0 PKCE](https://oauth.net/2/pkce/)

### 相关项目文档

- [GitHub OAuth 实现指南](./GITHUB_OAUTH_IMPLEMENTATION_GUIDE.md)
- [Supabase 配置指南](../setup/SUPABASE_SETUP.md)
- [Google OAuth 快速开始](./GOOGLE_OAUTH_QUICKSTART.md)
- [Google OAuth 测试指南](./GOOGLE_OAUTH_TEST_GUIDE.md)

---

## 🎉 总结

### 核心要点

1. ✅ **使用 Supabase 内置 OAuth**（最简单可靠）
2. ✅ **回调到首页避免路由冲突**（不要回调到 /auth/callback）
3. ✅ **依赖 auth state 监听更新 UI**（不要手动处理 token）
4. ✅ **使用 Flutter 原生路由**（避免 GetX 的 GlobalKey 冲突）
5. ✅ **在路由跳转时注册 AuthController**（避免 not found 错误）

### 实施清单

- [ ] 依赖包已安装
- [ ] 环境变量已配置
- [ ] Google Cloud Console 已配置
- [ ] Supabase Dashboard 已配置
- [ ] 代码已实现
- [ ] 本地测试通过
- [ ] 生产环境配置已更新

### 与 GitHub OAuth 的区别

| 特性 | Google OAuth | GitHub OAuth |
|------|--------------|--------------|
| 配置复杂度 | 较复杂（需要 OAuth 同意屏幕） | 较简单 |
| 测试用户 | 需要添加测试用户 | 不需要 |
| 用户信息 | 更丰富（名称、头像等） | 基本信息 |
| 实现方式 | 完全相同 | 完全相同 |
| Supabase 配置 | 完全相同 | 完全相同 |

---

**文档版本**: 1.0  
**测试环境**: Flutter 3.2.0+ / Supabase 2.10.0 / GetX 4.6.5  
**最后更新**: 2025-11-03  
**维护者**: NanoBamboo Team

如有问题，请参考项目中的其他文档或提交 Issue。

