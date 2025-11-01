import 'package:get/get.dart';

/// 认证控制器
class AuthController extends GetxController {
  /// 当前选中的标签页索引（0:Google, 1:邮箱, 2:密码）
  final selectedTabIndex = 0.obs;

  /// 邮箱地址
  final email = ''.obs;

  /// 密码
  final password = ''.obs;

  /// 验证码
  final verificationCode = ''.obs;

  /// 是否显示密码
  final isPasswordVisible = false.obs;

  /// 是否正在加载
  final isLoading = false.obs;

  /// 验证码倒计时
  final countdown = 0.obs;

  /// 切换标签页
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Google 登录
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // TODO: 实现 Google 登录逻辑
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.snackbar(
        '登录成功',
        '欢迎回来！',
        snackPosition: SnackPosition.TOP,
      );
      Get.back<dynamic>();
    } catch (e) {
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 发送验证码
  Future<void> sendVerificationCode() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      // TODO: 实现发送验证码逻辑
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // 开始倒计时
      countdown.value = 60;
      _startCountdown();
      
      Get.snackbar(
        '发送成功',
        '验证码已发送到您的邮箱',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '发送失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 邮箱验证码登录
  Future<void> signInWithEmail() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (verificationCode.value.length != 6) {
      Get.snackbar(
        '提示',
        '请输入6位验证码',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      // TODO: 实现邮箱验证码登录逻辑
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.snackbar(
        '登录成功',
        '欢迎回来！',
        snackPosition: SnackPosition.TOP,
      );
      Get.back<dynamic>();
    } catch (e) {
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 密码登录
  Future<void> signInWithPassword() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        '提示',
        '请输入有效的邮箱地址',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (password.value.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入密码',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      // TODO: 实现密码登录逻辑
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.snackbar(
        '登录成功',
        '欢迎回来！',
        snackPosition: SnackPosition.TOP,
      );
      Get.back<dynamic>();
    } catch (e) {
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 倒计时
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (countdown.value > 0) {
        countdown.value--;
        _startCountdown();
      }
    });
  }

  @override
  void onClose() {
    countdown.value = 0;
    super.onClose();
  }
}

