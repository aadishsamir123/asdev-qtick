import 'package:flutter/material.dart';
import '../models/whatsapp_config.dart';
import '../services/database_service.dart';
import '../services/whatsapp_business_service.dart';

class WhatsAppConfigScreen extends StatefulWidget {
  const WhatsAppConfigScreen({super.key});

  @override
  State<WhatsAppConfigScreen> createState() => _WhatsAppConfigScreenState();
}

class _WhatsAppConfigScreenState extends State<WhatsAppConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _templateNameController = TextEditingController();
  final _phoneNumberIdController = TextEditingController();
  final _businessAccountIdController = TextEditingController();

  List<String> _arrivalTemplateVariables = [];
  List<String> _departureTemplateVariables = [];

  String _selectedLanguageCode = 'en';
  bool _arrivalNotificationsEnabled = true;
  bool _departureNotificationsEnabled = true;
  bool _isLoading = false;
  bool _isTesting = false;
  WhatsAppConfig? _existingConfig;
  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _templateNameController.dispose();
    _phoneNumberIdController.dispose();
    _businessAccountIdController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingConfig() async {
    setState(() => _isLoading = true);

    try {
      final config = await DatabaseService().getWhatsAppConfig();
      if (config != null) {
        setState(() {
          _existingConfig = config;
          _apiKeyController.text = config.apiKey;
          _templateNameController.text = config.templateName;
          _phoneNumberIdController.text = config.phoneNumberId;
          _businessAccountIdController.text = config.businessAccountId;
          _selectedLanguageCode = config.languageCode;
          _arrivalTemplateVariables = List.from(
            config.arrivalTemplateVariables,
          );
          _departureTemplateVariables = List.from(
            config.departureTemplateVariables,
          );
          _arrivalNotificationsEnabled = config.arrivalNotificationsEnabled;
          _departureNotificationsEnabled = config.departureNotificationsEnabled;
        });
      } else {
        // Set default variables
        setState(() {
          _arrivalTemplateVariables = ['student_name', 'time'];
          _departureTemplateVariables = ['student_name', 'time'];
        });
      }
    } catch (e) {
      _showErrorDialog('Error loading configuration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final config = WhatsAppConfig(
        id: _existingConfig?.id,
        apiKey: _apiKeyController.text.trim(),
        templateName: _templateNameController.text.trim(),
        phoneNumberId: _phoneNumberIdController.text.trim(),
        businessAccountId: _businessAccountIdController.text.trim(),
        languageCode: _selectedLanguageCode,
        arrivalNotificationsEnabled: _arrivalNotificationsEnabled,
        departureNotificationsEnabled: _departureNotificationsEnabled,
        arrivalTemplateVariables: _arrivalTemplateVariables,
        departureTemplateVariables: _departureTemplateVariables,
        createdAt: _existingConfig?.createdAt ?? now,
        updatedAt: now,
      );

      if (_existingConfig != null) {
        await DatabaseService().updateWhatsAppConfig(config);
      } else {
        await DatabaseService().insertWhatsAppConfig(config);
      }

      _showSuccessDialog('Configuration saved successfully!');
    } catch (e) {
      _showErrorDialog('Error saving configuration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill in all required fields before testing.');
      return;
    }

    // Get test phone number from user
    String? testPhoneNumber = await _showTestPhoneDialog();
    if (testPhoneNumber == null || testPhoneNumber.isEmpty) return;

    setState(() => _isTesting = true);

    try {
      final now = DateTime.now();
      final testConfig = WhatsAppConfig(
        apiKey: _apiKeyController.text.trim(),
        templateName: _templateNameController.text.trim(),
        phoneNumberId: _phoneNumberIdController.text.trim(),
        businessAccountId: _businessAccountIdController.text.trim(),
        arrivalNotificationsEnabled: _arrivalNotificationsEnabled,
        departureNotificationsEnabled: _departureNotificationsEnabled,
        arrivalTemplateVariables: _arrivalTemplateVariables,
        departureTemplateVariables: _departureTemplateVariables,
        languageCode: _selectedLanguageCode,
        createdAt: now,
        updatedAt: now,
      );

      final result = await WhatsAppBusinessService.sendTestMessage(
        config: testConfig,
        testPhoneNumber: testPhoneNumber,
      );

      if (result.isSuccessful) {
        _showSuccessDialog('Test message sent successfully!');
      } else {
        _showErrorDialog('Test failed: ${result.errorMessage}');
      }
    } catch (e) {
      _showErrorDialog('Test error: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<String?> _showTestPhoneDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Configuration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter a phone number to send a test message:'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '6512345678 (Singapore) or 911234567890 (India)',
                    helperText: 'International format without + prefix',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Send Test'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
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
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Business Config'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isTesting ? null : _testConfiguration,
            icon:
                _isTesting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.send),
            tooltip: 'Test Configuration',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('API Configuration'),
                      _buildApiKeyField(),
                      const SizedBox(height: 16),
                      _buildTemplateNameField(),
                      const SizedBox(height: 16),
                      _buildPhoneNumberIdField(),
                      const SizedBox(height: 16),
                      _buildBusinessAccountIdField(),
                      const SizedBox(height: 16),
                      _buildLanguageField(),

                      const SizedBox(height: 32),
                      _buildSectionTitle('Notification Settings'),
                      _buildNotificationToggles(),

                      const SizedBox(height: 32),
                      _buildSectionTitle('Template Variables'),
                      _buildTemplateFields(),

                      const SizedBox(height: 32),
                      _buildVariableHelp(),

                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildApiKeyField() {
    return TextFormField(
      controller: _apiKeyController,
      decoration: const InputDecoration(
        labelText: 'API Key *',
        hintText: 'Your WhatsApp Business API key',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.key),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'API Key is required';
        }
        return null;
      },
    );
  }

  Widget _buildTemplateNameField() {
    return TextFormField(
      controller: _templateNameController,
      decoration: const InputDecoration(
        labelText: 'Template Name *',
        hintText: 'Your approved message template name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.message),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Template Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberIdField() {
    return TextFormField(
      controller: _phoneNumberIdController,
      decoration: const InputDecoration(
        labelText: 'Phone Number ID *',
        hintText: 'WhatsApp Business phone number ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone Number ID is required';
        }
        return null;
      },
    );
  }

  Widget _buildBusinessAccountIdField() {
    return TextFormField(
      controller: _businessAccountIdController,
      decoration: const InputDecoration(
        labelText: 'Business Account ID *',
        hintText: 'WhatsApp Business account ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Business Account ID is required';
        }
        return null;
      },
    );
  }

  Widget _buildLanguageField() {
    const Map<String, String> languageOptions = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
    };

    return DropdownButtonFormField<String>(
      value: _selectedLanguageCode,
      decoration: const InputDecoration(
        labelText: 'Template Language *',
        hintText: 'Select message template language',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.language),
        helperText: 'Language for WhatsApp message templates',
      ),
      items:
          languageOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text('${entry.value} (${entry.key})'),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedLanguageCode = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Language is required';
        }
        return null;
      },
    );
  }

  Widget _buildNotificationToggles() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Arrival Notifications'),
              subtitle: const Text('Send WhatsApp messages for arrivals'),
              value: _arrivalNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _arrivalNotificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Departure Notifications'),
              subtitle: const Text('Send WhatsApp messages for departures'),
              value: _departureNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _departureNotificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateFields() {
    const variableOptions = [
      'student_name',
      'time',
      'date',
      'datetime',
      'attendance_type',
    ];

    return Column(
      children: [
        _buildVariableConfig(
          'Arrival Message Variables',
          _arrivalTemplateVariables,
          variableOptions,
          (variables) => setState(() => _arrivalTemplateVariables = variables),
          Icons.login,
        ),
        const SizedBox(height: 16),
        _buildVariableConfig(
          'Departure Message Variables',
          _departureTemplateVariables,
          variableOptions,
          (variables) =>
              setState(() => _departureTemplateVariables = variables),
          Icons.logout,
        ),
      ],
    );
  }

  Widget _buildVariableConfig(
    String title,
    List<String> currentVariables,
    List<String> availableOptions,
    Function(List<String>) onChanged,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select variables for template (max 5):',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  availableOptions.map((option) {
                    final isSelected = currentVariables.contains(option);
                    return FilterChip(
                      label: Text(option.replaceAll('_', ' ').toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newVariables = List<String>.from(
                          currentVariables,
                        );
                        if (selected && newVariables.length < 5) {
                          newVariables.add(option);
                        } else if (!selected) {
                          newVariables.remove(option);
                        }
                        onChanged(newVariables);
                      },
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[700],
                    );
                  }).toList(),
            ),
            if (currentVariables.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Selected order: ${currentVariables.map((v) => v.replaceAll('_', ' ')).join(' → ')}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVariableHelp() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Template Variable Configuration:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• student_name - Student\'s name'),
            const Text('• time - Time of attendance (HH:MM format)'),
            const Text('• date - Date of attendance (YYYY-MM-DD)'),
            const Text('• datetime - Full timestamp with date and time'),
            const Text('• attendance_type - "arrival" or "departure"'),
            const SizedBox(height: 12),
            Text(
              'Variables are sent to WhatsApp Business API in the order you select them. Make sure your approved message template has the same number of variables in the same order.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveConfiguration,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Save Configuration',
                  style: TextStyle(fontSize: 16),
                ),
      ),
    );
  }
}
