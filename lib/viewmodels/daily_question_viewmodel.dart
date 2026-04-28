import 'package:fact_or_myth/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../data/models/question_model.dart';
import '../data/repositories/question_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/network_service.dart';
import '../data/services/storage_service.dart';
import '../core/di/service_locator.dart';
import '../core/network/api_exception.dart';

class DailyQuestionViewModel extends ChangeNotifier {
  final QuestionRepository _questionRepository;
  final AuthRepository _authRepository;
  final NetworkService _networkService;
  final Random _random = Random();



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
      
      // TASK 5: Restore full answer state from local storage
      final storageService = getIt<StorageService>();
      final localAnswer = storageService.getDailyQuestionAnswer();
      
      if (localAnswer != null && localAnswer['question_id'] == _question!.id) {
        // Restore complete answer state
        _userAnswer = localAnswer['selected_answer'] as bool;
        _isCorrect = localAnswer['is_correct'] as bool;
        _resultMessage = localAnswer['result_message'] as String? ?? 
            (_isCorrect! 
                ? _getRandomMessage(AppConstants.correctMessages)
                : _getRandomMessage(AppConstants.wrongMessages));
        
        // Update question with voting stats from local storage
        if (localAnswer['true_votes'] != null && localAnswer['false_votes'] != null) {
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
            trueVotes: localAnswer['true_votes'] as int,
            falseVotes: localAnswer['false_votes'] as int,
          );
        }
        
        _calculateNextQuestionTime();
      }
      // Fallback: Check if user has answered (from API response)
      else if (_question!.userAnswer != null) {
        _userAnswer = _question!.userAnswer;
        _isCorrect = _question!.isCorrect;
        _resultMessage = _isCorrect! 
            ? _getRandomMessage(AppConstants.correctMessages)
            : _getRandomMessage(AppConstants.wrongMessages);
        _calculateNextQuestionTime();
      } 
      // Legacy: Check guest answer persistence (old format)
      else if (userId == null) {
        final guestAnswer = storageService.getGuestAnswer();
        
        if (guestAnswer != null && guestAnswer['question_id'] == _question!.id) {
          // Restore guest answer from legacy storage
          _userAnswer = guestAnswer['answer'];
          _isCorrect = guestAnswer['is_correct'];
          _resultMessage = _isCorrect! 
              ? _getRandomMessage(AppConstants.correctMessages)
              : _getRandomMessage(AppConstants.wrongMessages);
          _calculateNextQuestionTime();
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = e.toString();
      
      // TASK 2: Handle force_logout from backend
      if (errorMessage.contains('force_logout') || errorMessage.contains('المستخدم غير موجود')) {
        _error = 'force_logout'; // Special error code for UI to handle
      } else {
        _error = errorMessage;
      }
      
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
          ? _getRandomMessage(AppConstants.correctMessages)
          : _getRandomMessage(AppConstants.wrongMessages);
      
      // Update voting statistics from response
      int trueVotes = _question!.trueVotes;
      int falseVotes = _question!.falseVotes;
      
      if (result['true_votes'] != null && result['false_votes'] != null) {
        trueVotes = int.parse(result['true_votes'].toString());
        falseVotes = int.parse(result['false_votes'].toString());
        
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
          trueVotes: trueVotes,
          falseVotes: falseVotes,
        );
      }
      
      // TASK 1: Save answer state locally (CRITICAL)
      final storageService = getIt<StorageService>();
      await storageService.saveDailyQuestionAnswer(
        questionId: _question!.id,
        selectedAnswer: answer,
        isCorrect: _isCorrect!,
        explanation: _question!.explanation,
        resultMessage: _resultMessage,
        trueVotes: trueVotes,
        falseVotes: falseVotes,
      );
      
      _calculateNextQuestionTime();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = e.toString();
      
      // TASK 6: Check if error is "already answered" with data
      if (errorMessage.contains('لقد أجبت على هذا السؤال اليوم') ||
          errorMessage.contains('already answered')) {
        
        // Try to extract existing answer data from error
        // The ApiException should contain the data from backend
        if (e is ApiException && e.data != null) {
          final data = e.data as Map<String, dynamic>;
          
          // Use existing answer data from backend
          _userAnswer = data['user_answer'] as bool? ?? answer;
          
          final isCorrectValue = data['is_correct'];
          if (isCorrectValue is int) {
            _isCorrect = isCorrectValue == 1;
          } else if (isCorrectValue is bool) {
            _isCorrect = isCorrectValue;
          } else {
            _isCorrect = answer == _question!.correctAnswer;
          }
          
          _resultMessage = 'لقد أجبت على هذا السؤال مسبقاً';
          
          // Update voting statistics if provided
          if (data['true_votes'] != null && data['false_votes'] != null) {
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
              trueVotes: int.parse(data['true_votes'].toString()),
              falseVotes: int.parse(data['false_votes'].toString()),
            );
          }
        } else {
          // Fallback if no data provided
          _userAnswer = answer;
          _isCorrect = answer == _question!.correctAnswer;
          _resultMessage = 'لقد أجبت على هذا السؤال مسبقاً';
        }
        
        // TASK 1: Save answer state locally even for duplicate attempts
        final storageService = getIt<StorageService>();
        await storageService.saveDailyQuestionAnswer(
          questionId: _question!.id,
          selectedAnswer: _userAnswer!,
          isCorrect: _isCorrect!,
          explanation: _question!.explanation,
          resultMessage: _resultMessage,
          trueVotes: _question!.trueVotes,
          falseVotes: _question!.falseVotes,
        );
        
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
        ? _getRandomMessage(AppConstants.correctMessages)
        : _getRandomMessage(AppConstants.wrongMessages);
    
    // Save guest answer to local storage (legacy format for migration)
    final storageService = getIt<StorageService>();
    storageService.saveGuestAnswer(
      questionId: _question!.id,
      answer: answer,
      isCorrect: _isCorrect!,
    );
    
    // Also save to daily question answer storage (new format)
    storageService.saveDailyQuestionAnswer(
      questionId: _question!.id,
      selectedAnswer: answer,
      isCorrect: _isCorrect!,
      explanation: _question!.explanation,
      resultMessage: _resultMessage,
      trueVotes: _question!.trueVotes,
      falseVotes: _question!.falseVotes,
    );
    
    _calculateNextQuestionTime();
    notifyListeners();
  }

  void _calculateNextQuestionTime() {
    final startUtc = DateTime.utc(2026, 4, 1, 0, 0, 0);
    final nowUtc = DateTime.now().toUtc();

    final secondsPassed =
        nowUtc.difference(startUtc).inSeconds;

    final currentDay = secondsPassed ~/ 86400;

    _nextQuestionTime = startUtc.add(
      Duration(seconds: (currentDay + 1) * 86400),
    );
  }

}
