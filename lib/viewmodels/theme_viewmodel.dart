import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeViewModel(this._storageService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final savedMode = _storageService.getThemeMode();
    _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storageService.saveThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
