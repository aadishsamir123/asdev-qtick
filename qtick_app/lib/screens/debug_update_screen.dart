import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';

class DebugUpdateScreen extends StatelessWidget {
  const DebugUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Update Testing'),
        backgroundColor: AppTheme.appBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UpdateService>(
          builder: (context, updateService, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Update System Testing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Current Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update Available: ${updateService.updateAvailable}',
                        ),
                        Text(
                          'Update Downloaded: ${updateService.updateDownloaded}',
                        ),
                        Text('Can Update: ${updateService.canUpdate}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildTestButton(
                    context,
                    'Check for Real Updates',
                    'Check Play Store for actual updates',
                    () => updateService.checkForUpdate(),
                  ),

                  _buildTestButton(
                    context,
                    'Simulate Update Available',
                    'Simulate that an update is available',
                    () => updateService.simulateUpdateAvailable(),
                  ),

                  _buildTestButton(
                    context,
                    'Simulate Update Downloaded',
                    'Simulate that update is downloaded and ready',
                    () => updateService.simulateUpdateDownloaded(),
                  ),

                  _buildTestButton(
                    context,
                    'Reset Update State',
                    'Clear all update states',
                    () => updateService.resetUpdateState(),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Testing Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Use "Simulate Update Available" to see the orange badge with download icon\n'
                          '2. Tap the badge to see the download dialog\n'
                          '3. Use "Simulate Update Downloaded" to see the green badge with restart icon\n'
                          '4. Tap the badge to see the restart dialog\n'
                          '5. Use "Check for Real Updates" to test with actual Play Store\n'
                          '6. Badge appears in top-right corner of home screen',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
