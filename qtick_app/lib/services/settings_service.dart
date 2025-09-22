import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _placeNameKey = 'place_name';
  static const String _defaultPlaceName = 'Learning Center';

  String _placeName = _defaultPlaceName;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  String get placeName => _placeName;
  bool get isInitialized => _isInitialized;

  /// Initialize the settings service and load saved preferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _placeName = _prefs?.getString(_placeNameKey) ?? _defaultPlaceName;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SettingsService: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update the place name and save to preferences
  Future<void> updatePlaceName(String newPlaceName) async {
    if (newPlaceName.trim().isEmpty) {
      return;
    }

    _placeName = newPlaceName.trim();

    try {
      await _prefs?.setString(_placeNameKey, _placeName);
    } catch (e) {
      debugPrint('Error saving place name: $e');
    }

    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _placeName = _defaultPlaceName;

    try {
      await _prefs?.clear();
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }

    notifyListeners();
  }

  /// Get welcome message with the current place name
  String getWelcomeMessage() {
    return 'Welcome to $_placeName!';
  }
}
