import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanobamboo/app/constants/image_assets.dart';
import 'package:nanobamboo/data/models/case_model.dart';
import 'package:nanobamboo/data/models/faq_model.dart';
import 'package:nanobamboo/data/models/testimonial_model.dart';

/// Home page controller
class HomeController extends GetxController {
  /// ⚠️ ScrollController removed, now managed in HomeView State
  /// Avoids multiple ScrollPosition issues during hot reload
  
  /// ⚠️ GlobalKey removed, now managed in HomeView (StatefulWidget)
  /// Avoids GlobalKey conflicts when Controller is recreated during hot reload

  /// Whether mobile menu is open
  final RxBool isMobileMenuOpen = false.obs;

  /// Uploaded image file
  final Rx<File?> uploadedImage = Rx<File?>(null);

  /// Whether image is processing
  final RxBool isProcessing = false.obs;

  /// Currently expanded FAQ ID
  final RxnInt expandedFaqId = RxnInt(0);

  /// Generation mode (image: image-to-image, text: text-to-image)
  final RxString generationMode = 'image'.obs;

  /// Reference images list
  final RxList<File> referenceImages = <File>[].obs;

  /// Main prompt text controller
  final TextEditingController promptController = TextEditingController();

  /// AI model selector focus node
  final FocusNode modelSelectorFocusNode = FocusNode();

  /// Whether AI model selector is focused
  final RxBool isModelSelectorFocused = false.obs;

  /// AI生成状态 (idle, loading, completed, error)
  final RxString generationStatus = 'idle'.obs;

  /// Generation progress (0-100)
  final RxInt generationProgress = 0.obs;

  /// Estimated remaining time (seconds)
  final RxInt estimatedTime = 0.obs;

  /// Generated image URL (placeholder)
  final RxString generatedImageUrl = ''.obs;

  /// Image picker
  final ImagePicker _picker = ImagePicker();

  /// Use cases list
  final List<CaseModel> cases = const [
    CaseModel(
      id: 1,
      title: 'E-commerce Product Enhancement',
      description: 'Automatically enhance and optimize product images for online stores',
      image: ImageAssets.ecommerceProduct,
      category: 'Retail',
    ),
    CaseModel(
      id: 2,
      title: 'Real Estate Photography',
      description: 'Professional photo enhancement for property listings and marketing',
      image: ImageAssets.realEstate,
      category: 'Real Estate',
    ),
    CaseModel(
      id: 3,
      title: 'Social Media Optimization',
      description: 'Perfect your images for maximum engagement across platforms',
      image: ImageAssets.socialMedia,
      category: 'Marketing',
    ),
    CaseModel(
      id: 4,
      title: 'Medical Image Analysis',
      description: 'AI-powered medical image processing and diagnostic support',
      image: ImageAssets.medicalImaging,
      category: 'Medical',
    ),
  ];

  /// Testimonials list
  final List<TestimonialModel> testimonials = const [
    TestimonialModel(
      id: 1,
      name: 'Chen Xiaoya',
      role: 'E-commerce Manager',
      content: 'NanoBamboo has completely transformed our product photography workflow. The AI enhancement features are incredibly fast and produce professional results.',
      rating: 5,
      avatar: '👩‍💼',
    ),
    TestimonialModel(
      id: 2,
      name: 'Wang Hao',
      role: 'Real Estate Agent',
      content: 'The image quality improvement is remarkable. Our property listings now look much more premium without expensive professional photographers.',
      rating: 5,
      avatar: '👨‍💼',
    ),
    TestimonialModel(
      id: 3,
      name: 'Li Siting',
      role: 'Content Creator',
      content: 'Perfect tool for social media. The AI understands context and enhances images while maintaining a natural look.',
      rating: 5,
      avatar: '👩‍🎨',
    ),
    TestimonialModel(
      id: 4,
      name: 'Zhang Ming',
      role: 'Marketing Director',
      content: 'The efficiency improvement is significant. We process 10 times more images daily while maintaining quality standards.',
      rating: 5,
      avatar: '👨‍💻',
    ),
  ];

  /// FAQ list
  final List<FaqModel> faqs = const [
    FaqModel(
      id: 0,
      question: 'What image formats does NanoBamboo support?',
      answer: 'We support all major image formats including PNG, JPG, WebP, JPEG, and GIF. Maximum file size is 10MB.',
    ),
    FaqModel(
      id: 1,
      question: 'How long does image processing take?',
      answer: 'Most images are processed within 1 second. Processing time depends on image size and complexity, but typically ranges from 0.2 to 3 seconds.',
    ),
    FaqModel(
      id: 2,
      question: 'Is my data secure and private?',
      answer: 'Absolutely. All images are processed with enterprise-grade encryption and automatically deleted after processing. We never store or share your data.',
    ),
    FaqModel(
      id: 3,
      question: 'Can I use NanoBamboo for commercial purposes?',
      answer: 'Yes, our Professional and Enterprise plans fully support commercial use. Processed images belong to you and can be used freely.',
    ),
    FaqModel(
      id: 4,
      question: 'What is the pricing model?',
      answer: 'We offer flexible pricing: Free plan (5 images/month), Professional (\$29/month, unlimited), and Enterprise (custom). No credit card required for free tier.',
    ),
    FaqModel(
      id: 5,
      question: 'Do you provide API access?',
      answer: 'Yes! We provide a powerful REST API and SDKs for Python, Node.js, and Go. Perfect for integration into your applications.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to AI model selector focus changes
    modelSelectorFocusNode.addListener(() {
      isModelSelectorFocused.value = modelSelectorFocusNode.hasFocus;
    });
    
    // OAuth callback detected
    _checkOAuthCallback();
  }
  
  /// Detect OAuth callback
  void _checkOAuthCallback() {
    // Delayed execution to ensure page is rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        // Check if current URL contains OAuth parameters
        final uri = Uri.base;
        final hasOAuthParams = uri.fragment.contains('access_token') || 
                                uri.queryParameters.containsKey('code') ||
                                uri.fragment.contains('type=recovery');
        
        if (hasOAuthParams) {
          debugPrint('✅ 检测到 OAuth 回调成功');
          
          // ⚠️ 注释掉 GetX Snackbar，因为使用 MaterialApp 会导致 null 错误
          // 用户可以从右上角的用户信息看到登录成功
          // Get.snackbar(
          //   '登录成功！',
          //   '欢迎回来，已成功登录',
          //   snackPosition: SnackPosition.TOP,
          //   duration: const Duration(seconds: 3),
          //   backgroundColor: Colors.green.withValues(alpha: 0.9),
          //   colorText: Colors.white,
          //   icon: const Icon(Icons.check_circle, color: Colors.white),
          //   margin: const EdgeInsets.all(16),
          // );
          
          // Clean URL parameters (avoid repeated prompts on refresh)
          // 注意：这在 Flutter Web 中可能不会立即生效
          Future.delayed(const Duration(seconds: 1), () {
            try {
              // Try to clean URL (without affecting app state)
              // This is just an attempt, may not work in some browsers
              debugPrint('💡 OAuth 回调处理完成');
            } catch (e) {
              debugPrint('⚠️ 清理 URL 失败: $e');
            }
          });
        }
      } catch (e) {
        debugPrint('⚠️ Detect OAuth callback失败: $e');
      }
    });
  }

  /// Toggle mobile menu
  void toggleMobileMenu() {
    isMobileMenuOpen.value = !isMobileMenuOpen.value;
  }

  /// Close mobile menu
  void closeMobileMenu() {
    isMobileMenuOpen.value = false;
  }

  /// Toggle FAQ expanded state
  void toggleFaq(int id) {
    if (expandedFaqId.value == id) {
      expandedFaqId.value = null;
    } else {
      expandedFaqId.value = id;
    }
  }

  /// Pick image
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        uploadedImage.value = File(image.path);
        await _processImage();
      }
    } catch (e) {
      debugPrint('❌ Pick image失败: $e');
      // ⚠️ 注释掉 GetX Snackbar，避免 null 错误
      // Get.snackbar(
      //   '错误',
      //   'Pick image失败，请重试',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Get.theme.colorScheme.error,
      //   colorText: Get.theme.colorScheme.onError,
      // );
    }
  }

  /// Process image (simulated)
  Future<void> _processImage() async {
    isProcessing.value = true;

    // Simulate processing delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    isProcessing.value = false;

    debugPrint('✅ 图片处理完成！');
    // ⚠️ 注释掉 GetX Snackbar，避免 null 错误
    // Get.snackbar(
    //   '成功',
    //   '图片处理完成！',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Get.theme.colorScheme.primary,
    //   colorText: Colors.white,
    // );
  }

  /// Clear uploaded image
  void clearImage() {
    uploadedImage.value = null;
    isProcessing.value = false;
  }

  /// Scroll to section
  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      // Close mobile menu
      closeMobileMenu();

      // Scroll to target position
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.1, // Leave 10% space at top
      );
    }
  }

  @override
  void onClose() {
    // Clean up resources
    promptController.dispose();
    modelSelectorFocusNode.dispose();
    uploadedImage.value = null;
    resetGeneration();
    super.onClose();
  }
  
  /// Copy main prompt content
  void copyPrompt() {
    if (promptController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: promptController.text));
      debugPrint('✅ 复制成功: ${promptController.text}');
      // ⚠️ 注释掉 GetX Snackbar，避免 null 错误
      // Get.snackbar(
      //   '复制成功',
      //   '已复制提示词内容',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: const Duration(seconds: 2),
      //   backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.9),
      //   colorText: Colors.white,
      // );
    }
  }

  /// Start AI image generation
  Future<void> startGeneration() async {
    if (promptController.text.isEmpty) {
      debugPrint('⚠️ 请输入主提示词');
      // ⚠️ 注释掉 GetX Snackbar，避免 null 错误
      // Get.snackbar(
      //   '提示',
      //   '请输入主提示词',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.9),
      //   colorText: Colors.white,
      // );
      return;
    }

    // Set to loading state
    generationStatus.value = 'loading';
    generationProgress.value = 0;
    estimatedTime.value = 60;

    // Simulate progress update
    for (int i = 0; i <= 100; i += 5) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      generationProgress.value = i;
      estimatedTime.value = ((100 - i) / 100 * 60).round();
    }

    // Complete generation, use placeholder image
    generationStatus.value = 'completed';
    generatedImageUrl.value = 'https://picsum.photos/600/400?random=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Download generated image
  void downloadGeneratedImage() {
    // TODO: Implement actual download functionality
    debugPrint('📥 下载图片');
    // ⚠️ 注释掉 GetX Snackbar，避免 null 错误
    // Get.snackbar(
    //   '下载成功',
    //   '图片已保存到下载文件夹',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: const Color(0xFFF97316).withValues(alpha: 0.9),
    //   colorText: Colors.white,
    // );
  }

  /// Reset generation state
  void resetGeneration() {
    generationStatus.value = 'idle';
    generationProgress.value = 0;
    estimatedTime.value = 0;
    generatedImageUrl.value = '';
  }
}

