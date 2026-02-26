import 'package:audioplayers/audioplayers.dart';

/// Singleton service for playing game sound effects.
/// Uses AudioPlayer with in-memory byte sources so no external asset files needed.
class SfxService {
  SfxService._();
  static final SfxService instance = SfxService._();

  final AudioPlayer _player = AudioPlayer();

  bool _enabled = true;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> _play(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Silently ignore if audio fails (e.g. no asset yet, or device issue)
    }
  }

  /// Short chime played when a task is completed.
  Future<void> playTaskComplete() => _play('sfx/task_complete.mp3');

  /// Victory fanfare played on level up.
  Future<void> playLevelUp() => _play('sfx/level_up.mp3');

  /// Soft click for UI button presses.
  Future<void> playButtonClick() => _play('sfx/button_click.mp3');

  void dispose() {
    _player.dispose();
  }
}
