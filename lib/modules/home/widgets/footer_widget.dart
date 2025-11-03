import 'package:flutter/material.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';

/// Footer 组件
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context),
        vertical: isMobile ? 48 : 60,
      ),
      color: isDark ? theme.colorScheme.surface : AppColors.darkBackground,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              // 主要内容
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandSection(context),
                        const SizedBox(height: 32),
                        _buildProductSection(context),
                        const SizedBox(height: 32),
                        _buildCompanySection(context),
                        const SizedBox(height: 32),
                        _buildLegalSection(context),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBrandSection(context),
                      ),
                      const SizedBox(width: 48),
                      Expanded(child: _buildProductSection(context)),
                      const SizedBox(width: 48),
                      Expanded(child: _buildCompanySection(context)),
                      const SizedBox(width: 48),
                      Expanded(child: _buildLegalSection(context)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // 分隔线
              Divider(
                color: Colors.white.withValues(alpha: 0.2),
              ),

              const SizedBox(height: 32),

              // 底部信息
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isMobile) {
                    return Column(
                      children: [
                        Text(
                          '© 2025 NanoBamboo. All rights reserved.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _buildSocialLinks(context),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2025 NanoBamboo. All rights reserved.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      _buildSocialLinks(context),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🍌',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NanoBamboo',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '为全球专业人士提供先进的 AI 驱动图像处理。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSection(BuildContext context) {
    return _buildFooterSection(
      context,
      'Product',
      ['Get Started', 'Pricing', 'API Docs', 'Blog'],
    );
  }

  Widget _buildCompanySection(BuildContext context) {
    return _buildFooterSection(
      context,
      'Company',
      ['About', 'Careers', 'Contact', 'News'],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return _buildFooterSection(
      context,
      'Legal',
      ['Privacy', 'Terms', 'Security', 'Cookie'],
    );
  }

  Widget _buildFooterSection(
    BuildContext context,
    String title,
    List<String> links,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialLink(context, 'Twitter', () {}),
        const SizedBox(width: 24),
        _buildSocialLink(context, 'GitHub', () {}),
        const SizedBox(width: 24),
        _buildSocialLink(context, 'LinkedIn', () {}),
      ],
    );
  }

  Widget _buildSocialLink(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

