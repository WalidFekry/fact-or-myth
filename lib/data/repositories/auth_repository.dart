import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<UserModel> register(String name, String avatar) async {
    // Get guest answer data for migration
    final guestAnswer = _storageService.getGuestAnswerForMigration();
    
    final requestData = <String, dynamic>{
      'name': name,
      'avatar': avatar,
    };
    
    // Include guest answer if exists
    if (guestAnswer != null) {
      requestData['guest_answer'] = guestAnswer;
    }
    
    final response = await _apiService.post('/register', requestData);

    final user = UserModel.fromJson(response['data']);
    await _storageService.saveUser(user.id, user.name, user.avatar);
    
    // Clear guest answer after successful registration
    if (guestAnswer != null) {
      await _storageService.clearGuestAnswer();
    }
    
    return user;
  }

  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  int? getUserId() {
    return _storageService.getUserId();
  }

  String? getUserName() {
    return _storageService.getUserName();
  }

  String? getUserAvatar() {
    return _storageService.getUserAvatar();
  }

  Future<void> logout() async {
    await _storageService.clearUser();
  }
}
