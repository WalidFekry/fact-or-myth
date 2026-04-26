class CommentModel {
  final int id;
  final int userId;
  final String userName;
  final String userAvatar;
  final int questionId;
  final String comment;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.questionId,
    required this.comment,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'] ?? '👨',
      questionId: int.parse(json['question_id'].toString()),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'question_id': questionId,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}
