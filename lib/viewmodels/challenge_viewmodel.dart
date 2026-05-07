import 'dart:math';

import 'package:fact_or_myth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/share_utils.dart';
import '../data/models/cached_question_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/question_repository.dart';
import '../data/services/network_service.dart';

class ChallengeViewModel extends ChangeNotifier {
  final QuestionRepository _questionRepository;
  final ProfileRepository _profileRepository;
  final NetworkService _networkService;
  final AuthRepository _authRepository;
  final Random _random = Random();

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  CachedQuestionModel? _question;
  bool? _userAnswer;
  String _selectedCategory = 'عشوائي';
  ProfileModel? _profile;

  // Fake live counter values (generated once per question)
  int _fakePlayersCount = 0;
  int _fakeLiveNowCount = 0;

  ChallengeViewModel(this._questionRepository, this._profileRepository,
      this._networkService, this._authRepository);

  // Getters
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get profileName => _profile != null ? '${_profile?.name} ${_profile?.avatar}' : null;
  String? get error => _error;
  CachedQuestionModel? get question => _question;
  bool? get userAnswer => _userAnswer;
  String get selectedCategory => _selectedCategory;
  bool get hasAnswered => _userAnswer != null;
  bool? get isCorrect => _userAnswer != null && _question != null
      ? _userAnswer == _question!.correctAnswer
      : null;
  int get fakePlayersCount => _fakePlayersCount;
  int get fakeLiveNowCount => _fakeLiveNowCount;

  String? get resultMessage {
    if (_userAnswer == null || _question == null) return null;
    final isCorrect = _userAnswer == _question!.correctAnswer;
    return isCorrect
        ? _getRandomMessage(AppConstants.correctMessages)
        : _getRandomMessage(AppConstants.wrongMessages);
  }

  String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  /// Generate realistic fake live counter numbers
  void _generateFakeLiveCounters() {
    // Total players: 500 to 10000
    _fakePlayersCount = 500 + _random.nextInt(9501);
    // Live now: 20 to 1000
    _fakeLiveNowCount = 20 + _random.nextInt(981);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load a random challenge question based on selected category
  Future<void> loadChallengeQuestion() async {
    _isLoading = true;
    _error = null;
    _userAnswer = null;
    _question = null;
    notifyListeners();

    try {
      final isConnected = await _networkService.isConnected();

      // Try to sync if online and no offline data
      if (isConnected && !_questionRepository.hasOfflineData()) {
        await _questionRepository.syncFreeQuestions();
      }

      // Check if we have offline data
      if (!_questionRepository.hasOfflineData()) {
        _error =
            'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لتحميل الأسئلة';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get all questions for the category
      final questions =
          _questionRepository.getAllQuestionsForCategory(_selectedCategory);

      if (questions.isEmpty) {
        _error = 'لا توجد أسئلة متاحة في هذه الفئة';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Pick a random question
      questions.shuffle();
      _question = questions.first;

      // Generate fake live counters for this question
      _generateFakeLiveCounters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuestionAndUserNameById(int questionId, int? userId) async {
    _isLoading = true;
    _error = null;
    _userAnswer = null;
    _question = null;
    notifyListeners();

    try {
      final isConnected = await _networkService.isConnected();
      // Try to sync if online and no offline data
      if (isConnected && !_questionRepository.hasOfflineData()) {
        await _questionRepository.syncFreeQuestions();
      }
      // Check if we have offline data
      if (!_questionRepository.hasOfflineData()) {
        _error =
            'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لتحميل الأسئلة';
        _isLoading = false;
        notifyListeners();
        return;
      }
      // Get user profile
      if (userId != null) {
        _profile = await _profileRepository.getUser(userId);
      }
      // Get all questions and find the one with matching ID
      final allQuestions =
          _questionRepository.getAllQuestionsForCategory('عشوائي');
      try {
        _question = allQuestions.firstWhere((q) => q.id == questionId);
      } catch (_) {
        await _questionRepository.syncFreeQuestions();
        for (final category in AppConstants.categories) {
          final categoryQuestions =
              _questionRepository.getAllQuestionsForCategory(category);
          try {
            _question = categoryQuestions.firstWhere((q) => q.id == questionId);
            break;
          } catch (_) {
            continue;
          }
        }
      }

      // Generate fake live counters for this question
      _generateFakeLiveCounters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'لم يتم العثور على السؤال';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit answer (local only, no backend call)
  void submitAnswer(bool answer) {
    if (_question == null || _userAnswer != null) return;
    _userAnswer = answer;
    notifyListeners();
  }

  /// Load another random question (for "Try Another Question" button)
  Future<void> loadAnotherQuestion() async {
    // Reset answer state but keep the category
    _userAnswer = null;
    _error = null;

    // Load new question
    await loadChallengeQuestion();
  }

  /// Sync questions from server
  Future<bool> syncQuestions() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final success = await _questionRepository.syncFreeQuestions();
      _isSyncing = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> shareChallenge() async {
    if (question == null || userAnswer == null) return;
    await ShareUtils.shareChallenge(
      question: question!,
      userAnswer: userAnswer!,
      userId: _authRepository.getUserId(),
    );
  }
}
