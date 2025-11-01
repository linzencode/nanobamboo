/// 用户评价数据模型
class TestimonialModel {
  const TestimonialModel({
    required this.id,
    required this.name,
    required this.role,
    required this.content,
    required this.rating,
    required this.avatar,
  });

  /// 从 JSON 创建
  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      rating: json['rating'] as int,
      avatar: json['avatar'] as String,
    );
  }

  /// ID
  final int id;

  /// 姓名
  final String name;

  /// 角色/职位
  final String role;

  /// 评价内容
  final String content;

  /// 评分
  final int rating;

  /// 头像（emoji 或图片路径）
  final String avatar;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'content': content,
      'rating': rating,
      'avatar': avatar,
    };
  }

  /// 复制并更新
  TestimonialModel copyWith({
    int? id,
    String? name,
    String? role,
    String? content,
    int? rating,
    String? avatar,
  }) {
    return TestimonialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      avatar: avatar ?? this.avatar,
    );
  }
}

