import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/theme/app_colors.dart';
import 'package:nanobamboo/core/utils/responsive_utils.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';

/// AI 图像生成器组件
class AiGeneratorWidget extends StatelessWidget {
  const AiGeneratorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveUtils.isMobile(context);

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
              // 上标题
              const Text(
                '开始使用',
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // 主标题
              Text(
                '试用 AI 编辑器',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 32 : 42,
                ),
              ),
              const SizedBox(height: 12),
              
              // 副标题
              Text(
                '体验NanoBamboo的自然语言图像编辑能力，用简单的文字命令变换任何照片',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 主内容区域
              if (isMobile)
                Column(
                  children: [
                    _buildPromptEngine(context, controller, isDark),
                    const SizedBox(height: 24),
                    _buildOutputGallery(context, controller, isDark),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPromptEngine(context, controller, isDark),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildOutputGallery(context, controller, isDark),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 提示引擎（左侧）
  Widget _buildPromptEngine(BuildContext context, HomeController controller, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: Color(0xFFF97316),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '提示引擎',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '用 AI 技术编辑您的图像',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 标签页切换
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      context,
                      '图生图',
                      true,
                      controller.generationMode.value == 'image',
                      () => controller.generationMode.value = 'image',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeTab(
                      context,
                      '文生图',
                      false,
                      controller.generationMode.value == 'text',
                      () => controller.generationMode.value = 'text',
                    ),
                  ),
                ],
              ),),
          const SizedBox(height: 24),

          // AI 模型选择
          _buildAIModelSelector(context, theme),
          const SizedBox(height: 24),

          // 批量生成（仅图生图模式显示）
          Obx(() {
            if (controller.generationMode.value != 'image') {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF0E5C8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              '批量生成',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Pro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF97316)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.upgrade, size: 14, color: Color(0xFFF97316)),
                            SizedBox(width: 4),
                            Text(
                              '升级',
                              style: TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '批量生成减低单个图片的时长，生成多张级联输出片',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // 参考图像（仅图生图模式显示）
          Obx(() {
            if (controller.generationMode.value != 'image') {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 16, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      '参考图像',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => Text(
                          '${controller.referenceImages.length}/9',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 32,
                            color: Color(0xFFF97316),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '添加图片',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '最大10MB',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // 主提示词
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, size: 16, color: Color(0xFFF97316)),
                  SizedBox(width: 8),
                  Text(
                    '主提示词',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.promptController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '由摄影技术拍摄的未来城市，黄金时段照明，超高清晰度...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFF0E5C8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFF0E5C8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.copyPrompt,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.content_copy, size: 14),
                      SizedBox(width: 4),
                      Text('复制', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 提示框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '想要体验更强大的图像生成功能？',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          '访问完整版生成器 →',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 立即生成按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.startGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '立即生成',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 输出画廊（右侧）
  Widget _buildOutputGallery(BuildContext context, HomeController controller, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.collections_outlined,
                  color: Color(0xFFF97316),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '输出画廊',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '您的内电脑 AI 创作即时显示在这里',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 根据状态显示不同内容
          Obx(() {
            final status = controller.generationStatus.value;
            
            if (status == 'loading') {
              return _buildLoadingState(context, controller, theme);
            } else if (status == 'completed') {
              return _buildCompletedState(context, controller, isDark, theme);
            } else {
              return _buildIdleState(context, theme, isDark);
            }
          }),
        ],
      ),
    );
  }

  // AI 模型选择器
  Widget _buildAIModelSelector(BuildContext context, ThemeData theme) {
    final controller = Get.find<HomeController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_fix_high, size: 16, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text(
              'AI模型选择',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.isModelSelectorFocused.value 
                      ? const Color(0xFFF97316) 
                      : const Color(0xFFF0E5C8),
                  width: controller.isModelSelectorFocused.value ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                focusNode: controller.modelSelectorFocusNode,
                initialValue: 'nano_banana',
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'nano_banana', child: Text('Nano Banana')),
                  DropdownMenuItem(value: 'nano_banana_pro', child: Text('Nano Banana Pro')),
                ],
                onChanged: (value) {
                  // 选择后移除焦点
                  controller.modelSelectorFocusNode.unfocus();
                },
              ),
            ),),
        const SizedBox(height: 8),
        Text(
          '不同模型具有不同特性和风格',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  // 空闲状态
  Widget _buildIdleState(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              '准备即时生成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '输入提示词，释放强大力量',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 加载状态
  Widget _buildLoadingState(BuildContext context, HomeController controller, ThemeData theme) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? Colors.black.withValues(alpha: 0.2) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
              ? theme.dividerColor 
              : const Color(0xFFF0E5C8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 橙色转圈动画
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Color(0xFFF97316),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          // "正在处理您的请求..."
          const Text(
            '正在处理您的请求...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // "光速生成进行中"
          Text(
            '光速生成进行中',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          // 进度百分比
          Obx(() => Text(
                '${controller.generationProgress.value}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),),
          const SizedBox(height: 12),
          // 进度条
          SizedBox(
            width: double.infinity,
            child: Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.generationProgress.value / 100,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFFF97316),
                    minHeight: 8,
                  ),
                ),),
          ),
          const SizedBox(height: 12),
          // 预计剩余时间
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '预计剩余时间: ${controller.estimatedTime.value} 秒',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),),
          const SizedBox(height: 24),
          // 底部提示文字
          Text(
            'This may take 2-5 minutes. Please wait while we create your masterpiece using advanced AI models.',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 三个橙色点动画
          _buildDotsAnimation(),
        ],
      ),
    );
  }

  // 三个橙色点动画
  Widget _buildDotsAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFF97316),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  // 完成状态
  Widget _buildCompletedState(BuildContext context, HomeController controller, bool isDark, ThemeData theme) {
    return Column(
      children: [
        // 生成的图片
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            controller.generatedImageUrl.value,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
                  ),
                ),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Color(0xFFF97316),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? theme.dividerColor : const Color(0xFFF0E5C8),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('图片加载失败'),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 下载图片按钮
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: controller.downloadGeneratedImage,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFF0E5C8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.download, color: Colors.black87),
            label: const Text(
              '下载图片',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // 模式标签页
  Widget _buildModeTab(
    BuildContext context,
    String label,
    bool isLeft,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF97316) : const Color(0xFFFFFAEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLeft ? Icons.image : Icons.text_fields,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

