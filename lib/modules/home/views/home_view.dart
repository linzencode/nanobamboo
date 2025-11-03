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
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // ✅ 在 State 中管理 GlobalKey，避免热重载时冲突
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _showcaseKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  
  // ✅ 在 State 中管理 ScrollController，避免多个 ScrollPosition 共享
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 直接获取全局单例 HomeController（在 main.dart 中已注册）
    final controller = Get.find<HomeController>();
    return Scaffold(
      body: Stack(
        children: [
          // 主内容
          Column(
            children: [
              // 顶部导航栏（传递 GlobalKey）
              HeaderWidget(
                featuresKey: _featuresKey,
                showcaseKey: _showcaseKey,
                testimonialsKey: _testimonialsKey,
                faqKey: _faqKey,
              ),

              // 可滚动内容
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Hero 首屏（传递 GlobalKey）
                      HeroWidget(
                        featuresKey: _featuresKey,
                        showcaseKey: _showcaseKey,
                      ),

                      // AI 图像生成器（Get Started）
                      Container(
                        key: _featuresKey,
                        child: const AiGeneratorWidget(),
                      ),

                      // 核心功能
                      const FeaturesWidget(),

                      // Cases展示
                      Container(
                        key: _showcaseKey,
                        child: const CaseShowcaseWidget(),
                      ),

                      // 用户Reviews
                      Container(
                        key: _testimonialsKey,
                        child: const TestimonialsWidget(),
                      ),

                      // FAQ
                      Container(
                        key: _faqKey,
                        child: const FaqWidget(),
                      ),

                      // Footer
                      const FooterWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 移动端菜单（覆盖层）
          MobileMenuDrawer(
            featuresKey: _featuresKey,
            showcaseKey: _showcaseKey,
            testimonialsKey: _testimonialsKey,
            faqKey: _faqKey,
          ),
        ],
      ),
    );
  }
}

/// 移动端菜单抽屉（覆盖层）
class MobileMenuDrawer extends StatefulWidget {
  const MobileMenuDrawer({
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
  State<MobileMenuDrawer> createState() => _MobileMenuDrawerState();
}

class _MobileMenuDrawerState extends State<MobileMenuDrawer> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    // 手动监听菜单开关状态
    _controller.isMobileMenuOpen.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_controller.isMobileMenuOpen.value) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 64, // Header 高度
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () => _controller.toggleMobileMenu(), // 点击背景关闭菜单
        child: Container(
          color: Colors.black.withValues(alpha: 0.5), // 半透明遮罩
          child: GestureDetector(
            onTap: () {}, // 防止点击菜单内容时关闭
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    _buildMobileNavLink(context, 'Get Started', () {
                      _controller.closeMobileMenu();
                      _controller.scrollToSection(widget.featuresKey);
                    }),
                    const SizedBox(height: 16),
                    _buildMobileNavLink(context, 'Cases', () {
                      _controller.closeMobileMenu();
                      _controller.scrollToSection(widget.showcaseKey);
                    }),
                    const SizedBox(height: 16),
                    _buildMobileNavLink(context, 'Reviews', () {
                      _controller.closeMobileMenu();
                      _controller.scrollToSection(widget.testimonialsKey);
                    }),
                    const SizedBox(height: 16),
                    _buildMobileNavLink(context, 'FAQ', () {
                      _controller.closeMobileMenu();
                      _controller.scrollToSection(widget.faqKey);
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.closeMobileMenu();
                          _controller.scrollToSection(widget.featuresKey);
                        },
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
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
