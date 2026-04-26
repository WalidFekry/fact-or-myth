class QuestionModel {
  final int id;
  final String question;
  final bool correctAnswer;
  final String explanation;
  final String category;
  final bool isDaily;
  final DateTime? date;
  final bool? userAnswer;
  final bool? isCorrect;
  final int trueVotes;
  final int falseVotes;

  QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.isDaily,
    this.date,
    this.userAnswer,
    this.isCorrect,
    this.trueVotes = 0,
    this.falseVotes = 0,
  });

  int get totalVotes => trueVotes + falseVotes;
  double get truePercentage => totalVotes > 0 ? (trueVotes / totalVotes) * 100 : 0;
  double get falsePercentage => totalVotes > 0 ? (falseVotes / totalVotes) * 100 : 0;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: int.parse(json['id'].toString()),
      question: json['question'] ?? '',
      correctAnswer: json['correct_answer'] == '1' || json['correct_answer'] == true,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? 'عشوائي',
      isDaily: json['is_daily'] == '1' || json['is_daily'] == true,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      userAnswer: json['user_answer'] != null 
          ? (json['user_answer'] == '1' || json['user_answer'] == true)
          : null,
      isCorrect: json['is_correct'] != null
          ? (json['is_correct'] == '1' || json['is_correct'] == true)
          : null,
      trueVotes: json['true_votes'] != null ? int.parse(json['true_votes'].toString()) : 0,
      falseVotes: json['false_votes'] != null ? int.parse(json['false_votes'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correct_answer': correctAnswer ? 1 : 0,
      'explanation': explanation,
      'category': category,
      'is_daily': isDaily ? 1 : 0,
      'date': date?.toIso8601String(),
      'user_answer': userAnswer != null ? (userAnswer! ? 1 : 0) : null,
      'is_correct': isCorrect != null ? (isCorrect! ? 1 : 0) : null,
      'true_votes': trueVotes,
      'false_votes': falseVotes,
    };
  }
}
