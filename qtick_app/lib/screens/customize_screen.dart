import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  final TextEditingController _placeNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize the text field with current place name
    final settingsService = Provider.of<SettingsService>(
      context,
      listen: false,
    );
    _placeNameController.text = settingsService.placeName;
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    super.dispose();
  }

  Future<void> _savePlaceName() async {
    if (_placeNameController.text.trim().isEmpty) {
      _showErrorDialog('Place name cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsService = Provider.of<SettingsService>(
        context,
        listen: false,
      );
      await settingsService.updatePlaceName(_placeNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully!'),
            backgroundColor: AppTheme.appGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save settings. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset to Defaults'),
            content: const Text(
              'Are you sure you want to reset all settings to default values?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final settingsService = Provider.of<SettingsService>(
          // ignore: use_build_context_synchronously
          context,
          listen: false,
        );
        await settingsService.resetToDefaults();
        _placeNameController.text = settingsService.placeName;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Settings reset to defaults!'),
              backgroundColor: AppTheme.appBlue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to reset settings. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Customize'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Personalize Your App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.appBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize the app settings to match your needs',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.appBlue.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Place Name Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.appBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Place Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.appBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This will be displayed on the main screen welcome message',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.appBlue.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _placeNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter place name',
                          hintText: 'e.g., Learning Center, Math Academy, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.appBlue),
                          ),
                          prefixIcon: Icon(
                            Icons.business,
                            color: AppTheme.appBlue,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        textCapitalization: TextCapitalization.words,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 20),

                      // Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.appBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.appBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.appBlue.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer<SettingsService>(
                              builder: (context, settingsService, child) {
                                final previewText =
                                    _placeNameController.text.trim().isEmpty
                                        ? 'Welcome to Learning Center!'
                                        : 'Welcome to ${_placeNameController.text.trim()}!';
                                return Text(
                                  previewText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.appBlue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _savePlaceName,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.appBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _resetToDefaults,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reset to Defaults',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
