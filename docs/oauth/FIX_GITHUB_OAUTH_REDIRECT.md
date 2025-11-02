# 🔧 修复 GitHub OAuth "Invalid Redirect URI" 错误

## ❌ 错误原因

GitHub 提示：`The redirect_uri is not associated with this application.`

这是因为使用 **Supabase OAuth** 时，GitHub 不会直接回调到您的应用，而是先回调到 **Supabase 服务器**！

---

## ✅ 正确的 OAuth 流程

```
用户点击登录
    ↓
打开 GitHub 授权页面
    ↓
用户授权
    ↓
GitHub 回调到 Supabase 服务器 ⬅️ 关键！
    ↓
Supabase 处理 token exchange（使用 Client Secret）
    ↓
Supabase 重定向回您的应用（http://localhost:3000/home）
    ↓
登录成功
```

---

## 🔧 修复步骤

### 步骤 1️⃣：查找您的 Supabase Project URL

1. 打开终端，查看您的 `.env` 文件：

```bash
cd /Users/charles/Documents/2-WorkSpace/1-Project/cursorflutter/nanobamboo
cat .env | grep SUPABASE_URL
```

2. 您会看到类似：

```
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
```

3. 记下这个 URL，例如：`https://anckcqushwdznckreytdg.supabase.co`

---

### 步骤 2️⃣：修改 GitHub OAuth App 配置

1. 访问 GitHub Settings: https://github.com/settings/developers
2. 找到您的 OAuth App：`NanoBamboo`（或其他名称）
3. 点击应用名称进入设置页面
4. 修改以下配置：

#### ✅ Authorization callback URL（回调 URL）

**错误的配置**：
```
http://localhost:3000/home
http://localhost:3000/auth/callback
```

**正确的配置**：
```
https://your-project-ref.supabase.co/auth/v1/callback
```

**示例**（假设您的 Supabase URL 是 `https://anckcqushwdznckreytdg.supabase.co`）：
```
https://anckcqushwdznckreytdg.supabase.co/auth/v1/callback
```

#### ✅ Homepage URL（主页 URL）

可以保持为：
```
http://localhost:3000
```

或者改为您的 Supabase URL：
```
https://your-project-ref.supabase.co
```

5. 点击 "Update application" 保存

---

### 步骤 3️⃣：在 Supabase Dashboard 中配置 GitHub Provider

**重要**：还需要在 Supabase 中启用 GitHub 登录！

1. 登录 [Supabase Dashboard](https://app.supabase.com)
2. 选择您的项目
3. 点击左侧菜单 "Authentication" > "Providers"
4. 找到 "GitHub" 并展开
5. 启用 GitHub provider（打开开关）
6. 填入以下信息：
   - **Client ID**：从 GitHub OAuth App 复制
   - **Client Secret**：从 GitHub OAuth App 复制（如果没有，需要重新生成）
7. 点击 "Save"

---

### 步骤 4️⃣：测试登录

1. 刷新您的应用页面
2. 点击"GitHub 登录"
3. 应该能成功跳转到 GitHub 授权页面
4. 授权后自动跳转回应用首页
5. 显示登录成功 ✅

---

## 📋 配置检查清单

- [ ] 找到了 Supabase Project URL（从 `.env` 文件）
- [ ] 修改了 GitHub OAuth App 的回调 URL 为：
  ```
  https://<your-project-ref>.supabase.co/auth/v1/callback
  ```
- [ ] 在 Supabase Dashboard 中启用了 GitHub Provider
- [ ] 在 Supabase 中填入了 GitHub Client ID 和 Client Secret
- [ ] 测试登录成功

---

## 🆘 仍然有问题？

### 错误 1：Supabase Dashboard 提示 Client ID/Secret 无效

**解决方案**：
1. 重新生成 GitHub Client Secret
2. 复制新的 Client Secret 到 Supabase
3. 确保 Client ID 和 Secret 匹配

### 错误 2：授权后无法跳转回应用

**检查**：
1. 确认代码中的 `redirectTo` 参数：
   ```dart
   redirectTo: 'http://localhost:3000/home'
   ```
2. 确认 Supabase 的 "Site URL" 配置：
   - 在 Supabase Dashboard > Authentication > URL Configuration
   - 添加 `http://localhost:3000` 到 "Site URL" 或 "Additional Redirect URLs"

### 错误 3：登录后显示 404

**解决方案**：
- 确认您的应用有 `/home` 路由
- 或者将 `redirectTo` 改为 `http://localhost:3000/`

---

## 📚 参考文档

- [Supabase GitHub OAuth 指南](https://supabase.com/docs/guides/auth/social-login/auth-github)
- [GitHub OAuth Apps 文档](https://docs.github.com/en/apps/oauth-apps)
- 项目文档：`SUPABASE_SETUP.md`

---

**最后更新**：2025-11-02
**修复原因**：GitHub OAuth App 回调 URL 配置错误

