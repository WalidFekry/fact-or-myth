import '../models/question_model.dart';
import '../models/cached_question_model.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/network_service.dart';

class QuestionRepository {
  final ApiService _apiService;
  final OfflineStorageService _offlineStorage;
  final NetworkService _networkService;

  QuestionRepository(
    this._apiService,
    this._offlineStorage,
    this._networkService,
  );

  Future<QuestionModel> getDailyQuestion(int? userId) async {
    final response = await _apiService.get('/daily-question', params: {
      if (userId != null) 'user_id': userId.toString(),
    });
    return QuestionModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> submitAnswer({
    required int questionId,
    required bool answer,
    int? userId,
  }) async {
    final response = await _apiService.post('/submit-answer', {
      'question_id': questionId,
      'answer': answer ? 1 : 0,
      if (userId != null) 'user_id': userId,
    });
    return response['data'];
  }

  Future<QuestionModel> getFreeQuestion(String category) async {
    final response = await _apiService.get('/free-question', params: {
      'category': category,
    });
    return QuestionModel.fromJson(response['data']);
  }

  // Offline support methods
  Future<bool> syncFreeQuestions() async {
    try {
      final isConnected = await _networkService.isConnected();
      if (!isConnected) return false;

      final response = await _apiService.get('/all-free-questions');
      final List<dynamic> questionsData = response['data']['questions'];
      
      final questions = questionsData
          .map((json) => CachedQuestionModel.fromJson(json))
          .toList();
      
      await _offlineStorage.saveQuestions(questions);
      return true;
    } catch (e) {
      return false;
    }
  }

  CachedQuestionModel? getOfflineFreeQuestion(String category) {
    return _offlineStorage.getRandomQuestion(category);
  }
  
  List<CachedQuestionModel> getAllQuestionsForCategory(String category) {
    return _offlineStorage.getAllQuestionsForCategory(category);
  }

  bool hasOfflineData() {
    return _offlineStorage.hasData();
  }

  bool needsSync() {
    return _offlineStorage.needsSync();
  }

  DateTime? getLastSyncTime() {
    return _offlineStorage.getLastSyncTime();
  }

  Map<String, int> getOfflineStats() {
    return _offlineStorage.getStats();
  }

  // Progress persistence methods
  Future<void> saveCategoryProgress(String category, List<int> answeredIds) async {
    await _offlineStorage.saveCategoryProgress(category, answeredIds);
  }

  List<int> loadCategoryProgress(String category) {
    return _offlineStorage.loadCategoryProgress(category);
  }

  Future<void> clearCategoryProgress(String category) async {
    await _offlineStorage.clearCategoryProgress(category);
  }
}
