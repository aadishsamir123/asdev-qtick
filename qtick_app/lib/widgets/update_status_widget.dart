import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/update_service.dart';

class UpdateStatusWidget extends StatelessWidget {
  const UpdateStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateService>(
      builder: (context, updateService, _) {
        final showBadge =
            updateService.updateAvailable || updateService.updateDownloaded;

        if (!showBadge) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _handleUpdateTap(context, updateService),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  updateService.updateDownloaded
                      ? Colors.green.withValues(alpha: 0.9)
                      : Colors.orange.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  updateService.updateDownloaded
                      ? Icons.restart_alt
                      : Icons.download,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  updateService.updateDownloaded ? 'Restart' : 'Update',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleUpdateTap(BuildContext context, UpdateService updateService) {
    if (updateService.updateDownloaded) {
      _showRestartDialog(context, updateService);
    } else if (updateService.updateAvailable) {
      _showDownloadDialog(context, updateService);
    }
  }

  void _showDownloadDialog(BuildContext context, UpdateService updateService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Available'),
            content: const Text(
              'A new version is available. Download it now?\n\nThe app will continue working while the update downloads in the background.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await updateService.startFlexibleUpdate();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Update downloading in background...'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  void _showRestartDialog(BuildContext context, UpdateService updateService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Ready'),
            content: const Text(
              'The update has been downloaded and is ready to install. Restart the app now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  updateService.completeFlexibleUpdate();
                },
                child: const Text('Restart Now'),
              ),
            ],
          ),
    );
  }
}
