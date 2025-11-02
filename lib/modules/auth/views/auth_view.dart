import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/modules/auth/controllers/auth_controller.dart';

/// 认证页面
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  // 获取 AuthController
  AuthController get controller {
    // 确保 AuthController 已注册
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    return Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCD34D),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🍌',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 标题
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    children: const [
                      TextSpan(
                        text: '欢迎来到 ',
                        style: TextStyle(color: Colors.black87),
                      ),
                      TextSpan(
                        text: 'NanoBamboo',
                        style: TextStyle(color: Color(0xFFF97316)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 副标题
                Text(
                  '登录以继续使用 AI 图像编辑器',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

                // 标签页切换
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _buildTab(
                          context,
                          '社交登录',
                          0,
                          controller.selectedTabIndex.value == 0,
                        ),
                      ),
                      Expanded(
                        child: _buildTab(
                          context,
                          '邮箱登录',
                          1,
                          controller.selectedTabIndex.value == 1,
                        ),
                      ),
                      Expanded(
                        child: _buildTab(
                          context,
                          '密码登录',
                          2,
                          controller.selectedTabIndex.value == 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 内容区域
                Obx(() {
                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      return _buildSocialLogin(context);
                    case 1:
                      return _buildEmailLogin(context);
                    case 2:
                      return _buildPasswordLogin(context);
                    default:
                      return const SizedBox.shrink();
                  }
                }),

                const SizedBox(height: 24),

                // 隐私政策
                Text(
                  '登录即表示您同意我们的服务条款和隐私政策',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    int index,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => controller.switchTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFFF97316) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFF97316) : Colors.black54,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSocialLogin(BuildContext context) {
    return Column(
      children: [
        // GitHub 登录按钮
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.signInWithGitHub,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24292e),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.code, size: 20),
                        SizedBox(width: 12),
                        Text(
                          '使用 GitHub 继续',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Google 登录按钮
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google 图标（使用 Text emoji 作为简单替代）
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '使用 Google 继续',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLogin(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 邮箱输入
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(text: '邮箱地址'),
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFF97316)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => controller.email.value = value,
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFF97316), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 发送验证码按钮
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value || controller.countdown.value > 0
                      ? null
                      : controller.sendVerificationCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      controller.countdown.value > 0
                          ? '${controller.countdown.value}秒后重试'
                          : '发送验证码',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 提示文字
        Text(
          '我们将向您的邮箱发送一个 6 位数验证码',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPasswordLogin(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 邮箱输入
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(text: '邮箱地址'),
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFF97316)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => controller.email.value = value,
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFF97316), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 密码输入
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(text: '密码'),
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFF97316)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => TextField(
                onChanged: (value) => controller.password.value = value,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: '请输入密码',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFF97316), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 忘记密码
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: 实现忘记密码功能
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF97316),
              padding: EdgeInsets.zero,
            ),
            child: const Text('忘记密码?'),
          ),
        ),
        const SizedBox(height: 16),

        // 登录按钮
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.signInWithPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 提示文字
        Text(
          '还没设置密码？登录后可以在中心设置',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
