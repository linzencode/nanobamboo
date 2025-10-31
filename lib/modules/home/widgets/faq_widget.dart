import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/constants/app_constants.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/section_title.dart';

/// FAQ 组件
class FaqWidget extends StatelessWidget {
  const FaqWidget({super.key});

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
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            children: [
              const SectionTitle(
                title: '常见问题',
                subtitle: '关于 NanoBanana 您需要了解的一切',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.faqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final faq = controller.faqs[index];
                  return _buildFaqItem(
                    context,
                    controller,
                    faq.id,
                    faq.question,
                    faq.answer,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    HomeController controller,
    int id,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);

    return Obx(() {
      final isExpanded = controller.expandedFaqId.value == id;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isExpanded
                ? AppColors.primary.withOpacity(0.5)
                : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // 问题按钮
            InkWell(
              onTap: () => controller.toggleFaq(id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: AppConstants.shortAnimationDuration,
                      child: Icon(
                        Icons.add,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 答案
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppConstants.mediumAnimationDuration,
            ),
          ],
        ),
      );
    });
  }
}

