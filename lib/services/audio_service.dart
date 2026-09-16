import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small static audio manager for one-off sound effects (no background
/// music). Sound is global to the app rather than tied to one screen's
/// lifecycle, so this is a lightweight static class rather than a
/// per-screen service.
class AudioService {
  AudioService._();

  static const _mutedKey = 'stack_it_muted';

  static bool _muted = false;
  static bool _initialized = false;
  static AudioPlayer? _splashPlayer;

  static bool get isMuted => _muted;

  /// Loads persisted mute state and preloads all sound files. Safe to
  /// call multiple times — only does real work once.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_mutedKey) ?? false;

    await FlameAudio.audioCache.loadAll([
      'splash.wav',
      'tap.wav',
      'place.wav',
      'coin.wav',
      'gameover.wav',
    ]);
  }

  static Future<void> setMuted(bool value) async {
    _muted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, value);
    if (value) {
      await stopSplash();
    }
  }

  static Future<void> toggleMuted() => setMuted(!_muted);

  /// Plays the splash-screen transition sound once. Call [stopSplash]
  /// when leaving the splash screen so it never bleeds into gameplay.
  static Future<void> playSplash() async {
    if (_muted) return;
    _splashPlayer = await FlameAudio.play('splash.wav', volume: 0.6);
  }

  /// Stops the splash sound immediately, regardless of whether it has
  /// finished playing on its own yet.
  static Future<void> stopSplash() async {
    final player = _splashPlayer;
    _splashPlayer = null;
    await player?.stop();
  }

  static void _playSfx(String file, {double volume = 0.6}) {
    if (_muted) return;
    FlameAudio.play(file, volume: volume);
  }

  static void playTap() => _playSfx('tap.wav', volume: 0.4);
  static void playPlace() => _playSfx('place.wav', volume: 0.6);
  static void playCoin() => _playSfx('coin.wav', volume: 0.5);
  static void playGameOver() => _playSfx('gameover.wav', volume: 0.6);
}
