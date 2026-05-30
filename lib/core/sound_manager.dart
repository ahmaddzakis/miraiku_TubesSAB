import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  // Membuat satu mesin player global agar efisien
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playSound(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Pastikan 'setting_sound' sesuai dengan key toggle suara di halaman Pengaturan
      final isSoundOn = prefs.getBool('setting_sound') ?? true;

      if (isSoundOn) {
        // Memutar suara dari folder assets/audio/
        await _audioPlayer.play(AssetSource('audio/$fileName'));
      }
    } catch (e) {
      // Biarkan kosong agar jika ada error audio, aplikasi tidak crash
    }
  }
}
