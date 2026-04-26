import 'package:flutter/material.dart';
import 'dart:math';
import '../data/models/question_model.dart';
import '../data/repositories/question_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/network_service.dart';

class DailyQuestionViewModel extends ChangeNotifier {
  final QuestionRepository _questionRepository;
  final AuthRepository _authRepository;
  final NetworkService _networkService;
  final Random _random = Random();

  // Smart feedback messages
  final List<String> _correctMessages = [
    'جامد 🔥',
    'واضح إنك مركز 👀',
    'إجابة قوية 💪',
    'كده تمام جدًا 🚀',
    'ممتاز! استمر 🌟',
    'رائع جدًا 🎯',
  ];

  final List<String> _wrongMessages = [
    'دي كانت tricky 😅',
    'مش مشكلة، المعلومة دي بتتلخبط كتير',
    'قريبة جدًا 👀',
    'هتتعلمها مع الوقت 💪',
    'مش لوحدك في دي 🤝',
    'المرة الجاية أحسن 💫',
  ];

  bool _isLoading = false;
  String? _error;
  QuestionModel? _question;
  bool? _userAnswer;
  bool? _isCorrect;
  String? _resultMessage;
  DateTime? _nextQuestionTime;
  bool _isOnline = true;

  DailyQuestionViewModel(
    this._questionRepository,
    this._authRepository,
    this._networkService,
  ) {
    _checkConnectivity();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  QuestionModel? get question => _question;
  bool? get userAnswer => _userAnswer;
  bool? get isCorrect => _isCorrect;
  String? get resultMessage => _resultMessage;
  DateTime? get nextQuestionTime => _nextQuestionTime;
  bool get hasAnswered => _userAnswer != null;
  bool get isOnline => _isOnline;
  bool get canSubmitAnswer => !_isLoading && _userAnswer == null && _question != null;

  String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  Future<void> _checkConnectivity() async {
    _isOnline = await _networkService.isConnected();
    notifyListeners();
  }

  Future<void> loadDailyQuestion() async {
    await _checkConnectivity();

    if (!_isOnline) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nالسؤال اليومي يتطلب اتصال بالإنترنت';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authRepository.getUserId();
      _question = await _questionRepository.getDailyQuestion(userId);
      
      if (_question!.userAnswer != null) {
        _userAnswer = _question!.userAnswer;
        _isCorrect = _question!.isCorrect;
        _calculateNextQuestionTime();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(bool answer) async {
    // Enhanced guard: Check loading state, answered state, and question existence
    if (_question == null || _userAnswer != null || _isLoading) {
      return;
    }

    final userId = _authRepository.getUserId();
    final isLoggedIn = userId != null;

    // Guest Mode: Handle locally without API call
    // This prevents 400 errors for guest users
    if (!isLoggedIn) {
      _handleAnswerLocally(answer);
      return;
    }

    // Logged-in Mode: Check connectivity and submit to server
    await _checkConnectivity();

    if (!_isOnline) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لإرسال الإجابة';
      notifyListeners();
      return;
    }

    // Set loading state BEFORE any async operation
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _questionRepository.submitAnswer(
        questionId: _question!.id,
        answer: answer,
        userId: userId,
      );

      // Parse response with type safety
      _userAnswer = answer;
      
      // Handle both int and bool types from backend
      final isCorrectValue = result['is_correct'];
      if (isCorrectValue is int) {
        _isCorrect = isCorrectValue == 1;
      } else if (isCorrectValue is bool) {
        _isCorrect = isCorrectValue;
      } else {
        _isCorrect = false;
      }
      
      _resultMessage = _isCorrect! 
          ? _getRandomMessage(_correctMessages)
          : _getRandomMessage(_wrongMessages);
      
      // Update voting statistics from response
      if (result['true_votes'] != null && result['false_votes'] != null) {
        _question = QuestionModel(
          id: _question!.id,
          question: _question!.question,
          correctAnswer: _question!.correctAnswer,
          explanation: _question!.explanation,
          category: _question!.category,
          isDaily: _question!.isDaily,
          date: _question!.date,
          userAnswer: _userAnswer,
          isCorrect: _isCorrect,
          trueVotes: int.parse(result['true_votes'].toString()),
          falseVotes: int.parse(result['false_votes'].toString()),
        );
      }
      
      _calculateNextQuestionTime();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = e.toString();
      
      // Check if error is "already answered"
      if (errorMessage.contains('لقد أجبت على هذا السؤال اليوم') ||
          errorMessage.contains('already answered')) {
        // Lock the UI by setting userAnswer (prevent further attempts)
        _userAnswer = answer;
        _isCorrect = answer == _question!.correctAnswer;
        _resultMessage = 'لقد أجبت على هذا السؤال مسبقاً';
        _calculateNextQuestionTime();
        _error = null; // Clear error to show result UI
      } else {
        _error = errorMessage;
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle answer evaluation locally for guest users
  void _handleAnswerLocally(bool answer) {
    // Evaluate answer locally for guest users
    _userAnswer = answer;
    _isCorrect = answer == _question!.correctAnswer;
    _resultMessage = _isCorrect! 
        ? _getRandomMessage(_correctMessages)
        : _getRandomMessage(_wrongMessages);
    
    _calculateNextQuestionTime();
    notifyListeners();
  }

  void _calculateNextQuestionTime() {
    final now = DateTime.now();
    _nextQuestionTime = DateTime(now.year, now.month, now.day + 1);
  }

  Duration? getTimeUntilNextQuestion() {
    if (_nextQuestionTime == null) return null;
    return _nextQuestionTime!.difference(DateTime.now());
  }
}
