# GitHub 登录快速开始指南

这是一个快速配置指南，帮助您在 5 分钟内启用 GitHub OAuth 登录。

## 📋 前置检查清单

- [x] ✅ Supabase Flutter SDK 已安装
- [x] ✅ 环境变量服务已创建
- [x] ✅ Supabase 服务层已实现
- [x] ✅ AuthController 已集成
- [x] ✅ 登录UI 已更新为 GitHub

## 🚀 快速配置步骤

### 1. 创建 Supabase 项目（3 分钟）

1. 访问 https://supabase.com 并登录
2. 创建新项目
3. 在 **Settings > API** 中获取：
   - Project URL
   - anon public key

### 2. 配置 GitHub OAuth（2 分钟）

1. 访问 https://github.com/settings/developers
2. 创建新的 OAuth App：
   ```
   Application name: NanoBamboo
   Homepage URL: https://your-project-ref.supabase.co
   Callback URL: https://your-project-ref.supabase.co/auth/v1/callback
   ```
3. 获取 Client ID 和 Client Secret

4. 在 Supabase Dashboard 的 **Authentication > Providers > GitHub**：
   - 启用 GitHub
   - 输入 Client ID 和 Client Secret
   - 保存

### 3. 配置项目环境变量（1 分钟）

在项目根目录创建 `.env` 文件：

```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**注意**：
- 复制 `env.example` 作为模板
- 替换为您的真实值
- `.env` 文件不会被提交到 Git

### 4. 运行项目

```bash
flutter pub get
flutter run
```

## ✨ 功能特性

已实现的认证功能：

### 🔐 GitHub OAuth 登录
- ✅ 服务器端 PKCE 认证流程
- ✅ 安全的令牌交换
- ✅ 自动会话管理

### 📧 邮箱 OTP 登录
- ✅ 魔法链接方式
- ✅ 验证码验证
- ✅ 60秒倒计时

### 🔑 邮箱密码登录
- ✅ 传统密码认证
- ✅ 密码显示/隐藏切换
- ✅ 完整的表单验证

## 📁 项目结构

```
lib/
├── core/
│   └── services/
│       ├── env_service.dart          # 环境变量管理
│       └── supabase_service.dart     # Supabase 客户端封装
├── modules/
│   └── auth/
│       ├── controllers/
│       │   └── auth_controller.dart  # 认证逻辑控制器
│       └── views/
│           └── auth_view.dart        # 登录UI界面
└── main.dart                         # 应用入口，初始化服务
```

## 🔧 关键代码文件

### 1. 环境变量服务
`lib/core/services/env_service.dart`
- 加载和管理 .env 配置
- 提供 Supabase 配置访问

### 2. Supabase 服务
`lib/core/services/supabase_service.dart`
- GitHub OAuth 登录
- 邮箱 OTP 登录
- 密码登录/注册
- 会话管理
- 用户状态监听

### 3. 认证控制器
`lib/modules/auth/controllers/auth_controller.dart`
- UI 状态管理
- 表单验证
- 错误处理
- 用户反馈

### 4. 应用初始化
`lib/main.dart`
- 环境变量初始化
- Supabase 服务初始化
- 全局错误捕获

## 🎯 使用方法

### GitHub 登录
```dart
// 用户点击 "使用 GitHub 继续" 按钮
await authController.signInWithGitHub();

// 1. 打开 GitHub 授权页面
// 2. 用户授权
// 3. 自动重定向回应用
// 4. 完成登录
```

### 邮箱 OTP 登录
```dart
// 1. 发送验证码
await authController.sendVerificationCode();

// 2. 验证码登录
await authController.signInWithEmail();
```

### 密码登录
```dart
await authController.signInWithPassword();
```

### 登出
```dart
await authController.signOut();
```

## 🔐 安全特性

### PKCE 认证流程
项目使用 OAuth 2.0 PKCE（Proof Key for Code Exchange）流程：

1. **生成随机 Code Verifier**
2. **计算 Code Challenge**（SHA-256）
3. **发送 Challenge 到授权服务器**
4. **验证 Verifier 完成认证**

这种方式确保即使授权码被拦截也无法被利用，比传统的 Implicit Flow 更安全。

### 环境变量安全
- ✅ 敏感信息存储在 .env 文件
- ✅ .env 文件已添加到 .gitignore
- ✅ 提供 env.example 作为模板

### Supabase Row Level Security (RLS)
建议在 Supabase 中配置 RLS 规则来保护数据：

```sql
-- 示例：用户只能读取自己的数据
CREATE POLICY "Users can only read their own data"
ON your_table
FOR SELECT
USING (auth.uid() = user_id);
```

## 📱 移动端配置（可选）

如果需要在移动端运行，需要配置 Deep Link。

### iOS
编辑 `ios/Runner/Info.plist`：

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.nanobamboo</string>
    </array>
  </dict>
</array>
```

### Android
编辑 `android/app/src/main/AndroidManifest.xml`：

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

## 🧪 测试流程

1. 启动应用
2. 点击 "注册/登录"
3. 选择 "GitHub 登录" 标签
4. 点击 "使用 GitHub 继续"
5. 在弹出的浏览器中授权
6. 自动返回应用并登录成功

## ❓ 常见问题

**Q: 提示 "环境变量加载失败"？**

A: 检查是否创建了 `.env` 文件，并确保在项目根目录。

**Q: GitHub 登录无法打开？**

A: 
- 检查网络连接
- 确认 Supabase 中 GitHub Provider 已启用
- 验证 GitHub OAuth App 配置正确

**Q: 回调后没有登录成功？**

A: 
- 检查 GitHub OAuth App 的 Callback URL
- 查看 Flutter 控制台的错误日志
- 检查 Supabase Dashboard 的认证日志

## 📚 更多资源

- 📖 [详细配置指南](./SUPABASE_SETUP.md)
- 🔗 [Supabase 官方文档](https://supabase.com/docs)
- 🔗 [Supabase Flutter SDK](https://pub.dev/packages/supabase_flutter)
- 🔗 [GitHub OAuth 文档](https://docs.github.com/en/developers/apps/building-oauth-apps)

## 🎉 完成！

现在您已经成功集成了 GitHub OAuth 登录功能！用户可以使用 GitHub 账号快速登录您的应用。

如有问题，请参考 [详细配置指南](./SUPABASE_SETUP.md) 或在 Issues 中提问。

