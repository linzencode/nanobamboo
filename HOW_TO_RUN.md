# 🚀 如何运行 NanoBamboo

本文档提供快速运行项目的方法。所有方法都将在**端口 3000**上启动应用。

## 📍 访问地址

无论使用哪种方式运行，应用都会在以下地址启动：

```
http://localhost:3000
```

## 🎯 推荐方式

### ✅ 方式 1: VS Code 一键启动（最简单）

1. 在 VS Code 中打开项目
2. 按下 `F5`（或点击菜单"运行" → "启动调试"）
3. 在弹出的选项中选择：**NanoBamboo (Web - 端口 3000)**
4. 等待编译完成，浏览器会自动打开 `http://localhost:3000`

**优点**：
- ✅ 最简单，一键启动
- ✅ 支持热重载
- ✅ 集成调试功能
- ✅ 自动使用端口 3000

---

### ✅ 方式 2: 脚本启动（推荐终端用户）

#### Mac/Linux
```bash
./run_web.sh
```

#### Windows
```batch
run_web.bat
```

**优点**：
- ✅ 简单易用
- ✅ 显示启动信息
- ✅ 无需记忆命令

---

### ✅ 方式 3: Makefile 命令（开发者推荐）

```bash
# 运行 Web 应用
make web

# 查看所有可用命令
make help
```

**其他命令**：
```bash
make web          # Web 开发模式
make web-release  # Web 发布模式
make ios          # iOS 模拟器
make android      # Android 模拟器
make get          # 安装依赖
make clean        # 清理构建
make build        # 构建 Web
```

**优点**：
- ✅ 命令简短易记
- ✅ 支持多种平台
- ✅ 提供更多操作

---

### ✅ 方式 4: Flutter 命令行

```bash
flutter run -d chrome --web-port=3000
```

**优点**：
- ✅ 官方标准方式
- ✅ 完全可控
- ✅ 适合 CI/CD

---

## 🔧 首次运行前的准备

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 配置环境变量

如果需要使用 GitHub 登录等功能，需要配置 `.env` 文件：

```bash
# 1. 复制示例文件
cp env.example .env

# 2. 编辑 .env 文件，填入您的配置
# SUPABASE_URL=...
# SUPABASE_ANON_KEY=...
```

详细配置请参考：[QUICKSTART_GITHUB_AUTH.md](./QUICKSTART_GITHUB_AUTH.md)

---

## 📱 运行其他平台

### iOS
```bash
# 方式 1: Makefile
make ios

# 方式 2: Flutter 命令
flutter run -d ios
```

### Android
```bash
# 方式 1: Makefile
make android

# 方式 2: Flutter 命令
flutter run -d android
```

---

## 🛠️ 常见问题

### Q1: 端口 3000 已被占用？

**解决方法**：

1. 查找占用端口的进程：
```bash
# Mac/Linux
lsof -i :3000

# Windows
netstat -ano | findstr :3000
```

2. 关闭占用端口的程序，或使用其他端口：
```bash
flutter run -d chrome --web-port=3001
```

### Q2: 脚本无法执行（Mac/Linux）？

**解决方法**：
```bash
# 添加执行权限
chmod +x run_web.sh

# 然后运行
./run_web.sh
```

### Q3: VS Code 中看不到启动配置？

**解决方法**：
1. 确保安装了 Flutter 和 Dart 扩展
2. 重新加载 VS Code 窗口
3. 查看 `.vscode/launch.json` 文件是否存在

### Q4: 热重载不工作？

**解决方法**：
- 按 `r` 手动触发热重载
- 按 `R` 热重启
- 确保使用的是 debug 模式，不是 release 模式

---

## 🎉 运行成功的标志

当您看到以下输出时，说明应用启动成功：

```
✓ Built build/web/main.dart.js
Launching lib/main.dart on Chrome in debug mode...
This app is linked to the debug service: ws://127.0.0.1:3000/xxx
```

打开浏览器访问 `http://localhost:3000`，您应该能看到 NanoBamboo 的首页。

---

## 💡 提示

- **推荐使用 VS Code**，体验最佳
- **首次启动**会比较慢，后续会快很多
- **开发时**使用 debug 模式，部署前使用 release 模式
- **遇到问题**时，先尝试 `make clean` 然后重新运行

---

## 📚 更多文档

- [README.md](./README.md) - 项目介绍和完整文档
- [QUICKSTART_GITHUB_AUTH.md](./QUICKSTART_GITHUB_AUTH.md) - GitHub 登录快速配置
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) - Supabase 详细配置指南

---

**祝您开发愉快！** 🚀

