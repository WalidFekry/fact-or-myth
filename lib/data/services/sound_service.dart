import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _soundEnabledKey = 'sound_enabled';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  SoundService() {
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
  }

  bool get isSoundEnabled => _soundEnabled;

  Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play a simple beep sound using frequency
      // Since we don't have actual sound files, we'll use a simple tone
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
      // In production, you would add actual sound files
    }
  }

  Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
