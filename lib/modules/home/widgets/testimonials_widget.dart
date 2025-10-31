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
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context),
        vertical: isMobile ? 60 : 80,
      ),
      color: theme.colorScheme.surface.withOpacity(0.5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              const SectionTitle(
                title: '全球用户喜爱',
                subtitle: '加入数千名信任 NanoBanana 满足其图像处理需求的专业人士',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = ResponsiveUtils.getResponsiveValue(
                    context: context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 4,
                  );

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isMobile ? 1.2 : 0.9,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像和信息
          Row(
            children: [
              Text(
                avatar,
                style: const TextStyle(fontSize: 32),
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 评分
          Row(
            children: List.generate(
              rating,
              (index) => const Icon(
                Icons.star,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 评价内容
          Text(
            '"$content"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

