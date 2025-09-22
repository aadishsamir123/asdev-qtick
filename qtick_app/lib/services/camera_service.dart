import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraService extends ChangeNotifier {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isDetectionEnabled = false;
  StreamController<BarcodeCapture>? _detectionStreamController;
  Function(BarcodeCapture)? _onDetect;

  MobileScannerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isDetectionEnabled => _isDetectionEnabled;

  /// Initialize the camera when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _controller = MobileScannerController(
        facing: CameraFacing.front,
        detectionSpeed: DetectionSpeed.noDuplicates,
      );

      // Start the camera but don't start detecting yet
      await _controller!.start();
      _isInitialized = true;

      debugPrint('Camera service initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize camera service: $e');
      _isInitialized = false;
    }
  }

  /// Enable QR code detection with a callback
  void enableDetection(Function(BarcodeCapture) onDetect) {
    if (!_isInitialized || _controller == null) return;

    _onDetect = onDetect;
    _isDetectionEnabled = true;

    debugPrint('QR code detection enabled');
    notifyListeners();
  }

  /// Handle barcode detection from MobileScanner
  void handleBarcodeDetection(BarcodeCapture barcodeCapture) {
    if (_isDetectionEnabled && _onDetect != null) {
      _onDetect!(barcodeCapture);
    }
  }

  /// Disable QR code detection but keep camera running
  void disableDetection() {
    _isDetectionEnabled = false;
    _onDetect = null;

    debugPrint('QR code detection disabled');
    // Note: Not calling notifyListeners() here to avoid setState during dispose
  }

  /// Ensure camera stays running (call this when leaving scanner)
  Future<void> ensureCameraRunning() async {
    if (_controller != null && _isInitialized) {
      try {
        // Check if camera is running, if not restart it
        await _controller!.start();
        debugPrint('Camera ensured to stay running');
      } catch (e) {
        debugPrint('Camera was stopped, restarting: $e');
        // If start fails, try to reinitialize
        try {
          await _controller!.start();
          debugPrint('Camera restarted successfully');
        } catch (restartError) {
          debugPrint('Failed to restart camera: $restartError');
          // As a last resort, reinitialize the entire service
          await restart();
        }
      }
    }
  }

  /// Pause the camera (e.g., when app goes to background)
  Future<void> pause() async {
    if (_controller != null && _isInitialized) {
      await _controller!.stop();
      debugPrint('Camera paused');
    }
  }

  /// Resume the camera (e.g., when app comes to foreground)
  Future<void> resume() async {
    if (_controller != null && _isInitialized) {
      await _controller!.start();
      debugPrint('Camera resumed');
    }
  }

  /// Dispose the camera service
  @override
  Future<void> dispose() async {
    _isDetectionEnabled = false;
    _onDetect = null;
    _detectionStreamController?.close();
    _detectionStreamController = null;

    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    _isInitialized = false;
    debugPrint('Camera service disposed');
    super.dispose();
  }

  /// Restart the camera if something goes wrong
  Future<void> restart() async {
    await dispose();
    await initialize();
  }
}
