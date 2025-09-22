import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:intl/intl.dart';

class ExportService {
  /// Export attendance data to CSV format
  static Future<String> exportToCsv({
    required List<AttendanceRecord> records,
    required DateTime? startDate,
    required DateTime? endDate,
    String centerName = 'Learning Center',
  }) async {
    // Filter records based on date range
    List<AttendanceRecord> filteredRecords = records;

    if (startDate != null || endDate != null) {
      filteredRecords =
          records.where((record) {
            final recordDate = DateTime(
              record.timestamp.year,
              record.timestamp.month,
              record.timestamp.day,
            );

            bool isAfterStart = true;
            bool isBeforeEnd = true;

            if (startDate != null) {
              final startOfDay = DateTime(
                startDate.year,
                startDate.month,
                startDate.day,
              );
              isAfterStart =
                  recordDate.isAtSameMomentAs(startOfDay) ||
                  recordDate.isAfter(startOfDay);
            }

            if (endDate != null) {
              final endOfDay = DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
              );
              isBeforeEnd =
                  recordDate.isAtSameMomentAs(endOfDay) ||
                  recordDate.isBefore(endOfDay);
            }

            return isAfterStart && isBeforeEnd;
          }).toList();
    }

    // Group records by student and date to calculate study minutes
    final Map<String, Map<String, AttendanceData>> studentData = {};

    for (final record in filteredRecords) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);

      studentData.putIfAbsent(record.studentName, () => {});
      studentData[record.studentName]!.putIfAbsent(
        dateKey,
        () => AttendanceData(),
      );

      final attendanceData = studentData[record.studentName]![dateKey]!;

      if (record.attendanceType == 'arrival') {
        attendanceData.arrivalTime = record.timestamp;
      } else if (record.attendanceType == 'departure') {
        attendanceData.departureTime = record.timestamp;
      }
    }

    // Prepare CSV data with metadata header
    final List<List<String>> csvData = [];

    // Add metadata header
    final now = DateTime.now();
    final exportDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final totalStudents = studentData.keys.length;
    final totalRecords = filteredRecords.length;

    // Date range info
    String dateRangeInfo;
    if (startDate != null && endDate != null) {
      final startStr = DateFormat('dd/MM/yyyy').format(startDate);
      final endStr = DateFormat('dd/MM/yyyy').format(endDate);
      dateRangeInfo = '$startStr to $endStr';
    } else if (startDate != null) {
      final dateStr = DateFormat('dd/MM/yyyy').format(startDate);
      dateRangeInfo = 'Date: $dateStr';
    } else {
      dateRangeInfo = 'Date Range: All records';
    }

    // Add metadata rows
    csvData.addAll([
      ['QTICK ATTENDANCE EXPORT REPORT'],
      [''],
      ['Export Information:'],
      ['Centre Name:', centerName],
      ['Generated On:', exportDate],
      ['Date Range:', dateRangeInfo],
      ['Total Students:', totalStudents.toString()],
      ['Total Records:', totalRecords.toString()],
      [''],
      ['Attendance Data:'],
      [
        'Student Name',
        'Date',
        'Arrival Time',
        'Departure Time',
        'Study Minutes',
      ],
    ]);

    // Sort students alphabetically
    final sortedStudents = studentData.keys.toList()..sort();

    for (final studentName in sortedStudents) {
      final studentAttendance = studentData[studentName]!;

      // Sort dates
      final sortedDates = studentAttendance.keys.toList()..sort();

      for (final dateKey in sortedDates) {
        final attendanceData = studentAttendance[dateKey]!;

        final arrivalTimeStr =
            attendanceData.arrivalTime != null
                ? DateFormat('HH:mm').format(attendanceData.arrivalTime!)
                : '-';

        final departureTimeStr =
            attendanceData.departureTime != null
                ? DateFormat('HH:mm').format(attendanceData.departureTime!)
                : '-';

        final studyMinutes = attendanceData.calculateStudyMinutes();
        final studyMinutesStr =
            studyMinutes > 0 ? studyMinutes.toString() : '-';

        csvData.add([
          studentName,
          dateKey,
          arrivalTimeStr,
          departureTimeStr,
          studyMinutesStr,
        ]);
      }
    }

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);
    return csvString;
  }

  /// Export and share CSV data using Android share menu
  static Future<void> exportAndSave({
    required List<AttendanceRecord> records,
    required DateTime? startDate,
    required DateTime? endDate,
    String centerName = 'Learning Center',
  }) async {
    try {
      final csvString = await exportToCsv(
        records: records,
        startDate: startDate,
        endDate: endDate,
        centerName: centerName,
      );

      // Create filename with date range
      String filename = 'attendance_export';
      if (startDate != null && endDate != null) {
        final startStr = DateFormat('yyyy-MM-dd').format(startDate);
        final endStr = DateFormat('yyyy-MM-dd').format(endDate);
        filename = 'attendance_${startStr}_to_$endStr';
      } else if (startDate != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(startDate);
        filename = 'attendance_$dateStr';
      } else {
        final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        filename = 'attendance_export_$dateStr';
      }
      filename += '.csv';

      // Create temporary file for sharing
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsString(csvString);

      debugPrint('Export Service: File created at ${file.path}');
      debugPrint('Export Service: File exists: ${await file.exists()}');
      debugPrint('Export Service: File size: ${await file.length()} bytes');

      // Share the file using Android share menu
      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Attendance Export - $filename');

      debugPrint('Export Service: Share result: $result');
    } catch (e) {
      debugPrint('Export Service Error: $e');
      throw Exception('Failed to export data: $e');
    }
  }

  /// Save CSV data to file and share it (legacy method)
  static Future<void> exportAndShare({
    required List<AttendanceRecord> records,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    // This method now just calls exportAndSave since it does the same thing
    await exportAndSave(
      records: records,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Helper class to store attendance data for a student on a specific date
class AttendanceData {
  DateTime? arrivalTime;
  DateTime? departureTime;

  /// Calculate study minutes between arrival and departure
  int calculateStudyMinutes() {
    if (arrivalTime != null && departureTime != null) {
      final duration = departureTime!.difference(arrivalTime!);
      return duration.inMinutes;
    }
    return 0;
  }
}
