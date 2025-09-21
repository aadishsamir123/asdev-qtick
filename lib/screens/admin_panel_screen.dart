import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:qr_attendance/models/attendance_model.dart';
import 'package:qr_attendance/screens/more_options_screen.dart';
import 'package:provider/provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceModel>(
        context,
        listen: false,
      ).loadAttendanceRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _showRecordDetails(AttendanceRecord record) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Attendance Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Student:', record.studentName),
                _buildDetailRow('Type:', record.attendanceType.toUpperCase()),
                _buildDetailRow(
                  'Date:',
                  DateFormat('MMM dd, yyyy').format(record.timestamp),
                ),
                _buildDetailRow(
                  'Time:',
                  DateFormat('hh:mm a').format(record.timestamp),
                ),
                if (record.notes != null && record.notes!.isNotEmpty)
                  _buildDetailRow('Notes:', record.notes!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  // Get the AttendanceModel reference before popping the dialog
                  final attendanceModel = Provider.of<AttendanceModel>(
                    context,
                    listen: false,
                  );
                  Navigator.of(context).pop();
                  final confirmed = await _showDeleteConfirmation(record);
                  if (confirmed) {
                    await attendanceModel.deleteAttendanceRecord(record.id!);
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(AttendanceRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Record'),
            content: Text(
              'Are you sure you want to delete the attendance record for ${record.studentName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MoreOptionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
          ),
          IconButton(
            onPressed: () {
              Provider.of<AttendanceModel>(
                context,
                listen: false,
              ).loadAttendanceRecords();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AttendanceModel>(
        builder: (context, attendanceModel, child) {
          if (attendanceModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${attendanceModel.errorMessage}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      attendanceModel.clearError();
                      attendanceModel.loadAttendanceRecords();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredRecords = attendanceModel.getFilteredRecords(
            studentName: _searchQuery.isNotEmpty ? _searchQuery : null,
            attendanceType: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
          );

          return Column(
            children: [
              // Filters
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search field
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search by student name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Type filter
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Attendance Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          DropdownMenuItem(
                            value: 'arrival',
                            child: Text('Arrival'),
                          ),
                          DropdownMenuItem(
                            value: 'departure',
                            child: Text('Departure'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date filters
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectStartDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _startDate != null
                                    ? DateFormat('MMM dd').format(_startDate!)
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectEndDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _endDate != null
                                    ? DateFormat('MMM dd').format(_endDate!)
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Clear filters
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Records count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredRecords.length} records found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (filteredRecords.isNotEmpty)
                      Text(
                        'Tap record for details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Records list
              Expanded(
                child:
                    filteredRecords.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No attendance records found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            final isArrival =
                                record.attendanceType == 'arrival';
                            final typeColor =
                                isArrival ? Colors.green : Colors.orange;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: typeColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    isArrival ? Icons.login : Icons.logout,
                                    color: typeColor,
                                  ),
                                ),
                                title: Text(
                                  record.studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.attendanceType.toUpperCase(),
                                      style: TextStyle(
                                        color: typeColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy • hh:mm a',
                                      ).format(record.timestamp),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showRecordDetails(record),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
