# 故障排除指南

本文档包含了 NanoBamboo 项目常见问题的解决方案。

---

## 🔐 认证相关问题

### 1. OAuth 登录时出现 "Code verifier could not be found in local storage"

**错误信息：**
```
AuthException(message: Code verifier could not be found in local storage., statusCode: null, code: null)
```

**原因：**
- Web 环境中的 PKCE flow 和 localStorage 冲突
- 浏览器缓存了旧的认证状态

**解决方案：**

#### 方法 1: 清理浏览器缓存（推荐）

1. **清理 Application Storage**
   - 在 Chrome 中按 `F12` 打开开发者工具
   - 切换到 **"Application"** 标签
   - 在左侧选择 **"Local Storage"**
   - 右键点击 `http://localhost:3000` 并选择 **"Clear"**
   - 在左侧选择 **"Session Storage"**
   - 右键点击 `http://localhost:3000` 并选择 **"Clear"**

2. **清理所有站点数据**
   - 在 Application 标签中
   - 点击左侧的 **"Storage"**
   - 点击 **"Clear site data"** 按钮

3. **刷新页面并重新登录**

#### 方法 2: 使用隐私模式

1. 打开 Chrome 隐私窗口 (`Cmd+Shift+N` 或 `Ctrl+Shift+N`)
2. 访问 `http://localhost:3000`
3. 尝试登录

#### 方法 3: 完全重启应用

```bash
# 停止当前应用（Ctrl+C 或 Command+C）

# 清理构建缓存
flutter clean

# 重新安装依赖
flutter pub get

# 重新运行
make web
```

---

### 2. 点击 OAuth 登录按钮没有反应

**可能原因：**
- Supabase 环境变量未配置
- OAuth 提供商未在 Supabase 中启用

**解决方案：**

#### 检查环境变量

```bash
# 查看 .env 文件
cat .env
```

确保包含以下内容：
```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

#### 检查 Supabase 配置

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择您的项目
3. 进入 **Authentication > Providers**
4. 确保 GitHub/Google Provider 已启用并正确配置

---

### 3. OAuth 回调后显示 "redirect_uri_mismatch"

**错误信息：**
```
Error 400: redirect_uri_mismatch
```

**原因：**
- OAuth 提供商中配置的重定向 URI 与实际回调 URL 不匹配

**解决方案：**

#### GitHub OAuth

在 GitHub OAuth App 设置中，确保 **Authorization callback URL** 包含：
```
http://localhost:3000
https://your-project-ref.supabase.co/auth/v1/callback
```

#### Google OAuth

在 Google Cloud Console 的 OAuth 客户端中，确保 **已获授权的重定向 URI** 包含：
```
http://localhost:3000/auth/callback
https://your-project-ref.supabase.co/auth/v1/callback
```

---

### 4. 登录成功但右上角仍显示"注册/登录"

**可能原因：**
- `UserController` 未正确注册
- 认证状态未同步

**解决方案：**

#### 检查 UserController 注册

确保 `main.dart` 中包含：
```dart
Get.put(UserController());
```

#### 完全重启应用

```bash
# 停止应用
# 完全重启（不是热重启）
flutter run -d chrome --web-port=3000
```

#### 检查浏览器控制台

按 `F12` 打开开发者工具，查看 Console 是否有错误信息。

---

## 🌐 网络和端口问题

### 5. 端口 3000 被占用

**错误信息：**
```
Port 3000 is already in use
```

**解决方案：**

#### Mac/Linux

```bash
# 查找占用端口 3000 的进程
lsof -ti:3000

# 杀死该进程
kill -9 $(lsof -ti:3000)

# 或者使用其他端口
flutter run -d chrome --web-port=3001
```

#### Windows

```cmd
# 查找占用端口 3000 的进程
netstat -ano | findstr :3000

# 杀死该进程（替换 PID 为实际的进程 ID）
taskkill /PID <PID> /F

# 或者使用其他端口
flutter run -d chrome --web-port=3001
```

---

### 6. 无法连接到 Supabase

**错误信息：**
```
Failed to connect to Supabase
Network error
```

**解决方案：**

#### 检查网络连接

```bash
# 测试 Supabase URL 是否可访问
curl https://your-project-ref.supabase.co
```

#### 检查防火墙设置

确保防火墙没有阻止连接到 Supabase。

#### 检查 Supabase 项目状态

1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 检查项目是否处于活动状态
3. 查看项目是否暂停（免费计划可能会暂停不活跃的项目）

---

## 🖼️ UI 渲染问题

### 7. RenderFlex overflow 错误

**错误信息：**
```
A RenderFlex overflowed by X pixels
```

**解决方案：**

#### 完全重启应用

热重启可能不会完全应用布局更改：

```bash
# 停止应用
# 完全重启
flutter run -d chrome --web-port=3000
```

#### 清理构建缓存

```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port=3000
```

---

### 8. 移动端菜单无法关闭

**问题：**
点击移动端菜单外部区域无法关闭菜单。

**解决方案：**

确保 `HomeController` 中的 `toggleMobileMenu()` 方法可用，或者完全重启应用。

---

## 📦 依赖和构建问题

### 9. pub get 失败

**错误信息：**
```
Running "flutter pub get" in nanobamboo...
version solving failed
```

**解决方案：**

#### 清理依赖缓存

```bash
# 清理 Flutter 缓存
flutter clean

# 清理 pub 缓存
flutter pub cache clean

# 重新获取依赖
flutter pub get
```

#### 检查 Flutter 版本

```bash
flutter --version

# 确保 Flutter SDK >= 3.2.0
# 如果版本过低，升级 Flutter
flutter upgrade
```

---

### 10. Linter 错误

**错误信息：**
各种 linter 警告和错误。

**解决方案：**

#### 自动修复

```bash
# 分析代码
dart analyze

# 自动修复可修复的问题
dart fix --apply
```

#### 手动修复

根据 linter 提示手动修复代码，常见问题：
- 缺少 trailing commas
- 使用 deprecated API
- 构造函数顺序错误

---

## 🔧 开发环境问题

### 11. VS Code 无法识别 Dart/Flutter

**问题：**
VS Code 中 Dart 代码没有语法高亮或代码补全。

**解决方案：**

#### 安装必要的扩展

1. 安装 **Dart** 扩展
2. 安装 **Flutter** 扩展

#### 重新加载窗口

按 `Cmd+Shift+P` (Mac) 或 `Ctrl+Shift+P` (Windows)，输入 `Reload Window`。

#### 检查 Flutter 路径

```bash
# 查看 Flutter 路径
which flutter

# 在 VS Code 设置中配置 Flutter SDK 路径
```

---

### 12. 热重载不生效

**问题：**
修改代码后，热重载没有更新 UI。

**解决方案：**

#### 使用完全重启

按 `Shift+R` 或 `Shift+Cmd+F5` (Mac) 进行完全重启。

#### 检查修改的文件类型

热重载只支持 Dart 代码：
- ✅ Widget 代码
- ✅ Controller 代码
- ❌ pubspec.yaml（需要完全重启）
- ❌ 资源文件（需要完全重启）
- ❌ 原生代码（需要完全重启）

---

## 🚀 生产环境问题

### 13. Web 构建失败

**错误信息：**
```
Failed to build web
```

**解决方案：**

#### 清理并重新构建

```bash
flutter clean
flutter pub get
flutter build web --release
```

#### 检查 Web 特定配置

确保 `web/index.html` 文件存在且配置正确。

---

### 14. 构建的应用在生产环境无法运行

**问题：**
本地开发正常，但部署到生产环境后无法运行。

**解决方案：**

#### 检查环境变量

生产环境需要配置正确的 `.env` 文件：

```bash
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
```

#### 更新 OAuth 重定向 URL

在 GitHub/Google OAuth 设置中，添加生产环境的回调 URL：

```
https://your-domain.com
https://your-production-project.supabase.co/auth/v1/callback
```

#### 在 Supabase 中配置生产 URL

在 Supabase Dashboard 的 **Authentication > URL Configuration** 中：
- Site URL: `https://your-domain.com`
- Redirect URLs: `https://your-domain.com/**`

---

## 📞 获取帮助

如果以上方法都无法解决您的问题，请：

1. **查看完整日志**
   ```bash
   flutter run -d chrome --web-port=3000 --verbose
   ```

2. **检查浏览器控制台**
   按 `F12` 查看详细错误信息

3. **查看 Supabase 日志**
   在 Supabase Dashboard 中查看认证日志

4. **参考官方文档**
   - [Flutter 官方文档](https://flutter.dev/docs)
   - [Supabase 官方文档](https://supabase.com/docs)
   - [GetX 官方文档](https://github.com/jonataslaw/getx)

---

## 📚 相关文档

- [Supabase 配置指南](./SUPABASE_SETUP.md)
- [GitHub 登录配置](./QUICKSTART_GITHUB_AUTH.md)
- [Google 登录配置](./GOOGLE_AUTH_SETUP.md)
- [运行项目指南](./HOW_TO_RUN.md)
