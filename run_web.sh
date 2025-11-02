#!/bin/bash

# NanoBamboo Web 启动脚本
# 使用固定端口 3000 启动 Flutter Web 应用

echo "🚀 正在启动 NanoBamboo Web 应用..."
echo "📍 端口: 3000"
echo "🌐 URL: http://localhost:3000"
echo ""

flutter run -d chrome --web-port=3000 --web-hostname=localhost

