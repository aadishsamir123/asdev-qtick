class StudentContact {
  final int? id;
  final String studentName;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentContact({
    this.id,
    required this.studentName,
    required this.phoneNumber,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_name': studentName,
      'phone_number': phoneNumber,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentContact.fromMap(Map<String, dynamic> map) {
    return StudentContact(
      id: map['id'],
      studentName: map['student_name'],
      phoneNumber: map['phone_number'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory StudentContact.fromCsv(Map<String, dynamic> csvRow) {
    final now = DateTime.now();
    return StudentContact(
      studentName: csvRow['studentName'] ?? csvRow['student_name'] ?? '',
      phoneNumber: csvRow['phoneNumber'] ?? csvRow['phone_number'] ?? '',
      createdAt: now,
      updatedAt: now,
    );
  }

  StudentContact copyWith({
    int? id,
    String? studentName,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentContact(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StudentContact{id: $id, studentName: $studentName, phoneNumber: $phoneNumber, isActive: $isActive}';
  }
}
