# 端口占用问题解决方案

## 🚨 错误信息
```
Failed to bind web development server:
SocketException: Failed to create server socket (OS Error: Address already in use, errno = 48)
address = localhost, port = 3000
```

## ✅ 快速解决方案

### 方法 1: 一键清理端口（推荐）

```bash
# macOS/Linux
lsof -ti :3000 | xargs kill -9

# Windows (PowerShell)
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force
```

### 方法 2: 使用 Makefile

```bash
cd /Users/charles/Documents/2-WorkSpace/1-Project/cursorflutter/nanobamboo
make kill
make web
```

### 方法 3: 手动查找并终止进程

```bash
# 1. 查找占用端口的进程
lsof -i :3000

# 2. 记下 PID（进程 ID）
# 输出示例:
# COMMAND   PID   USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
# flutter  12345  user   28u  IPv4  0x...      0t0  TCP localhost:3000

# 3. 终止进程
kill -9 12345  # 替换为实际的 PID
```

---

## 🔍 检查所有 Flutter 进程

```bash
# 查看所有 Flutter 相关进程
ps aux | grep flutter

# 终止所有 Flutter 进程
killall -9 flutter

# 或者更彻底的清理
pkill -9 -f flutter
```

---

## 🛠️ 完整重启流程

### 步骤 1: 停止所有相关进程

```bash
# 终止端口占用
lsof -ti :3000 | xargs kill -9

# 终止所有 Flutter 进程
killall -9 flutter

# 终止 Chrome 调试实例（可选）
killall -9 "Google Chrome"
```

### 步骤 2: 清理并重启

```bash
cd /Users/charles/Documents/2-WorkSpace/1-Project/cursorflutter/nanobamboo

# 清理构建缓存
flutter clean

# 重新启动
flutter run -d chrome --web-port=3000
```

---

## 💡 预防措施

### 1. 使用快捷脚本

**创建 `restart.sh`:**

```bash
#!/bin/bash

echo "🛑 停止所有 Flutter 进程..."
lsof -ti :3000 | xargs kill -9 2>/dev/null
killall -9 flutter 2>/dev/null

echo "🧹 清理构建缓存..."
flutter clean

echo "🚀 启动应用..."
flutter run -d chrome --web-port=3000
```

**使用方法:**
```bash
chmod +x restart.sh
./restart.sh
```

### 2. 使用别名

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Flutter 端口清理
alias fkill='lsof -ti :3000 | xargs kill -9'
alias fclean='flutter clean'
alias frun='flutter run -d chrome --web-port=3000'
alias frestart='fkill && frun'
```

使用方法：
```bash
source ~/.zshrc  # 重新加载配置
fkill            # 清理端口
frun             # 启动应用
frestart         # 清理 + 启动
```

### 3. 使用不同端口

如果 3000 端口经常被占用，可以使用其他端口：

```bash
# 使用 8080 端口
flutter run -d chrome --web-port=8080

# 使用 5000 端口
flutter run -d chrome --web-port=5000
```

**记得同步更新 Supabase 重定向 URL:**
```
http://localhost:8080/**
```

---

## 🚨 常见问题

### Q1: `kill -9` 后仍然报端口占用

**可能原因:**
- 端口被其他应用占用（如本地服务器、Node.js、Python 等）

**解决方案:**
```bash
# 查看端口详细信息
sudo lsof -i :3000

# 如果是系统进程，可能需要 sudo
sudo kill -9 <PID>
```

### Q2: VS Code 终端无法使用 `killall` 命令

**解决方案:**
使用 Cursor/VS Code 的 "终止任务" 功能：
1. 按 `Cmd+Shift+P` (macOS) 或 `Ctrl+Shift+P` (Windows)
2. 输入 "Tasks: Terminate Task"
3. 选择对应的 Flutter 任务

### Q3: 后台进程找不到

**解决方案:**
```bash
# 查找所有监听 3000 端口的进程
netstat -vanp tcp | grep 3000

# 或使用 lsof 详细查看
sudo lsof -iTCP:3000 -sTCP:LISTEN
```

---

## 📊 端口状态检查

### 检查端口是否空闲

```bash
# 方法 1: lsof
lsof -i :3000

# 方法 2: netstat
netstat -an | grep 3000

# 方法 3: nc (netcat)
nc -zv localhost 3000
```

**输出解读:**
- **无输出** = 端口空闲 ✅
- **有进程信息** = 端口被占用 ❌

---

## 🎯 应急快速命令

### 一键清理 + 重启（macOS/Linux）

```bash
lsof -ti :3000 | xargs kill -9 && cd /Users/charles/Documents/2-WorkSpace/1-Project/cursorflutter/nanobamboo && flutter run -d chrome --web-port=3000
```

### 一键清理 + 重启（Windows PowerShell）

```powershell
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force; cd C:\path\to\nanobamboo; flutter run -d chrome --web-port=3000
```

---

## 🔧 Makefile 增强

在 `Makefile` 中添加更多实用命令：

```makefile
# 清理端口
kill:
	@echo "🛑 终止占用端口 3000 的进程..."
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || echo "端口已清理"

# 清理所有 Flutter 进程
kill-all:
	@echo "🛑 终止所有 Flutter 进程..."
	@killall -9 flutter 2>/dev/null || echo "所有 Flutter 进程已终止"

# 完全重启（清理 + 启动）
restart: kill
	@echo "🧹 清理构建缓存..."
	@flutter clean
	@echo "🚀 启动应用..."
	@flutter run -d chrome --web-port=3000

# 检查端口状态
check-port:
	@echo "🔍 检查端口 3000 状态..."
	@lsof -i :3000 || echo "✅ 端口空闲"

# 快速重启（不清理缓存）
quick-restart: kill web
```

**使用方法:**
```bash
make kill           # 清理端口
make kill-all       # 清理所有 Flutter 进程
make restart        # 完全重启
make check-port     # 检查端口
make quick-restart  # 快速重启
```

---

## 📝 备忘清单

| 命令 | 作用 |
|------|------|
| `lsof -ti :3000 \| xargs kill -9` | 终止占用 3000 端口的进程 |
| `killall -9 flutter` | 终止所有 Flutter 进程 |
| `lsof -i :3000` | 查看 3000 端口占用情况 |
| `netstat -an \| grep 3000` | 检查 3000 端口状态 |
| `make kill && make web` | 清理端口并启动应用 |
| `flutter clean` | 清理构建缓存 |
| `ps aux \| grep flutter` | 查看所有 Flutter 进程 |

---

**最后更新:** 2025-11-01
**问题:** 端口 3000 被占用
**状态:** ✅ 已解决

