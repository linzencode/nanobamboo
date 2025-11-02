# Google OAuth 登录测试指南

> **测试清单**：验证 Google 登录功能是否正常工作

---

## 📋 前置检查

在开始测试前，请确认以下配置已完成：

### 1. 环境变量配置

检查 `.env` 文件是否包含：

```env
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google OAuth 配置
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

✅ **验证方式**：
```bash
cat .env | grep GOOGLE_WEB_CLIENT_ID
```

---

### 2. Google Cloud Console 配置

确认已完成以下配置：

- ✅ 创建了 OAuth 2.0 Client ID（Web application）
- ✅ Authorized JavaScript origins 包含 `http://localhost:3000`
- ✅ 在 OAuth 同意屏幕添加了测试用户（开发阶段必需）

**检查方式**：
1. 访问 [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. 找到您的 Web Client ID
3. 确认配置正确

---

### 3. Supabase Dashboard 配置

确认已在 Supabase 启用 Google Provider：

- ✅ Authentication → Providers → Google 已启用
- ✅ Client ID 和 Client Secret 已填写
- ✅ 与 Google Cloud Console 的 Client ID 匹配

**检查方式**：
1. 访问 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择项目 → Authentication → Providers
3. 确认 Google Provider 已启用

---

### 4. 依赖安装

确保已安装所有依赖：

```bash
flutter pub get
```

---

## 🧪 测试步骤

### 步骤 1: 启动应用

```bash
flutter run -d chrome --web-port=3000
```

**预期输出**：
```
✓ Built build/web/main.dart.js
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...                         
web service listening on http://localhost:3000
```

---

### 步骤 2: 打开登录页面

1. 浏览器自动打开 http://localhost:3000
2. 点击右上角的 **"注册/登录"** 按钮
3. 进入登录页面

**预期结果**：
- ✅ 看到登录模态框
- ✅ 有两个标签页：社交登录、密码登录
- ✅ 社交登录标签页显示 GitHub 和 Google 按钮

---

### 步骤 3: 点击 Google 登录

点击 **"使用 Google 继续"** 按钮

**预期行为**：
- ✅ 弹出 Google 登录窗口（而不是跳转到新页面）
- ✅ 窗口显示 Google 账号选择页面

**控制台日志**：
```
🚀 开始 Google 登录流程...
```

---

### 步骤 4: 选择 Google 账号

在弹出的窗口中：
1. 选择您的 Google 账号（必须是测试用户）
2. 如果是首次登录，需要授权应用访问您的基本信息

**预期行为**：
- ✅ 显示您的 Google 账号列表
- ✅ 点击账号后显示授权页面（首次）

**⚠️ 可能遇到的错误**：
- **"未验证的应用"**：正常，点击"继续"即可（测试阶段）
- **"此应用未验证"**：需要在 OAuth 同意屏幕添加测试用户

---

### 步骤 5: 授权并登录

1. 授权应用访问您的基本信息
2. 弹窗自动关闭
3. 返回主页

**预期结果**：
- ✅ 登录窗口自动关闭
- ✅ 看到绿色成功提示："登录成功！欢迎回来，your@gmail.com！"
- ✅ 右上角显示您的 Google 头像和名称
- ✅ 可以点击头像查看用户菜单（登出、设置等）

**控制台日志**：
```
✅ Google 登录成功: your@gmail.com
✅ 获取到认证信息
🔐 使用 Google Token 登录 Supabase...
✅ Supabase session 创建成功
   用户: your@gmail.com
   ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   名称: Your Name
🎉 Google 登录流程完成！
✅ 用户已登录: your@gmail.com
```

---

### 步骤 6: 验证登录状态

**UI 验证**：
- ✅ Header 右上角显示用户头像（Google 头像）
- ✅ 点击头像显示下拉菜单：
  - 用户名
  - 邮箱
  - 登出按钮

**后端验证**：
1. 打开 [Supabase Dashboard](https://supabase.com/dashboard)
2. Authentication → Users
3. 应该看到新用户（邮箱为您的 Google 账号）

**本地存储验证**：
1. 打开浏览器控制台 → Application → Local Storage
2. 应该看到 `supabase.auth.token` 相关的键值
3. 包含 `access_token` 和 `refresh_token`

---

### 步骤 7: 测试登出

1. 点击右上角的用户头像
2. 点击 **"登出"** 按钮

**预期结果**：
- ✅ 显示提示："您已成功登出"
- ✅ Header 右上角恢复为 "注册/登录" 按钮
- ✅ 用户头像消失

**控制台日志**：
```
✅ Supabase session 已清除
✅ Web localStorage 已强制清除
用户已登出
```

---

### 步骤 8: 测试静默登录（可选）

1. 登出后，再次点击 **"使用 Google 继续"**
2. 如果之前未撤销授权，应该直接登录（不弹窗或快速弹窗后关闭）

**预期行为**：
- ✅ 静默登录成功（无需重新选择账号）
- ✅ 或快速弹窗后自动关闭

**控制台日志**：
```
🚀 开始 Google 登录流程...
✅ Google 登录成功: your@gmail.com （静默登录）
```

---

## ✅ 测试通过标准

如果以下所有项都通过，说明 Google 登录功能正常：

- [ ] 点击 "使用 Google 继续" 按钮弹出 Google 登录窗口
- [ ] 选择账号并授权成功
- [ ] 弹窗自动关闭，返回主页
- [ ] 显示绿色成功提示
- [ ] Header 显示 Google 头像和名称
- [ ] 控制台输出完整的登录日志（无错误）
- [ ] Supabase Dashboard 显示新用户
- [ ] 点击登出后状态正确清除
- [ ] 再次登录时可以静默登录（可选）

---

## ❌ 常见错误排查

### 错误 1: "popup_closed_by_user"

**现象**：
```
PlatformException(popup_closed_by_user, The user closed the popup, null, null)
```

**原因**：用户取消了 Google 登录

**解决**：这是正常行为，代码已处理，不影响使用

---

### 错误 2: "idpiframe_initialization_failed"

**现象**：
```
PlatformException(idpiframe_initialization_failed)
```

**原因**：
- Client ID 配置错误
- Authorized JavaScript origins 未配置

**解决**：
1. 检查 `.env` 中的 `GOOGLE_WEB_CLIENT_ID` 是否正确
2. 在 Google Cloud Console 检查 Authorized JavaScript origins 是否包含 `http://localhost:3000`

---

### 错误 3: "未获取到 ID Token"

**现象**：
```
❌ 未获取到 ID Token
```

**原因**：Scopes 配置不正确

**解决**：
检查 `lib/core/services/google_signin_service.dart` 中的 scopes：
```dart
scopes: [
  'email',
  'profile',
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/userinfo.email',
],
```

---

### 错误 4: "Invalid token"

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

### 错误 5: "此应用未验证"

**现象**：Google 登录页面显示 "此应用未验证"

**原因**：OAuth 同意屏幕未添加测试用户

**解决**：
1. 访问 [Google Cloud Console](https://console.cloud.google.com/apis/credentials/consent)
2. OAuth 同意屏幕 → 测试用户
3. 添加您的 Google 账号

---

### 错误 6: 登录后仍显示 "注册/登录" 按钮

**原因**：Session 未正确创建或状态未更新

**解决**：
1. 检查控制台日志，确认 `✅ Supabase session 创建成功`
2. 检查 Supabase Dashboard → Authentication → Users，确认用户已创建
3. 刷新页面（F5）看是否恢复登录状态

---

## 🎯 调试技巧

### 1. 查看详细日志

打开浏览器控制台（F12），查看完整的登录流程日志：

```
🚀 开始 Google 登录流程...
✅ Google 登录成功: your@gmail.com
✅ 获取到认证信息
ID Token: eyJhbGciOiJSUzI1N...
Access Token: ya29.a0AfB_byC...
🔐 使用 Google Token 登录 Supabase...
✅ Supabase session 创建成功
   用户: your@gmail.com
   ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   名称: Your Name
🎉 Google 登录流程完成！
✅ 用户已登录: your@gmail.com
```

---

### 2. 检查 Network 请求

打开 Network 标签，查看请求：

- **google-signin** 请求：Google OAuth 流程
- **https://your-project.supabase.co/auth/v1/token?grant_type=id_token** - 使用 Google token 创建 Supabase session

---

### 3. 检查 Local Storage

打开 Application → Local Storage → http://localhost:3000

应该看到：
- `supabase.auth.token` - 包含 access_token 和 refresh_token

---

### 4. 清除缓存重新测试

如果遇到奇怪的问题，尝试清除缓存：

**浏览器控制台**：
```javascript
localStorage.clear()
sessionStorage.clear()
```

**或者使用隐私模式（Incognito）**：
- Chrome: Ctrl+Shift+N
- 避免缓存干扰

---

## 📚 相关文档

- [Google OAuth 配置指南](./GOOGLE_OAUTH_SETUP_GUIDE.md) - 完整配置步骤
- [Google OAuth 快速开始](./GOOGLE_OAUTH_QUICKSTART.md) - 5分钟配置
- [Supabase 配置指南](../setup/SUPABASE_SETUP.md) - Supabase 基础配置

---

## 🤝 获取帮助

如果测试失败，请：

1. 仔细阅读错误信息
2. 查看本文档的"常见错误排查"部分
3. 检查控制台日志
4. 查看 Network 请求
5. 参考完整的配置指南

---

**文档版本**: 1.0  
**测试环境**: Flutter 3.2.0+ / google_sign_in 6.2.1 / Supabase 2.10.0  
**最后更新**: 2025-11-02  
**维护者**: NanoBamboo Team

