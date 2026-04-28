import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Theme
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
  }

  // User
  Future<void> saveUser(int userId, String name, String avatar) async {
    await _prefs.setInt(AppConstants.keyUserId, userId);
    await _prefs.setString(AppConstants.keyUserName, name);
    await _prefs.setString(AppConstants.keyUserAvatar, avatar);
    await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  int? getUserId() {
    return _prefs.getInt(AppConstants.keyUserId);
  }

  String? getUserName() {
    return _prefs.getString(AppConstants.keyUserName);
  }

  String? getUserAvatar() {
    return _prefs.getString(AppConstants.keyUserAvatar);
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserAvatar);
    await _prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }

  // Guest Mode Persistence
  Future<void> saveGuestAnswer({
    required int questionId,
    required bool answer,
    required bool isCorrect,
  }) async {
    await _prefs.setInt(AppConstants.keyGuestQuestionId, questionId);
    await _prefs.setBool(AppConstants.keyGuestAnswer, answer);
    await _prefs.setBool(AppConstants.keyGuestIsCorrect, isCorrect);
    await _prefs.setString(AppConstants.keyGuestAnsweredDate, DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getGuestAnswer() {
    final questionId = _prefs.getInt(AppConstants.keyGuestQuestionId);
    final answer = _prefs.getBool(AppConstants.keyGuestAnswer);
    final isCorrect = _prefs.getBool(AppConstants.keyGuestIsCorrect);
    final answeredDate = _prefs.getString(AppConstants.keyGuestAnsweredDate);

    if (questionId == null || answer == null || isCorrect == null || answeredDate == null) {
      return null;
    }

    // Check if answer is from today
    final savedDate = DateTime.parse(answeredDate);
    final now = DateTime.now();
    final isToday = savedDate.year == now.year &&
        savedDate.month == now.month &&
        savedDate.day == now.day;

    if (!isToday) {
      // Clear old guest data
      clearGuestAnswer();
      return null;
    }

    return {
      'question_id': questionId,
      'answer': answer,
      'is_correct': isCorrect,
      'answered_date': answeredDate,
    };
  }

  Future<void> clearGuestAnswer() async {
    await _prefs.remove(AppConstants.keyGuestQuestionId);
    await _prefs.remove(AppConstants.keyGuestAnswer);
    await _prefs.remove(AppConstants.keyGuestIsCorrect);
    await _prefs.remove(AppConstants.keyGuestAnsweredDate);
  }

  // Get guest answer for migration on registration
  Map<String, dynamic>? getGuestAnswerForMigration() {
    final questionId = _prefs.getInt(AppConstants.keyGuestQuestionId);
    final answer = _prefs.getBool(AppConstants.keyGuestAnswer);
    final isCorrect = _prefs.getBool(AppConstants.keyGuestIsCorrect);

    if (questionId == null || answer == null || isCorrect == null) {
      return null;
    }

    return {
      'question_id': questionId,
      'answer': answer,
      'is_correct': isCorrect,
    };
  }

  // Daily Question Caching (1 hour)
  Future<void> cacheDailyQuestion(dynamic question, DateTime timestamp) async {
    final questionJson = question is Map<String, dynamic> 
        ? question 
        : question.toJson();
    
    await _prefs.setString(AppConstants.keyCachedDailyQuestion, jsonEncode(questionJson));
    await _prefs.setString(AppConstants.keyCachedDailyQuestionTimestamp, timestamp.toIso8601String());
  }

  Map<String, dynamic>? getCachedDailyQuestion() {
    final questionStr = _prefs.getString(AppConstants.keyCachedDailyQuestion);
    final timestampStr = _prefs.getString(AppConstants.keyCachedDailyQuestionTimestamp);

    if (questionStr == null || timestampStr == null) {
      return null;
    }

    return {
      'question': jsonDecode(questionStr),
      'timestamp': timestampStr,
    };
  }

  Future<void> clearDailyQuestionCache() async {
    await _prefs.remove(AppConstants.keyCachedDailyQuestion);
    await _prefs.remove(AppConstants.keyCachedDailyQuestionTimestamp);
  }

  // Save Daily Question Answer State (CRITICAL)
  Future<void> saveDailyQuestionAnswer({
    required int questionId,
    required bool selectedAnswer,
    required bool isCorrect,
    required String explanation,
    String? resultMessage,
    int? trueVotes,
    int? falseVotes,
  }) async {
    final answerData = {
      'question_id': questionId,
      'selected_answer': selectedAnswer,
      'is_correct': isCorrect,
      'explanation': explanation,
      'result_message': resultMessage,
      'true_votes': trueVotes,
      'false_votes': falseVotes,
      'answered': true,
      'timestamp': DateTime.now().toIso8601String(),
      'date': DateTime.now().toIso8601String().split('T')[0], // Store date for daily reset
    };
    
    await _prefs.setString(AppConstants.keyDailyQuestionAnswer, jsonEncode(answerData));
  }

  // Load Daily Question Answer State
  Map<String, dynamic>? getDailyQuestionAnswer() {
    final answerStr = _prefs.getString(AppConstants.keyDailyQuestionAnswer);
    
    if (answerStr == null) {
      return null;
    }

    final answerData = jsonDecode(answerStr) as Map<String, dynamic>;
    
    // Check if answer is from today
    final savedDate = answerData['date'] as String?;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (savedDate != today) {
      // Answer is from a previous day - clear it
      clearDailyQuestionAnswer();
      return null;
    }
    
    return answerData;
  }

  Future<void> clearDailyQuestionAnswer() async {
    await _prefs.remove(AppConstants.keyDailyQuestionAnswer);
  }

  // Clear ALL user-related data (for logout/delete account)
  Future<void> clearAllUserData() async {
    // Clear user session
    await clearUser();
    
    // Clear daily question cache
    await clearDailyQuestionCache();
    
    // Clear daily question answer
    await clearDailyQuestionAnswer();
    
    // Clear guest answer (legacy)
    await clearGuestAnswer();
    
    // Clear any other user-specific data
    await _prefs.remove(AppConstants.keyOnboardingCompleted);
    
    // Note: We keep theme preference and sound preference
    // as they are user preferences, not session data
  }

  // Clear only session data (keep preferences like theme, sound)
  Future<void> clearSessionData() async {
    // Clear user session
    await clearUser();
    
    // Clear daily question cache
    await clearDailyQuestionCache();
    
    // Clear daily question answer
    await clearDailyQuestionAnswer();
    
    // Clear guest answer (legacy)
    await clearGuestAnswer();
  }

  // clear EVERYTHING (for testing/debugging)
  Future<void> clearEverything() async {
    await _prefs.clear();
  }

  // Notification Permission
  Future<void> setNotificationPermissionShown(bool shown) async {
    await _prefs.setBool(AppConstants.keyNotificationPermissionShown, shown);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool(AppConstants.keyNotificationsEnabled) ?? false;
  }
  
  // Explanation Font Size
  Future<void> saveExplanationFontSize(double size) async {
    await _prefs.setDouble(AppConstants.keyExplanationFontSize, size);
  }

  double getExplanationFontSize() {
    return _prefs.getDouble(AppConstants.keyExplanationFontSize) ?? 
           AppConstants.defaultExplanationFontSize;
  }
}
