import 'package:flutter/material.dart';
import '../data/models/comment_model.dart';
import '../data/repositories/comment_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/network_service.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentRepository _commentRepository;
  final AuthRepository _authRepository;
  final NetworkService _networkService;

  bool _isLoading = false;
  String? _error;
  List<CommentModel> _comments = [];
  bool _isOnline = true;

  CommentViewModel(
    this._commentRepository,
    this._authRepository,
    this._networkService,
  );

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CommentModel> get comments => _comments;
  bool get isOnline => _isOnline;
  
  bool hasUserCommented() {
    final userId = _authRepository.getUserId();
    if (userId == null) return false;
    
    return _comments.any((comment) => comment.userId == userId);
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadComments(int questionId) async {
    final isConnected = await _networkService.isConnected();
    _isOnline = isConnected;

    if (!isConnected) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nالتعليقات تتطلب اتصال بالإنترنت';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _commentRepository.getComments(questionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment(int questionId, String comment) async {
    final isConnected = await _networkService.isConnected();
    
    if (!isConnected) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لإضافة تعليق';
      notifyListeners();
      return false;
    }

    final userId = _authRepository.getUserId();
    if (userId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newComment = await _commentRepository.addComment(
        userId: userId,
        questionId: questionId,
        comment: comment,
      );
      _comments.insert(0, newComment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
