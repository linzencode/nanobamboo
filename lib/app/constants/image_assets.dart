import 'package:nanobamboo/app/constants/app_constants.dart';

/// 图片资源路径
class ImageAssets {
  ImageAssets._();

  static const String _basePath = AppConstants.imagePath;

  /// Logo
  static const String logo = '$_basePath/placeholder-logo.png';
  static const String logoSvg = '$_basePath/placeholder-logo.svg';

  /// 占位图
  static const String placeholder = '$_basePath/placeholder.jpg';
  static const String placeholderSvg = '$_basePath/placeholder.svg';
  static const String placeholderUser = '$_basePath/placeholder-user.jpg';

  /// 案例展示图片
  static const String ecommerceProduct =
      '$_basePath/ecommerce-product-showcase-with-enhanced-quality.jpg';
  static const String realEstate =
      '$_basePath/modern-real-estate-property-interior-design.jpg';
  static const String socialMedia =
      '$_basePath/vibrant-social-media-content-creation-setup.jpg';
  static const String medicalImaging =
      '$_basePath/medical-imaging-healthcare-technology.jpg';
}

