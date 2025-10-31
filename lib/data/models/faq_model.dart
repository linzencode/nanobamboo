/// FAQ 数据模型
class FaqModel {
  /// ID
  final int id;

  /// 问题
  final String question;

  /// 答案
  final String answer;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  /// 从 JSON 创建
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  /// 复制并更新
  FaqModel copyWith({
    int? id,
    String? question,
    String? answer,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}

