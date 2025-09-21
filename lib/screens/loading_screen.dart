import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _appName = '';
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();

    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (mounted) {
        setState(() {
          _appName = packageInfo.appName;
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      // Fallback values if package info fails
      if (mounted) {
        setState(() {
          _appName = 'QTick';
          _version = '1.0.0';
          _buildNumber = '1';
        });
      }
    }

    // Navigate to HomeScreen after 2 seconds and check for updates
    Timer(const Duration(seconds: 2), () async {
      if (mounted) {
        // Navigate to HomeScreen first
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

        // Then check for updates after a small delay to let the UI settle
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            UpdateService().checkForUpdate();
          }
        });
      }
    });
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
          child: Column(
            children: [
              // Main loading content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    const Text('🎓', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 32),

                    // App name
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appBlue,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading spinner
                    CircularProgressIndicator(
                      color: AppTheme.appBlue,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),

                    // Loading text
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.appBlue.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Version info at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Text(
                      _appName.isNotEmpty ? _appName : 'qtick',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.appBlue.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _version.isNotEmpty && _buildNumber.isNotEmpty
                          ? 'Version $_version (Build $_buildNumber)'
                          : 'Loading version...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.appBlue.withValues(alpha: 0.5),
                      ),
                    ),
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
