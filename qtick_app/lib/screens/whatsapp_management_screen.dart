import 'package:flutter/material.dart';
import '../screens/whatsapp_config_screen.dart';
import '../screens/csv_import_screen.dart';
import '../screens/message_logs_screen.dart';
import '../services/database_service.dart';
import '../models/whatsapp_config.dart';

class WhatsAppManagementScreen extends StatefulWidget {
  const WhatsAppManagementScreen({super.key});

  @override
  State<WhatsAppManagementScreen> createState() =>
      _WhatsAppManagementScreenState();
}

class _WhatsAppManagementScreenState extends State<WhatsAppManagementScreen> {
  bool _isLoading = true;
  WhatsAppConfig? _config;
  int _totalContacts = 0;
  int _totalLogs = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final config = await DatabaseService().getWhatsAppConfig();
      final contacts = await DatabaseService().getAllStudentContacts();
      final logs = await DatabaseService().getAllMessageLogs();

      setState(() {
        _config = config;
        _totalContacts = contacts.length;
        _totalLogs = logs.length;
      });
    } catch (e) {
      _showErrorDialog('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
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
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _navigateToConfig() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WhatsAppConfigScreen()),
    );
    _loadData(); // Refresh data when returning
  }

  void _navigateToImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CsvImportScreen()),
    );
    _loadData(); // Refresh data when returning
  }

  void _navigateToLogs() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MessageLogsScreen()),
    );
    _loadData(); // Refresh data when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Business'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildManagementOptions(),
                    const SizedBox(height: 24),
                    _buildHelpSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusCard() {
    final isConfigured = _config != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isConfigured
                        ? 'WhatsApp Business Configured'
                        : 'Configuration Required',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isConfigured
                  ? 'Your WhatsApp Business integration is ready to send notifications.'
                  : 'Configure your WhatsApp Business API to start sending notifications.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (isConfigured) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (_config!.arrivalNotificationsEnabled)
                    Chip(
                      label: const Text('Arrival Notifications'),
                      backgroundColor: Colors.green[100],
                      avatar: const Icon(Icons.login, size: 16),
                    ),
                  if (_config!.departureNotificationsEnabled)
                    Chip(
                      label: const Text('Departure Notifications'),
                      backgroundColor: Colors.blue[100],
                      avatar: const Icon(Icons.logout, size: 16),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Contacts',
            _totalContacts.toString(),
            Icons.contacts,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Messages Sent',
            _totalLogs.toString(),
            Icons.message,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          title: 'API Configuration',
          subtitle: 'Configure WhatsApp Business API settings',
          icon: Icons.settings,
          color: Colors.green,
          onTap: _navigateToConfig,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: 'Import Contacts',
          subtitle: 'Import student phone numbers from CSV',
          icon: Icons.upload_file,
          color: Colors.blue,
          onTap: _navigateToImport,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: 'Message Logs',
          subtitle: 'View sent messages and delivery status',
          icon: Icons.history,
          color: Colors.purple,
          onTap: _navigateToLogs,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Getting Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Configure your WhatsApp Business API settings',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              '2. Import student contacts from a CSV file',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              '3. Notifications will be sent automatically when students scan QR codes',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Note: You need a valid WhatsApp Business API account and approved message templates.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
