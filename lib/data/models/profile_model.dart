class ProfileModel {
  final int userId;
  final String name;
  final String avatar;
  final int totalAnswers;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracy;
  final int currentStreak;

  ProfileModel({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracy,
    required this.currentStreak,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '👨',
      totalAnswers: int.tryParse(json['total_answers']?.toString() ?? '0') ?? 0,
      correctAnswers: int.tryParse(json['correct_answers']?.toString() ?? '0') ?? 0,
      wrongAnswers: int.tryParse(json['wrong_answers']?.toString() ?? '0') ?? 0,
      accuracy: double.tryParse(json['accuracy']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'avatar': avatar,
      'total_answers': totalAnswers,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'accuracy': accuracy,
      'current_streak': currentStreak,
    };
  }
}
