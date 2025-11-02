#!/bin/bash

echo "🔧 NanoBamboo 完全重启脚本"
echo "================================"
echo ""

# 1. 终止所有相关进程
echo "🛑 1/5 终止所有 Flutter 进程..."
lsof -ti :3000 | xargs kill -9 2>/dev/null
killall -9 flutter 2>/dev/null
killall -9 dart 2>/dev/null
echo "✅ 所有进程已终止"
echo ""

# 2. 清理构建缓存
echo "🧹 2/5 清理构建缓存..."
cd "$(dirname "$0")"
flutter clean
echo "✅ 构建缓存已清理"
echo ""

# 3. 获取依赖
echo "📦 3/5 重新获取依赖..."
flutter pub get
echo "✅ 依赖获取完成"
echo ""

# 4. 提示清理浏览器缓存
echo "⚠️  4/5 重要提示："
echo "   请在浏览器中清理缓存："
echo "   1. 打开 Chrome"
echo "   2. 按 F12 打开开发者工具"
echo "   3. 右键点击刷新按钮"
echo "   4. 选择 '清空缓存并硬性重新加载'"
echo ""
echo "   或者："
echo "   1. F12 > Application 标签"
echo "   2. Storage > Clear site data"
echo "   3. 点击 'Clear site data' 按钮"
echo ""
read -p "按 Enter 继续启动应用..."
echo ""

# 5. 启动应用
echo "🚀 5/5 启动应用..."
echo "   访问: http://localhost:3000"
echo "================================"
echo ""
flutter run -d chrome --web-port=3000

