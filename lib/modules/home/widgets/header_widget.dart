import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/controllers/user_controller.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/theme_controller.dart';
import 'package:nanobamboo/core/services/supabase_service.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/app_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Header 组件
class HeaderWidget extends StatefulWidget {
  const HeaderWidget({
    super.key,
    required this.featuresKey,
    required this.showcaseKey,
    required this.testimonialsKey,
    required this.faqKey,
  });

  final GlobalKey featuresKey;
  final GlobalKey showcaseKey;
  final GlobalKey testimonialsKey;
  final GlobalKey faqKey;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  UserController? _userController;
  StreamSubscription<AuthState>? _authSubscription;
  late ThemeController _themeController;
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    
    // 获取 ThemeController 并监听变化
    _themeController = Get.find<ThemeController>();
    _themeController.addListener(_onThemeChanged);
    
    // 获取 HomeController 并监听菜单状态（用于移动端菜单按钮）
    _homeController = Get.find<HomeController>();
    _homeController.isMobileMenuOpen.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    
    // 尝试获取 UserController（可能还没注册）
    _tryGetUserController();
    
    // 定期检查 UserController 是否已注册
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _userController == null) {
        _tryGetUserController();
      }
    });
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  void _tryGetUserController() {
    try {
      if (Get.isRegistered<UserController>()) {
        _userController = Get.find<UserController>();
        debugPrint('✅ HeaderWidget 已连接到 UserController');
        
        // ✅ 手动监听 auth state 变化，避免 Obx 的 GlobalKey 问题
        _listenToAuthChanges();
        
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint('⏳ UserController 尚未注册，稍后重试...');
      }
    } catch (e) {
      debugPrint('⚠️ 获取 UserController 失败: $e');
    }
  }
  
  /// 监听认证状态变化（手动，不使用 Obx）
  void _listenToAuthChanges() {
    if (_userController == null) return;
    
    try {
      final supabaseService = Get.find<SupabaseService>();
      _authSubscription = supabaseService.authStateChanges?.listen((data) {
        if (mounted) {
          // 手动触发重建
          setState(() {});
          debugPrint('🔄 HeaderWidget 已更新用户状态');
        }
      });
    } catch (e) {
      debugPrint('⚠️ 监听 auth state 失败: $e');
    }
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    _themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 使用已在 initState 中获取的 _homeController，避免重复调用 Get.find
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(
            Colors.transparent,
            BlendMode.src,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🍌',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nano Bamboo',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 桌面端导航
                if (!isMobile) ...[
                  Row(
                    children: [
                      _buildNavLink(context, 'Get Started', () {
                        _homeController.scrollToSection(widget.featuresKey);
                      }),
                      const SizedBox(width: 32),
                      _buildNavLink(context, 'Showcase', () {
                        _homeController.scrollToSection(widget.showcaseKey);
                      }),
                      const SizedBox(width: 32),
                      _buildNavLink(context, 'Reviews', () {
                        _homeController.scrollToSection(widget.testimonialsKey);
                      }),
                      const SizedBox(width: 32),
                      _buildNavLink(context, 'FAQ', () {
                        _homeController.scrollToSection(widget.faqKey);
                      }),
                      const SizedBox(width: 32),
                      // 主题切换按钮（手动管理，避免 Obx）
                      IconButton(
                        icon: Icon(
                          _themeController.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () => _themeController.toggleTheme(),
                      ),
                      const SizedBox(width: 16),
                      // 用户信息或登录按钮（手动管理状态，避免 Obx 的 GlobalKey 问题）
                      if (_userController == null)
                        const SizedBox(
                          width: 100,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (_userController!.isLoggedIn)
                        _buildUserMenu(context, _userController!, theme)
                      else
                        AppButton(
                          text: 'Sign Up / Login',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/auth');
                          },
                          isRounded: true,
                        ),
                    ],
                  ),
                ],

                // 移动端菜单按钮
                if (isMobile)
                  Row(
                    children: [
                      // 主题切换按钮（手动管理）
                      IconButton(
                        icon: Icon(
                          _themeController.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () => _themeController.toggleTheme(),
                      ),
                      // 移动端菜单按钮（手动管理，避免 Obx）
                      IconButton(
                        icon: Icon(
                          _homeController.isMobileMenuOpen.value
                              ? Icons.close
                              : Icons.menu,
                        ),
                        onPressed: _homeController.toggleMobileMenu,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 构建用户菜单
  Widget _buildUserMenu(
    BuildContext context,
    UserController userController,
    ThemeData theme,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户头像
            if (userController.avatarUrl != null)
              ClipOval(
                child: Image.network(
                  userController.avatarUrl!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 24);
                  },
                ),
              )
            else
              const Icon(Icons.person, size: 24, color: AppColors.primary),
            const SizedBox(width: 8),
            // 用户名
            Text(
              userController.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 12),
              Text(
                '个人资料',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 18),
              const SizedBox(width: 12),
              Text(
                '设置',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                '登出',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // 跳转到个人资料页面
            debugPrint('💡 个人资料功能开发中...');
            // Get.snackbar(
            //   '提示',
            //   '个人资料功能开发中...',
            //   snackPosition: SnackPosition.TOP,
            // );
            break;
          case 'settings':
            // 跳转到设置页面
            debugPrint('💡 设置功能开发中...');
            // Get.snackbar(
            //   '提示',
            //   '设置功能开发中...',
            //   snackPosition: SnackPosition.TOP,
            // );
            break;
          case 'logout':
            // 登出
            userController.signOut();
            break;
        }
      },
    );
  }
}
