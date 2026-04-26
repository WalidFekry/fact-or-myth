import 'package:flutter/material.dart';
import '../data/models/leaderboard_model.dart';
import '../data/repositories/leaderboard_repository.dart';
import '../data/services/network_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final LeaderboardRepository _leaderboardRepository;
  final NetworkService _networkService;

  bool _isLoading = false;
  String? _error;
  List<LeaderboardModel> _leaderboard = [];
  LeaderboardModel? _myRank;
  bool _isOnline = true;
  bool _hasLoadedOnce = false;

  LeaderboardViewModel(this._leaderboardRepository, this._networkService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LeaderboardModel> get leaderboard => _leaderboard;
  LeaderboardModel? get myRank => _myRank;
  bool get isOnline => _isOnline;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Future<void> loadLeaderboard({int? userId}) async {
    final isConnected = await _networkService.isConnected();
    _isOnline = isConnected;

    if (!isConnected) {
      _error = 'لا يوجد اتصال بالإنترنت 🌐\nالترتيب يتطلب اتصال بالإنترنت';
      _hasLoadedOnce = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaderboard = await _leaderboardRepository.getLeaderboard();
      
      if (userId != null) {
        _myRank = await _leaderboardRepository.getMyRank(userId);
      }
      
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }
}
