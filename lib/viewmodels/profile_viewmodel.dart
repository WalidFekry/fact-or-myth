import 'package:flutter/material.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/network_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final NetworkService _networkService;

  bool _isLoading = false;
  String? _error;
  ProfileModel? _profile;
  bool _isOnline = true;

  ProfileViewModel(
    this._profileRepository,
    this._authRepository,
    this._networkService,
  );

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProfileModel? get profile => _profile;
  bool get isOnline => _isOnline;

  Future<void> loadProfile() async {
    final userId = _authRepository.getUserId();
    if (userId == null) return;

    final isConnected = await _networkService.isConnected();
    _isOnline = isConnected;

    if (!isConnected) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nبعض المميزات غير متاحة حالياً';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String name, String avatar) async {
    final userId = _authRepository.getUserId();
    if (userId == null) return false;

    final isConnected = await _networkService.isConnected();
    
    if (!isConnected) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nيرجى الاتصال بالإنترنت لتحديث الملف الشخصي';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.updateProfile(
        userId: userId,
        name: name,
        avatar: avatar,
      );
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
