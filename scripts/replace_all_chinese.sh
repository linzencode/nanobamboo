#!/bin/bash

# Batch replace Chinese to English
# Usage: chmod +x replace_all_chinese.sh && ./replace_all_chinese.sh

cd "$(dirname "$0")/.."

echo "🔍 Starting batch replacement of Chinese text..."

# Common UI text replacements
find lib -name "*.dart" -type f -exec sed -i '' \
  -e "s/用 AI 智能转换您的图片/Transform Your Images with AI/g" \
  -e "s/专业级图像处理，由前沿 AI 驱动/Professional Image Processing Powered by AI/g" \
  -e "s/开始处理/Get Started/g" \
  -e "s/查看演示/View Demo/g" \
  -e "s/登录/Login/g" \
  -e "s/注册/Sign Up/g" \
  -e "s/退出登录/Logout/g" \
  -e "s/首页/Home/g" \
  -e "s/功能特点/Features/g" \
  -e "s/案例展示/Showcase/g" \
  -e "s/用户评价/Testimonials/g" \
  -e "s/常见问题/FAQ/g" \
  -e "s/关于我们/About Us/g" \
  -e "s/联系我们/Contact Us/g" \
  -e "s/立即体验/Try Now/g" \
  -e "s/了解更多/Learn More/g" \
  -e "s/邮箱/Email/g" \
  -e "s/密码/Password/g" \
  -e "s/验证码/Verification Code/g" \
  -e "s/发送验证码/Send Code/g" \
  -e "s/秒后重试/s to retry/g" \
  -e "s/请输入/Please enter/g" \
  -e "s/确认/Confirm/g" \
  -e "s/取消/Cancel/g" \
  -e "s/保存/Save/g" \
  -e "s/删除/Delete/g" \
  -e "s/编辑/Edit/g" \
  -e "s/上传/Upload/g" \
  -e "s/下载/Download/g" \
  -e "s/分享/Share/g" \
  -e "s/收藏/Favorite/g" \
  -e "s/设置/Settings/g" \
  -e "s/帮助/Help/g" \
  -e "s/加载中.../Loading.../g" \
  -e "s/加载中/Loading/g" \
  -e "s/请稍候/Please wait/g" \
  -e "s/操作成功/Success/g" \
  -e "s/操作失败/Failed/g" \
  -e "s/用户名/Username/g" \
  -e "s/版权所有/All Rights Reserved/g" \
  {} +

# Auth specific
find lib/modules/auth -name "*.dart" -type f -exec sed -i '' \
  -e "s/社交账号登录/Social Login/g" \
  -e "s/邮箱登录/Email Login/g" \
  -e "s/密码登录/Password Login/g" \
  -e "s/忘记密码/Forgot Password/g" \
  -e "s/已有账号？/Already have an account?/g" \
  -e "s/还没有账号？/Don't have an account?/g" \
  -e "s/返回登录/Back to Login/g" \
  -e "s/重新发送/Resend/g" \
  {} +

# Feature related
find lib/modules/home -name "*.dart" -type f -exec sed -i '' \
  -e "s/核心功能/Core Features/g" \
  -e "s/为什么选择我们/Why Choose Us/g" \
  -e "s/成功案例/Success Stories/g" \
  -e "s/客户评价/Client Reviews/g" \
  -e "s/常见问题解答/Frequently Asked Questions/g" \
  {} +

# Comments
find lib -name "*.dart" -type f -exec sed -i '' \
  -e "s/\/\/ 首屏组件/\/\/ Hero component/g" \
  -e "s/\/\/ 主要内容/\/\/ Main content/g" \
  -e "s/\/\/ 标题/\/\/ Title/g" \
  -e "s/\/\/ 副标题/\/\/ Subtitle/g" \
  -e "s/\/\/ 按钮/\/\/ Button/g" \
  -e "s/\/\/ 功能特点/\/\/ Features/g" \
  -e "s/\/\/ 页脚/\/\/ Footer/g" \
  -e "s/\/\/ 导航栏/\/\/ Navigation/g" \
  {} +

echo "✅ Replacement complete!"
echo "📝 Please check the changes and test the application."

