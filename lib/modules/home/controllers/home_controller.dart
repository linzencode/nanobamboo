import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanobamboo/app/constants/image_assets.dart';
import 'package:nanobamboo/data/models/case_model.dart';
import 'package:nanobamboo/data/models/faq_model.dart';
import 'package:nanobamboo/data/models/testimonial_model.dart';

/// 首页控制器
class HomeController extends GetxController {
  /// 移动端菜单是否打开
  final RxBool isMobileMenuOpen = false.obs;

  /// 上传的图片文件
  final Rx<File?> uploadedImage = Rx<File?>(null);

  /// 是否正在处理图片
  final RxBool isProcessing = false.obs;

  /// 当前展开的 FAQ ID
  final RxnInt expandedFaqId = RxnInt(0);

  /// 图片选择器
  final ImagePicker _picker = ImagePicker();

  /// 应用场景列表
  final List<CaseModel> cases = const [
    CaseModel(
      id: 1,
      title: '电商产品增强',
      description: '自动增强和优化在线商店的产品图片',
      image: ImageAssets.ecommerceProduct,
      category: '零售',
    ),
    CaseModel(
      id: 2,
      title: '房地产摄影',
      description: '为房产列表和营销提供专业照片增强',
      image: ImageAssets.realEstate,
      category: '房地产',
    ),
    CaseModel(
      id: 3,
      title: '社交媒体优化',
      description: '完善您的图片以获得跨平台的最大参与度',
      image: ImageAssets.socialMedia,
      category: '营销',
    ),
    CaseModel(
      id: 4,
      title: '医学影像分析',
      description: 'AI 驱动的医学图像分析和诊断支持',
      image: ImageAssets.medicalImaging,
      category: '医疗',
    ),
  ];

  /// 用户评价列表
  final List<TestimonialModel> testimonials = const [
    TestimonialModel(
      id: 1,
      name: '陈小雅',
      role: '电商经理',
      content: 'NanoBanana 彻底改变了我们的产品摄影工作流程。AI 增强功能非常快速，产生专业的效果。',
      rating: 5,
      avatar: '👩‍💼',
    ),
    TestimonialModel(
      id: 2,
      name: '王浩',
      role: '房地产经纪人',
      content: '图像质量改进非常显著。我们的房产列表现在看起来很高端，而无需昂贵的专业摄影师。',
      rating: 5,
      avatar: '👨‍💼',
    ),
    TestimonialModel(
      id: 3,
      name: '李思婷',
      role: '内容创作者',
      content: '社交媒体的完美工具。AI 理解上下文并增强图像，同时保持自然的外观。',
      rating: 5,
      avatar: '👩‍🎨',
    ),
    TestimonialModel(
      id: 4,
      name: '张明',
      role: '营销总监',
      content: '效率提升非常显著。我们每天处理的图像数量是原来的 10 倍，同时保持质量标准。',
      rating: 5,
      avatar: '👨‍💻',
    ),
  ];

  /// FAQ 列表
  final List<FaqModel> faqs = const [
    FaqModel(
      id: 0,
      question: 'NanoBanana 支持哪些图片格式？',
      answer: '我们支持所有主要的图像格式，包括 PNG、JPG、WebP、JPEG 和 GIF。最大可处理 10MB 的文件。',
    ),
    FaqModel(
      id: 1,
      question: '图片处理需要多长时间？',
      answer: '大多数图像在 1 秒内处理完成。处理时间取决于图像大小和复杂性，但通常在 0.2 到 3 秒之间。',
    ),
    FaqModel(
      id: 2,
      question: '我的数据是否安全和私密？',
      answer: '绝对安全。所有图像都采用企业级加密处理，并在处理后自动删除。我们从不存储或分享您的数据。',
    ),
    FaqModel(
      id: 3,
      question: '我可以将 NanoBanana 用于商业用途吗？',
      answer: '可以，我们的专业版和企业版计划完全支持商业用途。处理后的图像归您所有，可以自由使用。',
    ),
    FaqModel(
      id: 4,
      question: '定价模式是什么？',
      answer: '我们提供灵活的定价：免费计划（每月 5 张图片）、专业版（29 美元/月，无限制）和企业版（定制）。免费套餐无需信用卡。',
    ),
    FaqModel(
      id: 5,
      question: '你们提供 API 访问吗？',
      answer: '是的！我们提供强大的 REST API 和 Python、Node.js 和 Go 的 SDK。非常适合集成到您的应用程序中。',
    ),
  ];

  /// 切换移动端菜单
  void toggleMobileMenu() {
    isMobileMenuOpen.value = !isMobileMenuOpen.value;
  }

  /// 关闭移动端菜单
  void closeMobileMenu() {
    isMobileMenuOpen.value = false;
  }

  /// 切换 FAQ 展开状态
  void toggleFaq(int id) {
    if (expandedFaqId.value == id) {
      expandedFaqId.value = null;
    } else {
      expandedFaqId.value = id;
    }
  }

  /// 选择图片
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
      debugPrint('选择图片失败: $e');
      Get.snackbar(
        '错误',
        '选择图片失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// 处理图片（模拟）
  Future<void> _processImage() async {
    isProcessing.value = true;

    // 模拟处理延迟
    await Future.delayed(const Duration(milliseconds: 300));

    isProcessing.value = false;

    Get.snackbar(
      '成功',
      '图片处理完成！',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );
  }

  /// 清除上传的图片
  void clearImage() {
    uploadedImage.value = null;
    isProcessing.value = false;
  }

  @override
  void onClose() {
    // 清理资源
    uploadedImage.value = null;
    super.onClose();
  }
}

