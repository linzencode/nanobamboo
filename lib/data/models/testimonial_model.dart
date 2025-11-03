/// User testimonial data model
class TestimonialModel {
  const TestimonialModel({
    required this.id,
    required this.name,
    required this.role,
    required this.content,
    required this.rating,
    required this.avatar,
  });

  /// Create from JSON
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

  /// Name
  final String name;

  /// Role/Position
  final String role;

  /// Review content
  final String content;

  /// Rating
  final int rating;

  /// Avatar (emoji or image path)
  final String avatar;

  /// Convert to JSON
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

  /// Copy with updates
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

