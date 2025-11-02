# GitHub OAuth 登录完整实现指南

> **版本**: 1.0  
> **适用场景**: Flutter Web + Supabase 后端  
> **测试状态**: ✅ 已验证可用  
> **最后更新**: 2025-11-02

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

**Flutter Web + Supabase OAuth + PKCE**

```
用户点击登录
    ↓
Supabase.signInWithOAuth(GitHub)
    ↓
跳转到 GitHub 授权页面
    ↓
用户授权
    ↓
GitHub 回调到: http://localhost:3000/home#access_token=xxx
    ↓
Supabase SDK 自动处理 token → 建立会话
    ↓
UserController 监听 auth state → 更新 UI
    ↓
完成登录
```

### 关键特性

- ✅ **服务器端 Token 交换**：通过 Supabase 后端处理，安全可靠
- ✅ **自动 PKCE 保护**：Supabase 自动启用 PKCE 防止 CSRF
- ✅ **Session 持久化**：自动保存到 localStorage，刷新页面保持登录
- ✅ **Token 自动刷新**：access_token 过期后自动刷新
- ✅ **跨平台支持**：Web 和移动端使用不同但兼容的方案

---

## 🎯 核心原则

### ✅ 必须遵守的原则

1. **OAuth 回调直接到首页**
   - ❌ 不要回调到专门的 `/auth/callback` 路由
   - ✅ 直接回调到 `/home` 避免 GetX 路由冲突
   - 原因：GetX 在处理外部 URL 变化时可能创建重复的 Navigator 实例

2. **依赖 Supabase SDK 自动处理**
   - ✅ 让 Supabase SDK 自动解析 URL 中的 token
   - ✅ 让 UserController 监听 auth state 变化
   - ❌ 不要手动从 URL 提取 token 并处理

3. **避免路由跳转操作**
   - ❌ 不要在 OAuth 回调后使用 `Get.offAllNamed()` 或 `Get.back()`
   - ✅ 让页面保持在首页，只更新状态

4. **禁用 GetX 过渡动画**
   - ✅ 使用 `Transition.noTransition` 避免 GlobalKey 冲突
   - ✅ 设置 `transitionDuration: Duration.zero`

---

## 📦 依赖包选择

### ✅ 推荐使用（已验证）

```yaml
dependencies:
  # 后端服务和认证
  supabase_flutter: ^2.10.0
  
  # Web 平台 OAuth（Flutter Web 必需）
  flutter_web_auth_2: ^3.1.2
  
  # 移动平台 OAuth（iOS/Android 推荐）
  flutter_appauth: ^6.0.5
  
  # PKCE 加密支持
  crypto: ^3.0.3
  
  # HTTP 请求（token 交换）
  http: ^1.2.0
  
  # 环境变量管理
  flutter_dotenv: ^5.1.0
  
  # URL 启动器（OAuth 回调）
  url_launcher: ^6.3.1
  
  # 状态管理（降级版本避免 Web GlobalKey 问题）
  get: ^4.6.5  # ⚠️ 不要升级到 4.6.6+
```

### ❌ 不推荐使用

| 包名 | 原因 | 替代方案 |
|-----|------|---------|
| `google_sign_in` | Web 端不稳定，跨域问题多 | Supabase OAuth |
| `firebase_auth` | 与 Supabase 冲突 | Supabase Auth |
| `flutter_appauth` (Web) | Web 不支持 | flutter_web_auth_2 |
| `uni_links` | 已废弃 | url_launcher |
| `app_links` | 移动端专用 | Web 用 flutter_web_auth_2 |

### ⚠️ 版本注意事项

1. **GetX 4.6.5**
   - 更高版本在 Flutter Web 有 GlobalKey 冲突问题
   - 必须固定在 4.6.5 或更低

2. **flutter_web_auth_2**
   - 必须是 v3.1.2+，旧版本有回调问题
   - 是 `flutter_web_auth` 的维护版本（使用新版）

---

## 🚀 完整实现步骤

### 步骤 1: 安装依赖

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.0
  flutter_web_auth_2: ^3.1.2
  flutter_appauth: ^6.0.5
  crypto: ^3.0.3
  http: ^1.2.0
  flutter_dotenv: ^5.1.0
  url_launcher: ^6.3.1
  get: ^4.6.5

flutter:
  assets:
    - .env
```

### 步骤 2: 配置环境变量

创建 `.env` 文件：

```.env
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# GitHub OAuth Client ID（从 GitHub Developer Settings 获取）
GITHUB_CLIENT_ID=your_github_client_id
```

创建 `env.example` 作为模板：

```.env
# Supabase 配置
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 步骤 3: Supabase Dashboard 配置

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择项目 → **Authentication** → **Providers**
3. 启用 **GitHub**：
   - Client ID: `从 GitHub 获取`
   - Client Secret: `从 GitHub 获取`
   - Redirect URL: 自动生成（类似 `https://xxx.supabase.co/auth/v1/callback`）

4. 进入 **URL Configuration**：
   - 添加 Site URL: `http://localhost:3000`
   - 添加 Redirect URLs:
     ```
     http://localhost:3000/home
     http://localhost:3000/*
     ```

### 步骤 4: GitHub OAuth App 配置

1. 访问 [GitHub Developer Settings](https://github.com/settings/developers)
2. 创建 **New OAuth App**：
   - Application name: `Your App Name`
   - Homepage URL: `http://localhost:3000`
   - Authorization callback URL: `https://your-project.supabase.co/auth/v1/callback`
   - ⚠️ 使用 Supabase 提供的回调 URL（不是 localhost）

3. 创建后获取：
   - Client ID（公开，可放在前端）
   - Client Secret（保密，配置在 Supabase Dashboard）

### 步骤 5: 创建环境变量服务

```dart
// lib/core/services/env_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  /// Supabase URL
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase Anon Key
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// GitHub Client ID
  String get githubClientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';

  /// 是否已配置
  bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
```

### 步骤 6: 创建 Supabase 服务

```dart
// lib/core/services/supabase_service.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nanobamboo/core/services/env_service.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<SupabaseService> init() async {
    final envService = EnvService();

    await Supabase.initialize(
      url: envService.supabaseUrl,
      anonKey: envService.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );

    _client = Supabase.instance.client;
    return this;
  }

  /// GitHub OAuth 登录（Web 端推荐）
  Future<bool> signInWithGitHub() async {
    try {
      // ✅ 先清除现有 session（避免直接登录不跳转授权页）
      final currentSession = _client.auth.currentSession;
      if (currentSession != null) {
        await _client.auth.signOut();
      }
      
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.github,
        // ⚠️ 关键：回调到首页而不是 /auth/callback
        redirectTo: kIsWeb 
            ? 'http://localhost:3000/home' 
            : 'io.supabase.yourapp://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      return response;
    } catch (e) {
      debugPrint('GitHub OAuth 失败: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

### 步骤 7: 创建认证控制器

```dart
// lib/modules/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';

class AuthController extends GetxController {
  late final SupabaseService _supabaseService;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _supabaseService = Get.find<SupabaseService>();
  }

  Future<void> signInWithGitHub() async {
    try {
      isLoading.value = true;

      final success = await _supabaseService.signInWithGitHub();

      if (success) {
        debugPrint('GitHub OAuth 请求成功，等待回调...');
        // ⚠️ 不要在这里关闭页面或跳转
        // OAuth 会重定向，UserController 会处理登录后的状态
      }
    } catch (e) {
      debugPrint('GitHub 登录失败: $e');
      Get.snackbar('登录失败', '请稍后重试');
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

class UserController extends GetxController {
  late final SupabaseService _supabaseService;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _supabaseService = Get.find<SupabaseService>();
    
    // 初始化用户状态
    currentUser.value = _supabaseService.currentUser;
    isAuthenticated.value = currentUser.value != null;

    // ✅ 监听认证状态变化
    _supabaseService.authStateChanges.listen((AuthState data) {
      final event = data.event;
      
      if (event == AuthChangeEvent.signedIn) {
        currentUser.value = data.session?.user;
        isAuthenticated.value = true;
        debugPrint('✅ 用户已登录: ${currentUser.value?.email}');
      } else if (event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
        isAuthenticated.value = false;
        debugPrint('👋 用户已登出');
      }
    });
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
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final uri = Uri.base;
        final hasOAuthParams = uri.fragment.contains('access_token') || 
                                uri.queryParameters.containsKey('code');
        
        if (hasOAuthParams) {
          debugPrint('✅ 检测到 OAuth 回调成功');
          
          // 显示成功提示
          Get.snackbar(
            '登录成功！',
            '欢迎回来',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
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
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/app/controllers/user_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量
  await dotenv.load(fileName: '.env');

  // 初始化 Supabase
  final supabaseService = await Get.putAsync(() => SupabaseService().init());

  // 注册全局服务
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NanoBamboo',
      
      // ⚠️ 关键：禁用过渡动画避免 GlobalKey 冲突
      defaultTransition: Transition.noTransition,
      transitionDuration: const Duration(milliseconds: 0),
      
      initialRoute: '/home',
      getPages: AppPages.routes,
    );
  }
}
```

---

## 💻 关键代码实现

### OAuth 服务（跨平台）

如果需要支持移动端，可以创建 `OAuthService` 使用 `flutter_appauth`：

```dart
// lib/core/services/oauth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class OAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  /// GitHub 登录（自动选择平台）
  Future<AuthorizationTokenResponse?> signInWithGitHub() async {
    if (kIsWeb) {
      return await _signInWithGitHubWeb();
    } else {
      return await _signInWithGitHubMobile();
    }
  }

  /// Web 平台 GitHub 登录
  Future<AuthorizationTokenResponse?> _signInWithGitHubWeb() async {
    // 1. 生成 PKCE 参数
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateState();

    // 2. 构建授权 URL
    final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': 'YOUR_CLIENT_ID',
      'redirect_uri': 'http://localhost:3000/auth/callback',
      'scope': 'read:user user:email',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    // 3. 打开授权页面
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'http',
    );

    // 4. 解析回调
    final callbackUri = Uri.parse(result);
    final code = callbackUri.queryParameters['code'];
    
    if (code == null) return null;

    // 5. 交换 access_token
    final tokenResponse = await http.post(
      Uri.parse('https://github.com/login/oauth/access_token'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': 'YOUR_CLIENT_ID',
        'code': code,
        'code_verifier': codeVerifier,
      },
    );

    final json = jsonDecode(tokenResponse.body);
    return AuthorizationTokenResponse(
      json['access_token'],
      null,
      null,
      null,
      json['token_type'],
      null,
      null,
      null,
    );
  }

  /// 移动平台 GitHub 登录
  Future<AuthorizationTokenResponse?> _signInWithGitHubMobile() async {
    return await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        'YOUR_CLIENT_ID',
        'io.supabase.yourapp://login-callback/',
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://github.com/login/oauth/authorize',
          tokenEndpoint: 'https://github.com/login/oauth/access_token',
        ),
        scopes: <String>['read:user', 'user:email'],
      ),
    );
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }
}
```

---

## ✅ 配置清单

### 环境变量 (.env)

- [ ] `SUPABASE_URL` 已配置
- [ ] `SUPABASE_ANON_KEY` 已配置
- [ ] `GITHUB_CLIENT_ID` 已配置（移动端需要）
- [ ] `.env` 文件已添加到 `.gitignore`

### Supabase Dashboard

- [ ] GitHub Provider 已启用
- [ ] Client ID 和 Secret 已配置
- [ ] Redirect URLs 已添加 `http://localhost:3000/home`
- [ ] Site URL 设置为 `http://localhost:3000`

### GitHub OAuth App

- [ ] OAuth App 已创建
- [ ] Callback URL 设置为 Supabase 的回调地址
- [ ] Client Secret 已保密（只配置在 Supabase）

### pubspec.yaml

- [ ] `supabase_flutter: ^2.10.0`
- [ ] `flutter_web_auth_2: ^3.1.2`
- [ ] `flutter_appauth: ^6.0.5`
- [ ] `crypto: ^3.0.3`
- [ ] `http: ^1.2.0`
- [ ] `flutter_dotenv: ^5.1.0`
- [ ] `get: ^4.6.5`（不要升级）

### 代码实现

- [ ] EnvService 已创建
- [ ] SupabaseService 已创建
- [ ] AuthController 已创建
- [ ] UserController 已创建并监听 auth state
- [ ] HomeController 已添加 OAuth 回调检测
- [ ] GetMaterialApp 已禁用过渡动画

---

## 🚨 踩过的坑

### 坑 1: GlobalKey 冲突错误

**问题**：
```
The following assertion was thrown while finalizing the widget tree:
Multiple widgets used the same GlobalKey.
```

**原因**：
- OAuth 回调到 `/auth/callback` 路由
- GetX 在处理外部 URL 变化时创建了重复的 Navigator 实例

**解决方案**：
- ✅ OAuth 直接回调到 `/home` 而不是专门的回调路由
- ✅ 禁用 GetX 过渡动画：`defaultTransition: Transition.noTransition`

### 坑 2: OAuth 回调后 context 为 null

**问题**：
```
Null check operator used on a null value
at Get.snackbar()
```

**原因**：
- 在 OAuth 回调处理时 GetMaterialApp 还未完全初始化

**解决方案**：
- ✅ 延迟 500ms 后再显示 Snackbar
- ✅ 或者使用 Flutter 原生的 ScaffoldMessenger

### 坑 3: 重复登录导致不跳转授权页

**问题**：
- 用户已登录时点击 GitHub 登录，直接成功但没有跳转到 GitHub 授权页

**原因**：
- localStorage 中有残留的 Supabase session
- Supabase SDK 检测到有效 session 就不跳转了

**解决方案**：
```dart
// 在 signInWithGitHub 前先清除现有 session
final currentSession = _client.auth.currentSession;
if (currentSession != null) {
  await _client.auth.signOut();
}
```

### 坑 4: flutter_web_auth 回调失败

**问题**：
- 使用旧版 `flutter_web_auth` 回调到自定义 scheme 失败

**解决方案**：
- ✅ 改用 `flutter_web_auth_2` (维护版本)
- ✅ Web 端使用 `http` scheme：`callbackUrlScheme: 'http'`

### 坑 5: Token 交换失败 (400 Bad Request)

**问题**：
- 使用 GitHub OAuth 授权码交换 token 时返回 400

**原因**：
- 缺少 `Content-Type` header
- PKCE 参数错误

**解决方案**：
```dart
final tokenResponse = await http.post(
  Uri.parse('https://github.com/login/oauth/access_token'),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',  // 必需
  },
  body: {
    'client_id': clientId,
    'code': code,
    'code_verifier': codeVerifier,  // PKCE 必需
    'redirect_uri': redirectUrl,
  },
);
```

### 坑 6: GetX 版本升级导致的问题

**问题**：
- 升级 GetX 到 4.6.6+ 后出现 GlobalKey 冲突

**解决方案**：
```yaml
# pubspec.yaml
dependencies:
  get: ^4.6.5  # 固定版本，不要升级
```

---

## 🧪 测试验证

### 本地测试步骤

1. **启动应用**
   ```bash
   flutter run -d chrome --web-port=3000
   ```

2. **测试 GitHub 登录**
   - 打开 http://localhost:3000
   - 点击"注册/登录"
   - 选择"社交登录"标签
   - 点击"使用 GitHub 继续"

3. **预期结果**
   - ✅ 浏览器打开 GitHub 授权页面
   - ✅ 授权后回调到 `http://localhost:3000/home#access_token=...`
   - ✅ 首页显示绿色成功提示："登录成功！"
   - ✅ Header 显示用户头像和名称
   - ✅ 控制台输出：`✅ 用户已登录: user@email.com`
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
   
   // 或手动清除 localStorage
   localStorage.clear()
   ```

---

## 🎯 最佳实践

### 1. 安全性

- ❌ 不要在前端代码中硬编码 Client Secret
- ✅ Client Secret 只配置在 Supabase Dashboard
- ✅ 使用 PKCE 保护授权流程（Supabase 自动启用）
- ✅ 在生产环境配置正确的 Redirect URLs（不使用 wildcard）

### 2. 用户体验

- ✅ OAuth 回调后显示欢迎提示
- ✅ 登录按钮添加 loading 状态
- ✅ 失败时显示友好的错误信息
- ✅ 已登录时禁用登录按钮或自动跳转

### 3. 错误处理

```dart
Future<void> signInWithGitHub() async {
  try {
    isLoading.value = true;
    await _supabaseService.signInWithGitHub();
  } on AuthException catch (e) {
    // Supabase 认证错误
    Get.snackbar('登录失败', e.message);
  } on PlatformException catch (e) {
    // 平台错误（如用户取消）
    debugPrint('用户取消登录: $e');
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
- ✅ 使用 Obx 或 GetBuilder 响应状态变化

### 5. 生产环境配置

**更新 Redirect URLs**：
```
https://yourdomain.com/home
https://yourdomain.com/*
```

**更新 GitHub OAuth App**：
- Homepage URL: `https://yourdomain.com`
- Callback URL: `https://your-project.supabase.co/auth/v1/callback`

**更新环境变量**：
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
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [OAuth 2.0 PKCE](https://oauth.net/2/pkce/)

### 依赖包文档

- [flutter_web_auth_2](https://pub.dev/packages/flutter_web_auth_2)
- [flutter_appauth](https://pub.dev/packages/flutter_appauth)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter)
- [GetX](https://pub.dev/packages/get)

### 相关项目文档

- [OAuth 最终解决方案](./OAUTH_FINAL_SOLUTION.md)
- [Supabase 配置指南](../setup/SUPABASE_SETUP.md)
- [GlobalKey 修复指南](../fixes/GLOBALKEY_ULTIMATE_FIX.md)

---

## 🎉 总结

### 核心要点

1. ✅ **使用 Supabase 内置 OAuth**（Web 端最简单可靠）
2. ✅ **回调到首页避免路由冲突**（不要回调到 /auth/callback）
3. ✅ **依赖 auth state 监听更新 UI**（不要手动处理 token）
4. ✅ **禁用 GetX 过渡动画**（避免 GlobalKey 冲突）
5. ✅ **固定 GetX 4.6.5 版本**（不要升级）

### 实施清单

- [ ] 依赖包已安装
- [ ] 环境变量已配置
- [ ] Supabase Dashboard 已配置
- [ ] GitHub OAuth App 已创建
- [ ] 代码已实现
- [ ] 本地测试通过
- [ ] 生产环境配置已更新

---

**文档版本**: 1.0  
**测试环境**: Flutter 3.2.0+ / Supabase 2.10.0 / GetX 4.6.5  
**最后更新**: 2025-11-02  
**维护者**: NanoBamboo Team

如有问题，请参考项目中的其他文档或提交 Issue。

