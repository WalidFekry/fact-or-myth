class LeaderboardModel {
  final int userId;
  final String userName;
  final String userAvatar;
  final int correctCount;
  final int wrongCount;
  final double percentage;
  final int? rank; // Nullable for users with 0 answers
  final int? totalAnswers;
  final bool? eligible;

  LeaderboardModel({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.correctCount,
    required this.wrongCount,
    required this.percentage,
    this.rank,
    this.totalAnswers,
    this.eligible,
  });

  int get answersCount => totalAnswers ?? (correctCount + wrongCount);
  bool get isEligible => eligible ?? (answersCount >= 5);

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      userId: int.parse(json['user_id'].toString()),
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'] ?? '👨',
      correctCount: int.parse(json['correct_count'].toString()),
      wrongCount: int.parse(json['wrong_count'].toString()),
      percentage: double.parse(json['percentage'].toString()),
      rank: json['rank'] != null ? int.parse(json['rank'].toString()) : null,
      totalAnswers: json['total_answers'] != null ? int.parse(json['total_answers'].toString()) : null,
      eligible: json['eligible'] != null ? (json['eligible'] == true || json['eligible'] == 1) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'percentage': percentage,
      'rank': rank,
      'total_answers': totalAnswers,
      'eligible': eligible,
    };
  }
}
