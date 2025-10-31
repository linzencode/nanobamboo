import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/app_text_styles.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/shared/widgets/app_button.dart';

/// Hero 首屏组件
class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context),
        vertical: isMobile ? 60 : 120,
      ),
      child: Stack(
        children: [
          // 装饰性渐变背景
          Positioned(
            left: 0,
            top: 80,
            child: Container(
              width: 96,
              height: 192,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 80,
            child: Container(
              width: 96,
              height: 192,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),

          // 主要内容
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 896),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  Text(
                    '用 AI 智能转换您的图片',
                    style: isMobile
                        ? AppTextStyles.h2.copyWith(
                            color: theme.colorScheme.onSurface,
                          )
                        : AppTextStyles.h1.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                    textAlign: TextAlign.center,
                  ),

                  // 主色调文字
                  const SizedBox(height: 8),
                  Text(
                    '',
                    style: isMobile
                        ? AppTextStyles.h2.copyWith(color: AppColors.primary)
                        : AppTextStyles.h1.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // 副标题
                  Text(
                    '专业级图像处理，由前沿 AI 驱动。上传、分析并在几秒钟内增强您的图像。',
                    style: isMobile
                        ? AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          )
                        : AppTextStyles.bodyLarge.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // CTA 按钮
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      AppButton(
                        text: '开始处理',
                        onPressed: () {},
                        type: AppButtonType.primary,
                        isRounded: true,
                      ),
                      AppButton(
                        text: '查看演示',
                        onPressed: () {},
                        type: AppButtonType.outline,
                        isRounded: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

