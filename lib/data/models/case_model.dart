/// Use case data model
class CaseModel {
  const CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
  });

  /// Create from JSON
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

  /// Title
  final String title;

  /// Description
  final String description;

  /// Image path
  final String image;

  /// Category
  final String category;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
    };
  }

  /// Copy with updates
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

