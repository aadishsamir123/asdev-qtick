class WhatsAppConfig {
  final int? id;
  final String apiKey;
  final String templateName;
  final String phoneNumberId;
  final String businessAccountId;
  final String languageCode;
  final bool arrivalNotificationsEnabled;
  final bool departureNotificationsEnabled;
  final List<String> arrivalTemplateVariables;
  final List<String> departureTemplateVariables;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhatsAppConfig({
    this.id,
    required this.apiKey,
    required this.templateName,
    required this.phoneNumberId,
    required this.businessAccountId,
    this.languageCode = 'en',
    this.arrivalNotificationsEnabled = true,
    this.departureNotificationsEnabled = true,
    this.arrivalTemplateVariables = const [],
    this.departureTemplateVariables = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'api_key': apiKey,
      'template_name': templateName,
      'phone_number_id': phoneNumberId,
      'business_account_id': businessAccountId,
      'language_code': languageCode,
      'arrival_notifications_enabled': arrivalNotificationsEnabled ? 1 : 0,
      'departure_notifications_enabled': departureNotificationsEnabled ? 1 : 0,
      'arrival_template_variables': arrivalTemplateVariables.join(','),
      'departure_template_variables': departureTemplateVariables.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WhatsAppConfig.fromMap(Map<String, dynamic> map) {
    return WhatsAppConfig(
      id: map['id'] as int?,
      apiKey: map['api_key'] as String,
      templateName: map['template_name'] as String,
      phoneNumberId: map['phone_number_id'] as String,
      businessAccountId: map['business_account_id'] as String,
      languageCode: (map['language_code'] as String?) ?? 'en',
      arrivalNotificationsEnabled:
          (map['arrival_notifications_enabled'] as int?) == 1,
      departureNotificationsEnabled:
          (map['departure_notifications_enabled'] as int?) == 1,
      arrivalTemplateVariables:
          (map['arrival_template_variables'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      departureTemplateVariables:
          (map['departure_template_variables'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  WhatsAppConfig copyWith({
    int? id,
    String? apiKey,
    String? templateName,
    String? phoneNumberId,
    String? businessAccountId,
    String? languageCode,
    bool? arrivalNotificationsEnabled,
    bool? departureNotificationsEnabled,
    List<String>? arrivalTemplateVariables,
    List<String>? departureTemplateVariables,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WhatsAppConfig(
      id: id ?? this.id,
      apiKey: apiKey ?? this.apiKey,
      templateName: templateName ?? this.templateName,
      phoneNumberId: phoneNumberId ?? this.phoneNumberId,
      businessAccountId: businessAccountId ?? this.businessAccountId,
      languageCode: languageCode ?? this.languageCode,
      arrivalNotificationsEnabled:
          arrivalNotificationsEnabled ?? this.arrivalNotificationsEnabled,
      departureNotificationsEnabled:
          departureNotificationsEnabled ?? this.departureNotificationsEnabled,
      arrivalTemplateVariables:
          arrivalTemplateVariables ?? this.arrivalTemplateVariables,
      departureTemplateVariables:
          departureTemplateVariables ?? this.departureTemplateVariables,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
