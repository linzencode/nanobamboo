import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/app_text_styles.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/app_button.dart';

/// Hero Section Widget
class HeroWidget extends StatelessWidget {
  const HeroWidget({
    super.key,
    this.featuresKey,
    this.showcaseKey,
  });

  final GlobalKey? featuresKey;
  final GlobalKey? showcaseKey;

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
          // Decorative gradient background
          Positioned(
            left: 0,
            top: 80,
            child: Container(
              width: 96,
              height: 192,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.1),
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
                    AppColors.secondary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),

          // Main content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 896),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Transform Your Images with AI',
                    style: isMobile
                        ? AppTextStyles.h2.copyWith(
                            color: theme.colorScheme.onSurface,
                          )
                        : AppTextStyles.h1.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Subtitle
                  Text(
                    'Professional image processing powered by cutting-edge AI. Upload, analyze, and enhance your images in seconds.',
                    style: isMobile
                        ? AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          )
                        : AppTextStyles.bodyLarge.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // CTA Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      AppButton(
                        text: 'Get Started',
                        onPressed: () {
                          if (featuresKey != null) {
                            Get.find<HomeController>().scrollToSection(featuresKey!);
                          }
                        },
                        type: AppButtonType.primary,
                        isRounded: true,
                      ),
                      AppButton(
                        text: 'View Demo',
                        onPressed: () {
                          if (showcaseKey != null) {
                            Get.find<HomeController>().scrollToSection(showcaseKey!);
                          }
                        },
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

