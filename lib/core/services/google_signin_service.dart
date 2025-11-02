import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/logger.dart';
import 'env_service.dart';

/// Google 登录服务
///
/// ✅ 使用 google_sign_in 插件实现跨平台 Google 登录
/// ✅ 配合 Supabase 服务器端认证
/// ✅ 支持静默登录和弹窗登录
class GoogleSignInService {
  GoogleSignIn? _googleSignIn;

  /// 初始化 GoogleSignIn
  void init() {
    try {
      final envService = Get.find<EnvService>();

      _googleSignIn = GoogleSignIn(
        clientId: envService.googleWebClientId,
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/userinfo.profile',
          'https://www.googleapis.com/auth/userinfo.email',
        ],
      );

      Logger.info('✅ GoogleSignInService 初始化成功');
    } catch (e) {
      Logger.error('❌ GoogleSignInService 初始化失败', e);
    }
  }

  /// Google 登录
  ///
  /// 返回包含 idToken 和 accessToken 的认证信息
  Future<({String idToken, String accessToken})> signIn() async {
    if (_googleSignIn == null) {
      throw Exception('GoogleSignIn 未初始化，请先调用 init()');
    }

    try {
      Logger.info('🚀 开始 Google 登录流程...');

      // 1. 尝试静默登录（如果用户之前已授权）
      GoogleSignInAccount? account = await _googleSignIn!.signInSilently();

      // 2. 如果静默登录失败，弹出登录窗口
      if (account == null) {
        Logger.warning('⚠️ 静默登录失败，弹出登录窗口...');
        account = await _googleSignIn!.signIn();
      }

      if (account == null) {
        throw Exception('用户取消登录');
      }

      Logger.info('✅ Google 登录成功: ${account.email}');

      // 3. 获取认证信息（ID Token 和 Access Token）
      final authentication = await account.authentication;

      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;

      if (idToken == null) {
        throw Exception('未获取到 ID Token');
      }

      if (accessToken == null) {
        throw Exception('未获取到 Access Token');
      }

      Logger.info('✅ 获取到认证信息');
      Logger.debug('ID Token: ${idToken.substring(0, 20)}...');
      Logger.debug('Access Token: ${accessToken.substring(0, 20)}...');

      return (idToken: idToken, accessToken: accessToken);
    } catch (e) {
      Logger.error('❌ Google 登录失败', e);
      rethrow;
    }
  }

  /// Google 登出
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      Logger.info('✅ Google 登出成功');
    } catch (e) {
      Logger.error('❌ Google 登出失败', e);
    }
  }
}
