#!/bin/bash

echo "💣 NanoBamboo 核弹级重启（彻底清理所有缓存）"
echo "======================================================="
echo ""

# 1. 终止所有相关进程
echo "🛑 1/7 终止所有进程..."
lsof -ti :3000 | xargs kill -9 2>/dev/null
killall -9 flutter 2>/dev/null
killall -9 dart 2>/dev/null
killall -9 "Google Chrome" 2>/dev/null
echo "✅ 所有进程已终止"
echo ""

# 2. 清理 Flutter 缓存
echo "🧹 2/7 清理 Flutter 缓存..."
cd "$(dirname "$0")"
flutter clean
rm -rf .dart_tool
rm -rf build
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
echo "✅ Flutter 缓存已清理"
echo ""

# 3. 清理 Chrome 缓存（macOS）
echo "🧹 3/7 清理 Chrome 缓存..."
rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cache 2>/dev/null
rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Code\ Cache 2>/dev/null
rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker 2>/dev/null
rm -rf ~/Library/Caches/Google/Chrome 2>/dev/null
echo "✅ Chrome 缓存已清理"
echo ""

# 4. 重新获取依赖
echo "📦 4/7 重新获取依赖..."
flutter pub get
echo "✅ 依赖获取完成"
echo ""

# 5. 等待用户确认
echo "⚠️  5/7 重要提示："
echo ""
echo "    🔴 请确保所有 Chrome 窗口已关闭！"
echo "    🔴 如果 Chrome 仍在运行，缓存清理可能无效！"
echo ""
read -p "按 Enter 继续..."
echo ""

# 6. 清理环境
echo "🧹 6/7 清理环境变量和临时文件..."
unset FLUTTER_WEB_AUTO_DETECT
unset FLUTTER_WEB_USE_SKIA
rm -rf /tmp/flutter_tools* 2>/dev/null
echo "✅ 环境已清理"
echo ""

# 7. 启动应用
echo "🚀 7/7 启动应用（使用全新环境）..."
echo ""
echo "    📍 访问: http://localhost:3000"
echo "    ⚠️  重要：第一次启动需要 2-3 分钟编译"
echo "    ⚠️  启动后请刷新页面（Cmd+Shift+R 或 Ctrl+Shift+R）"
echo ""
echo "======================================================="
echo ""

# 启动前再次确认端口清理
lsof -ti :3000 | xargs kill -9 2>/dev/null

# 启动应用
flutter run -d chrome --web-port=3000 --web-renderer=canvaskit

