/// FAQ data model
class FaqModel {
  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  /// Create from JSON
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  /// ID
  final int id;

  /// Question
  final String question;

  /// Answer
  final String answer;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  /// Copy with updates
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

