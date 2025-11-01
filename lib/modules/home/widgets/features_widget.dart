import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/data/models/feature_model.dart';
import 'package:nanobamboo/shared/widgets/section_title.dart';

/// 核心功能组件
class FeaturesWidget extends StatelessWidget {
  const FeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    final features = [
      FeatureModel(
        title: '自然语言编辑',
        description: '使用简单的文字提示编辑图像。NanoBamboo AI 像图像版 GPT 一样理解复杂指令',
        icon: Icons.edit_note_rounded,
        iconColor: const Color(0xFFFBBF24),
      ),
      FeatureModel(
        title: '角色一致性',
        description: '在编辑过程中保持完美的角色细节。这个模型在保留面部和身份方面表现卓越',
        icon: Icons.person_pin_rounded,
        iconColor: const Color(0xFFF97316),
      ),
      FeatureModel(
        title: '场景保留',
        description: '无缝融合编辑内容与原始背景。场景融合能力优于 Flux Kontext',
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFFEF4444),
      ),
      FeatureModel(
        title: '一键编辑',
        description: '一次尝试就能获得完美效果。NanoBamboo 轻松解决一键图像编辑难题',
        icon: Icons.code_rounded,
        iconColor: const Color(0xFFFBBF24),
      ),
      FeatureModel(
        title: '多图上下文',
        description: '同时处理多张图像。支持高级多图编辑工作流',
        icon: Icons.layers_rounded,
        iconColor: const Color(0xFFF97316),
      ),
      FeatureModel(
        title: 'AI UGC 创作',
        description: '创建一致的 AI 影响者和 UGC 内容。完美适用于社交媒体和营销活动',
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
                overline: '核心功能',
                title: '为什么选择Nano Bamboo?',
                subtitle:
                    'Nano Bamboo 是 LMArena 上最先进的 AI 图像编辑器，用自然语言理解彻底改变您的照片编辑方式',
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
