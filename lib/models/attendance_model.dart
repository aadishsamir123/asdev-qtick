import 'package:flutter/foundation.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:qr_attendance/services/database_service.dart';
import 'package:qr_attendance/services/export_service.dart';

class AttendanceModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAttendanceRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendanceRecords = await _databaseService.getAllAttendanceRecords();
    } catch (e) {
      _errorMessage = 'Failed to load attendance records: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAttendanceRecord(AttendanceRecord record) async {
    try {
      await _databaseService.insertAttendanceRecord(record);
      await loadAttendanceRecords(); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add attendance record: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAttendanceRecord(int id) async {
    try {
      await _databaseService.deleteAttendanceRecord(id);
      await loadAttendanceRecords(); // Refresh the list
    } catch (e) {
      _errorMessage = 'Failed to delete attendance record: $e';
      notifyListeners();
    }
  }

  List<AttendanceRecord> getFilteredRecords({
    String? studentName,
    String? attendanceType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _attendanceRecords.where((record) {
      bool matchesName =
          studentName == null ||
          record.studentName.toLowerCase().contains(studentName.toLowerCase());

      bool matchesType =
          attendanceType == null || record.attendanceType == attendanceType;

      bool matchesStartDate =
          startDate == null ||
          record.timestamp.isAfter(startDate.subtract(const Duration(days: 1)));

      bool matchesEndDate =
          endDate == null ||
          record.timestamp.isBefore(endDate.add(const Duration(days: 1)));

      return matchesName && matchesType && matchesStartDate && matchesEndDate;
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Export attendance records to CSV and open share menu
  Future<void> exportToCsv({
    DateTime? startDate,
    DateTime? endDate,
    String centerName = 'Learning Center',
  }) async {
    try {
      final filteredRecords = getFilteredRecords(
        startDate: startDate,
        endDate: endDate,
      );

      await ExportService.exportAndSave(
        records: filteredRecords,
        startDate: startDate,
        endDate: endDate,
        centerName: centerName,
      );
    } catch (e) {
      _errorMessage = 'Failed to export data: $e';
      notifyListeners();
      rethrow;
    }
  }
}
