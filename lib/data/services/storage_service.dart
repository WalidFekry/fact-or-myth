import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Theme
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
  }

  // User
  Future<void> saveUser(int userId, String name, String avatar) async {
    await _prefs.setInt(AppConstants.keyUserId, userId);
    await _prefs.setString(AppConstants.keyUserName, name);
    await _prefs.setString(AppConstants.keyUserAvatar, avatar);
    await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  int? getUserId() {
    return _prefs.getInt(AppConstants.keyUserId);
  }

  String? getUserName() {
    return _prefs.getString(AppConstants.keyUserName);
  }

  String? getUserAvatar() {
    return _prefs.getString(AppConstants.keyUserAvatar);
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserAvatar);
    await _prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }
}
