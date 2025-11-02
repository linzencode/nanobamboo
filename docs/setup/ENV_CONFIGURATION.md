# 环境变量配置指南

## 📋 `.env` 文件配置

项目使用 `.env` 文件管理敏感配置和环境变量。

### 🔧 配置步骤

#### 1. 打开 `.env` 文件

文件位置：`/Users/charles/Documents/2-WorkSpace/1-Project/cursorflutter/nanobamboo/.env`

#### 2. 添加以下配置

```env
# Supabase 配置
SUPABASE_URL=https://anckcqushwdznckreytdg.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# GitHub OAuth 配置
GITHUB_CLIENT_ID=Ov23lijrIS2pV9KB33Zm
```

### 📝 配置项说明

| 配置项 | 说明 | 示例 |
|-------|------|------|
| `SUPABASE_URL` | Supabase 项目 URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase 匿名密钥 | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `GITHUB_CLIENT_ID` | GitHub OAuth App Client ID | `Ov23lijrIS2pV9KB33Zm` |

### 🔒 安全说明

#### ✅ 应该放在 `.env` 中的配置：

- GitHub Client ID（本项目已配置）
- Supabase URL
- Supabase Anon Key
- API Keys
- 任何敏感配置

#### ❌ 不应该放在代码中的配置：

- Client Secret（**绝对不要！**）
- Private Keys
- 数据库密码
- API Secret Keys

#### 📌 注意事项：

1. **`.env` 文件已添加到 `.gitignore`**
   - 不会被提交到 Git 仓库
   - 保护敏感信息

2. **GitHub Client ID vs Client Secret**
   - **Client ID**：可以公开，用于标识 OAuth App（✅ 可以放在 .env）
   - **Client Secret**：绝对保密，服务器端使用（❌ 永远不要暴露）

3. **前端 OAuth 2.0 PKCE 流程**
   - 使用 PKCE（Proof Key for Code Exchange）
   - **不需要 Client Secret**
   - Client ID 虽然可以公开，但放在 .env 中便于管理

### 🚀 如何使用

#### 代码中读取配置

```dart
// lib/core/services/env_service.dart
class EnvService {
  String get githubClientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';
}

// lib/core/services/oauth_service.dart
class OAuthService {
  final EnvService _envService = EnvService();
  
  String get _githubClientId => _envService.githubClientId;
}
```

#### 初始化流程

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. 加载环境变量
  await EnvService.init();
  
  // 2. 初始化其他服务
  await Get.putAsync(() => SupabaseService().init());
  
  runApp(const MyApp());
}
```

### 🔍 验证配置

启动应用时，如果配置缺失，控制台会显示警告：

```
⚠️ GITHUB_CLIENT_ID 未配置，GitHub 登录将无法使用
```

### 📚 相关文档

- [GitHub OAuth Apps 文档](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [OAuth 2.0 PKCE 规范](https://tools.ietf.org/html/rfc7636)
- [flutter_dotenv 文档](https://pub.dev/packages/flutter_dotenv)

---

## 🌍 多环境配置（可选）

如果需要区分开发/生产环境：

### 创建多个 .env 文件

```
.env                  # 默认配置
.env.development      # 开发环境
.env.production       # 生产环境
```

### 修改初始化代码

```dart
// lib/core/services/env_service.dart
static Future<void> init() async {
  const String env = String.fromEnvironment('ENV', defaultValue: 'development');
  final String fileName = env == 'production' ? '.env.production' : '.env.development';
  await dotenv.load(fileName: fileName);
}
```

### 运行时指定环境

```bash
# 开发环境
flutter run --dart-define=ENV=development

# 生产环境
flutter run --dart-define=ENV=production
```

---

**配置完成后，记得重启应用！** 🚀

