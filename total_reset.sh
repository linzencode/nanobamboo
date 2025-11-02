#!/bin/bash

echo "🛑 第 1 步：强制终止所有 Flutter 进程..."
killall -9 flutter 2>/dev/null || true
killall -9 dart 2>/dev/null || true
killall -9 Chrome 2>/dev/null || true
lsof -ti :3000 | xargs kill -9 2>/dev/null || true
sleep 1

echo "🧹 第 2 步：清理 Flutter 构建缓存..."
flutter clean
rm -rf build/
rm -rf .dart_tool/
rm -rf ~/.pub-cache/hosted/pub.dartlang.org/get-*/

echo "📦 第 3 步：重新获取依赖..."
flutter pub get

echo ""
echo "⚠️ 第 4 步：清除浏览器缓存"
echo ""
echo "请手动执行以下操作："
echo "1. 关闭所有 Chrome 窗口"
echo "2. 按 Cmd+Shift+Delete 打开清除浏览数据"
echo "3. 选择 '全部时间'"
echo "4. 勾选 '缓存的图片和文件' 和 'Cookie 及其他网站数据'"
echo "5. 点击 '清除数据'"
echo ""
read -p "完成后按 Enter 继续..."

echo ""
echo "🚀 第 5 步：启动应用..."
flutter run -d chrome --web-port=3000 --web-hostname=localhost

