import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<UserModel> register(String name, String avatar) async {
    final response = await _apiService.post('/register', {
      'name': name,
      'avatar': avatar,
    });

    final user = UserModel.fromJson(response['data']);
    await _storageService.saveUser(user.id, user.name, user.avatar);
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
