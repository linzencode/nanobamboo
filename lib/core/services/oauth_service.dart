import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:nanobamboo/core/services/env_service.dart';

/// OAuth 2.0 + PKCE 认证服务
///
/// Web: 使用 flutter_web_auth_2 实现 OAuth 2.0 授权码流程（PKCE）
/// Mobile: 使用 flutter_appauth 实现标准的 OAuth 2.0 授权码流程（PKCE）
/// 支持 GitHub、Google、GitLab 等主流 OAuth 提供商
class OAuthService {
  /// flutter_appauth 实例（移动端）
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  /// 环境变量服务
  final EnvService _envService = EnvService();

  /// GitHub OAuth 配置
  /// 从 .env 文件读取 Client ID
  String get _githubClientId => _envService.githubClientId;
  static const String _githubAuthorizationEndpoint =
      'https://github.com/login/oauth/authorize';
  static const String _githubTokenEndpoint =
      'https://github.com/login/oauth/access_token';

  /// OAuth 回调 URI
  /// Web: http://localhost:3000/auth/callback
  /// iOS/Android: 使用 Custom URL Scheme
  static const String _redirectUrl = kIsWeb
      ? 'http://localhost:3000/auth/callback'
      : 'io.supabase.nanobamboo://login-callback/';

  /// GitHub 登录
  ///
  /// 使用 OAuth 2.0 授权码流程 + PKCE
  /// 返回 access_token，可用于 Supabase.signInWithIdToken()
  Future<AuthorizationTokenResponse?> signInWithGitHub() async {
    try {
      debugPrint('🔐 开始 GitHub OAuth 2.0 + PKCE 流程...');
      debugPrint('   平台: ${kIsWeb ? "Web" : "Mobile"}');

      if (kIsWeb) {
        // Web 平台：使用 flutter_web_auth_2
        return await _signInWithGitHubWeb();
      } else {
        // 移动平台：使用 flutter_appauth
        return await _signInWithGitHubMobile();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ GitHub OAuth 错误: $e');
      debugPrint('堆栈: $stackTrace');
      rethrow;
    }
  }

  /// Web 平台 GitHub 登录
  Future<AuthorizationTokenResponse?> _signInWithGitHubWeb() async {
    try {
      // 1. 生成 PKCE 参数
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      final state = _generateState();

      debugPrint('🔐 [Web] 生成 PKCE 参数完成');

      // 2. 构建授权 URL
      final authUrl = Uri.https(
        'github.com',
        '/login/oauth/authorize',
        {
          'client_id': _githubClientId,
          'redirect_uri': _redirectUrl,
          'scope': 'read:user user:email',
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
        },
      );

      debugPrint('🔐 [Web] 打开授权页面: $authUrl');

      // 3. 打开授权页面并等待回调
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'http',
      );

      debugPrint('✅ [Web] 收到回调: $result');

      // 4. 解析回调 URL
      final callbackUri = Uri.parse(result);
      debugPrint('📋 [Web] 解析后的 URI:');
      debugPrint('   - scheme: ${callbackUri.scheme}');
      debugPrint('   - host: ${callbackUri.host}');
      debugPrint('   - path: ${callbackUri.path}');
      debugPrint('   - query: ${callbackUri.query}');
      debugPrint('   - fragment: ${callbackUri.fragment}');

      final code = callbackUri.queryParameters['code'];
      final returnedState = callbackUri.queryParameters['state'];

      debugPrint('🔑 [Web] 提取参数:');
      debugPrint('   - code: $code');
      debugPrint('   - state: $returnedState');
      debugPrint('   - expected state: $state');

      // 5. 验证 state
      if (returnedState != state) {
        debugPrint('❌ State 验证失败');
        debugPrint('   期望: $state');
        debugPrint('   实际: $returnedState');
        return null;
      }

      if (code == null) {
        debugPrint('❌ 未获取到授权码');
        debugPrint('   查询参数: ${callbackUri.queryParameters}');
        return null;
      }

      debugPrint('✅ [Web] 获取到授权码: ${code.substring(0, 10)}...');

      // 6. 交换 access_token
      final tokenResponse = await http.post(
        Uri.parse(_githubTokenEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': _githubClientId,
          'code': code,
          'code_verifier': codeVerifier,
          'redirect_uri': _redirectUrl,
        },
      );

      if (tokenResponse.statusCode == 200) {
        final json = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
        final accessToken = json['access_token'] as String?;
        final tokenType = json['token_type'] as String?;

        if (accessToken != null) {
          debugPrint('✅ [Web] GitHub OAuth 成功！');
          debugPrint('   Access Token: ${accessToken.substring(0, 10)}...');
          debugPrint('   Token Type: $tokenType');

          // 返回兼容的 AuthorizationTokenResponse 格式
          return AuthorizationTokenResponse(
            accessToken, // accessToken
            null, // refreshToken
            null, // accessTokenExpirationDateTime
            null, // idToken
            tokenType, // tokenType
            null, // scopes
            null, // authorizationAdditionalParameters
            null, // tokenAdditionalParameters
          );
        }
      }

      debugPrint('❌ [Web] Token 交换失败: ${tokenResponse.statusCode}');
      debugPrint('   响应: ${tokenResponse.body}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [Web] GitHub OAuth 错误: $e');
      debugPrint('堆栈: $stackTrace');
      return null;
    }
  }

  /// 移动平台 GitHub 登录
  Future<AuthorizationTokenResponse?> _signInWithGitHubMobile() async {
    try {
      // 使用 flutter_appauth（移动端）
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _githubClientId,
          _redirectUrl,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _githubAuthorizationEndpoint,
            tokenEndpoint: _githubTokenEndpoint,
          ),
          scopes: <String>['read:user', 'user:email'],
          promptValues: ['consent'],
        ),
      );

      if (result != null) {
        debugPrint('✅ [Mobile] GitHub OAuth 成功！');
        debugPrint(
            '   Access Token: ${result.accessToken?.substring(0, 10)}...',
        );
        return result;
      } else {
        debugPrint('⚠️ [Mobile] GitHub OAuth 取消或失败');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [Mobile] GitHub OAuth 错误: $e');
      rethrow;
    }
  }

  /// 生成 Code Verifier（PKCE）
  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// 生成 Code Challenge（PKCE）
  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// 生成 State（防止 CSRF）
  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Google 登录（预留）
  ///
  /// 实现方式类似 GitHub，只需修改配置参数
  /// 
  /// ⚠️ 待实现功能：需要配置 Google OAuth Client ID 和 Secret
  Future<AuthorizationTokenResponse?> signInWithGoogle() async {
    // 暂未实现 Google OAuth，实现方式类似 GitHub
    debugPrint('⚠️ Google OAuth 暂未实现');
    throw UnimplementedError('Google OAuth 暂未实现');
  }

  /// 获取 GitHub 用户信息
  ///
  /// 使用 access_token 调用 GitHub API 获取用户信息
  Future<Map<String, dynamic>?> getGitHubUserInfo(String accessToken) async {
    try {
      debugPrint('📡 获取 GitHub 用户信息...');

      // 这里可以使用 http 或 dio 调用 GitHub API
      // GET https://api.github.com/user
      // Headers: Authorization: Bearer {accessToken}

      // 暂时返回 null，由 Supabase 自动获取
      return null;
    } catch (e) {
      debugPrint('❌ 获取 GitHub 用户信息失败: $e');
      return null;
    }
  }
}
