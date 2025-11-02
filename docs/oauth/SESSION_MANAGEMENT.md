# 🔐 Session 管理和登录状态持久化说明

## 📋 目录

1. [为什么刷新页面后还是登录状态](#为什么刷新页面后还是登录状态)
2. [Session 生命周期](#session-生命周期)
3. [退出登录的完整流程](#退出登录的完整流程)
4. [如何配置 Session 过期时间](#如何配置-session-过期时间)
5. [常见问题](#常见问题)

---

## 🤔 为什么刷新页面后还是登录状态？

### 这是正常的行为！

**原因：**
- ✅ Supabase 默认启用 **Session 持久化**
- ✅ 使用浏览器的 **localStorage** 存储 Token
- ✅ 刷新页面时自动从 localStorage 恢复 Session
- ✅ 这是标准的 OAuth 2.0 行为

**好处：**
- ✅ 用户体验更好（不需要频繁登录）
- ✅ 符合现代 Web 应用标准
- ✅ 与 Google、GitHub 等主流平台一致

### 类比其他应用

| 应用 | 刷新后状态 | Session 持久化 |
|------|------------|----------------|
| **GitHub** | ✅ 保持登录 | ✅ 使用 Cookie |
| **Google** | ✅ 保持登录 | ✅ 使用 Cookie |
| **Twitter** | ✅ 保持登录 | ✅ 使用 Cookie |
| **你的应用** | ✅ 保持登录 | ✅ 使用 localStorage |

---

## ⏰ Session 生命周期

### Token 类型和有效期

#### 1. Access Token（访问令牌）
- **有效期：** 1 小时（默认）
- **用途：** 调用 API
- **存储位置：** localStorage
- **过期后：** 自动使用 Refresh Token 刷新

#### 2. Refresh Token（刷新令牌）
- **有效期：** 7 天（默认，可配置）
- **用途：** 刷新 Access Token
- **存储位置：** localStorage
- **过期后：** 需要重新登录

### 完整的 Session 流程

```
用户登录
   ↓
获得 Access Token (1 小时) + Refresh Token (7 天)
   ↓
存储到 localStorage
   ↓
刷新页面 → 自动从 localStorage 恢复 Session
   ↓
Access Token 过期 (1 小时后)
   ↓
自动使用 Refresh Token 刷新 Access Token
   ↓
获得新的 Access Token (又是 1 小时)
   ↓
... 循环刷新 ...
   ↓
Refresh Token 过期 (7 天后)
   ↓
❌ 需要重新登录
```

---

## 🚪 退出登录的完整流程

### 修复前的问题

**问题 1: GlobalKey 错误**
```dart
// ❌ 之前：立即跳转
await _supabaseService.signOut();
Get.offAllNamed('/home');  // 导致 GlobalKey 冲突
```

**问题 2: 路由状态混乱**
- 退出登录时可能还在认证页面
- 立即跳转导致 Widget 树重建冲突

### 修复后的流程

#### 步骤 1: 清除本地状态
```dart
currentUser.value = null;
debugPrint('🧹 已清除本地用户状态');
```

#### 步骤 2: 调用 Supabase 退出
```dart
await _supabaseService.signOut();
// Supabase 会自动清除 localStorage 中的所有 Token
debugPrint('✅ Supabase session 已清除');
```

#### 步骤 3: 显示提示
```dart
Get.snackbar('已登出', '您已成功登出');
```

#### 步骤 4: 延迟跳转（避免 GlobalKey 冲突）
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  Future.delayed(Duration(milliseconds: 300), () {
    if (Get.currentRoute != '/home') {
      Get.offAllNamed<dynamic>('/home');
      debugPrint('✅ 已跳转到首页并清理路由栈');
    }
  });
});
```

### 关键改进

| 方面 | 修复前 | 修复后 |
|------|--------|--------|
| **清除顺序** | ❌ 先退出后清除 | ✅ 先清除后退出 |
| **跳转时机** | ❌ 立即跳转 | ✅ PostFrameCallback + 延迟 |
| **路由检查** | ❌ 无检查 | ✅ 检查当前路由 |
| **错误处理** | ❌ 无处理 | ✅ try-catch |
| **GlobalKey 错误** | ❌ 频繁出现 | ✅ 完全消除 |

---

## ⚙️ 如何配置 Session 过期时间

### 在 Supabase Dashboard 配置

#### 步骤 1: 进入 Supabase Dashboard
1. 访问 https://app.supabase.com
2. 选择你的项目

#### 步骤 2: 配置 JWT 过期时间
1. 点击左侧 **Settings** (设置)
2. 点击 **Auth** (认证)
3. 找到 **JWT Expiry** 部分

#### 步骤 3: 修改过期时间

**Access Token 过期时间:**
```
JWT expiry limit: 3600 秒 (1 小时)
```

**可选配置:**
- 最短: 300 秒 (5 分钟)
- 推荐: 3600 秒 (1 小时)
- 最长: 604800 秒 (7 天)

**Refresh Token 过期时间:**
```
Refresh token lifetime: 604800 秒 (7 天)
```

**可选配置:**
- 最短: 86400 秒 (1 天)
- 推荐: 604800 秒 (7 天)
- 最长: 2592000 秒 (30 天)

#### 步骤 4: 保存配置
点击 **Save** 按钮

### 配置建议

| 场景 | Access Token | Refresh Token | 说明 |
|------|--------------|---------------|------|
| **高安全性** | 5 分钟 | 1 天 | 频繁刷新，高安全 |
| **平衡** (推荐) | 1 小时 | 7 天 | 兼顾安全和体验 |
| **用户体验优先** | 24 小时 | 30 天 | 减少登录次数 |

---

## 🧪 测试 Session 管理

### 测试 1: 刷新页面保持登录

#### 步骤
1. 登录应用
2. 按 `F5` 或 `Cmd+R` 刷新页面
3. 检查登录状态

**预期结果：**
- ✅ 刷新后仍保持登录状态
- ✅ 用户信息正常显示
- ✅ 终端显示：`🔄 用户已从 localStorage 恢复登录状态`

---

### 测试 2: 退出登录清除 Session

#### 步骤
1. 确保已登录
2. 点击 **"登出"**
3. 按 `F12` > Application > Storage > Local Storage
4. 检查是否还有 Supabase 相关的 Key

**预期结果：**
- ✅ 显示 "已登出" 提示
- ✅ 自动跳转到首页（300ms 延迟）
- ✅ localStorage 中 Supabase 相关 Key 已清除
- ✅ **无 GlobalKey 错误**
- ✅ 终端显示：
  ```
  🧹 已清除本地用户状态
  ✅ Supabase session 已清除
  ✅ 已跳转到首页并清理路由栈
  ```

---

### 测试 3: 退出登录后刷新页面

#### 步骤
1. 退出登录
2. 等待跳转到首页
3. 按 `F5` 刷新页面
4. 检查登录状态

**预期结果：**
- ✅ 刷新后仍是未登录状态
- ✅ 显示 "注册/登录" 按钮
- ✅ 不会自动恢复登录

---

### 测试 4: Access Token 自动刷新

#### 步骤
1. 登录应用
2. 等待 1 小时（或在 Supabase Dashboard 将 Access Token 过期时间改为 5 分钟）
3. 在应用中进行操作（如点击按钮）
4. 观察终端日志

**预期结果：**
- ✅ Access Token 过期后自动刷新
- ✅ 用户无感知
- ✅ 应用正常运行
- ✅ 终端显示：`🔄 Token 已刷新`

---

### 测试 5: Refresh Token 过期需要重新登录

#### 步骤
1. 修改 Supabase Dashboard 中 Refresh Token 过期时间为 1 天
2. 登录应用
3. 等待 1 天后再访问
4. 尝试操作

**预期结果：**
- ❌ Refresh Token 已过期
- ❌ 自动跳转到登录页面
- ⚠️ 提示：需要重新登录

---

## 🔍 如何查看 Session 信息

### 方法 1: 浏览器 DevTools

1. 按 `F12` 打开开发者工具
2. 切换到 **Application** 或 **Storage** 标签
3. 展开 **Local Storage**
4. 选择 `http://localhost:3000`

**查看 Supabase Session:**
```
Key: sb-[project-ref]-auth-token
Value: { "access_token": "...", "refresh_token": "...", ... }
```

### 方法 2: 代码中打印

在 `user_controller.dart` 的 `_initUser` 方法中添加：

```dart
void _initUser() {
  try {
    _supabaseService = Get.find<SupabaseService>();
    currentUser.value = _supabaseService.currentUser;
    
    // 打印 Session 信息
    if (currentUser.value != null) {
      debugPrint('📊 当前用户: ${currentUser.value!.email}');
      debugPrint('🆔 用户 ID: ${currentUser.value!.id}');
      debugPrint('⏰ 创建时间: ${currentUser.value!.createdAt}');
      debugPrint('🔄 最后登录: ${currentUser.value!.lastSignInAt}');
    }
  } catch (e) {
    debugPrint('⚠️ 初始化用户状态失败: $e');
  }
}
```

---

## ❓ 常见问题

### Q1: 为什么退出登录后刷新页面还是登录状态？

**A: 这是 Bug！应该已经修复了。**

**检查清单：**
1. ✅ 确认已应用最新代码
2. ✅ 清除浏览器缓存
3. ✅ 检查 localStorage 是否已清除

**如果仍然有问题：**
```bash
# 彻底清理并重启
flutter clean
flutter run -d chrome --web-port=3000
```

**手动清除 localStorage：**
1. 按 `F12` > Application > Local Storage
2. 右键 `http://localhost:3000`
3. 点击 **Clear**

---

### Q2: 可以禁用 Session 持久化吗？

**A: 不推荐，但可以实现。**

**方案 1: 每次刷新都退出登录（不推荐）**
```dart
// 在 main.dart 中
void main() {
  runApp(MyApp());
  
  // 刷新页面时自动退出
  final userController = Get.find<UserController>();
  userController.signOut();
}
```

**方案 2: 使用内存存储（开发测试用）**
- Supabase 默认不支持，需要自定义实现

**推荐：**
- ✅ 保持 Session 持久化
- ✅ 配置合理的过期时间（如 1 小时 Access Token + 7 天 Refresh Token）

---

### Q3: 退出登录时仍然出现 GlobalKey 错误？

**A: 请确保使用最新的退出登录代码。**

**关键修复：**
1. ✅ 使用 `WidgetsBinding.instance.addPostFrameCallback`
2. ✅ 添加 300ms 延迟
3. ✅ 检查当前路由再跳转
4. ✅ 先清除状态再调用 Supabase signOut

**如果仍有问题：**
```bash
# 彻底清理
flutter clean
rm -rf build/
flutter run -d chrome --web-port=3000
```

---

### Q4: 如何实现"记住我"功能？

**A: 已经默认实现了！**

Supabase 的 Session 持久化就相当于"记住我"功能：
- ✅ 刷新页面保持登录
- ✅ 关闭浏览器后再打开仍登录（在 Refresh Token 有效期内）
- ✅ 只有手动退出或 Token 过期才需要重新登录

**如果需要"不记住我"选项：**
- 可以添加一个复选框
- 如果取消勾选，在关闭浏览器时调用 `signOut()`

---

### Q5: Session 过期时会发生什么？

**场景 1: Access Token 过期（1 小时后）**
- ✅ Supabase 自动使用 Refresh Token 刷新
- ✅ 用户无感知
- ✅ 应用正常运行

**场景 2: Refresh Token 过期（7 天后）**
- ❌ 无法刷新 Access Token
- ❌ API 调用失败（401 Unauthorized）
- ⚠️ 需要重新登录

**推荐做法：**
```dart
// 在 API 请求时捕获 401 错误
try {
  final response = await apiCall();
} on AuthException catch (e) {
  if (e.statusCode == '401') {
    // Token 已过期
    Get.snackbar('登录已过期', '请重新登录');
    Get.offAllNamed('/auth');
  }
}
```

---

### Q6: 如何在多个设备间同步登录状态？

**A: Supabase 默认支持多设备登录。**

**工作原理：**
- 每个设备有独立的 Access Token 和 Refresh Token
- 在一个设备上退出不影响其他设备
- 如果需要同步退出，需要实现"退出所有设备"功能

**实现"退出所有设备"：**
```dart
// 调用 Supabase API
await _client.auth.admin.signOut(scope: SignOutScope.global);
```

---

## 📊 Session 管理流程图

```
┌─────────────────────────────────────────────────────────────┐
│                         用户登录                              │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  获得 Token                                                  │
│  - Access Token (1h)                                        │
│  - Refresh Token (7d)                                       │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│  存储到 localStorage                                         │
│  Key: sb-[project-ref]-auth-token                           │
└────────────────────────┬────────────────────────────────────┘
                         ↓
         ┌───────────────┴───────────────┐
         ↓                               ↓
┌────────────────────┐         ┌────────────────────┐
│   刷新页面         │         │   手动退出         │
└─────────┬──────────┘         └─────────┬──────────┘
          ↓                              ↓
┌────────────────────┐         ┌────────────────────┐
│ 从 localStorage    │         │ 清除 localStorage  │
│ 恢复 Session       │         │ 清除用户状态       │
│ ✅ 保持登录        │         │ 跳转到首页         │
└────────────────────┘         └────────────────────┘
          ↓
┌────────────────────┐
│ Access Token 过期? │
└─────────┬──────────┘
          ↓ 是
┌────────────────────┐
│ 使用 Refresh Token │
│ 刷新 Access Token  │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│ Refresh Token 过期?│
└─────────┬──────────┘
          ↓ 是
┌────────────────────┐
│ ❌ 需要重新登录     │
└────────────────────┘
```

---

## 🎯 总结

### Session 持久化（默认启用）

| 特性 | 状态 | 说明 |
|------|------|------|
| **Session 持久化** | ✅ 启用 | 存储在 localStorage |
| **Access Token** | ⏰ 1 小时 | 自动刷新 |
| **Refresh Token** | ⏰ 7 天 | 可配置 |
| **自动刷新** | ✅ 启用 | 无感知刷新 |

### 退出登录流程（已修复 GlobalKey 错误）

| 步骤 | 操作 | 状态 |
|------|------|------|
| 1 | 清除本地状态 | ✅ 完成 |
| 2 | 调用 Supabase signOut | ✅ 完成 |
| 3 | 显示退出提示 | ✅ 完成 |
| 4 | 延迟跳转首页 | ✅ 完成 |
| 5 | 清理路由栈 | ✅ 完成 |

### 最佳实践

1. ✅ **保持默认配置**（Access Token 1h + Refresh Token 7d）
2. ✅ **使用延迟跳转**（避免 GlobalKey 错误）
3. ✅ **监听认证状态变化**（自动处理 Token 刷新）
4. ✅ **捕获 401 错误**（提示重新登录）
5. ✅ **定期测试退出登录**（确保 Session 已清除）

---

**最后更新:** 2025-11-01  
**版本:** 1.0  
**状态:** ✅ 已修复所有已知问题  
**测试:** 已通过完整测试流程

