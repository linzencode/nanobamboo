# Google OAuth 快速开始

> **5 分钟快速配置 Google 登录**

## 📦 1. 安装依赖

```bash
flutter pub get
```

## ⚙️ 2. 配置环境变量

在 `.env` 文件中添加：

```env
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

## 🔑 3. 获取 Client ID

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建项目 → APIs & Services → Credentials
3. Create Credentials → OAuth client ID
4. 选择 **Web application**
5. Authorized JavaScript origins: `http://localhost:3000`
6. 复制 **Client ID**

## 🔐 4. 配置 Supabase

1. [Supabase Dashboard](https://supabase.com/dashboard)
2. Authentication → Providers → Google
3. 启用并填入 Client ID 和 Secret

## ✅ 5. 测试

```bash
flutter run -d chrome --web-port=3000
```

点击"使用 Google 继续" → 选择账号 → 完成！

---

## 📚 完整文档

需要详细配置步骤和问题排查？

👉 [Google OAuth 完整配置指南](./GOOGLE_OAUTH_SETUP_GUIDE.md)

---

**提示**: 首次使用需要在 Google OAuth 同意屏幕添加测试用户。




