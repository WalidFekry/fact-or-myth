import 'package:flutter/material.dart';
import 'dart:math';
import '../data/models/cached_question_model.dart';
import '../data/repositories/question_repository.dart';
import '../data/services/network_service.dart';

class FreeQuestionsViewModel extends ChangeNotifier {
  final QuestionRepository _questionRepository;
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
  CachedQuestionModel? _question;
  bool? _userAnswer;
  String _selectedCategory = 'عشوائي';
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  // Track answered questions to avoid repetition
  final Set<int> _answeredQuestionIds = {};
  List<CachedQuestionModel> _allCategoryQuestions = [];

  FreeQuestionsViewModel(this._questionRepository, this._networkService) {
    _checkConnectivity();
    _checkSyncStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  CachedQuestionModel? get question => _question;
  bool? get userAnswer => _userAnswer;
  String get selectedCategory => _selectedCategory;
  bool get hasAnswered => _userAnswer != null;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool? get isCorrect => _userAnswer != null && _question != null
      ? _userAnswer == _question!.correctAnswer
      : null;
  bool get isRandomMode => _selectedCategory == 'عشوائي';
  
  int get remainingQuestionsCount => 
      isRandomMode ? 0 : _allCategoryQuestions.where((q) => !_answeredQuestionIds.contains(q.id)).length;
  int get totalQuestionsCount => isRandomMode ? 0 : _allCategoryQuestions.length;
  bool get shouldShowProgress => !isRandomMode && totalQuestionsCount > 0;

  String _getRandomMessage(List<String> messages) {
    return messages[_random.nextInt(messages.length)];
  }

  String? getResultMessage() {
    if (_userAnswer == null || _question == null) return null;
    final isCorrect = _userAnswer == _question!.correctAnswer;
    return isCorrect 
        ? _getRandomMessage(_correctMessages)
        : _getRandomMessage(_wrongMessages);
  }

  Future<void> _checkConnectivity() async {
    _isOnline = await _networkService.isConnected();
    notifyListeners();
  }

  void _checkSyncStatus() {
    _lastSyncTime = _questionRepository.getLastSyncTime();
    notifyListeners();
  }

  void setCategory(String category) {
    // Save current category progress before switching
    if (_selectedCategory != 'عشوائي' && _answeredQuestionIds.isNotEmpty) {
      _saveCategoryProgress();
    }
    
    _selectedCategory = category;
    _answeredQuestionIds.clear();
    _allCategoryQuestions = [];
    
    // Load progress for new category (except random mode)
    if (!isRandomMode) {
      _loadCategoryProgress();
    }
    
    notifyListeners();
  }

  void _saveCategoryProgress() {
    if (isRandomMode) return;
    _questionRepository.saveCategoryProgress(
      _selectedCategory,
      _answeredQuestionIds.toList(),
    );
  }

  void _loadCategoryProgress() {
    if (isRandomMode) return;
    final savedProgress = _questionRepository.loadCategoryProgress(_selectedCategory);
    _answeredQuestionIds.clear();
    _answeredQuestionIds.addAll(savedProgress);
  }

  Future<void> loadQuestion() async {
    _isLoading = true;
    _error = null;
    _userAnswer = null;
    notifyListeners();

    try {
      await _checkConnectivity();

      // Load all questions for category if not loaded yet
      if (_allCategoryQuestions.isEmpty) {
        if (_questionRepository.hasOfflineData()) {
          _allCategoryQuestions = _questionRepository.getAllQuestionsForCategory(_selectedCategory);
        }
        
        // If no offline data and online, try to sync
        if (_allCategoryQuestions.isEmpty && _isOnline) {
          await syncQuestions();
          _allCategoryQuestions = _questionRepository.getAllQuestionsForCategory(_selectedCategory);
        }
        
        if (_allCategoryQuestions.isEmpty) {
          _error = 'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لتحميل الأسئلة';
          _isLoading = false;
          notifyListeners();
          return;
        }
        
        // Load saved progress for this category (except random mode)
        if (!isRandomMode) {
          _loadCategoryProgress();
        }
        
        // Shuffle questions once when loaded (only if not random mode or no progress)
        if (isRandomMode || _answeredQuestionIds.isEmpty) {
          _allCategoryQuestions.shuffle();
        }
      }

      // Random mode: always pick random question without tracking
      if (isRandomMode) {
        _allCategoryQuestions.shuffle();
        _question = _allCategoryQuestions.first;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get remaining unanswered questions
      final remainingQuestions = _allCategoryQuestions
          .where((q) => !_answeredQuestionIds.contains(q.id))
          .toList();

      if (remainingQuestions.isEmpty) {
        // All questions answered - show completion
        _question = null;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Pick first question from remaining (already shuffled)
      _question = remainingQuestions.first;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncQuestions() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _questionRepository.syncFreeQuestions();
      
      if (success) {
        _lastSyncTime = DateTime.now();
        _error = null;
        
        // Save current progress before clearing
        if (!isRandomMode && _answeredQuestionIds.isNotEmpty) {
          _saveCategoryProgress();
        }
        
        // Reset category data to reload with new questions
        _allCategoryQuestions = [];
        _question = null;
        _userAnswer = null;
        
        // Reload progress after sync
        if (!isRandomMode) {
          _loadCategoryProgress();
        }
      } else {
        _error = 'فشل تحميل الأسئلة. يرجى المحاولة لاحقاً';
      }
    } catch (e) {
      _error = 'خطأ في التحميل: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void submitAnswer(bool answer) {
    if (_question == null || _userAnswer != null) return;
    _userAnswer = answer;
    
    // Mark question as answered (only for non-random mode)
    if (!isRandomMode) {
      _answeredQuestionIds.add(_question!.id);
      _saveCategoryProgress();
    }
    
    notifyListeners();
  }

  void nextQuestion() {
    loadQuestion();
  }
  
  Future<void> resetCategory() async {
    if (!isRandomMode) {
      await _questionRepository.clearCategoryProgress(_selectedCategory);
    }
    _answeredQuestionIds.clear();
    _userAnswer = null;
    _allCategoryQuestions.shuffle(); // Reshuffle for new playthrough
    notifyListeners();
  }
  
  bool hasCompletedCategory() {
    return !isRandomMode && 
           _allCategoryQuestions.isNotEmpty && 
           remainingQuestionsCount == 0;
  }

  Map<String, int> getOfflineStats() {
    return _questionRepository.getOfflineStats();
  }

  bool needsSync() {
    return _questionRepository.needsSync();
  }
}
