import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:qr_attendance/models/attendance_record.dart';
import 'package:qr_attendance/models/whatsapp_config.dart';
import 'package:qr_attendance/models/student_contact.dart';
import 'package:qr_attendance/models/message_log.dart';

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
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
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

    // WhatsApp configuration table
    await db.execute('''
      CREATE TABLE whatsapp_config(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_key TEXT NOT NULL,
        template_name TEXT NOT NULL,
        phone_number_id TEXT NOT NULL,
        business_account_id TEXT NOT NULL,
        language_code TEXT DEFAULT 'en',
        arrival_notifications_enabled INTEGER DEFAULT 1,
        departure_notifications_enabled INTEGER DEFAULT 1,
        arrival_template_variables TEXT DEFAULT '',
        departure_template_variables TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Student contacts table
    await db.execute('''
      CREATE TABLE student_contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Message logs table
    await db.execute('''
      CREATE TABLE message_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        message_type TEXT NOT NULL,
        message_content TEXT NOT NULL,
        status TEXT NOT NULL,
        error_message TEXT,
        whatsapp_message_id TEXT,
        timestamp TEXT NOT NULL,
        delivered_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add WhatsApp tables for version 2
      await db.execute('''
        CREATE TABLE whatsapp_config(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          api_key TEXT NOT NULL,
          template_name TEXT NOT NULL,
          phone_number_id TEXT NOT NULL,
          business_account_id TEXT NOT NULL,
          language_code TEXT DEFAULT 'en',
          arrival_notifications_enabled INTEGER DEFAULT 1,
          departure_notifications_enabled INTEGER DEFAULT 1,
          arrival_template_variables TEXT DEFAULT '',
          departure_template_variables TEXT DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE student_contacts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_name TEXT NOT NULL,
          phone_number TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE message_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_name TEXT NOT NULL,
          phone_number TEXT NOT NULL,
          message_type TEXT NOT NULL,
          message_content TEXT NOT NULL,
          status TEXT NOT NULL,
          error_message TEXT,
          whatsapp_message_id TEXT,
          timestamp TEXT NOT NULL,
          delivered_at TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add language_code field for version 3
      await db.execute('''
        ALTER TABLE whatsapp_config 
        ADD COLUMN language_code TEXT DEFAULT 'en'
      ''');
    }

    if (oldVersion < 4) {
      // Replace message template fields with variable configuration fields for version 4
      await db.execute('''
        ALTER TABLE whatsapp_config 
        ADD COLUMN arrival_template_variables TEXT DEFAULT ''
      ''');

      await db.execute('''
        ALTER TABLE whatsapp_config 
        ADD COLUMN departure_template_variables TEXT DEFAULT ''
      ''');

      // Drop old template columns if they exist
      // Note: SQLite doesn't support DROP COLUMN, so we recreate the table
      await db.execute('''
        CREATE TABLE whatsapp_config_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          api_key TEXT NOT NULL,
          template_name TEXT NOT NULL,
          phone_number_id TEXT NOT NULL,
          business_account_id TEXT NOT NULL,
          language_code TEXT DEFAULT 'en',
          arrival_notifications_enabled INTEGER DEFAULT 1,
          departure_notifications_enabled INTEGER DEFAULT 1,
          arrival_template_variables TEXT DEFAULT '',
          departure_template_variables TEXT DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Copy data from old table to new table
      await db.execute('''
        INSERT INTO whatsapp_config_new 
        (id, api_key, template_name, phone_number_id, business_account_id, language_code, 
         arrival_notifications_enabled, departure_notifications_enabled, 
         arrival_template_variables, departure_template_variables, created_at, updated_at)
        SELECT id, api_key, template_name, phone_number_id, business_account_id, language_code,
               arrival_notifications_enabled, departure_notifications_enabled,
               '', '', created_at, updated_at
        FROM whatsapp_config
      ''');

      // Drop old table and rename new table
      await db.execute('DROP TABLE whatsapp_config');
      await db.execute(
        'ALTER TABLE whatsapp_config_new RENAME TO whatsapp_config',
      );
    }
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

  // WhatsApp Configuration methods
  Future<int> insertWhatsAppConfig(WhatsAppConfig config) async {
    final db = await database;
    return await db.insert('whatsapp_config', config.toMap());
  }

  Future<WhatsAppConfig?> getWhatsAppConfig() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'whatsapp_config',
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return WhatsAppConfig.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWhatsAppConfig(WhatsAppConfig config) async {
    final db = await database;
    return await db.update(
      'whatsapp_config',
      config.toMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  Future<int> deleteWhatsAppConfig(int id) async {
    final db = await database;
    return await db.delete('whatsapp_config', where: 'id = ?', whereArgs: [id]);
  }

  // Student Contacts methods
  Future<int> insertStudentContact(StudentContact contact) async {
    final db = await database;
    return await db.insert('student_contacts', contact.toMap());
  }

  /// Insert or update contact (handles duplicates by overwriting)
  Future<int> insertOrUpdateStudentContact(StudentContact contact) async {
    final db = await database;

    // Check if contact with same name exists
    final existing = await db.query(
      'student_contacts',
      where: 'LOWER(student_name) = LOWER(?)',
      whereArgs: [contact.studentName.trim()],
    );

    if (existing.isNotEmpty) {
      // Update existing contact
      return await db.update(
        'student_contacts',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Insert new contact
      return await db.insert('student_contacts', contact.toMap());
    }
  }

  /// Update student contact
  Future<int> updateStudentContact(StudentContact contact) async {
    final db = await database;
    return await db.update(
      'student_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// Delete student contact
  Future<int> deleteStudentContact(int id) async {
    final db = await database;
    return await db.delete(
      'student_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all student contacts
  Future<List<StudentContact>> getAllStudentContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'student_contacts',
      orderBy: 'student_name ASC',
    );

    return List.generate(maps.length, (i) {
      return StudentContact.fromMap(maps[i]);
    });
  }

  /// Clear all student contacts
  Future<void> clearAllStudentContacts() async {
    final db = await database;
    await db.delete('student_contacts');
  }

  /// Get active student contacts
  Future<List<StudentContact>> getActiveStudentContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'student_contacts',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'student_name ASC',
    );

    return List.generate(maps.length, (i) {
      return StudentContact.fromMap(maps[i]);
    });
  }

  /// Bulk insert student contacts
  Future<int> bulkInsertStudentContacts(List<StudentContact> contacts) async {
    int successCount = 0;

    for (final contact in contacts) {
      try {
        await insertOrUpdateStudentContact(contact);
        successCount++;
      } catch (e) {
        // Continue with other contacts even if one fails
        continue;
      }
    }

    return successCount;
  }

  // Message Logs methods
  Future<int> insertMessageLog(MessageLog log) async {
    final db = await database;
    return await db.insert('message_logs', log.toMap());
  }

  Future<List<MessageLog>> getAllMessageLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'message_logs',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return MessageLog.fromMap(maps[i]);
    });
  }

  Future<List<MessageLog>> getMessageLogsByStatus(MessageStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'message_logs',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return MessageLog.fromMap(maps[i]);
    });
  }

  Future<List<MessageLog>> getMessageLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'message_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return MessageLog.fromMap(maps[i]);
    });
  }

  Future<int> updateMessageLog(MessageLog log) async {
    final db = await database;
    return await db.update(
      'message_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteMessageLog(int id) async {
    final db = await database;
    return await db.delete('message_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllMessageLogs() async {
    final db = await database;
    await db.delete('message_logs');
  }
}
