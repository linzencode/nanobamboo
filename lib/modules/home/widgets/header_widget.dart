import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/theme_controller.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/app_button.dart';

/// Header 组件
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
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
                      'NanoBanana',
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
                      _buildNavLink(context, '功能', () {}),
                      const SizedBox(width: 32),
                      _buildNavLink(context, '案例', () {}),
                      const SizedBox(width: 32),
                      _buildNavLink(context, '评价', () {}),
                      const SizedBox(width: 32),
                      _buildNavLink(context, 'FAQ', () {}),
                      const SizedBox(width: 32),
                      // 主题切换按钮
                      Obx(() => IconButton(
                            icon: Icon(
                              themeController.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            onPressed: () => themeController.toggleTheme(),
                          )),
                      const SizedBox(width: 16),
                      AppButton(
                        text: '开始使用',
                        onPressed: () {},
                        isRounded: true,
                      ),
                    ],
                  ),
                ],

                // 移动端菜单按钮
                if (isMobile)
                  Row(
                    children: [
                      // 主题切换按钮
                      Obx(() => IconButton(
                            icon: Icon(
                              themeController.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            onPressed: () => themeController.toggleTheme(),
                          )),
                      Obx(() => IconButton(
                            icon: Icon(
                              controller.isMobileMenuOpen.value
                                  ? Icons.close
                                  : Icons.menu,
                            ),
                            onPressed: controller.toggleMobileMenu,
                          )),
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
}

/// 移动端菜单抽屉
class MobileMenuDrawer extends StatelessWidget {
  const MobileMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final theme = Theme.of(context);

    return Obx(() {
      if (!controller.isMobileMenuOpen.value) {
        return const SizedBox.shrink();
      }

      return Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileNavLink(context, '功能', () {
              controller.closeMobileMenu();
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, '案例', () {
              controller.closeMobileMenu();
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, '评价', () {
              controller.closeMobileMenu();
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, 'FAQ', () {
              controller.closeMobileMenu();
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: '开始使用',
                onPressed: () {
                  controller.closeMobileMenu();
                },
                isRounded: true,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMobileNavLink(
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
}

