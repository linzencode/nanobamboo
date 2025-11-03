import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/data/models/feature_model.dart';
import 'package:nanobamboo/shared/widgets/section_title.dart';

/// Core Features Widget
class FeaturesWidget extends StatelessWidget {
  const FeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    final features = [
      FeatureModel(
        title: 'Natural Language Editing',
        description: 'Edit images using simple text prompts. NanoBamboo AI understands complex instructions like GPT for images',
        icon: Icons.edit_note_rounded,
        iconColor: const Color(0xFFFBBF24),
      ),
      FeatureModel(
        title: 'Character Consistency',
        description: 'Maintain perfect character details during editing. This model excels at preserving faces and identities',
        icon: Icons.person_pin_rounded,
        iconColor: const Color(0xFFF97316),
      ),
      FeatureModel(
        title: 'Scene Preservation',
        description: 'Seamlessly blend edited content with original backgrounds. Scene blending capability superior to Flux Kontext',
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFFEF4444),
      ),
      FeatureModel(
        title: 'One-Click Editing',
        description: 'Get perfect results in one try. NanoBamboo easily solves one-click image editing challenges',
        icon: Icons.code_rounded,
        iconColor: const Color(0xFFFBBF24),
      ),
      FeatureModel(
        title: 'Multi-Image Context',
        description: 'Process multiple images simultaneously. Supports advanced multi-image editing workflows',
        icon: Icons.layers_rounded,
        iconColor: const Color(0xFFF97316),
      ),
      FeatureModel(
        title: 'AI UGC Creation',
        description: 'Create consistent AI influencers and UGC content. Perfect for social media and marketing campaigns',
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFFEF4444),
      ),
    ];

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
                overline: 'Core Features',
                title: 'Why Choose Nano Bamboo?',
                subtitle:
                    'Nano Bamboo is LMArena\'s most advanced AI image editor, revolutionizing your photo editing with natural language understanding',
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
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return _buildFeatureCard(
                        context,
                        feature.title,
                        feature.description,
                        feature.icon,
                        feature.iconColor,
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

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color iconColor,
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 标题
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          // 描述
          Flexible(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.6,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
