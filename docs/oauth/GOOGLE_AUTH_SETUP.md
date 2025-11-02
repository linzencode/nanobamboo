# Google OAuth 登录配置指南

本指南将帮助您在 NanoBamboo 项目中配置 Google OAuth 登录功能。

---

## 📋 前置条件

1. ✅ 已完成 [Supabase 基础配置](SUPABASE_SETUP.md)
2. ✅ 拥有 Google 账号
3. ✅ 已安装并运行项目

---

## 🎯 配置步骤

### 第一步：在 Google Cloud Console 创建 OAuth 应用

#### 1.1 访问 Google Cloud Console

打开浏览器，访问：[https://console.cloud.google.com/](https://console.cloud.google.com/)

#### 1.2 创建新项目（如果还没有）

1. 点击顶部导航栏的项目选择器
2. 点击 **"新建项目"**
3. 输入项目名称（如：`NanoBamboo`）
4. 点击 **"创建"**

#### 1.3 启用 Google+ API

1. 在左侧菜单中，选择 **"API 和服务" > "库"**
2. 搜索 **"Google+ API"**
3. 点击进入，然后点击 **"启用"**

#### 1.4 配置 OAuth 同意屏幕

1. 在左侧菜单中，选择 **"API 和服务" > "OAuth 同意屏幕"**
2. 选择 **"外部"** 用户类型（个人项目）
3. 点击 **"创建"**

**填写应用信息：**

- **应用名称**：`NanoBamboo`
- **用户支持电子邮件**：您的邮箱
- **应用首页链接**：`http://localhost:3000`（开发环境）
- **应用隐私政策链接**：`http://localhost:3000`（开发环境，可选）
- **授权域**：
  - `localhost`
  - `你的Supabase项目域名.supabase.co`
- **开发者联系信息**：您的邮箱

4. 点击 **"保存并继续"**

**添加作用域（Scopes）：**

5. 点击 **"添加或移除作用域"**
6. 添加以下作用域：
   - `email`
   - `profile`
   - `openid`
7. 点击 **"更新"**
8. 点击 **"保存并继续"**

**添加测试用户（开发阶段）：**

9. 点击 **"添加用户"**
10. 输入您的 Google 账号邮箱
11. 点击 **"添加"**
12. 点击 **"保存并继续"**

#### 1.5 创建 OAuth 客户端 ID

1. 在左侧菜单中，选择 **"API 和服务" > "凭据"**
2. 点击 **"+ 创建凭据"**
3. 选择 **"OAuth 客户端 ID"**

**配置客户端 ID：**

- **应用类型**：选择 **"Web 应用"**
- **名称**：`NanoBamboo Web Client`

**已获授权的 JavaScript 来源：**

```
http://localhost:3000
```

**已获授权的重定向 URI：**

```
https://你的项目ID.supabase.co/auth/v1/callback
```

> **📌 重要提示：**
> - 将 `你的项目ID` 替换为您的实际 Supabase 项目 ID
> - 例如：`https://abcdefghijklmn.supabase.co/auth/v1/callback`
> - 您可以在 Supabase Dashboard 的 Project Settings > API 中找到您的项目 URL

4. 点击 **"创建"**

#### 1.6 获取 OAuth 凭据

创建成功后，会弹出一个对话框，显示：

- **客户端 ID**：`xxxxx.apps.googleusercontent.com`
- **客户端密钥**：`GOCSPX-xxxxx`

⚠️ **请妥善保存这些信息，稍后会用到！**

---

### 第二步：在 Supabase 中配置 Google Provider

#### 2.1 打开 Supabase Dashboard

1. 访问 [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. 选择您的项目

#### 2.2 启用 Google 认证

1. 在左侧菜单中，选择 **"Authentication" > "Providers"**
2. 找到 **"Google"**
3. 点击展开

#### 2.3 配置 Google Provider

**填写以下信息：**

- **Enable Google provider**：✅ 开启
- **Client ID**：粘贴您从 Google Cloud Console 获取的客户端 ID
- **Client Secret**：粘贴您从 Google Cloud Console 获取的客户端密钥
- **Redirect URL**：（Supabase 自动生成，无需修改）

4. 点击 **"Save"** 保存配置

---

### 第三步：配置重定向 URL

#### 3.1 在 Google Cloud Console 中配置

1. 返回 [Google Cloud Console](https://console.cloud.google.com/)
2. 进入 **"API 和服务" > "凭据"**
3. 点击您刚创建的 OAuth 客户端 ID
4. 在 **"已获授权的重定向 URI"** 中，添加：

**Web 开发环境：**
```
http://localhost:3000/auth/callback
https://你的项目ID.supabase.co/auth/v1/callback
```

**生产环境（可选）：**
```
https://你的域名.com
https://你的项目ID.supabase.co/auth/v1-callback
```

#### 3.2 在 Supabase 中配置

1. 在 Supabase Dashboard 中，选择 **"Authentication" > "URL Configuration"**
2. 在 **"Site URL"** 中添加：
   ```
   http://localhost:3000
   ```

3. 在 **"Redirect URLs"** 中添加：
   ```
   http://localhost:3000/**
   http://localhost:*/**
   ```

4. 点击 **"Save"** 保存配置

---

## 🧪 测试 Google 登录

### 1. 启动开发服务器

```bash
# 使用 make（推荐）
make web

# 或使用脚本
./run_web.sh

# 或直接使用 Flutter CLI
flutter run -d chrome --web-port=3000
```

### 2. 测试登录流程

1. 访问 [http://localhost:3000](http://localhost:3000)
2. 点击右上角的 **"注册/登录"** 按钮
3. 在登录页面选择 **"社交登录"** 标签
4. 点击 **"使用 Google 继续"** 按钮
5. 浏览器将跳转到 Google 登录页面
6. 选择您的 Google 账号（必须是测试用户）
7. 授权应用访问您的基本信息
8. 登录成功后，会自动返回到应用首页
9. 右上角应显示您的 Google 用户名和头像

---

## ✅ 验证配置

### 检查用户信息

登录成功后，您应该能看到：

- ✅ 右上角显示您的 Google 用户名
- ✅ 显示您的 Google 头像
- ✅ 点击头像可以看到下拉菜单（个人中心、设置、登出）

### 在 Supabase 中查看用户

1. 打开 Supabase Dashboard
2. 选择 **"Authentication" > "Users"**
3. 您应该能看到刚刚通过 Google 登录的用户记录
4. 用户的 `provider` 字段应该显示为 `google`

---

## 🔧 常见问题

### 1. 点击 Google 登录按钮没有反应

**可能原因：**
- Supabase 环境变量未配置
- Google OAuth 凭据配置错误

**解决方案：**
```bash
# 检查 .env 文件
cat .env

# 应该包含：
SUPABASE_URL=https://你的项目ID.supabase.co
SUPABASE_ANON_KEY=你的匿名密钥
```

### 2. 跳转到 Google 登录页面后报错

**常见错误：**
- `redirect_uri_mismatch`：重定向 URI 不匹配
- `access_denied`：用户拒绝授权或不在测试用户列表中

**解决方案：**
- 确保 Google Cloud Console 中的重定向 URI 与 Supabase 的回调 URL 一致
- 确保您的 Google 账号已添加为测试用户

### 3. 登录后页面显示"配置错误"

**可能原因：**
- Supabase 服务未正确初始化

**解决方案：**
```bash
# 完全重启应用
flutter clean
flutter pub get
flutter run -d chrome --web-port=3000
```

### 4. 登录成功但右上角仍显示"注册/登录"

**可能原因：**
- `UserController` 未正确注册或更新

**解决方案：**
- 检查浏览器控制台是否有错误
- 执行完全重启（不是热重启）

### 5. 生产环境中 Google 登录不可用

**可能原因：**
- OAuth 同意屏幕未发布

**解决方案：**
1. 在 Google Cloud Console 中，进入 **"OAuth 同意屏幕"**
2. 点击 **"发布应用"**
3. 提交审核（可能需要几天时间）

---

## 📱 移动端配置（iOS/Android）

### iOS 配置

#### 1. 配置 URL Scheme

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

#### 2. 在 Google Cloud Console 添加 iOS 客户端

1. 创建新的 OAuth 客户端 ID
2. 选择 **"iOS"**
3. 填写 Bundle ID：`io.supabase.nanobamboo`
4. 保存客户端 ID

### Android 配置

#### 1. 配置 Intent Filter

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

#### 2. 在 Google Cloud Console 添加 Android 客户端

1. 创建新的 OAuth 客户端 ID
2. 选择 **"Android"**
3. 填写包名：`io.supabase.nanobamboo`
4. 获取 SHA-1 证书指纹：
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. 粘贴 SHA-1 指纹
6. 保存客户端 ID

---

## 🔐 安全最佳实践

1. **保护客户端密钥**
   - 不要将 Google OAuth 密钥提交到 Git
   - 使用环境变量存储敏感信息

2. **限制重定向 URI**
   - 只添加必要的重定向 URI
   - 生产环境使用 HTTPS

3. **定期更新凭据**
   - 定期轮换客户端密钥
   - 监控异常登录活动

4. **测试用户管理**
   - 开发阶段只添加必要的测试用户
   - 发布前移除测试限制

---

## 📚 相关文档

- [Supabase Google Auth 官方文档](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google OAuth 2.0 文档](https://developers.google.com/identity/protocols/oauth2)
- [Google Cloud Console](https://console.cloud.google.com/)

---

## 🎉 完成！

现在您的 NanoBamboo 项目已经成功集成了 Google OAuth 登录！

用户可以通过以下方式登录：
- ✅ Google 账号
- ✅ GitHub 账号
- ✅ 邮箱验证码
- ✅ 邮箱密码

---

**🔗 快速链接：**

- [Supabase 配置指南](SUPABASE_SETUP.md)
- [GitHub 登录配置](QUICKSTART_GITHUB_AUTH.md)
- [运行项目](HOW_TO_RUN.md)
- [故障排除](TROUBLESHOOTING.md)

