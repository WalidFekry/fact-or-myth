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
      userId: int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '👨',
      totalAnswers: int.parse(json['total_answers'].toString()),
      correctAnswers: int.parse(json['correct_answers'].toString()),
      wrongAnswers: int.parse(json['wrong_answers'].toString()),
      accuracy: double.parse(json['accuracy'].toString()),
      currentStreak: int.parse(json['current_streak'].toString()),
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
