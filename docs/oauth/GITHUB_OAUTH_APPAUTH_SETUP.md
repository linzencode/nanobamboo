# GitHub OAuth 2.0 + PKCE 配置指南

## 🎯 新的回调 URL

使用 `flutter_appauth` 后，回调 URL 需要更新为：

```
http://localhost:3000/auth/callback
```

**重要**：这是标准的 OAuth 2.0 回调路径，与之前的 `http://localhost:3000/home` 不同。

## 📝 配置步骤

### 1. 访问 GitHub OAuth App 设置

1. 打开 [GitHub Settings - Developer settings - OAuth Apps](https://github.com/settings/developers)
2. 找到您的 OAuth App（Client ID: `Ov23lixyWLDfY2QTuFDt`）
3. 点击 "Edit" 编辑

### 2. 更新回调 URL

找到 **Authorization callback URL** 字段，更新为：

```
http://localhost:3000/auth/callback
```

**注意**：
- ✅ 必须使用 `/auth/callback` 结尾
- ✅ 确保端口号是 `3000`（与项目配置一致）
- ❌ 不要使用 `/home` 或其他路径

### 3. 保存设置

点击 **Update application** 保存更改。

## 🔍 当前配置

### OAuth 2.0 参数

```dart
// lib/core/services/oauth_service.dart
static const String _githubClientId = 'Ov23lixyWLDfY2QTuFDt';
static const String _githubAuthorizationEndpoint = 'https://github.com/login/oauth/authorize';
static const String _githubTokenEndpoint = 'https://github.com/login/oauth/access_token';
static const String _redirectUrl = 'http://localhost:3000/auth/callback';
```

### OAuth 授权范围

```dart
scopes: <String>['read:user', 'user:email']
```

- `read:user`：读取用户基本信息
- `user:email`：读取用户邮箱地址

## 🚀 新的登录流程

### 1. 用户点击 "使用 GitHub 继续"

```dart
// lib/modules/auth/controllers/auth_controller.dart
await signInWithGitHub();
```

### 2. 打开 GitHub 授权页面

```
https://github.com/login/oauth/authorize?
  client_id=Ov23lixyWLDfY2QTuFDt
  &redirect_uri=http://localhost:3000/auth/callback
  &scope=read:user user:email
  &code_challenge=xxx  ← PKCE challenge
  &code_challenge_method=S256
```

### 3. 用户授权后回调

```
http://localhost:3000/auth/callback?code=xxx
```

**关键点**：
- ✅ 使用 **授权码**（code），不是 access_token
- ✅ 回调路径是 `/auth/callback`
- ✅ flutter_appauth 会自动拦截此回调

### 4. 交换 access_token

```dart
// flutter_appauth 自动完成
POST https://github.com/login/oauth/access_token
Body:
  code=xxx
  code_verifier=xxx  ← PKCE verifier
  client_id=Ov23lixyWLDfY2QTuFDt
  redirect_uri=http://localhost:3000/auth/callback
```

### 5. 使用 token 创建 Supabase 会话

```dart
final authResponse = await _supabaseService.signInWithGitHubToken(
  result.accessToken!,
);
```

### 6. 登录成功，返回主页

```dart
final navigator = main_app.navigatorKey.currentState;
navigator?.pop();
```

## ✅ 优势对比

### 旧方案（Supabase OAuth - 有问题）

```
┌─────────────────────────────────────────────┐
│ 回调: http://localhost:3000/home#access_token=xxx │
│                                             │
│ ❌ token 在 URL fragment 中                  │
│ ❌ 与 Flutter 路由系统冲突                    │
│ ❌ GlobalKey 冲突                            │
│ ❌ 安全性较低                                │
└─────────────────────────────────────────────┘
```

### 新方案（flutter_appauth + PKCE - 生产级）

```
┌─────────────────────────────────────────────┐
│ 回调: http://localhost:3000/auth/callback?code=xxx │
│                                             │
│ ✅ 使用授权码（code），不是 token            │
│ ✅ PKCE 防止授权码拦截攻击                    │
│ ✅ 标准 OAuth 2.0 流程                       │
│ ✅ 不经过 Flutter 路由系统                    │
│ ✅ 安全性高                                  │
└─────────────────────────────────────────────┘
```

## 🧪 测试步骤

### 1. 确认配置

```bash
# 检查 GitHub OAuth App 回调 URL
http://localhost:3000/auth/callback
```

### 2. 启动应用

```bash
flutter run -d chrome --web-port=3000
```

### 3. 测试登录

1. 点击 "注册/登录"
2. 选择 "社交登录" 标签
3. 点击 "使用 GitHub 继续"
4. 在 GitHub 授权页面点击 "Authorize"

### 4. 预期结果

```
✅ 浏览器重定向到 http://localhost:3000/auth/callback?code=xxx
✅ flutter_appauth 自动拦截并交换 token
✅ 控制台输出：
   🔐 开始 GitHub OAuth 2.0 + PKCE 流程...
   ✅ GitHub OAuth 成功！
   🔐 使用 GitHub token 登录 Supabase...
   ✅ Supabase session 创建成功
   ✅ 登录成功: your@email.com
✅ 自动返回主页
✅ Header 显示用户头像和名称
✅ 没有任何 GlobalKey 错误！
```

## 🔒 安全性说明

### PKCE（Proof Key for Code Exchange）

这是一种增强的 OAuth 2.0 流程，防止授权码拦截攻击：

1. **生成 code_verifier**（随机字符串）
2. **生成 code_challenge**（SHA256(code_verifier)）
3. **授权请求**：发送 `code_challenge`
4. **回调**：获取授权码 `code`
5. **Token 请求**：发送 `code` + `code_verifier`
6. **服务器验证**：SHA256(code_verifier) == code_challenge

即使攻击者拦截了授权码，也无法交换 token（因为不知道 code_verifier）。

### 为什么更安全？

| 旧方案（Implicit Flow） | 新方案（Authorization Code + PKCE） |
|------------------------|-----------------------------------|
| ❌ Token 直接在 URL 中 | ✅ 只有授权码在 URL 中 |
| ❌ Token 可能被浏览器历史记录保存 | ✅ 授权码一次性使用 |
| ❌ Token 可能被第三方脚本读取 | ✅ Token 在后台交换 |
| ❌ 不适合公共客户端 | ✅ 专为公共客户端设计 |

## 📚 参考资料

- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [flutter_appauth 文档](https://pub.dev/packages/flutter_appauth)
- [GitHub OAuth Apps 文档](https://docs.github.com/en/developers/apps/building-oauth-apps)

---

**配置完成后，立即测试！** 🚀

