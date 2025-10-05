import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/whatsapp_config.dart';
import '../models/message_log.dart';
import '../models/student_contact.dart';
import '../models/attendance_record.dart';

class WhatsAppBusinessService {
  static const String baseUrl = 'https://graph.facebook.com/v17.0';

  /// Send a WhatsApp message using Business API
  static Future<MessageLog> sendMessage({
    required WhatsAppConfig config,
    required StudentContact contact,
    required String messageType,
    Map<String, String>? templateVariables,
  }) async {
    final messageLog = MessageLog(
      studentName: contact.studentName,
      phoneNumber: contact.phoneNumber,
      messageType: messageType,
      messageContent: _buildMessageContent(
        config,
        messageType,
        templateVariables,
      ),
      timestamp: DateTime.now(),
    );

    try {
      final response = await _sendWhatsAppMessage(
        config: config,
        phoneNumber: contact.phoneNumber,
        messageType: messageType,
        templateVariables: templateVariables ?? {},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final messageId = responseData['messages']?[0]?['id'];

        return messageLog.copyWith(
          status: MessageStatus.sent,
          whatsappMessageId: messageId,
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';

        return messageLog.copyWith(
          status: MessageStatus.failed,
          errorMessage: 'HTTP ${response.statusCode}: $errorMessage',
        );
      }
    } catch (e) {
      return messageLog.copyWith(
        status: MessageStatus.failed,
        errorMessage: 'Exception: $e',
      );
    }
  }

  /// Send attendance notification
  static Future<MessageLog?> sendAttendanceNotification({
    required WhatsAppConfig config,
    required AttendanceRecord attendanceRecord,
    required List<StudentContact> contacts,
  }) async {
    // Find matching contact for the student
    final contact = contacts.firstWhere(
      (c) =>
          c.studentName.toLowerCase().trim() ==
              attendanceRecord.studentName.toLowerCase().trim() &&
          c.isActive,
      orElse:
          () => StudentContact(
            studentName: '',
            phoneNumber: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    // If no contact found, return null (no message to send)
    if (contact.studentName.isEmpty) {
      return null;
    }

    // Check if notifications are enabled for this type
    final isArrival =
        attendanceRecord.attendanceType.toLowerCase() == 'arrival';
    final isDeparture =
        attendanceRecord.attendanceType.toLowerCase() == 'departure';

    if ((isArrival && !config.arrivalNotificationsEnabled) ||
        (isDeparture && !config.departureNotificationsEnabled)) {
      return null;
    }

    // Prepare template variables
    final templateVariables = {
      'student_name': attendanceRecord.studentName,
      'attendance_type': attendanceRecord.attendanceType,
      'timestamp': _formatDateTime(attendanceRecord.timestamp),
      'date': _formatDate(attendanceRecord.timestamp),
      'time': _formatTime(attendanceRecord.timestamp),
    };

    return await sendMessage(
      config: config,
      contact: contact,
      messageType: attendanceRecord.attendanceType,
      templateVariables: templateVariables,
    );
  }

  /// Validate WhatsApp Business API configuration
  static Future<bool> validateConfiguration(WhatsAppConfig config) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/${config.phoneNumberId}'),
        headers: {'Authorization': 'Bearer ${config.apiKey}'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Test message sending with a simple test message
  static Future<MessageLog> sendTestMessage({
    required WhatsAppConfig config,
    required String testPhoneNumber,
  }) async {
    final testContact = StudentContact(
      studentName: 'Test Student',
      phoneNumber: testPhoneNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await sendMessage(
      config: config,
      contact: testContact,
      messageType: 'test',
      templateVariables: {
        'student_name': 'Test Student',
        'test_message': 'This is a test message from QTick app',
      },
    );
  }

  static Future<http.Response> _sendWhatsAppMessage({
    required WhatsAppConfig config,
    required String phoneNumber,
    required String messageType,
    required Map<String, String> templateVariables,
  }) async {
    final url = '$baseUrl/${config.phoneNumberId}/messages';

    final headers = {
      'Authorization': 'Bearer ${config.apiKey}',
      'Content-Type': 'application/json',
    };

    // Get the configured variables for this message type
    final configuredVariables =
        messageType.toLowerCase() == 'arrival' ||
                messageType.toLowerCase().contains('arrival')
            ? config.arrivalTemplateVariables
            : config.departureTemplateVariables;

    final body = {
      'messaging_product': 'whatsapp',
      'to': phoneNumber,
      'type': 'template',
      'template': {
        'name': config.templateName,
        'language': {'code': config.languageCode},
        'components': [
          {
            'type': 'body',
            'parameters': _buildTemplateParameters(
              configuredVariables,
              templateVariables,
            ),
          },
        ],
      },
    };

    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
  }

  static List<Map<String, String>> _buildTemplateParameters(
    List<String> configuredVariables,
    Map<String, String> availableData,
  ) {
    return configuredVariables
        .map(
          (variableType) => {
            'type': 'text',
            'text': _getVariableValue(variableType, availableData),
          },
        )
        .toList();
  }

  static String _getVariableValue(
    String variableType,
    Map<String, String> data,
  ) {
    switch (variableType.toLowerCase()) {
      case 'student_name':
      case 'name':
        return data['student_name'] ?? '';
      case 'time':
        return data['time'] ?? '';
      case 'date':
        return data['date'] ?? '';
      case 'datetime':
      case 'timestamp':
        return data['timestamp'] ?? '';
      case 'attendance_type':
      case 'type':
        return data['attendance_type'] ?? '';
      default:
        return data[variableType] ?? '';
    }
  }

  static String _buildMessageContent(
    WhatsAppConfig config,
    String messageType,
    Map<String, String>? templateVariables,
  ) {
    // Since we're using WhatsApp Business API templates,
    // the message content is just for logging purposes
    final configuredVariables =
        messageType.toLowerCase() == 'arrival' ||
                messageType.toLowerCase().contains('arrival')
            ? config.arrivalTemplateVariables
            : config.departureTemplateVariables;

    final values = configuredVariables
        .map((variable) => _getVariableValue(variable, templateVariables ?? {}))
        .join(', ');

    return 'Template: ${config.templateName}, Variables: $values';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  static String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  /// Get delivery status of a message
  static Future<MessageStatus> getMessageStatus({
    required WhatsAppConfig config,
    required String messageId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$messageId'),
        headers: {'Authorization': 'Bearer ${config.apiKey}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        switch (status) {
          case 'sent':
            return MessageStatus.sent;
          case 'delivered':
            return MessageStatus.delivered;
          case 'failed':
            return MessageStatus.failed;
          default:
            return MessageStatus.pending;
        }
      }

      return MessageStatus.failed;
    } catch (e) {
      return MessageStatus.failed;
    }
  }
}
