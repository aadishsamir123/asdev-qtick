import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'models/attendance_model.dart';
import 'theme/app_theme.dart';
import 'widgets/battery_widget.dart';
import 'widgets/update_status_widget.dart';
import 'widgets/qtick_logo.dart';
import 'services/update_service.dart';
import 'services/settings_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const QRAttendanceApp());
}

class QRAttendanceApp extends StatelessWidget {
  const QRAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set fullscreen mode for the entire app
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AttendanceModel()),
        ChangeNotifierProvider(create: (context) => UpdateService()),
        ChangeNotifierProvider(create: (context) => SettingsService()),
      ],
      child: MaterialApp(
        title: 'QTick',
        theme: AppTheme.lightTheme,
        home: const LoadingScreen(),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final settingsService = Provider.of<SettingsService>(
      context,
      listen: false,
    );
    await settingsService.initialize();

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFF1F3F4)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const QTickLogo(size: 80, showBrandName: true),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.appBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-enable fullscreen when app resumes
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure fullscreen mode is active when returning to this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    String weekday = weekdays[date.weekday - 1];
    String month = months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  Widget _buildResponsiveButtonContent({
    required String imagePath,
    required String text,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

        if (isTablet) {
          // Tablet layout: Row with larger elements
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(imagePath, width: 48, height: 48),
              ),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        } else {
          // Mobile layout: Column with smaller elements
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(imagePath, width: 32, height: 32),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFF1F3F4)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Welcome card - compact
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🎓', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Consumer<SettingsService>(
                            builder: (context, settingsService, child) {
                              return Text(
                                settingsService.getWelcomeMessage(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.appBlue,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _formatTime(_currentTime),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.appBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(_currentTime),
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.appBlue.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Question text - smaller
                    Text(
                      'Are you arriving or leaving?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.appBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Buttons - responsive height
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.shortestSide >= 600
                              ? 160
                              : 120,
                      child: Row(
                        children: [
                          // Arrival button
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const QRScannerScreen(
                                            attendanceType: 'arrival',
                                          ),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.appGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: _buildResponsiveButtonContent(
                                  imagePath: 'assets/images/arrival.png',
                                  text: 'I\'m arriving!',
                                ),
                              ),
                            ),
                          ),

                          // Departure button
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 12),
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const QRScannerScreen(
                                            attendanceType: 'departure',
                                          ),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.appOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: _buildResponsiveButtonContent(
                                  imagePath: 'assets/images/departure.png',
                                  text: 'I\'m leaving!',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Admin button - smaller
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminPanelScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings,
                        size: 20,
                        color: AppTheme.appBlue,
                      ),
                      label: Text(
                        'Admin Panel',
                        style: TextStyle(fontSize: 16, color: AppTheme.appBlue),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.appBlue),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top-right widgets: Update status and Battery
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const UpdateStatusWidget(),
                    const SizedBox(width: 8),
                    const BatteryWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
