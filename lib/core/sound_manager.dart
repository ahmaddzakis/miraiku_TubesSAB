import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static AudioPlayer? _audioPlayer;

  static Future<void> playSound(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSoundOn = prefs.getBool('setting_sound') ?? true;

      if (isSoundOn) {
        _audioPlayer ??= AudioPlayer();
        await _audioPlayer!.play(AssetSource('audio/$fileName'));
      }
    } catch (_) {
      // Ignore audio errors on headless/test platforms so gameplay never crashes
    }
  }
}
