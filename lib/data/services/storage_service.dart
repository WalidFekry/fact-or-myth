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
    await _prefs.setInt('guest_question_id', questionId);
    await _prefs.setBool('guest_answer', answer);
    await _prefs.setBool('guest_is_correct', isCorrect);
    await _prefs.setString('guest_answered_date', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getGuestAnswer() {
    final questionId = _prefs.getInt('guest_question_id');
    final answer = _prefs.getBool('guest_answer');
    final isCorrect = _prefs.getBool('guest_is_correct');
    final answeredDate = _prefs.getString('guest_answered_date');

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
    await _prefs.remove('guest_question_id');
    await _prefs.remove('guest_answer');
    await _prefs.remove('guest_is_correct');
    await _prefs.remove('guest_answered_date');
  }

  // Get guest answer for migration on registration
  Map<String, dynamic>? getGuestAnswerForMigration() {
    final questionId = _prefs.getInt('guest_question_id');
    final answer = _prefs.getBool('guest_answer');
    final isCorrect = _prefs.getBool('guest_is_correct');

    if (questionId == null || answer == null || isCorrect == null) {
      return null;
    }

    return {
      'question_id': questionId,
      'answer': answer,
      'is_correct': isCorrect,
    };
  }

  // TASK 3: Daily Question Caching (1 hour)
  Future<void> cacheDailyQuestion(dynamic question, DateTime timestamp) async {
    final questionJson = question is Map<String, dynamic> 
        ? question 
        : question.toJson();
    
    await _prefs.setString('cached_daily_question', jsonEncode(questionJson));
    await _prefs.setString('cached_daily_question_timestamp', timestamp.toIso8601String());
  }

  Map<String, dynamic>? getCachedDailyQuestion() {
    final questionStr = _prefs.getString('cached_daily_question');
    final timestampStr = _prefs.getString('cached_daily_question_timestamp');

    if (questionStr == null || timestampStr == null) {
      return null;
    }

    return {
      'question': jsonDecode(questionStr),
      'timestamp': timestampStr,
    };
  }

  Future<void> clearDailyQuestionCache() async {
    await _prefs.remove('cached_daily_question');
    await _prefs.remove('cached_daily_question_timestamp');
  }

  // TASK 1: Save Daily Question Answer State (CRITICAL)
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
    
    await _prefs.setString('daily_question_answer', jsonEncode(answerData));
  }

  // TASK 2: Load Daily Question Answer State
  Map<String, dynamic>? getDailyQuestionAnswer() {
    final answerStr = _prefs.getString('daily_question_answer');
    
    if (answerStr == null) {
      return null;
    }

    final answerData = jsonDecode(answerStr) as Map<String, dynamic>;
    
    // TASK 3: Check if answer is from today
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
    await _prefs.remove('daily_question_answer');
  }

  // Check if answer is from today
  bool isDailyQuestionAnsweredToday() {
    final answerData = getDailyQuestionAnswer();
    return answerData != null && answerData['answered'] == true;
  }

  // TASK 1: Clear ALL user-related data (for logout/delete account)
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
    await _prefs.remove('onboarding_completed');
    
    // Note: We keep theme preference and sound preference
    // as they are user preferences, not session data
  }

  // TASK 1: Clear only session data (keep preferences like theme, sound)
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

  // TASK 1: Nuclear option - clear EVERYTHING (for testing/debugging)
  Future<void> clearEverything() async {
    await _prefs.clear();
  }

  // Notification Permission
  Future<void> setNotificationPermissionShown(bool shown) async {
    await _prefs.setBool('notification_permission_shown', shown);
  }

  bool hasNotificationPermissionBeenShown() {
    return _prefs.getBool('notification_permission_shown') ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? false;
  }

  // FCM Token
  Future<void> saveFCMToken(String token) async {
    await _prefs.setString('fcm_token', token);
  }

  Future<String?> getFCMToken() async {
    return _prefs.getString('fcm_token');
  }
}
