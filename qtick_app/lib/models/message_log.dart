enum MessageStatus { pending, sent, failed, delivered }

class MessageLog {
  final int? id;
  final String studentName;
  final String phoneNumber;
  final String messageType; // 'arrival' or 'departure'
  final String messageContent;
  final MessageStatus status;
  final String? errorMessage;
  final String? whatsappMessageId;
  final DateTime timestamp;
  final DateTime? deliveredAt;

  MessageLog({
    this.id,
    required this.studentName,
    required this.phoneNumber,
    required this.messageType,
    required this.messageContent,
    this.status = MessageStatus.pending,
    this.errorMessage,
    this.whatsappMessageId,
    required this.timestamp,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_name': studentName,
      'phone_number': phoneNumber,
      'message_type': messageType,
      'message_content': messageContent,
      'status': status.name,
      'error_message': errorMessage,
      'whatsapp_message_id': whatsappMessageId,
      'timestamp': timestamp.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  factory MessageLog.fromMap(Map<String, dynamic> map) {
    return MessageLog(
      id: map['id'],
      studentName: map['student_name'],
      phoneNumber: map['phone_number'],
      messageType: map['message_type'],
      messageContent: map['message_content'],
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.pending,
      ),
      errorMessage: map['error_message'],
      whatsappMessageId: map['whatsapp_message_id'],
      timestamp: DateTime.parse(map['timestamp']),
      deliveredAt:
          map['delivered_at'] != null
              ? DateTime.parse(map['delivered_at'])
              : null,
    );
  }

  MessageLog copyWith({
    int? id,
    String? studentName,
    String? phoneNumber,
    String? messageType,
    String? messageContent,
    MessageStatus? status,
    String? errorMessage,
    String? whatsappMessageId,
    DateTime? timestamp,
    DateTime? deliveredAt,
  }) {
    return MessageLog(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      messageType: messageType ?? this.messageType,
      messageContent: messageContent ?? this.messageContent,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      whatsappMessageId: whatsappMessageId ?? this.whatsappMessageId,
      timestamp: timestamp ?? this.timestamp,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  bool get isSuccessful =>
      status == MessageStatus.sent || status == MessageStatus.delivered;
  bool get isFailed => status == MessageStatus.failed;

  @override
  String toString() {
    return 'MessageLog{id: $id, studentName: $studentName, phoneNumber: $phoneNumber, messageType: $messageType, status: $status}';
  }
}
