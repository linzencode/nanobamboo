import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/app/theme/app_text_styles.dart';

/// 章节标题组件
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
    this.textAlign = TextAlign.center,
  });

  /// 上标题（小标题）
  final String? overline;

  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 标题对齐方式
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : textAlign == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          Text(
            overline!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: textAlign,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: textAlign,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }
}

