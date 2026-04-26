import '../models/leaderboard_model.dart';
import '../services/api_service.dart';

class LeaderboardRepository {
  final ApiService _apiService;

  LeaderboardRepository(this._apiService);

  Future<List<LeaderboardModel>> getLeaderboard() async {
    final response = await _apiService.get('/leaderboard');
    final List<dynamic> data = response['data'];
    return data.map((json) => LeaderboardModel.fromJson(json)).toList();
  }

  Future<LeaderboardModel?> getMyRank(int userId) async {
    final response = await _apiService.get('/my-rank', params: {
      'user_id': userId.toString(),
    });
    if (response['data'] != null) {
      return LeaderboardModel.fromJson(response['data']);
    }
    return null;
  }
}
