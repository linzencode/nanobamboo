import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';

/// 按钮类型
enum AppButtonType {
  /// 主要按钮
  primary,

  /// 次要按钮
  secondary,

  /// 轮廓按钮
  outline,
}

/// 自定义按钮组件
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isRounded = true,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final AppButtonType type;

  /// 是否为圆角按钮
  final bool isRounded;

  /// 图标
  final IconData? icon;

  /// 是否加载中
  final bool isLoading;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty) Text(text),
      ],
    );

    final borderRadius = isRounded
        ? BorderRadius.circular(100)
        : BorderRadius.circular(12);

    switch (type) {
      case AppButtonType.primary:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );

      case AppButtonType.secondary:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );

      case AppButtonType.outline:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}

