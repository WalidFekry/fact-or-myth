import '../models/comment_model.dart';
import '../services/api_service.dart';

class CommentRepository {
  final ApiService _apiService;

  CommentRepository(this._apiService);

  Future<List<CommentModel>> getComments(int questionId) async {
    final response = await _apiService.get('/comments', params: {
      'question_id': questionId.toString(),
    });
    final List<dynamic> data = response['data'];
    return data.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<CommentModel> addComment({
    required int userId,
    required int questionId,
    required String comment,
  }) async {
    final response = await _apiService.post('/add-comment', {
      'user_id': userId,
      'question_id': questionId,
      'comment': comment,
    });
    return CommentModel.fromJson(response['data']);
  }
}
