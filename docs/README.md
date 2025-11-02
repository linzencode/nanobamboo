# 项目文档目录

本目录包含了 NanoBamboo 项目的所有技术文档，按主题分类整理。

## 📁 文档结构

### 📌 根目录主要文档
- [README.md](../README.md) - 项目总览和简介
- [HOW_TO_RUN.md](../HOW_TO_RUN.md) - 快速开始和运行指南

---

## 📂 分类文档

### 🔐 OAuth 和认证 (`oauth/`)
OAuth 集成、认证流程、第三方登录等相关文档。

#### 📖 核心文档
- **`GITHUB_OAUTH_IMPLEMENTATION_GUIDE.md`** - 🌟 **GitHub OAuth 完整实现指南**（推荐首读）
  - 技术选型和架构
  - 完整实现步骤
  - 踩过的坑和解决方案
  - 配置清单和最佳实践

#### 🔧 问题修复
- `FIX_GITHUB_OAUTH_REDIRECT.md` - GitHub OAuth 重定向修复
- `FLUTTER_APPAUTH_SETUP.md` - Flutter AppAuth 配置指南
- `GITHUB_LOGIN_GLOBALKEY_FIX.md` - GitHub 登录 GlobalKey 问题修复
- `GITHUB_OAUTH_APPAUTH_SETUP.md` - GitHub OAuth AppAuth 配置
- `GOOGLE_AUTH_SETUP.md` - Google 认证配置
- `GOOGLE_OAUTH_QUICK_FIX.md` - Google OAuth 快速修复
- `OAUTH_APPAUTH_IMPLEMENTATION_SUMMARY.md` - OAuth AppAuth 实现总结
- `OAUTH_APPAUTH_TEST_CHECKLIST.md` - OAuth AppAuth 测试清单
- `OAUTH_CALLBACK_FIX_TEST.md` - OAuth 回调修复测试
- `OAUTH_CALLBACK_NULL_FIX.md` - OAuth 回调空值修复
- `OAUTH_CALLBACK_SUCCESS_PAGE.md` - OAuth 回调成功页面
- `OAUTH_FINAL_SOLUTION.md` - OAuth 最终解决方案
- `QUICKSTART_GITHUB_AUTH.md` - GitHub 认证快速开始
- `REFRESH_TOKEN_ERROR_FIX.md` - 刷新令牌错误修复
- `SESSION_MANAGEMENT.md` - 会话管理
- `URGENT_FIX_GITHUB_AUTH.md` - GitHub 认证紧急修复
- `USER_AUTH_UPDATE.md` - 用户认证更新
- `WEB_SUPABASE_OAUTH_IMPLEMENTATION.md` - Web Supabase OAuth 实现

---

### 🔧 问题修复 (`fixes/`)
各类 Bug 修复、问题排查和解决方案。

- `BUGFIX_MOBILE_MENU.md` - 移动端菜单 Bug 修复
- `FINAL_LOGOUT_GLOBALKEY_FIX.md` - 登出 GlobalKey 最终修复
- `GLOBALKEY_ERROR_FIX.md` - GlobalKey 错误修复
- `GLOBALKEY_ULTIMATE_FIX.md` - GlobalKey 终极修复
- `LOGOUT_FIX_TEST_GUIDE.md` - 登出修复测试指南
- `LOGOUT_LOGIN_GLOBALKEY_FIX.md` - 登录登出 GlobalKey 修复
- `NUCLEAR_FIX.md` - 核心问题修复
- `ULTIMATE_FIX_LAZY_INIT.md` - 延迟初始化终极修复

---

### ⚙️ 配置和设置 (`setup/`)
环境配置、服务设置、故障排查等文档。

- `ENV_CONFIGURATION.md` - 环境配置
- `SUPABASE_SETUP.md` - Supabase 配置指南
- `PORT_TROUBLESHOOTING.md` - 端口问题排查
- `TROUBLESHOOTING.md` - 故障排查指南

---

### 🔄 迁移和重构 (`migration/`)
项目迁移、架构调整和重构相关文档。

- `MIGRATE_TO_NATIVE_ROUTER.md` - 迁移到原生路由
- `MIGRATION_SUMMARY.md` - 迁移总结
- `FINAL_SOLUTION_MANUAL_NAVIGATION.md` - 手动导航最终方案

---

## 📖 阅读建议

### 新手入门
1. 先阅读根目录的 [README.md](../README.md)
2. 按照 [HOW_TO_RUN.md](../HOW_TO_RUN.md) 配置环境
3. 查看 `setup/` 目录下的配置文档

### 功能开发
- **实现认证功能**：查看 `oauth/` 目录
- **遇到问题**：先查 `fixes/` 目录是否有类似问题
- **配置服务**：参考 `setup/` 目录

### 项目维护
- **升级迁移**：查看 `migration/` 目录
- **故障排查**：参考 `setup/TROUBLESHOOTING.md`

---

## 📝 文档更新

如果需要添加新文档，请按照以下分类原则：
- **OAuth/认证相关** → `oauth/`
- **Bug 修复** → `fixes/`
- **配置设置** → `setup/`
- **迁移重构** → `migration/`
- **项目主文档** → 根目录

---

*最后更新时间：2025-11-02*

