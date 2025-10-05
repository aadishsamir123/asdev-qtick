import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_attendance/screens/settings_screen.dart';
import 'package:qr_attendance/screens/debug_update_screen.dart';
import 'package:qr_attendance/screens/customize_screen.dart';
import 'package:qr_attendance/screens/whatsapp_management_screen.dart';
import 'package:qr_attendance/models/attendance_model.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:qr_attendance/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MoreOptionsScreen extends StatefulWidget {
  const MoreOptionsScreen({super.key});

  @override
  State<MoreOptionsScreen> createState() => _MoreOptionsScreenState();
}

class _MoreOptionsScreenState extends State<MoreOptionsScreen> {
  @override
  void initState() {
    super.initState();
    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _showExportDialog() async {
    DateTime? exportStartDate;
    DateTime? exportEndDate;
    bool exportToday = true;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Export Attendance Data'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select date range for export:'),
                      const SizedBox(height: 16),

                      // Today option
                      RadioListTile<bool>(
                        value: true,
                        groupValue: exportToday,
                        onChanged: (value) {
                          setState(() {
                            exportToday = true;
                            exportStartDate = DateTime.now();
                            exportEndDate = DateTime.now();
                          });
                        },
                        title: const Text('Today'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      // Custom date range option
                      RadioListTile<bool>(
                        value: false,
                        groupValue: exportToday,
                        onChanged: (value) {
                          setState(() {
                            exportToday = false;
                            exportStartDate = null;
                            exportEndDate = null;
                          });
                        },
                        title: const Text('Custom Date Range'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (!exportToday) ...[
                        const SizedBox(height: 16),

                        // Start Date
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exportStartDate != null
                                    ? 'From: ${DateFormat('MMM dd, yyyy').format(exportStartDate!)}'
                                    : 'From: Select date',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      exportStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    exportStartDate = date;
                                  });
                                }
                              },
                              child: const Text('Select'),
                            ),
                          ],
                        ),

                        // End Date
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exportEndDate != null
                                    ? 'To: ${DateFormat('MMM dd, yyyy').format(exportEndDate!)}'
                                    : 'To: Select date',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      exportEndDate ??
                                      exportStartDate ??
                                      DateTime.now(),
                                  firstDate: exportStartDate ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    exportEndDate = date;
                                  });
                                }
                              },
                              child: const Text('Select'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Set dates based on selection
                        DateTime? startDate;
                        DateTime? endDate;

                        if (exportToday) {
                          final today = DateTime.now();
                          startDate = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          );
                          endDate = DateTime(
                            today.year,
                            today.month,
                            today.day,
                            23,
                            59,
                            59,
                          );
                        } else {
                          if (exportStartDate != null) {
                            startDate = DateTime(
                              exportStartDate!.year,
                              exportStartDate!.month,
                              exportStartDate!.day,
                            );
                          }
                          if (exportEndDate != null) {
                            endDate = DateTime(
                              exportEndDate!.year,
                              exportEndDate!.month,
                              exportEndDate!.day,
                              23,
                              59,
                              59,
                            );
                          }
                        }

                        // Capture references early to avoid context issues
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final overlayState = Overlay.of(context);
                        final attendanceModel = Provider.of<AttendanceModel>(
                          context,
                          listen: false,
                        );

                        // Show loading indicator with dynamic message
                        late OverlayEntry loadingOverlay;
                        String loadingMessage = 'Calculating...';

                        loadingOverlay = OverlayEntry(
                          builder:
                              (context) => Material(
                                color: Colors.black54,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 16),
                                        StatefulBuilder(
                                          builder: (context, setState) {
                                            // Update message after delay
                                            Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                                if (loadingOverlay.mounted) {
                                                  setState(() {
                                                    loadingMessage =
                                                        'Exporting...';
                                                  });
                                                }
                                              },
                                            );

                                            return Text(
                                              loadingMessage,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        );

                        overlayState.insert(loadingOverlay);

                        try {
                          final settingsService = Provider.of<SettingsService>(
                            context,
                            listen: false,
                          );

                          await attendanceModel.exportToCsv(
                            startDate: startDate,
                            endDate: endDate,
                            centerName: settingsService.placeName,
                          );

                          loadingOverlay.remove();

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Data exported successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          loadingOverlay.remove();

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Export failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Export'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showDeleteDialog() async {
    DateTime? deleteStartDate;
    DateTime? deleteEndDate;
    bool deleteToday = true;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Delete Attendance Data'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select date range for deletion:'),
                      const SizedBox(height: 16),

                      // Today option
                      RadioListTile<bool>(
                        value: true,
                        groupValue: deleteToday,
                        onChanged: (value) {
                          setState(() {
                            deleteToday = true;
                            deleteStartDate = DateTime.now();
                            deleteEndDate = DateTime.now();
                          });
                        },
                        title: const Text('Today'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      // Custom date range option
                      RadioListTile<bool>(
                        value: false,
                        groupValue: deleteToday,
                        onChanged: (value) {
                          setState(() {
                            deleteToday = false;
                            deleteStartDate = null;
                            deleteEndDate = null;
                          });
                        },
                        title: const Text('Custom Date Range'),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (!deleteToday) ...[
                        const SizedBox(height: 16),

                        // Start Date
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deleteStartDate != null
                                    ? 'From: ${DateFormat('MMM dd, yyyy').format(deleteStartDate!)}'
                                    : 'From: Select date',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      deleteStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    deleteStartDate = date;
                                  });
                                }
                              },
                              child: const Text('Select'),
                            ),
                          ],
                        ),

                        // End Date
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deleteEndDate != null
                                    ? 'To: ${DateFormat('MMM dd, yyyy').format(deleteEndDate!)}'
                                    : 'To: Select date',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      deleteEndDate ??
                                      deleteStartDate ??
                                      DateTime.now(),
                                  firstDate: deleteStartDate ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    deleteEndDate = date;
                                  });
                                }
                              },
                              child: const Text('Select'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Set dates based on selection
                        DateTime? startDate;
                        DateTime? endDate;
                        String dateRangeText;

                        if (deleteToday) {
                          final today = DateTime.now();
                          startDate = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          );
                          endDate = DateTime(
                            today.year,
                            today.month,
                            today.day,
                            23,
                            59,
                            59,
                          );
                          dateRangeText =
                              'Today (${DateFormat('MMM dd, yyyy').format(today)})';
                        } else {
                          if (deleteStartDate != null) {
                            startDate = DateTime(
                              deleteStartDate!.year,
                              deleteStartDate!.month,
                              deleteStartDate!.day,
                            );
                          }
                          if (deleteEndDate != null) {
                            endDate = DateTime(
                              deleteEndDate!.year,
                              deleteEndDate!.month,
                              deleteEndDate!.day,
                              23,
                              59,
                              59,
                            );
                          }

                          if (deleteStartDate != null &&
                              deleteEndDate != null) {
                            dateRangeText =
                                'From ${DateFormat('MMM dd, yyyy').format(deleteStartDate!)} to ${DateFormat('MMM dd, yyyy').format(deleteEndDate!)}';
                          } else if (deleteStartDate != null) {
                            dateRangeText =
                                'From ${DateFormat('MMM dd, yyyy').format(deleteStartDate!)} onwards';
                          } else if (deleteEndDate != null) {
                            dateRangeText =
                                'Up to ${DateFormat('MMM dd, yyyy').format(deleteEndDate!)}';
                          } else {
                            dateRangeText = 'All records';
                          }
                        }

                        // Show confirmation dialog
                        _showDeleteConfirmation(
                          startDate,
                          endDate,
                          dateRangeText,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showDeleteConfirmation(
    DateTime? startDate,
    DateTime? endDate,
    String dateRangeText,
  ) async {
    // Get count of records that will be deleted
    final attendanceModel = Provider.of<AttendanceModel>(
      context,
      listen: false,
    );

    final recordsToDelete = attendanceModel.getFilteredRecords(
      startDate: startDate,
      endDate: endDate,
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Confirm Deletion'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You are about to permanently delete the following attendance records:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),

                // Date range
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(dateRangeText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${recordsToDelete.length} records will be deleted',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'This action cannot be undone. Are you sure you want to continue?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _performBulkDelete(
                    startDate,
                    endDate,
                    recordsToDelete.length,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _performBulkDelete(
    DateTime? startDate,
    DateTime? endDate,
    int expectedCount,
  ) async {
    final attendanceModel = Provider.of<AttendanceModel>(
      context,
      listen: false,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting attendance records...'),
              ],
            ),
          ),
    );

    try {
      // Get records to delete
      final recordsToDelete = attendanceModel.getFilteredRecords(
        startDate: startDate,
        endDate: endDate,
      );

      // Delete each record
      for (final record in recordsToDelete) {
        if (record.id != null) {
          await attendanceModel.deleteAttendanceRecord(record.id!);
        }
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully deleted ${recordsToDelete.length} attendance records',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete records: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateDebugData() async {
    final attendanceModel = Provider.of<AttendanceModel>(
      context,
      listen: false,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating debug attendance data...'),
              ],
            ),
          ),
    );

    try {
      // Sample student names
      final studentNames = [
        'Alice Johnson',
        'Bob Smith',
        'Charlie Brown',
        'Diana Prince',
        'Edward Norton',
        'Fiona Green',
        'George Wilson',
        'Hannah Davis',
        'Ivan Peterson',
        'Julia Roberts',
        'Kevin Hart',
        'Luna Martinez',
        'Michael Johnson',
        'Natasha Romanoff',
        'Oliver Stone',
        'Priya Sharma',
        'Quinn Anderson',
        'Rachel Green',
        'Samuel Jackson',
        'Tina Turner',
      ];

      // Generate data for the past 7 days
      final now = DateTime.now();
      final records = <AttendanceRecord>[];

      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final targetDate = now.subtract(Duration(days: dayOffset));

        // Generate 10-15 random students per day
        final studentsToday =
            (studentNames..shuffle()).take(10 + (dayOffset % 6)).toList();

        for (final studentName in studentsToday) {
          // Arrival time: between 4:00 PM and 4:30 PM
          final arrivalTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            16, // 4 PM
            (dayOffset * 5 + studentName.hashCode.abs()) % 30, // 0-29 minutes
          );

          // Departure time: between 7:30 PM and 8:00 PM
          final departureTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            19, // 7 PM
            30 +
                (dayOffset * 3 + studentName.hashCode.abs()) %
                    30, // 30-59 minutes (7:30-7:59)
          ).add(
            Duration(minutes: (studentName.length % 2) * 30),
          ); // Some go to 8:00-8:30

          // Create arrival record
          records.add(
            AttendanceRecord(
              studentName: studentName,
              attendanceType: 'arrival',
              timestamp: arrivalTime,
              notes: dayOffset == 0 ? 'Debug data - today' : 'Debug data',
            ),
          );

          // Create departure record (all students have both arrival and departure)
          records.add(
            AttendanceRecord(
              studentName: studentName,
              attendanceType: 'departure',
              timestamp: departureTime,
              notes: dayOffset == 0 ? 'Debug data - today' : 'Debug data',
            ),
          );
        }
      }

      // Add all records to database
      for (final record in records) {
        await attendanceModel.addAttendanceRecord(record);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generated ${records.length} debug attendance records for the past 7 days (complete arrival/departure pairs)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate debug data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Export Data Option
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.file_download,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: const Text('Export Data'),
                subtitle: const Text('Export attendance records to CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showExportDialog,
              ),
            ),

            const SizedBox(height: 8),

            // Delete Data Option
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: const Icon(Icons.delete_sweep, color: Colors.red),
                ),
                title: const Text('Delete Data'),
                subtitle: const Text('Bulk delete attendance records'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showDeleteDialog,
              ),
            ),

            const SizedBox(height: 8),

            // WhatsApp Business Option
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  child: const Icon(Icons.message, color: Colors.green),
                ),
                title: const Text('WhatsApp Business'),
                subtitle: const Text('Configure message notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WhatsAppManagementScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Customize Option
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  child: const Icon(Icons.tune, color: Colors.purple),
                ),
                title: const Text('Customize'),
                subtitle: const Text('Personalize your app settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CustomizeScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Settings Option
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.settings,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                title: const Text('Settings'),
                subtitle: const Text('App information and preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),

            // Debug Option (only in debug mode)
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    child: const Icon(Icons.bug_report, color: Colors.orange),
                  ),
                  title: const Text('Debug: Generate Test Data'),
                  subtitle: const Text(
                    'Generate sample attendance for past 7 days (4-8 PM)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Generate Debug Data'),
                            content: const Text(
                              'This will generate sample attendance records for the past 7 days between 4 PM and 8 PM. This action cannot be undone.\n\nContinue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _generateDebugData();
                                },
                                child: const Text('Generate'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: const Icon(Icons.system_update, color: Colors.blue),
                  ),
                  title: const Text('Debug: Test Updates'),
                  subtitle: const Text('Test app update dialogs and flows'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DebugUpdateScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
