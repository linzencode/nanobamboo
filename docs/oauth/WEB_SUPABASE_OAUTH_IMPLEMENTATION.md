# Web 端 Supabase OAuth 实现说明

## 📋 概述

根据用户建议和 Supabase 官方文档，我们采用了**跨平台双轨制 OAuth 方案**：

- **Web 端**：使用 Supabase 内置的 `signInWithOAuth()` 方法（推荐）
- **移动端**：使用 `flutter_appauth` + PKCE 标准流程

---

## 🎯 为什么 Web 端使用 Supabase OAuth？

### 问题背景

之前我们尝试在 Web 端使用 `flutter_appauth` + `flutter_web_auth_2` 实现 OAuth 2.0 + PKCE，但遇到了以下问题：

1. **GitHub 不支持 PKCE（Web）**：GitHub OAuth 的 token 交换需要 **Client Secret**，而前端无法安全存储
2. **复杂度高**：需要前端手动处理授权码、PKCE 参数、token 交换
3. **GlobalKey 冲突**：Flutter Web 的路由回调容易产生 Navigator 冲突

### Supabase OAuth 的优势 ✅

| 特性 | Supabase OAuth | flutter_appauth |
|------|----------------|-----------------|
| **Web 支持** | ✅ 原生支持 | ⚠️ 需要额外适配 |
| **Client Secret** | ✅ 服务器端处理 | ❌ 前端无法安全存储 |
| **PKCE** | ✅ 自动启用 | ✅ 手动配置 |
| **Session 管理** | ✅ 自动管理 | ⚠️ 需手动创建 |
| **实现复杂度** | 🟢 简单 | 🟡 中等 |
| **安全性** | 🟢 高（服务器端） | 🟢 高（PKCE） |

---

## 🏗️ 架构设计

### Web 平台流程

```
用户点击"GitHub 登录"
    ↓
AuthController.signInWithGitHub()
    ↓
SupabaseService.signInWithGitHub()
    ↓
Supabase SDK 打开 GitHub OAuth 页面
    ↓
用户授权
    ↓
GitHub 重定向到 Supabase 服务器
    ↓
Supabase 服务器交换 token（使用 Client Secret）
    ↓
Supabase 重定向回应用（http://localhost:3000/home）
    ↓
UserController 监听到 auth state 变化
    ↓
UI 自动更新（显示用户信息）
```

### 移动平台流程

```
用户点击"GitHub 登录"
    ↓
AuthController.signInWithGitHub()
    ↓
OAuthService.signInWithGitHub()
    ↓
flutter_appauth 打开 GitHub OAuth 页面（PKCE）
    ↓
用户授权
    ↓
GitHub 重定向回应用（Custom URL Scheme）
    ↓
flutter_appauth 自动交换 token（使用 code_verifier）
    ↓
OAuthService 返回 access_token
    ↓
SupabaseService.signInWithGitHubToken()
    ↓
Supabase 创建 session
    ↓
AuthController 显示成功提示并关闭登录页
    ↓
UI 自动更新
```

---

## 📝 代码修改

### 1. SupabaseService

#### 修改 `signInWithGitHub()` 方法

```dart
/// GitHub OAuth 登录（Web 端推荐）
Future<bool> signInWithGitHub() async {
  try {
    debugPrint('🚀 [Web] 开始 Supabase GitHub OAuth 流程...');
    
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
```

#### 保留 `signInWithGitHubToken()` 方法（移动端使用）

```dart
/// GitHub OAuth 登录（移动端推荐）
Future<AuthResponse> signInWithGitHubToken(String accessToken) async {
  try {
    debugPrint('🔐 [Mobile] 使用 GitHub token 登录 Supabase...');
    
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.github,
      idToken: accessToken,
      accessToken: accessToken,
    );

    // ...
  }
}
```

### 2. AuthController

#### 修改 `signInWithGitHub()` 方法（跨平台）

```dart
Future<void> signInWithGitHub() async {
  if (!_checkSupabaseConfig()) return;

  try {
    isLoading.value = true;

    if (kIsWeb) {
      // ==================== Web 平台 ====================
      debugPrint('🚀 [Web] 开始 Supabase GitHub OAuth 流程...');

      final success = await _supabaseService.signInWithGitHub();

      if (success) {
        Get.snackbar(
          '正在跳转',
          '即将打开 GitHub 登录页面...',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        
        // ⚠️ 关键：不要在这里关闭登录页或跳转
        // OAuth 会重定向到 /home，UserController 会监听到 auth state 变化并更新 UI
      }
    } else {
      // ==================== 移动平台 ====================
      debugPrint('🚀 [Mobile] 开始 flutter_appauth GitHub OAuth 流程...');

      // 1. 使用 flutter_appauth 进行 OAuth
      final result = await _oauthService.signInWithGitHub();

      // 2. 使用 token 创建 Supabase session
      final authResponse = await _supabaseService.signInWithGitHubToken(
        result.accessToken!,
      );

      // 3. 显示成功提示并关闭登录页
      Get.snackbar('登录成功', '欢迎回来！');
      navigator?.pop();
    }
  } catch (e) {
    // 错误处理
  } finally {
    isLoading.value = false;
  }
}
```

### 3. OAuthService

保持不变，只供移动端使用。

---

## 🔑 关键点

### 1. 避免 GlobalKey 冲突

**问题原因**：

- Web 端 OAuth 回调后，如果立即执行 `Get.back()` 或 `Navigator.pop()`，会导致 NavigatorState 重复创建

**解决方案**：

- ✅ OAuth 回调直接到 `/home` 路由
- ✅ 不在回调时执行任何导航操作
- ✅ 由 `UserController` 监听 `auth.onAuthStateChange`，自动更新 UI

### 2. Session 持久化

Supabase OAuth 自动将 session 存储在 `localStorage`（Web）或 `SharedPreferences`（移动端），无需手动处理。

### 3. Token 刷新

Supabase 自动刷新 access_token（默认 1 小时有效期），无需手动处理。

---

## 🧪 测试清单

### Web 端测试

- [ ] 点击"GitHub 登录"按钮
- [ ] 成功跳转到 GitHub 授权页面
- [ ] 授权后自动跳转回首页
- [ ] 首页显示用户信息（头像、邮箱）
- [ ] 刷新页面后仍然保持登录状态
- [ ] 登出后清除 session
- [ ] 重新登录正常

### 移动端测试（可选）

- [ ] 点击"GitHub 登录"按钮
- [ ] 成功跳转到 GitHub 授权页面
- [ ] 授权后自动返回应用
- [ ] 显示登录成功提示
- [ ] 显示用户信息
- [ ] 重启应用后仍然保持登录状态

---

## 📚 参考文档

- [Supabase OAuth 指南](https://supabase.com/docs/guides/auth/social-login/auth-github)
- [Flutter Web OAuth](https://supabase.com/docs/guides/auth/auth-oauth)
- [GitHub OAuth Apps](https://docs.github.com/en/apps/oauth-apps)

---

## 🎉 总结

### 优势

- ✅ **简单**：Web 端只需调用一个 Supabase API
- ✅ **安全**：Client Secret 在服务器端，不暴露给前端
- ✅ **可靠**：Supabase 官方推荐方案，经过大规模验证
- ✅ **跨平台**：Web 和移动端各自使用最优方案
- ✅ **无 GlobalKey 冲突**：通过 auth state listener 自动更新 UI

### 注意事项

- ⚠️ 确保 GitHub OAuth App 的回调 URL 配置正确：
  - **开发环境**：`http://localhost:3000/home`
  - **生产环境**：`https://yourdomain.com/home`
- ⚠️ Supabase Dashboard 的 GitHub OAuth 配置：
  - 填写 GitHub Client ID
  - 填写 GitHub Client Secret
  - 启用 GitHub Provider

---

**最后修改时间**：2025-11-02
**修改原因**：根据用户建议和 Supabase 官方文档，Web 端改用 Supabase OAuth

