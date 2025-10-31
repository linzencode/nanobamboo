import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/shared/widgets/section_title.dart';

/// 图片上传组件
class ImageUploaderWidget extends StatelessWidget {
  const ImageUploaderWidget({super.key});

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
          constraints: const BoxConstraints(maxWidth: 896),
          child: Column(
            children: [
              const SectionTitle(
                title: '上传您的图片',
                subtitle: '拖放您的图片或点击从您的设备浏览',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 上传区域
              Obx(() {
                final uploadedImage = controller.uploadedImage.value;

                return GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: uploadedImage != null
                            ? AppColors.primary
                            : theme.dividerColor,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: uploadedImage != null
                        ? _buildUploadedImage(
                            context,
                            controller,
                            uploadedImage,
                          )
                        : _buildUploadArea(context),
                  ),
                );
              }),

              // 处理结果
              Obx(() {
                if (controller.uploadedImage.value == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(top: 48),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '处理结果',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = isMobile ? 1 : 3;
                          return GridView.count(
                            crossAxisCount: columns,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.5,
                            children: [
                              _buildMetricCard(
                                context,
                                '图片质量',
                                '98%',
                              ),
                              _buildMetricCard(
                                context,
                                '处理时间',
                                '0.3s',
                              ),
                              _buildMetricCard(
                                context,
                                'AI 置信度',
                                '99.7%',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          '点击或拖动上传',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PNG、JPG、WebP 最大 10MB',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedImage(
    BuildContext context,
    HomeController controller,
    File image,
  ) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            fit: BoxFit.contain,
            height: 384,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: controller.clearImage,
          icon: const Icon(Icons.refresh),
          label: const Text('上传另一张'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

