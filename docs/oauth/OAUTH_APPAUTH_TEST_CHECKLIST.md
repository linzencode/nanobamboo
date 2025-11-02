# OAuth 2.0 + PKCE 测试清单

## 🎯 测试目标

验证新的 `flutter_appauth` OAuth 2.0 + PKCE 流程是否能彻底解决 GlobalKey 冲突问题。

## ⚠️ 测试前准备

### 1. 确认 GitHub OAuth App 配置

访问 [GitHub OAuth Apps](https://github.com/settings/developers)，确认：

- ✅ **Client ID**: `Ov23lixyWLDfY2QTuFDt`
- ✅ **Authorization callback URL**: `http://localhost:3000/auth/callback`

**如果回调 URL 不是 `/auth/callback`，请立即更新！**

### 2. 等待应用启动

```bash
flutter run -d chrome --web-port=3000
```

浏览器会自动打开 `http://localhost:3000`，等待应用完全加载。

## 📋 测试步骤

### 测试 1：基本路由测试 ✅

1. **首页加载**
   - ✅ 页面正常显示
   - ✅ Header 显示 "注册/登录" 按钮

2. **跳转到登录页**
   - ✅ 点击 "注册/登录"
   - ✅ URL 变为 `http://localhost:3000/auth`
   - ✅ 登录页面正常显示

3. **返回首页**
   - ✅ 点击浏览器返回按钮
   - ✅ URL 变回 `http://localhost:3000/home`
   - ✅ 首页正常显示

### 测试 2：GitHub OAuth 流程测试 🔐

1. **进入登录页**
   - 点击 Header 的 "注册/登录"
   - 选择 "社交登录" 标签

2. **发起 OAuth 请求**
   - 点击 "使用 GitHub 继续" 按钮
   - **预期**：浏览器新标签页打开 GitHub 授权页面
   - **URL 应该包含**：
     ```
     https://github.com/login/oauth/authorize?
       client_id=Ov23lixyWLDfY2QTuFDt
       &redirect_uri=http://localhost:3000/auth/callback
       &code_challenge=...
       &code_challenge_method=S256
     ```

3. **GitHub 授权**
   - 在 GitHub 页面点击 "Authorize" 按钮
   - **预期**：GitHub 重定向到 `http://localhost:3000/auth/callback?code=xxx`

4. **flutter_appauth 拦截回调**
   - **预期**：flutter_appauth 自动拦截 URL
   - **预期**：自动交换 access_token
   - **预期**：页面不会显示 "404" 或错误

5. **Supabase 创建会话**
   - **预期**：Supabase 使用 token 创建会话
   - **预期**：用户信息更新

6. **返回主页**
   - **预期**：自动返回登录页面
   - **预期**：登录页面关闭，回到首页
   - **预期**：Header 显示用户头像和名称

### 测试 3：关键检查点 🎯

#### 控制台输出检查

在浏览器控制台（F12）查看，应该看到：

```
✅ 正确的输出：
🔐 开始 GitHub OAuth 2.0 + PKCE 流程...
✅ GitHub OAuth 成功！
   Access Token: gho_xxxxx...
   Token Type: bearer
🔐 使用 GitHub token 登录 Supabase...
✅ Supabase session 创建成功
   用户: your@email.com
   ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
✅ 登录成功: your@email.com

❌ 不应该出现：
Exception caught by widgets library
A GlobalKey was used multiple times inside one widget's child list
The following assertion was thrown
```

#### URL 变化检查

OAuth 流程中的 URL 变化：

```
1. http://localhost:3000/auth
   ↓ (点击 GitHub 登录)
2. https://github.com/login/oauth/authorize?client_id=xxx&redirect_uri=http://localhost:3000/auth/callback&code_challenge=xxx
   ↓ (用户授权)
3. http://localhost:3000/auth/callback?code=xxx
   ↓ (flutter_appauth 拦截)
4. http://localhost:3000/auth
   ↓ (自动返回)
5. http://localhost:3000/home
```

**关键点**：
- ✅ 回调到 `/auth/callback`（不是 `/home`）
- ✅ 没有 `#access_token=` 在 URL 中
- ✅ 使用 `?code=` 参数（不是 fragment）

#### 页面状态检查

- ✅ 没有红色错误页面
- ✅ 没有"找不到页面"提示
- ✅ Header 正确显示用户信息
- ✅ 用户头像可点击，显示下拉菜单

### 测试 4：登出测试 🚪

1. **点击用户头像**
   - ✅ 下拉菜单显示
   - ✅ 菜单包含"退出登录"选项

2. **点击退出登录**
   - ✅ 显示"已登出"提示
   - ✅ URL 变为 `http://localhost:3000/home`
   - ✅ Header 显示"注册/登录"按钮

3. **控制台输出**
   ```
   ✅ Supabase 退出登录成功
   ✅ Supabase session 已清除
   ✅ 已跳转到首页并清理路由栈
   ```

### 测试 5：重复登录测试 🔄

1. **登出后再次登录**
   - ✅ 点击"注册/登录"
   - ✅ 点击"使用 GitHub 继续"
   - ✅ GitHub 可能直接授权（不需要再次点击）
   - ✅ 登录成功

2. **控制台检查**
   - ✅ 没有"Refresh Token Not Found"错误
   - ✅ 没有 GlobalKey 错误

## 📊 测试结果记录

### ✅ 成功标准

- [ ] 所有 URL 变化符合预期
- [ ] 没有任何 GlobalKey 错误
- [ ] 没有红色错误页面
- [ ] 控制台输出完整且正确
- [ ] 用户信息正确显示
- [ ] 登出功能正常
- [ ] 重复登录无问题

### ❌ 失败场景

如果出现以下任何情况，说明测试失败：

- 页面显示红色错误
- 控制台出现 GlobalKey 错误
- OAuth 回调后页面空白或404
- 用户信息未更新
- 登出后无法再次登录

## 🐛 常见问题排查

### 问题 1：回调后页面空白

**可能原因**：
- GitHub OAuth App 的回调 URL 不正确

**解决方案**：
1. 访问 [GitHub OAuth Apps](https://github.com/settings/developers)
2. 确认回调 URL 是 `http://localhost:3000/auth/callback`
3. 保存后重新测试

### 问题 2：OAuth 授权后卡住

**可能原因**：
- flutter_appauth 未能正确拦截回调

**解决方案**：
1. 查看浏览器控制台的错误信息
2. 确认 `flutter_appauth` 版本正确（^6.0.5）
3. 重启应用后重试

### 问题 3：Token 交换失败

**可能原因**：
- GitHub OAuth App 配置错误
- Client ID 不匹配

**解决方案**：
1. 确认 Client ID: `Ov23lixyWLDfY2QTuFDt`
2. 检查 `lib/core/services/oauth_service.dart` 中的配置
3. 确认没有 Client Secret 泄露

### 问题 4：Supabase session 创建失败

**可能原因**：
- Supabase 配置问题
- Token 格式不正确

**解决方案**：
1. 检查 `.env` 文件的 Supabase 配置
2. 查看控制台的详细错误信息
3. 确认 Supabase 项目的 GitHub OAuth 集成已启用

## 📈 性能对比

### 旧方案（Supabase OAuth）

- ❌ GlobalKey 错误频发
- ❌ 页面卡死
- ❌ 用户体验差
- ❌ 开发者压力大

### 新方案（flutter_appauth + PKCE）

- ✅ 零 GlobalKey 错误
- ✅ 流畅的用户体验
- ✅ 生产级安全性
- ✅ 开发者舒心

## 🎉 测试完成

如果所有测试都通过，恭喜！您已经成功实施了生产级的 OAuth 2.0 + PKCE 方案！

**下一步**：
1. 提交代码到 Git
2. 更新文档
3. 部署到生产环境（记得更新生产环境的回调 URL）

---

**测试时间**: ___________  
**测试人**: ___________  
**测试结果**: [ ] 通过 [ ] 失败  
**备注**: ___________

