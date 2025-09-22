import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon and Info Section
            Center(
              child: Column(
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.people_alt,
                      size: 80,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    'QTick',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // App Description
                  Text(
                    'QTick - Smart QR Attendance Tracking',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App Information Cards
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Version'),
                    subtitle: Text(_packageInfo?.version ?? 'Loading...'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.build_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Build Number'),
                    subtitle: Text(_packageInfo?.buildNumber ?? 'Loading...'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.extension_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Package Name'),
                    subtitle: Text(_packageInfo?.packageName ?? 'Loading...'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
