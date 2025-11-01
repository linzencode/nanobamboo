/// 应用场景数据模型
class CaseModel {
  const CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
  });

  /// 从 JSON 创建
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
    );
  }

  /// ID
  final int id;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 图片路径
  final String image;

  /// 分类
  final String category;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
    };
  }

  /// 复制并更新
  CaseModel copyWith({
    int? id,
    String? title,
    String? description,
    String? image,
    String? category,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }
}

