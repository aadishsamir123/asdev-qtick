import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:qr_attendance/models/attendance_model.dart';
import 'package:qr_attendance/theme/app_theme.dart';
import 'package:qr_attendance/services/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class QRScannerScreen extends StatefulWidget {
  final String attendanceType;

  const QRScannerScreen({super.key, required this.attendanceType});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;
  MobileScannerController? _controller;
  final AudioService _audioService = AudioService();

  // Helper methods for orientation and device detection
  bool get _isTablet {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 600;
  }

  bool get _isLandscape {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  // Calculate rotation based on device and orientation
  double get _cameraRotation {
    if (!_isTablet) return 0.0; // No rotation needed for phones

    if (_isLandscape) {
      // For tablets in landscape mode, front camera needs 90° rotation
      return 1.5708; // 90 degrees in radians (π/2)
    }

    return 0.0; // No rotation needed for portrait
  }

  @override
  void initState() {
    super.initState();
    // Set fullscreen for scanner
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize local controller with tablet-specific settings
    _controller = MobileScannerController(
      facing: CameraFacing.front,
      detectionSpeed: DetectionSpeed.noDuplicates,
      // Force specific camera resolution for tablets to avoid orientation issues
      // This helps ensure consistent camera behavior across devices
      returnImage: false, // We don't need the captured image
    );
  }

  @override
  void dispose() {
    // Dispose of our local controller
    _controller?.dispose();
    // Keep fullscreen mode when leaving scanner (don't restore system UI)
    // The main app should stay in fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  // Build orientation-aware scanner widget
  Widget _buildOrientationAwareScanner() {
    if (!_isTablet) {
      // For phones, use scanner as-is
      return MobileScanner(controller: _controller!, onDetect: _onDetect);
    }

    // For tablets, apply orientation correction
    if (_isLandscape) {
      // In landscape mode on tablets, rotate the camera view
      return Transform.rotate(
        angle: _cameraRotation,
        child: MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
          fit: BoxFit.cover, // Ensure proper fit
        ),
      );
    } else {
      // In portrait mode on tablets, use scanner normally
      return MobileScanner(
        controller: _controller!,
        onDetect: _onDetect,
        fit: BoxFit.cover,
      );
    }
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    // Process detection directly
    _handleBarcodeDetection(barcodeCapture);
  }

  void _handleBarcodeDetection(BarcodeCapture barcodeCapture) {
    final barcode = barcodeCapture.barcodes.first;
    if (!isProcessing && barcode.rawValue != null) {
      _processQRCode(barcode.rawValue!);
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Create attendance record
      final record = AttendanceRecord(
        studentName: qrCode.trim(),
        attendanceType: widget.attendanceType,
        timestamp: DateTime.now(),
      );

      // Add to database
      final attendanceModel = Provider.of<AttendanceModel>(
        context,
        listen: false,
      );
      final success = await attendanceModel.addAttendanceRecord(record);

      if (success && mounted) {
        _showSuccessDialog(qrCode);
      } else if (mounted) {
        _showErrorDialog('Failed to record attendance. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error processing QR code: $e');
      }
    }
  }

  void _showSuccessDialog(String studentName) {
    final isArrival = widget.attendanceType == 'arrival';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Play success sound
    _audioService.playSuccessSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            ),
            title: Column(
              children: [
                // Lottie animation instead of emoji
                SizedBox(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  child: Lottie.asset(
                    isArrival
                        ? 'assets/animations/success_arrival.json'
                        : 'assets/animations/success_departure.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  isArrival
                      ? 'Welcome, $studentName!'
                      : 'Bye Bye, $studentName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isArrival ? AppTheme.appGreen : AppTheme.appOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 36 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: (isArrival ? AppTheme.appGreen : AppTheme.appOrange)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Text(
                    isArrival ? 'Marked as arrived!' : 'Marked as left!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isArrival ? AppTheme.appGreen : AppTheme.appOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 20 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
    );

    // Automatically go back to home screen after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        // Ensure fullscreen mode before going back
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        Navigator.of(context).pop(); // Go back to home screen
      }
    });
  }

  void _showErrorDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Play error sound
    _audioService.playErrorSound();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            ),
            title: Column(
              children: [
                // Lottie animation instead of emoji
                SizedBox(
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
                  child: Lottie.asset(
                    'assets/animations/error.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.appRed,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 32 : 24,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Something went wrong.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 20 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Let\'s try scanning your QR code again!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 18 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resumeScanning();
                },
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: isTablet ? 18 : 14),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Ensure fullscreen mode before going back
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky,
                  );
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.appBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(fontSize: isTablet ? 18 : 14),
                ),
              ),
            ],
          ),
    );
  }

  void _resumeScanning() {
    setState(() {
      isProcessing = false;
    });
    // Scanning will automatically resume since we're not disabling the controller
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArrival = widget.attendanceType == 'arrival';
    final attendanceColor = isArrival ? AppTheme.appGreen : AppTheme.appOrange;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArrival ? '👋 Time to Arrive!' : '👋 Time to Leave!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 28 : 20,
          ),
        ),
        backgroundColor: attendanceColor.withValues(alpha: 0.1),
        foregroundColor: attendanceColor,
        toolbarHeight: isTablet ? 80 : 56,
        leading: IconButton(
          onPressed: () {
            // Ensure fullscreen mode before going back
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, size: isTablet ? 32 : 24),
        ),
      ),
      body:
          _controller == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: attendanceColor),
                    const SizedBox(height: 16),
                    Text(
                      'Initializing camera...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: attendanceColor,
                      ),
                    ),
                  ],
                ),
              )
              : _buildScannerContent(
                theme,
                attendanceColor,
                isTablet,
                isArrival,
              ),
    );
  }

  Widget _buildScannerContent(
    ThemeData theme,
    Color attendanceColor,
    bool isTablet,
    bool isArrival,
  ) {
    // Create the scanner widget once to avoid GlobalKey conflicts
    final scannerWidget = Stack(
      children: [
        // Wrap MobileScanner with proper orientation handling for tablets
        _buildOrientationAwareScanner(),
        CustomPaint(
          painter: ScannerOverlay(attendanceColor),
          child: Container(),
        ),
        if (isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: attendanceColor,
                    strokeWidth: isTablet ? 6 : 4,
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Text(
                    'Processing...',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 24 : 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return isTablet
        ? _buildTabletLayout(
          theme,
          attendanceColor,
          isTablet,
          isArrival,
          scannerWidget,
        )
        : _buildMobileLayout(
          theme,
          attendanceColor,
          isTablet,
          isArrival,
          scannerWidget,
        );
  }

  Widget _buildTabletLayout(
    ThemeData theme,
    Color attendanceColor,
    bool isTablet,
    bool isArrival,
    Widget scannerWidget,
  ) {
    return Row(
      children: [
        // Left side - Instructions for tablet
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: attendanceColor.withValues(alpha: 0.1),
            border: Border(
              right: BorderSide(
                color: attendanceColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    // Lottie animation showing how to scan QR code
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Lottie.asset(
                        'assets/animations/qr_scanning.json', // This will be the animation you download
                        repeat: true,
                        animate: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Show me your QR code!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: attendanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArrival
                          ? 'Hold your QR code in front of the camera so I can mark you as arrived!'
                          : 'Hold your QR code in front of the camera so I can mark you as left!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: attendanceColor.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: attendanceColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('📋', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            'Put your QR code in the square on the right',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {
                        // Ensure fullscreen mode before going back
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersiveSticky,
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.home, size: 24),
                      label: Text('Go Back', style: TextStyle(fontSize: 18)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.appBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right side - Scanner for tablet
        Expanded(child: scannerWidget),
      ],
    );
  }

  Widget _buildMobileLayout(
    ThemeData theme,
    Color attendanceColor,
    bool isTablet,
    bool isArrival,
    Widget scannerWidget,
  ) {
    return Column(
      children: [
        // Instructions for mobile
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: attendanceColor.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: attendanceColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small Lottie animation showing QR scanning
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/animations/qr_scanning.json',
                      repeat: true,
                      animate: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Show me your QR code!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: attendanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isArrival
                    ? 'Hold your QR code in front of the camera'
                    : 'Hold your QR code in front of the camera',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: attendanceColor.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // QR Scanner for mobile
        Expanded(child: scannerWidget),

        // Bottom instructions for mobile with Lottie animation
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie animation showing how to scan QR code
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Lottie.asset(
                      'assets/animations/qr_scanning.json', // This will be the animation you download
                      repeat: true,
                      animate: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Put your QR code in the square',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hold it steady and wait for the scan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  // Ensure fullscreen mode before going back
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.home),
                label: const Text('Go Back'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.appBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScannerOverlay extends CustomPainter {
  final Color borderColor;

  ScannerOverlay(this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final borderLength = 30.0;
    final borderWidth = 4.0;
    final cutOutSize = 250.0;
    final borderRadius = 10.0;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;

    // Draw background with cut-out
    final backgroundPath =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corner borders
    final cornerPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + borderLength),
      Offset(cutOutRect.left, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left + borderLength, cutOutRect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top + borderLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom - borderLength),
      Offset(cutOutRect.left, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left + borderLength, cutOutRect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom - borderLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
