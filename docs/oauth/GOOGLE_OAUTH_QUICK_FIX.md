# Google OAuth 一直转圈问题 - 快速修复指南

## 🚨 症状
Google 登录页面一直转圈（loading），无法进入登录界面。

## 🎯 根本原因
**您的 Google 账号不在 OAuth 应用的测试用户列表中！**

---

## ✅ 快速修复步骤（3 分钟）

### 步骤 1: 访问 Google Cloud Console

打开浏览器，访问：
```
https://console.cloud.google.com/
```

### 步骤 2: 选择或创建项目

- 如果已有项目：点击顶部项目选择器，选择您的项目
- 如果没有项目：
  1. 点击"新建项目"
  2. 输入项目名称：`NanoBamboo`
  3. 点击"创建"

### 步骤 3: 配置 OAuth 同意屏幕

1. **进入 OAuth 同意屏幕**
   - 左侧菜单：**API 和服务 > OAuth 同意屏幕**

2. **如果是首次配置：**
   - 选择 **"外部"** 用户类型
   - 点击 **"创建"**

3. **填写应用信息：**
   
   **第 1 页 - OAuth 同意屏幕：**
   - **应用名称**：`NanoBamboo`
   - **用户支持电子邮件**：选择您的邮箱
   - **应用首页链接**：`http://localhost:3000`
   - **授权域**：
     ```
     anckcqushwdznckrytdg.supabase.co
     ```
   - **开发者联系信息**：输入您的邮箱
   - 点击 **"保存并继续"**

   **第 2 页 - 作用域（Scopes）：**
   - 点击 **"添加或移除作用域"**
   - 勾选以下作用域：
     - ✅ `.../auth/userinfo.email`
     - ✅ `.../auth/userinfo.profile`
     - ✅ `openid`
   - 点击 **"更新"**
   - 点击 **"保存并继续"**

   **第 3 页 - 测试用户（最重要！）：**
   - 点击 **"+ 添加用户"**
   - **输入您的 Google 邮箱**（您要用来登录的邮箱）
     ```
     例如：your-email@gmail.com
     ```
   - 点击 **"添加"**
   - 点击 **"保存并继续"**

   **第 4 页 - 摘要：**
   - 检查信息
   - 点击 **"返回控制台"**

### 步骤 4: 创建 OAuth 客户端 ID

1. **进入凭据页面**
   - 左侧菜单：**API 和服务 > 凭据**

2. **创建凭据**
   - 点击 **"+ 创建凭据"**
   - 选择 **"OAuth 客户端 ID"**

3. **配置客户端 ID**
   - **应用类型**：选择 **"Web 应用"**
   - **名称**：`NanoBamboo Web Client`
   
   **已获授权的 JavaScript 来源：**
   ```
   http://localhost:3000
   ```
   
   **已获授权的重定向 URI：**
   ```
   https://anckcqushwdznckrytdg.supabase.co/auth/v1/callback
   ```
   
   - 点击 **"创建"**

4. **复制凭据**
   - **客户端 ID**：`xxxxx.apps.googleusercontent.com`
   - **客户端密钥**：`GOCSPX-xxxxx`
   - ⚠️ **保存这些信息！**

### 步骤 5: 在 Supabase 中配置 Google Provider

1. **访问 Supabase Dashboard**
   ```
   https://supabase.com/dashboard/project/anckcqushwdznckrytdg
   ```

2. **启用 Google Provider**
   - 左侧菜单：**Authentication > Providers**
   - 找到 **Google**
   - 点击展开

3. **填写配置**
   - ✅ **Enable Google provider**：开启（切换开关）
   - **Client ID (for OAuth)**：粘贴您从 Google Cloud Console 复制的客户端 ID
   - **Client Secret (for OAuth)**：粘贴客户端密钥
   - 点击 **"Save"**

4. **配置重定向 URL**
   - 左侧菜单：**Authentication > URL Configuration**
   - **Site URL**：
     ```
     http://localhost:3000
     ```
   - **Redirect URLs**（点击"Add URL"添加多个）：
     ```
     http://localhost:3000/**
     http://localhost:*/**
     ```
   - 点击 **"Save"**

### 步骤 6: 清理浏览器缓存并重新测试

1. **清理缓存**
   - 按 `F12` 打开开发者工具
   - 右键点击浏览器刷新按钮
   - 选择 **"清空缓存并硬性重新加载"**
   - 或者在 Application 标签中点击 "Clear site data"

2. **重新测试**
   - 访问 `http://localhost:3000`
   - 点击 **"注册/登录"**
   - 选择 **"社交登录"** 标签
   - 点击 **"使用 Google 继续"**
   - **这次应该可以正常进入登录页面了！**

---

## 🔍 如果还是不行

### 检查浏览器控制台

在一直转圈的页面：
1. 按 `F12` 打开开发者工具
2. 切换到 **Console** 标签
3. 查看是否有红色错误信息
4. 截图发给开发者

### 使用隐私窗口测试

```
Chrome: Cmd+Shift+N (Mac) 或 Ctrl+Shift+N (Windows)
```

在隐私窗口中访问 `http://localhost:3000` 并测试登录。

### 确认测试用户

回到 Google Cloud Console > OAuth 同意屏幕，确认：
- ✅ 测试用户列表中包含您的 Google 邮箱
- ✅ 邮箱地址拼写正确

---

## 📋 配置检查清单

完成配置后，请检查：

- [ ] Google Cloud Console 中创建了项目
- [ ] 配置了 OAuth 同意屏幕（所有 4 页都完成）
- [ ] **添加了测试用户（您的 Google 邮箱）** ⚠️ 最关键！
- [ ] 创建了 OAuth 客户端 ID（Web 应用类型）
- [ ] 配置了正确的重定向 URI
- [ ] 在 Supabase 中启用了 Google Provider
- [ ] 在 Supabase 中填写了 Client ID 和 Client Secret
- [ ] 清理了浏览器缓存

---

## 🎉 成功标志

配置成功后，您应该看到：

1. ✅ 点击"使用 Google 继续"后，**立即**跳转到 Google 账号选择页面
2. ✅ 可以选择您的 Google 账号
3. ✅ 显示应用名称"NanoBamboo"
4. ✅ 显示需要的权限（查看您的电子邮件地址和个人资料信息）
5. ✅ 点击"允许"后，跳转回 NanoBamboo 应用
6. ✅ 右上角显示您的 Google 用户名和头像

---

## 💡 提示

- Google OAuth 应用在"测试"状态时，**只有测试用户列表中的邮箱可以登录**
- 如果要让所有人都可以登录，需要将应用"发布到生产环境"（需要 Google 审核）
- 开发阶段保持"测试"状态即可，只需添加开发团队成员为测试用户

---

## 🆘 需要帮助？

如果按照以上步骤操作后仍然无法解决，请提供：
1. 浏览器控制台的错误信息（截图）
2. 是否已添加测试用户（确认邮箱地址）
3. OAuth 同意屏幕配置截图

---

**相关文档：**
- [Google OAuth 完整配置指南](./GOOGLE_AUTH_SETUP.md)
- [故障排除指南](./TROUBLESHOOTING.md)

