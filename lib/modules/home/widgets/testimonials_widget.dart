import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/section_title.dart';

/// 用户评价组件
class TestimonialsWidget extends StatelessWidget {
  const TestimonialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context),
        vertical: isMobile ? 60 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const SectionTitle(
                title: '全球用户喜爱',
                subtitle: '加入数千名信任 NanoBamboo 满足其图像处理需求的专业人士',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                  );

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isMobile ? 0.9 : 1.1,
                    ),
                    itemCount: controller.testimonials.length,
                    itemBuilder: (context, index) {
                      final testimonial = controller.testimonials[index];
                      return _buildTestimonialCard(
                        context,
                        testimonial.name,
                        testimonial.role,
                        testimonial.content,
                        testimonial.rating,
                        testimonial.avatar,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
    BuildContext context,
    String name,
    String role,
    String content,
    int rating,
    String avatar,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头像和信息
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getAvatarColor(avatar),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 评价内容
          Flexible(
            child: Text(
              '"$content"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.6,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String avatar) {
    // 根据不同的 emoji 返回不同的背景色
    switch (avatar) {
      case '👨‍💼':
        return const Color(0xFFFDB022).withValues(alpha: 0.2);
      case '👩‍💻':
        return const Color(0xFFFF6B2C).withValues(alpha: 0.2);
      case '👨‍🎨':
        return const Color(0xFFE63946).withValues(alpha: 0.2);
      default:
        return AppColors.primary.withValues(alpha: 0.2);
    }
  }
}

