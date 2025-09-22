import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'dart:io';

class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  bool _updateAvailable = false;
  bool _updateDownloaded = false;
  AppUpdateInfo? _updateInfo;
  
  bool get updateAvailable => _updateAvailable;
  bool get updateDownloaded => _updateDownloaded;
  bool get canUpdate => _updateInfo?.flexibleUpdateAllowed == true;

  /// Check for updates without showing dialogs
  Future<void> checkForUpdate() async {
    // Only check for updates on Android (in_app_update is Android-only)
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      _updateInfo = updateInfo;
      _updateAvailable = updateInfo.updateAvailability == UpdateAvailability.updateAvailable;
      
      debugPrint('Update check: Available=$_updateAvailable, Flexible=${updateInfo.flexibleUpdateAllowed}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      _updateAvailable = false;
      notifyListeners();
    }
  }

  /// Start flexible update download
  Future<bool> startFlexibleUpdate() async {
    if (!_updateAvailable || _updateInfo == null) {
      return false;
    }

    try {
      if (_updateInfo!.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        
        // Listen for download completion
        _listenForUpdateCompletion();
        return true;
      }
    } catch (e) {
      debugPrint('Error starting flexible update: $e');
    }
    return false;
  }

  /// Listen for update download completion
  void _listenForUpdateCompletion() {
    // This is a simplified approach - in a real app you might want to poll or use a timer
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        // Check if update is ready to install
        final updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.installStatus == InstallStatus.downloaded) {
          _updateDownloaded = true;
          _updateAvailable = false; // Hide the download badge, show install badge
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error checking update status: $e');
      }
    });
  }

  /// Complete flexible update (restart app)
  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('Error completing flexible update: $e');
    }
  }

  /// Reset update state (for testing)
  void resetUpdateState() {
    _updateAvailable = false;
    _updateDownloaded = false;
    _updateInfo = null;
    notifyListeners();
  }

  /// Debug method to simulate update available
  void simulateUpdateAvailable() {
    _updateAvailable = true;
    _updateDownloaded = false;
    notifyListeners();
  }

  /// Debug method to simulate update downloaded
  void simulateUpdateDownloaded() {
    _updateAvailable = false;
    _updateDownloaded = true;
    notifyListeners();
  }
}