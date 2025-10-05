import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_log.dart';
import '../services/database_service.dart';

class MessageLogsScreen extends StatefulWidget {
  const MessageLogsScreen({super.key});

  @override
  State<MessageLogsScreen> createState() => _MessageLogsScreenState();
}

class _MessageLogsScreenState extends State<MessageLogsScreen> {
  List<MessageLog> _allLogs = [];
  List<MessageLog> _filteredLogs = [];
  MessageStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessageLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessageLogs() async {
    setState(() => _isLoading = true);

    try {
      final logs = await DatabaseService().getAllMessageLogs();
      setState(() {
        _allLogs = logs;
        _applyFilters();
      });
    } catch (e) {
      _showErrorDialog('Error loading message logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<MessageLog> filtered = _allLogs;

    // Apply status filter
    if (_selectedStatus != null) {
      filtered =
          filtered.where((log) => log.status == _selectedStatus).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (log) =>
                    log.studentName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    log.phoneNumber.contains(_searchQuery),
              )
              .toList();
    }

    setState(() {
      _filteredLogs = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onStatusFilterChanged(MessageStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    _applyFilters();
  }

  Future<void> _clearAllLogs() async {
    final confirmed = await _showConfirmationDialog(
      'Clear All Logs',
      'Are you sure you want to delete all message logs? This action cannot be undone.',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService().clearAllMessageLogs();
      await _loadMessageLogs();
      _showSuccessDialog('All message logs have been cleared.');
    } catch (e) {
      _showErrorDialog('Error clearing logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
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

  void _showMessageDetails(MessageLog log) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Message Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Student:', log.studentName),
                  _buildDetailRow('Phone:', log.phoneNumber),
                  _buildDetailRow('Type:', log.messageType.toUpperCase()),
                  _buildDetailRow('Status:', _getStatusText(log.status)),
                  _buildDetailRow('Time:', _formatDateTime(log.timestamp)),
                  if (log.whatsappMessageId != null)
                    _buildDetailRow('Message ID:', log.whatsappMessageId!),
                  if (log.errorMessage != null)
                    _buildDetailRow('Error:', log.errorMessage!, isError: true),
                  if (log.deliveredAt != null)
                    _buildDetailRow(
                      'Delivered:',
                      _formatDateTime(log.deliveredAt!),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Message Content:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(log.messageContent),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isError ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  String _getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return 'Pending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.failed:
        return 'Failed';
      case MessageStatus.delivered:
        return 'Delivered';
    }
  }

  Color _getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return Colors.orange;
      case MessageStatus.sent:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
      case MessageStatus.delivered:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return Icons.schedule;
      case MessageStatus.sent:
        return Icons.send;
      case MessageStatus.failed:
        return Icons.error;
      case MessageStatus.delivered:
        return Icons.check_circle;
    }
  }

  Map<String, int> _getStatistics() {
    final stats = <String, int>{};

    for (final status in MessageStatus.values) {
      stats[status.name] = _allLogs.where((log) => log.status == status).length;
    }

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Logs'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadMessageLogs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          if (_allLogs.isNotEmpty)
            IconButton(
              onPressed: _clearAllLogs,
              icon: const Icon(Icons.delete),
              tooltip: 'Clear All Logs',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildStatisticsSection(stats),
                  _buildFiltersSection(),
                  Expanded(child: _buildLogsList()),
                ],
              ),
    );
  }

  Widget _buildStatisticsSection(Map<String, int> stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _allLogs.length.toString(),
                    Colors.blue,
                    Icons.message,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Successful',
                    (stats['sent']! + stats['delivered']!).toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Failed',
                    stats['failed'].toString(),
                    Colors.red,
                    Icons.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    stats['pending'].toString(),
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by student name or phone',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<MessageStatus?>(
                    value: _selectedStatus,
                    isExpanded: true,
                    hint: const Text('All statuses'),
                    items: [
                      const DropdownMenuItem<MessageStatus?>(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      ...MessageStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 16,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 8),
                              Text(_getStatusText(status)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: _onStatusFilterChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _allLogs.isEmpty
                ? 'No message logs yet.\nMessages will appear here after sending WhatsApp notifications.'
                : 'No logs match your current filters.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(log.status),
              child: Icon(
                _getStatusIcon(log.status),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(log.studentName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.phoneNumber),
                Text(
                  '${log.messageType.toUpperCase()} • ${_formatDateTime(log.timestamp)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusText(log.status),
                  style: TextStyle(
                    color: _getStatusColor(log.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showMessageDetails(log),
          ),
        );
      },
    );
  }
}
