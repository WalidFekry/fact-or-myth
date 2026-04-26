import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  AuthViewModel(this._authRepository) {
    _checkLoginStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  bool get isLoggedIn => _authRepository.isLoggedIn();

  void _checkLoginStatus() {
    if (_authRepository.isLoggedIn()) {
      final userId = _authRepository.getUserId();
      final userName = _authRepository.getUserName();
      final userAvatar = _authRepository.getUserAvatar();
      
      if (userId != null && userName != null && userAvatar != null) {
        _user = UserModel(
          id: userId,
          name: userName,
          avatar: userAvatar,
          createdAt: DateTime.now(),
        );
      }
    }
  }

  Future<bool> register(String name, String avatar) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(name, avatar);
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

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }

  int? getUserId() => _authRepository.getUserId();
  String? getUserName() => _authRepository.getUserName();
  String? getUserAvatar() => _authRepository.getUserAvatar();
}
