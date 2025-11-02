# NanoBamboo 项目 Makefile
# 快速运行命令

.PHONY: help web web-release ios android clean get build kill kill-all check-port restart quick-restart

# 默认目标：显示帮助
help:
	@echo "NanoBamboo 可用命令："
	@echo ""
	@echo "📱 运行应用："
	@echo "  make web          - 在 Chrome 中运行 Web 应用 (端口 3000)"
	@echo "  make web-release  - 在 Chrome 中运行 Web 应用 (Release 模式)"
	@echo "  make ios          - 在 iOS 模拟器中运行"
	@echo "  make android      - 在 Android 模拟器中运行"
	@echo ""
	@echo "🔧 维护工具："
	@echo "  make get          - 获取依赖包"
	@echo "  make clean        - 清理构建文件"
	@echo "  make build        - 构建 Web 应用"
	@echo ""
	@echo "🛑 进程管理："
	@echo "  make kill         - 终止占用端口 3000 的进程"
	@echo "  make kill-all     - 终止所有 Flutter 进程"
	@echo "  make check-port   - 检查端口 3000 状态"
	@echo "  make restart      - 完全重启（清理缓存 + 启动）"
	@echo "  make quick-restart - 快速重启（仅清理端口 + 启动）"
	@echo ""

# Web 端运行（开发模式，端口 3000）
web:
	@echo "🚀 启动 Web 应用 (http://localhost:3000)..."
	flutter run -d chrome --web-port=3000 --web-hostname=localhost

# Web 端运行（Release 模式，端口 3000）
web-release:
	@echo "🚀 启动 Web 应用 - Release 模式 (http://localhost:3000)..."
	flutter run -d chrome --web-port=3000 --web-hostname=localhost --release

# iOS 运行
ios:
	@echo "🚀 启动 iOS 应用..."
	flutter run -d ios

# Android 运行
android:
	@echo "🚀 启动 Android 应用..."
	flutter run -d android

# 获取依赖
get:
	@echo "📦 获取依赖包..."
	flutter pub get

# 清理构建文件
clean:
	@echo "🧹 清理构建文件..."
	flutter clean
	flutter pub get

# 构建 Web 应用
build:
	@echo "🔨 构建 Web 应用..."
	flutter build web --release

# 终止占用端口 3000 的进程
kill:
	@echo "🛑 终止占用端口 3000 的进程..."
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || echo "✅ 端口已清理或无进程占用"

# 终止所有 Flutter 进程
kill-all:
	@echo "🛑 终止所有 Flutter 进程..."
	@killall -9 flutter 2>/dev/null || echo "✅ 所有 Flutter 进程已终止"
	@killall -9 dart 2>/dev/null || echo "✅ 所有 Dart 进程已终止"

# 检查端口 3000 状态
check-port:
	@echo "🔍 检查端口 3000 状态..."
	@lsof -i :3000 || echo "✅ 端口空闲，可以正常启动应用"

# 完全重启（清理缓存 + 启动）
restart: kill clean
	@echo "🚀 启动 Web 应用 (http://localhost:3000)..."
	@flutter run -d chrome --web-port=3000 --web-hostname=localhost

# 快速重启（仅清理端口 + 启动）
quick-restart: kill web

