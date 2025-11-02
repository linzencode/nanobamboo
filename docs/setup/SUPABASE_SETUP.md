# Supabase GitHub OAuth 集成指南

本指南将帮助您在 NanoBamboo 项目中配置 Supabase GitHub OAuth 登录。

## 前置要求

- Supabase 账号：https://supabase.com
- GitHub 账号

## 第一步：创建 Supabase 项目

1. 登录 [Supabase Dashboard](https://app.supabase.com)
2. 点击 "New Project"
3. 填写项目信息并创建项目
4. 等待项目初始化完成

## 第二步：获取 Supabase 配置信息

1. 在 Supabase Dashboard 中，进入您的项目
2. 点击左侧菜单的 "Settings" > "API"
3. 复制以下信息：
   - **Project URL**（项目 URL）
   - **anon public**（匿名公钥）

## 第三步：配置 GitHub OAuth 应用

### 3.1 创建 GitHub OAuth App

1. 访问 GitHub Settings: https://github.com/settings/developers
2. 点击 "OAuth Apps" > "New OAuth App"
3. 填写应用信息：
   - **Application name**: NanoBamboo（或您喜欢的名称）
   - **Homepage URL**: `https://your-project-ref.supabase.co`（使用您的 Supabase 项目 URL）
   - **Authorization callback URL**: `https://your-project-ref.supabase.co/auth/v1/callback`
4. 点击 "Register application"
5. 在应用页面中：
   - 复制 **Client ID**
   - 点击 "Generate a new client secret" 并复制 **Client Secret**

### 3.2 在 Supabase 中启用 GitHub Provider

1. 在 Supabase Dashboard 中，进入 "Authentication" > "Providers"
2. 找到 "GitHub" 并展开
3. 启用 GitHub provider
4. 填入从 GitHub OAuth App 获取的：
   - **Client ID**
   - **Client Secret**
5. 点击 "Save"

## 第四步：配置项目环境变量

1. 在项目根目录创建 `.env` 文件：

```bash
# 从 Supabase Dashboard > Settings > API 获取
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key-here
```

2. 将实际的值替换到配置中

**重要**: 
- `.env` 文件已添加到 `.gitignore`，不会被提交到版本控制
- 不要将真实的密钥分享或提交到公共仓库

## 第五步：配置 Deep Link（移动端）

### iOS 配置

编辑 `ios/Runner/Info.plist`：

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.nanobamboo</string>
    </array>
  </dict>
</array>
```

### Android 配置

编辑 `android/app/src/main/AndroidManifest.xml`，在 `<activity>` 标签内添加：

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.nanobamboo"
        android:host="login-callback" />
</intent-filter>
```

### Web 配置

Web 端不需要特殊配置，OAuth 回调会自动处理。

## 第六步：安装依赖

运行以下命令安装所需依赖：

```bash
flutter pub get
```

## 第七步：运行项目

```bash
# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 测试 GitHub 登录

1. 启动应用
2. 点击 "注册/登录" 按钮
3. 在登录页面选择 "GitHub 登录" 标签
4. 点击 "使用 GitHub 继续" 按钮
5. 浏览器会打开 GitHub 授权页面
6. 授权后会自动返回应用并登录成功

## 故障排除

### 问题 1: "环境变量加载失败"

**解决方案**:
- 确保已创建 `.env` 文件
- 检查 `.env` 文件格式是否正确
- 确保 `.env` 文件在项目根目录

### 问题 2: "GitHub 登录无法打开"

**解决方案**:
- 检查 GitHub OAuth App 的回调 URL 是否正确
- 确保 Supabase 中的 GitHub Provider 已启用
- 检查网络连接

### 问题 3: 移动端回调失败

**解决方案**:
- 确保 Deep Link 配置正确
- iOS: 检查 `Info.plist` 配置
- Android: 检查 `AndroidManifest.xml` 配置
- 重新构建应用

### 问题 4: "Supabase 初始化失败"

**解决方案**:
- 检查 `.env` 中的 URL 和 Key 是否正确
- 确保 Supabase 项目已完成初始化
- 检查网络连接

## 安全注意事项

1. **永远不要**将 `.env` 文件提交到 Git
2. **永远不要**在公共场合分享您的密钥
3. 使用 Supabase RLS（Row Level Security）保护数据
4. 定期更新依赖包以修复安全漏洞

## 服务器端认证说明

本项目使用 Supabase Flutter SDK 的 PKCE（Proof Key for Code Exchange）流程，这是一种安全的 OAuth 2.0 认证方式：

- 客户端生成一个随机的 code verifier
- 使用 SHA-256 hash 生成 code challenge
- GitHub 认证时发送 code challenge
- 回调时使用 code verifier 验证
- 确保即使授权码被拦截也无法被利用

配置在 `lib/core/services/supabase_service.dart` 中：

```dart
authOptions: const FlutterAuthClientOptions(
  authFlowType: AuthFlowType.pkce,
),
```

这种方式比传统的 implicit flow 更安全，适合移动应用和单页应用。

## 其他认证方式

除了 GitHub 登录，项目还支持：

1. **邮箱 OTP 登录**（魔法链接）
   - 用户输入邮箱
   - 系统发送验证码到邮箱
   - 用户输入验证码完成登录

2. **邮箱密码登录**
   - 传统的邮箱密码登录方式
   - 支持用户注册

所有认证方法都已在 `SupabaseService` 和 `AuthController` 中实现。

## 参考资源

- [Supabase 文档](https://supabase.com/docs)
- [Supabase Auth 指南](https://supabase.com/docs/guides/auth)
- [GitHub OAuth 文档](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Supabase Flutter SDK](https://pub.dev/packages/supabase_flutter)

## 需要帮助？

如果遇到问题，请：
1. 查看 Flutter 控制台的错误信息
2. 检查 Supabase Dashboard 的日志
3. 参考官方文档
4. 在项目 Issues 中提问

