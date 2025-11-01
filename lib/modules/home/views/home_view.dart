import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/modules/home/widgets/ai_generator_widget.dart';
import 'package:nanobamboo/modules/home/widgets/case_showcase_widget.dart';
import 'package:nanobamboo/modules/home/widgets/faq_widget.dart';
import 'package:nanobamboo/modules/home/widgets/features_widget.dart';
import 'package:nanobamboo/modules/home/widgets/footer_widget.dart';
import 'package:nanobamboo/modules/home/widgets/header_widget.dart';
import 'package:nanobamboo/modules/home/widgets/hero_widget.dart';
import 'package:nanobamboo/modules/home/widgets/testimonials_widget.dart';

/// 首页视图
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部导航栏
          const HeaderWidget(),

          // 可滚动内容
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Column(
                children: [
                  // Hero 首屏
                  const HeroWidget(),

                  // AI 图像生成器（开始使用）
                  Container(
                    key: controller.featuresKey,
                    child: const AiGeneratorWidget(),
                  ),

                  // 核心功能
                  const FeaturesWidget(),

                  // 案例展示
                  Container(
                    key: controller.showcaseKey,
                    child: const CaseShowcaseWidget(),
                  ),

                  // 用户评价
                  Container(
                    key: controller.testimonialsKey,
                    child: const TestimonialsWidget(),
                  ),

                  // FAQ
                  Container(
                    key: controller.faqKey,
                    child: const FaqWidget(),
                  ),

                  // Footer
                  const FooterWidget(),
                ],
              ),
            ),
          ),

          // 移动端菜单（覆盖层）
          const MobileMenuDrawer(),
        ],
      ),
    );
  }
}

/// 移动端菜单抽屉（来自 HeaderWidget）
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMobileNavLink(context, '开始使用', () {
              controller.scrollToSection(controller.featuresKey);
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, '案例', () {
              controller.scrollToSection(controller.showcaseKey);
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, '评价', () {
              controller.scrollToSection(controller.testimonialsKey);
            }),
            const SizedBox(height: 16),
            _buildMobileNavLink(context, 'FAQ', () {
              controller.scrollToSection(controller.faqKey);
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.scrollToSection(controller.featuresKey);
                },
                child: const Text('开始使用'),
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
