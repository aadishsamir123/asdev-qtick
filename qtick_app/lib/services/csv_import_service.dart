import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student_contact.dart';

class CsvImportResult {
  final List<StudentContact> successfulImports;
  final List<String> errors;
  final int totalRows;

  CsvImportResult({
    required this.successfulImports,
    required this.errors,
    required this.totalRows,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => successfulImports.length;
  int get errorCount => errors.length;
}

class CsvImportService {
  static const List<String> requiredColumns = ['studentName', 'phoneNumber'];
  static const List<String> alternativeColumns = [
    'student_name',
    'phone_number',
  ];

  /// Pick and import CSV file
  static Future<CsvImportResult?> pickAndImportCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await importCsvFromFile(file);
      }
      return null;
    } catch (e) {
      return CsvImportResult(
        successfulImports: [],
        errors: ['Error picking file: $e'],
        totalRows: 0,
      );
    }
  }

  /// Import CSV from file
  static Future<CsvImportResult> importCsvFromFile(File file) async {
    try {
      final input = await file.readAsString();
      return _parseCsvContent(input);
    } catch (e) {
      return CsvImportResult(
        successfulImports: [],
        errors: ['Error reading file: $e'],
        totalRows: 0,
      );
    }
  }

  /// Import CSV from string content
  static CsvImportResult importCsvFromString(String csvContent) {
    return _parseCsvContent(csvContent);
  }

  /// Validate CSV file and return preview
  static Future<CsvValidationResult?> validateCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final input = await file.readAsString();
        return _validateCsvContent(input);
      }
      return null;
    } catch (e) {
      return CsvValidationResult(
        isValid: false,
        errors: ['Error validating file: $e'],
        headers: [],
        previewRows: [],
        totalRows: 0,
      );
    }
  }

  static CsvImportResult _parseCsvContent(String csvContent) {
    final List<StudentContact> successfulImports = [];
    final List<String> errors = [];

    try {
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvContent,
      );

      if (csvTable.isEmpty) {
        return CsvImportResult(
          successfulImports: [],
          errors: ['CSV file is empty'],
          totalRows: 0,
        );
      }

      // Get headers and normalize them
      final List<String> headers =
          csvTable[0].map((e) => e.toString().trim()).toList();
      final Map<String, int> columnMapping = _getColumnMapping(headers);

      if (columnMapping.isEmpty) {
        return CsvImportResult(
          successfulImports: [],
          errors: [
            'Required columns not found. Expected: studentName, phoneNumber',
          ],
          totalRows: csvTable.length,
        );
      }

      // Process data rows
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        try {
          final studentContact = _parseRow(row, columnMapping, i + 1);
          if (studentContact != null) {
            successfulImports.add(studentContact);
          }
        } catch (e) {
          errors.add('Row ${i + 1}: $e');
        }
      }

      return CsvImportResult(
        successfulImports: successfulImports,
        errors: errors,
        totalRows: csvTable.length,
      );
    } catch (e) {
      return CsvImportResult(
        successfulImports: [],
        errors: ['Error parsing CSV: $e'],
        totalRows: 0,
      );
    }
  }

  static CsvValidationResult _validateCsvContent(String csvContent) {
    try {
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvContent,
      );

      if (csvTable.isEmpty) {
        return CsvValidationResult(
          isValid: false,
          errors: ['CSV file is empty'],
          headers: [],
          previewRows: [],
          totalRows: 0,
        );
      }

      final List<String> headers =
          csvTable[0].map((e) => e.toString().trim()).toList();
      final Map<String, int> columnMapping = _getColumnMapping(headers);
      final List<String> errors = [];

      if (columnMapping.isEmpty) {
        errors.add(
          'Required columns not found. Expected: studentName, phoneNumber',
        );
      }

      // Get preview rows (first 5 data rows)
      final List<Map<String, dynamic>> previewRows = [];
      final int previewCount = csvTable.length > 6 ? 6 : csvTable.length;

      for (int i = 1; i < previewCount; i++) {
        final row = csvTable[i];
        final Map<String, dynamic> rowData = {};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          rowData[headers[j]] = row[j].toString();
        }
        previewRows.add(rowData);
      }

      return CsvValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        headers: headers,
        previewRows: previewRows,
        totalRows: csvTable.length - 1, // Exclude header row
      );
    } catch (e) {
      return CsvValidationResult(
        isValid: false,
        errors: ['Error validating CSV: $e'],
        headers: [],
        previewRows: [],
        totalRows: 0,
      );
    }
  }

  static Map<String, int> _getColumnMapping(List<String> headers) {
    final Map<String, int> mapping = {};

    // Look for studentName column
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase().replaceAll(' ', '');
      if (header == 'studentname' ||
          header == 'student_name' ||
          header == 'name') {
        mapping['studentName'] = i;
        break;
      }
    }

    // Look for phoneNumber column
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase().replaceAll(' ', '');
      if (header == 'phonenumber' ||
          header == 'phone_number' ||
          header == 'phone' ||
          header == 'mobile') {
        mapping['phoneNumber'] = i;
        break;
      }
    }

    return mapping.length == 2 ? mapping : {};
  }

  static StudentContact? _parseRow(
    List<dynamic> row,
    Map<String, int> columnMapping,
    int rowNumber,
  ) {
    final studentNameIndex = columnMapping['studentName']!;
    final phoneNumberIndex = columnMapping['phoneNumber']!;

    if (row.length <= studentNameIndex || row.length <= phoneNumberIndex) {
      throw 'Insufficient columns in row';
    }

    final studentName = row[studentNameIndex].toString().trim();
    final phoneNumber = row[phoneNumberIndex].toString().trim();

    if (studentName.isEmpty) {
      throw 'Student name is empty';
    }

    if (phoneNumber.isEmpty) {
      throw 'Phone number is empty';
    }

    // Basic phone number validation
    if (!_isValidPhoneNumber(phoneNumber)) {
      throw 'Invalid phone number format: $phoneNumber';
    }

    final now = DateTime.now();
    return StudentContact(
      studentName: studentName,
      phoneNumber: _normalizePhoneNumber(phoneNumber),
      createdAt: now,
      updatedAt: now,
    );
  }

  static bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters for validation
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Phone number should have at least 10 digits
    return digitsOnly.length >= 10;
  }

  static String _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it doesn't start with +, add country code if needed
    if (!normalized.startsWith('+')) {
      // Add + if number is long enough to potentially have country code
      if (normalized.length > 10) {
        normalized = '+$normalized';
      }
    }

    return normalized;
  }
}

class CsvValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> headers;
  final List<Map<String, dynamic>> previewRows;
  final int totalRows;

  CsvValidationResult({
    required this.isValid,
    required this.errors,
    required this.headers,
    required this.previewRows,
    required this.totalRows,
  });
}
