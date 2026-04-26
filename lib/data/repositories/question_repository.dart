import '../models/question_model.dart';
import '../models/cached_question_model.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/network_service.dart';
import '../services/storage_service.dart';
import '../../core/di/service_locator.dart';
import 'dart:convert';

class QuestionRepository {
  final ApiService _apiService;
  final OfflineStorageService _offlineStorage;
  final NetworkService _networkService;
  
  // Cache duration: 1 hour
  static const Duration _cacheDuration = Duration(hours: 1);

  QuestionRepository(
    this._apiService,
    this._offlineStorage,
    this._networkService,
  );

  Future<QuestionModel> getDailyQuestion(int? userId) async {
    final storageService = getIt<StorageService>();
    
    // TASK 2: Check local answer state FIRST
    final localAnswer = storageService.getDailyQuestionAnswer();
    
    // TASK 3: Check cache with 1-hour expiration
    final cachedData = storageService.getCachedDailyQuestion();
    if (cachedData != null) {
      final cachedTime = DateTime.parse(cachedData['timestamp']);
      final now = DateTime.now();
      
      // TASK 4: If cache is less than 1 hour old, return cached data
      if (now.difference(cachedTime) < _cacheDuration) {
        final question = QuestionModel.fromJson(cachedData['question']);
        
        // TASK 5: Restore answer state if exists
        if (localAnswer != null && localAnswer['question_id'] == question.id) {
          return QuestionModel(
            id: question.id,
            question: question.question,
            correctAnswer: question.correctAnswer,
            explanation: question.explanation,
            category: question.category,
            isDaily: question.isDaily,
            date: question.date,
            userAnswer: localAnswer['selected_answer'] as bool,
            isCorrect: localAnswer['is_correct'] as bool,
            trueVotes: localAnswer['true_votes'] as int? ?? question.trueVotes,
            falseVotes: localAnswer['false_votes'] as int? ?? question.falseVotes,
          );
        }
        
        return question;
      }
    }
    
    // Cache expired or doesn't exist - fetch from API
    final response = await _apiService.get('/daily-question.php', params: {
      if (userId != null) 'user_id': userId.toString(),
    });
    
    final question = QuestionModel.fromJson(response['data']);
    
    // Check if this is a new question (different from cached)
    final isNewQuestion = cachedData == null || 
        (cachedData['question'] as Map<String, dynamic>)['id'] != question.id;
    
    // TASK 3: Clear old answer if new question
    if (isNewQuestion && localAnswer != null) {
      await storageService.clearDailyQuestionAnswer();
    }
    
    // Save to cache with timestamp
    await storageService.cacheDailyQuestion(question, DateTime.now());
    
    // TASK 5: Restore answer state if exists and matches question
    if (localAnswer != null && localAnswer['question_id'] == question.id) {
      return QuestionModel(
        id: question.id,
        question: question.question,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        category: question.category,
        isDaily: question.isDaily,
        date: question.date,
        userAnswer: localAnswer['selected_answer'] as bool,
        isCorrect: localAnswer['is_correct'] as bool,
        trueVotes: localAnswer['true_votes'] as int? ?? question.trueVotes,
        falseVotes: localAnswer['false_votes'] as int? ?? question.falseVotes,
      );
    }
    
    return question;
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
