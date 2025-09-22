class AttendanceRecord {
  final int? id;
  final String studentName;
  final String attendanceType; // 'arrival' or 'departure'
  final DateTime timestamp;
  final String? notes;

  AttendanceRecord({
    this.id,
    required this.studentName,
    required this.attendanceType,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_name': studentName,
      'attendance_type': attendanceType,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      studentName: map['student_name'],
      attendanceType: map['attendance_type'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord{id: $id, studentName: $studentName, attendanceType: $attendanceType, timestamp: $timestamp, notes: $notes}';
  }

  AttendanceRecord copyWith({
    int? id,
    String? studentName,
    String? attendanceType,
    DateTime? timestamp,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      attendanceType: attendanceType ?? this.attendanceType,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}
