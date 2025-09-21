import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:qr_attendance/models/attendance_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        attendance_type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<int> insertAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.insert('attendance_records', record.toMap());
  }

  Future<List<AttendanceRecord>> getAllAttendanceRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByStudent(
    String studentName,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'student_name = ?',
      whereArgs: [studentName],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'attendance_type = ?',
      whereArgs: [type],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceRecord.fromMap(maps[i]);
    });
  }

  Future<int> updateAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.update(
      'attendance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteAttendanceRecord(int id) async {
    final db = await database;
    return await db.delete(
      'attendance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete('attendance_records');
  }

  Future<List<String>> getAllStudentNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      columns: ['student_name'],
      distinct: true,
      orderBy: 'student_name ASC',
    );

    return maps.map((map) => map['student_name'] as String).toList();
  }
}
