import 'package:hive_flutter/hive_flutter.dart';
import '../models/cached_question_model.dart';

class OfflineStorageService {
  static const String _questionsBoxName = 'free_questions';
  static const String _syncStatusKey = 'last_sync_time';
  static const String _progressPrefix = 'progress_';

  Box<CachedQuestionModel>? _questionsBox;
  Box? _metaBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedQuestionModelAdapter());
    }

    // Open boxes
    _questionsBox = await Hive.openBox<CachedQuestionModel>(_questionsBoxName);
    _metaBox = await Hive.openBox('meta');
  }

  // Save all questions
  Future<void> saveQuestions(List<CachedQuestionModel> questions) async {
    await _questionsBox?.clear();
    for (var question in questions) {
      await _questionsBox?.put(question.id, question);
    }
    await _metaBox?.put(_syncStatusKey, DateTime.now().toIso8601String());
  }

  // Get all questions
  List<CachedQuestionModel> getAllQuestions() {
    return _questionsBox?.values.toList() ?? [];
  }

  // Get questions by category
  List<CachedQuestionModel> getQuestionsByCategory(String category) {
    if (category == 'عشوائي') {
      return getAllQuestions();
    }
    return _questionsBox?.values
        .where((q) => q.category == category)
        .toList() ?? [];
  }

  // Get random question by category
  CachedQuestionModel? getRandomQuestion(String category) {
    final questions = getQuestionsByCategory(category);
    if (questions.isEmpty) return null;
    questions.shuffle();
    return questions.first;
  }
  
  // Get all questions for a category (for non-repetitive flow)
  List<CachedQuestionModel> getAllQuestionsForCategory(String category) {
    return getQuestionsByCategory(category);
  }

  // Check if data exists
  bool hasData() {
    return (_questionsBox?.isNotEmpty ?? false);
  }

  // Get last sync time
  DateTime? getLastSyncTime() {
    final syncTime = _metaBox?.get(_syncStatusKey);
    if (syncTime == null) return null;
    return DateTime.parse(syncTime);
  }

  // Check if sync is needed (older than 7 days)
  bool needsSync() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    
    final daysSinceSync = DateTime.now().difference(lastSync).inDays;
    return daysSinceSync > 7;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _questionsBox?.clear();
    await _metaBox?.delete(_syncStatusKey);
  }

  // Get stats
  Map<String, int> getStats() {
    final questions = getAllQuestions();
    final stats = <String, int>{};
    
    for (var question in questions) {
      stats[question.category] = (stats[question.category] ?? 0) + 1;
    }
    
    return stats;
  }

  // Save progress for a category
  Future<void> saveCategoryProgress(String category, List<int> answeredIds) async {
    final key = '$_progressPrefix$category';
    await _metaBox?.put(key, answeredIds);
  }

  // Load progress for a category
  List<int> loadCategoryProgress(String category) {
    final key = '$_progressPrefix$category';
    final data = _metaBox?.get(key);
    if (data == null) return [];
    if (data is List) {
      return data.cast<int>();
    }
    return [];
  }

  // Clear progress for a category
  Future<void> clearCategoryProgress(String category) async {
    final key = '$_progressPrefix$category';
    await _metaBox?.delete(key);
  }

  // Clear all progress
  Future<void> clearAllProgress() async {
    final keys = _metaBox?.keys.where((key) => key.toString().startsWith(_progressPrefix)).toList() ?? [];
    for (var key in keys) {
      await _metaBox?.delete(key);
    }
  }
}
