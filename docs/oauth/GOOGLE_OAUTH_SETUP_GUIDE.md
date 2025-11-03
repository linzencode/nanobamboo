# Google OAuth 登录配置指南

> **实现方式**: google_sign_in 插件 + Supabase 服务器端认证  
> **适用平台**: Web、iOS、Android  
> **认证模式**: 服务器端认证（推荐）  
> **最后更新**: 2025-11-02

---

## 📋 目录

- [技术方案](#技术方案)
- [配置步骤](#配置步骤)
- [代码实现](#代码实现)
- [测试验证](#测试验证)
- [常见问题](#常见问题)

---

## 🏗️ 技术方案

### 方案选择

**google_sign_in + Supabase 服务器端认证**

```
用户点击 Google 登录
    ↓
google_sign_in 弹出 Google 登录窗口
    ↓
用户授权
    ↓
获取 ID Token 和 Access Token
    ↓
将 token 发送到 Supabase 后端验证（服务器端认证）
    ↓
Supabase 创建 session
    ↓
完成登录
```

### 优势

- ✅ **跨平台一致体验**：Web、iOS、Android 统一实现
- ✅ **服务器端验证**：token 在 Supabase 后端验证，更安全
- ✅ **更好的用户体验**：支持静默登录、自动刷新
- ✅ **获取完整用户信息**：邮箱、名称、头像等
- ✅ **官方支持**：Google 和 Supabase 官方推荐方案

### 与 Supabase OAuth 的对比

| 特性 | google_sign_in + 服务器端认证 | Supabase 内置 OAuth |
|------|---------------------------|-------------------|
| 跨平台一致性 | ✅ 完全一致 | ⚠️ Web 和移动端略有差异 |
| 用户体验 | ✅ 原生体验，支持静默登录 | ⚠️ Web 端跳转体验 |
| 配置复杂度 | ⚠️ 需要配置 Google Cloud | ✅ 只需 Supabase 配置 |
| 错误处理 | ✅ 更精细的控制 | ⚠️ 依赖 Supabase |
| 获取用户信息 | ✅ 更丰富 | ⚠️ 基本信息 |
| 推荐场景 | 生产环境、需要完整功能 | 快速原型、简单需求 |

---

## ⚙️ 配置步骤

### 步骤 1: Google Cloud Console 配置

#### 1.1 创建项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 记住项目 ID

#### 1.2 启用 Google Sign-In API

1. 在左侧菜单选择 **APIs & Services** → **Library**
2. 搜索 **Google+ API** 并启用
3. 搜索 **People API** 并启用（获取用户信息）

#### 1.3 配置 OAuth 同意屏幕

1. 进入 **APIs & Services** → **OAuth consent screen**
2. 选择 **External**（外部用户）
3. 填写应用信息：
   - App name: `你的应用名称`
   - User support email: `你的邮箱`
   - Developer contact: `你的邮箱`
4. **Scopes**（权限范围）：
   - `email`
   - `profile`
   - `openid`
5. **Test users**（测试阶段必需）：
   - 添加你的 Google 账号
6. 保存并继续

#### 1.4 创建 OAuth 2.0 Client ID

1. 进入 **APIs & Services** → **Credentials**
2. 点击 **Create Credentials** → **OAuth client ID**

**为 Web 创建：**
- Application type: **Web application**
- Name: `NanoBamboo Web`
- Authorized JavaScript origins:
  ```
  http://localhost:3000
  https://yourdomain.com
  ```
- Authorized redirect URIs:
  ```
  http://localhost:3000
  https://yourdomain.com
  ```
- 创建后获取 **Client ID**（保存，用于配置）

**为 iOS 创建：**
- Application type: **iOS**
- Name: `NanoBamboo iOS`
- Bundle ID: `com.yourcompany.nanobamboo`
- 创建后获取 **iOS Client ID**

**为 Android 创建：**
- Application type: **Android**
- Name: `NanoBamboo Android`
- Package name: `com.yourcompany.nanobamboo`
- SHA-1 certificate fingerprint: （运行 `keytool -list -v -keystore ~/.android/debug.keystore` 获取）
- 创建后获取 **Android Client ID**

### 步骤 2: Supabase Dashboard 配置

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择项目 → **Authentication** → **Providers**
3. 启用 **Google**：
   - **Enabled**: 打开
   - **Client ID (for OAuth)**: 从 Google Cloud Console 复制（Web Client ID）
   - **Client Secret (for OAuth)**: 从 Google Cloud Console 复制
   - **Authorize redirect URL**: 自动生成（类似 `https://xxx.supabase.co/auth/v1/callback`）
4. 保存

### 步骤 3: 项目环境变量配置

创建或编辑 `.env` 文件：

```.env
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google OAuth 配置
# Web Client ID（从 Google Cloud Console 获取）
GOOGLE_WEB_CLIENT_ID=123456789-abcdefg.apps.googleusercontent.com

# iOS Client ID（从 Google Cloud Console 获取）
GOOGLE_IOS_CLIENT_ID=123456789-hijklmn.apps.googleusercontent.com
```

### 步骤 4: 平台特定配置

#### Web 平台

**index.html** 添加 Google API 脚本（可选，google_sign_in 会自动加载）：

```html
<!-- web/index.html -->
<head>
  <!-- ... 其他配置 -->
  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
</head>
```

#### iOS 平台

**Info.plist** 添加 URL Schemes：

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- 反转的 iOS Client ID -->
      <string>com.googleusercontent.apps.123456789-hijklmn</string>
    </array>
  </dict>
</array>
```

**获取反转的 Client ID**：
```bash
# 如果 iOS Client ID 是：123456789-hijklmn.apps.googleusercontent.com
# 反转后就是：com.googleusercontent.apps.123456789-hijklmn
```

#### Android 平台

**AndroidManifest.xml** 无需额外配置，google_sign_in 会自动处理。

但需要确保 SHA-1 证书指纹正确配置在 Google Cloud Console。

---

## 💻 代码实现

代码已在项目中实现，主要文件：

### 1. GoogleSignInService
`lib/core/services/google_signin_service.dart`

```dart
/// Google 登录服务
final googleSignInService = GoogleSignInService();

// 初始化
googleSignInService.init();

// 登录
final result = await googleSignInService.signIn();
if (result != null) {
  print('ID Token: ${result.idToken}');
  print('Access Token: ${result.accessToken}');
}

// 登出
await googleSignInService.signOut();
```

### 2. SupabaseService
`lib/core/services/supabase_service.dart`

```dart
/// 使用 Google token 登录 Supabase（服务器端认证）
final authResponse = await supabaseService.signInWithGoogleToken(
  idToken: result.idToken,
  accessToken: result.accessToken,
);
```

### 3. AuthController
`lib/modules/auth/controllers/auth_controller.dart`

```dart
/// Google 登录（推荐方式）
await authController.signInWithGoogle();

/// Google OAuth 登录（备用方式，使用 Supabase 内置 OAuth）
await authController.signInWithGoogleOAuth();
```

---

## 🧪 测试验证

### 本地测试步骤

1. **安装依赖**
   ```bash
   flutter pub get
   ```

2. **配置环境变量**
   - 确保 `.env` 文件已配置 `GOOGLE_WEB_CLIENT_ID`
   - 检查 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY`

3. **启动应用**
   ```bash
   flutter run -d chrome --web-port=3000
   ```

4. **测试 Google 登录**
   - 打开 http://localhost:3000
   - 点击"注册/登录"
   - 选择"社交登录"标签
   - 点击"使用 Google 继续"

5. **预期结果**
   - ✅ 弹出 Google 登录窗口（而不是跳转到新页面）
   - ✅ 选择 Google 账号
   - ✅ 授权后自动关闭窗口
   - ✅ 显示绿色成功提示："登录成功！"
   - ✅ Header 显示用户头像和名称
   - ✅ 控制台输出：`✅ 用户已登录: user@gmail.com`
   - ✅ 无任何错误

### 调试技巧

1. **查看控制台日志**
   ```
   🚀 开始 Google 登录流程...
   ✅ Google OAuth 成功，开始创建 Supabase session...
   🔐 使用 Google Token 登录 Supabase...
   ✅ Supabase session 创建成功
   🎉 Google 登录流程完成！
   ```

2. **查看 Supabase 日志**
   - Supabase Dashboard → Logs → Auth Logs
   - 查看 `signInWithIdToken` 请求

3. **检查 token**
   ```dart
   // 在代码中添加 debug 输出
   debugPrint('ID Token: ${result.idToken}');
   debugPrint('Access Token: ${result.accessToken}');
   ```

4. **清除缓存重新测试**
   ```bash
   # Web 端
   # 浏览器控制台
   localStorage.clear()
   
   # 或在代码中
   await googleSignInService.signOut();
   await supabaseService.signOut();
   ```

---

## ❓ 常见问题

### 问题 1: "popup_closed_by_user" 错误

**现象**：
```
PlatformException(popup_closed_by_user, The user closed the popup, null, null)
```

**原因**：用户取消了 Google 登录

**解决**：这是正常行为，代码已处理

---

### 问题 2: "idpiframe_initialization_failed" 错误

**现象**：
```
PlatformException(idpiframe_initialization_failed)
```

**原因**：
- Client ID 配置错误
- Authorized JavaScript origins 未配置

**解决**：
1. 检查 `.env` 中的 `GOOGLE_WEB_CLIENT_ID` 是否正确
2. 在 Google Cloud Console 检查 Authorized JavaScript origins：
   ```
   http://localhost:3000
   ```

---

### 问题 3: 获取不到 ID Token

**现象**：
```
❌ 未获取到 ID Token
```

**原因**：Scopes 配置不正确

**解决**：
```dart
GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'openid',  // ← 必需，用于获取 ID Token
  ],
)
```

---

### 问题 4: Supabase 认证失败

**现象**：
```
AuthException: Invalid token
```

**原因**：
- Supabase Dashboard 未正确配置 Google Provider
- Client ID 和 Secret 不匹配

**解决**：
1. 检查 Supabase Dashboard → Authentication → Providers → Google
2. 确认 Client ID 和 Secret 正确
3. 确认 Google Provider 已启用

---

### 问题 5: iOS 端无法登录

**现象**：iOS 端点击登录无反应

**原因**：
- Info.plist 未配置 URL Schemes
- iOS Client ID 配置错误

**解决**：
1. 检查 `ios/Runner/Info.plist` 中的 `CFBundleURLSchemes`
2. 确认 URL Scheme 是反转的 iOS Client ID
3. 重新运行应用（清理缓存）：
   ```bash
   flutter clean
   flutter run
   ```

---

### 问题 6: Android 端无法登录

**现象**：Android 端点击登录无反应

**原因**：SHA-1 证书指纹未配置

**解决**：
1. 获取 Debug Keystore 的 SHA-1：
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. 在 Google Cloud Console → Credentials → Android Client 中添加 SHA-1

3. 获取 Release Keystore 的 SHA-1（发布时需要）

---

### 问题 7: 静默登录失败

**现象**：每次都弹出登录窗口

**原因**：这是正常行为，首次登录必须用户授权

**说明**：
- 首次登录：必须弹窗授权
- 后续登录：如果用户未撤销授权，会尝试静默登录
- 静默登录失败时，会自动弹窗

---

## 🎯 最佳实践

### 1. 错误处理

```dart
try {
  final result = await _googleSignInService.signIn();
  
  if (result == null) {
    // 用户取消登录
    showUserCancelledMessage();
    return;
  }
  
  // 继续处理...
} on PlatformException catch (e) {
  if (e.code == 'popup_closed_by_user') {
    // 用户取消
  } else if (e.code == 'network_error') {
    // 网络错误
  } else {
    // 其他错误
  }
} catch (e) {
  // 未知错误
}
```

### 2. 用户体验优化

- ✅ 添加 loading 状态
- ✅ 登录成功后显示欢迎提示
- ✅ 登录失败时显示友好错误信息
- ✅ 支持一键登出

### 3. 安全性

- ✅ 使用服务器端认证（token 在 Supabase 后端验证）
- ✅ 不要在前端存储敏感信息
- ✅ 定期检查和更新依赖包
- ✅ 生产环境使用 HTTPS

### 4. 生产环境配置

**更新 Authorized JavaScript origins**：
```
https://yourdomain.com
```

**更新环境变量**：
```dart
final redirectUrl = kReleaseMode 
    ? 'https://yourdomain.com' 
    : 'http://localhost:3000';
```

**发布到 App Store/Play Store**：
- 确保配置了 Release Keystore 的 SHA-1
- 在 Google Cloud Console 添加生产环境的 Client ID

---

## 📚 参考资源

### 官方文档

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Supabase Auth - Social Login with Google](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Supabase Server-Side Auth](https://supabase.com/docs/guides/auth/server-side/creating-a-client)
- [Google Cloud Console](https://console.cloud.google.com/)

### 相关项目文档

- [GitHub OAuth 实现指南](./GITHUB_OAUTH_IMPLEMENTATION_GUIDE.md)
- [Supabase 配置指南](../setup/SUPABASE_SETUP.md)

---

**文档版本**: 1.0  
**测试环境**: Flutter 3.2.0+ / google_sign_in 6.2.1 / Supabase 2.10.0  
**最后更新**: 2025-11-02  
**维护者**: NanoBamboo Team









