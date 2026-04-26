import 'package:hive/hive.dart';

part 'cached_question_model.g.dart';

@HiveType(typeId: 0)
class CachedQuestionModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final bool correctAnswer;

  @HiveField(3)
  final String explanation;

  @HiveField(4)
  final String category;

  CachedQuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
  });

  factory CachedQuestionModel.fromJson(Map<String, dynamic> json) {
    return CachedQuestionModel(
      id: int.parse(json['id'].toString()),
      question: json['question'] ?? '',
      correctAnswer: json['correct_answer'] == '1' || json['correct_answer'] == true,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? 'عشوائي',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'category': category,
    };
  }
}
