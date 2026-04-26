import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ProfileRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  ProfileRepository(this._apiService, this._storageService);

  Future<ProfileModel> getProfile(int userId) async {
    final response = await _apiService.get('/profile', params: {
      'user_id': userId.toString(),
    });
    return ProfileModel.fromJson(response['data']);
  }

  Future<ProfileModel> updateProfile({
    required int userId,
    required String name,
    required String avatar,
  }) async {
    final response = await _apiService.post('/update-profile', {
      'user_id': userId,
      'name': name,
      'avatar': avatar,
    });
    
    await _storageService.saveUser(userId, name, avatar);
    return ProfileModel.fromJson(response['data']);
  }
}
