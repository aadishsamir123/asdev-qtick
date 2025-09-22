import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Play success sound
  Future<void> playSuccessSound() async {
    try {
      // First check if the sound file exists by trying to play it
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // If sound file doesn't exist, just log it (don't crash the app)
      if (kDebugMode) {
        print('Success sound file not found: $e');
        print('Please add success.mp3 to assets/sounds/ directory');
      }
    }
  }

  /// Play error sound
  Future<void> playErrorSound() async {
    try {
      // First check if the sound file exists by trying to play it
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // If sound file doesn't exist, just log it (don't crash the app)
      if (kDebugMode) {
        print('Error sound file not found: $e');
        print('Please add error.mp3 to assets/sounds/ directory');
      }
    }
  }

  /// Stop any currently playing sound
  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping sound: $e');
      }
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('Error setting volume: $e');
      }
    }
  }

  /// Dispose of the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
