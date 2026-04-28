class ReportModel {
  final int? id;
  final int? userId;
  final int questionId;
  final String questionText;
  final String category;
  final String source; // 'daily' or 'free'
  final String reason;
  final String message;
  final String? whatsapp;
  final String status; // 'new', 'reviewed', 'fixed'
  final DateTime createdAt;

  ReportModel({
    this.id,
    this.userId,
    required this.questionId,
    required this.questionText,
    required this.category,
    required this.source,
    required this.reason,
    required this.message,
    this.whatsapp,
    this.status = 'new',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'question_text': questionText,
      'category': category,
      'source': source,
      'reason': reason,
      'message': message,
      'whatsapp': whatsapp,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      questionId: json['question_id'] as int,
      questionText: json['question_text'] as String,
      category: json['category'] as String,
      source: json['source'] as String,
      reason: json['reason'] as String,
      message: json['message'] as String,
      whatsapp: json['whatsapp'] as String?,
      status: json['status'] as String? ?? 'new',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
