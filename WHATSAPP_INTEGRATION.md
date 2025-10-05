# WhatsApp Business Integration for QTick Attendance App

## Overview

The QTick attendance app now includes WhatsApp Business integration that automatically sends notification messages to students and their parents/guardians when attendance is recorded (arrival or departure).

## Features

### 🔧 **Configuration Management**

- Configure WhatsApp Business API credentials
- Set up custom message templates for arrivals and departures
- Enable/disable notifications by type (arrival/departure)
- Test configuration with sample messages

### 📋 **Contact Management**

- Import student contacts from CSV files
- Support for multiple CSV formats (studentName/student_name, phoneNumber/phone_number)
- Automatic phone number validation and normalization
- Preview CSV data before importing
- Manage existing contacts

### 📊 **Message Logging**

- View all sent messages with delivery status
- Filter logs by status (sent, failed, delivered, pending)
- Search logs by student name or phone number
- Detailed error messages for failed deliveries
- Export logs for reporting

### 🔄 **Automatic Integration**

- Seamless integration with existing QR attendance system
- Automatic message sending when students scan QR codes
- Student name matching with contact database
- Graceful error handling (attendance recording continues even if messaging fails)

## Setup Instructions

### 1. WhatsApp Business API Setup

Before configuring the app, you need:

1. **WhatsApp Business Account**: Set up a WhatsApp Business account
2. **Facebook Developer Account**: Create a Facebook Developer account
3. **WhatsApp Business API Access**: Apply for WhatsApp Business API access
4. **Message Templates**: Create and get approval for message templates

Required information:

- API Key (Bearer token)
- Phone Number ID
- Business Account ID
- Approved template name

### 2. App Configuration

1. **Navigate to WhatsApp Business Settings**:

   - Open QTick app
   - Go to "More Options" → "WhatsApp Business"

2. **Configure API Settings**:

   - Tap "API Configuration"
   - Enter your WhatsApp Business API credentials:
     - API Key
     - Template Name
     - Phone Number ID
     - Business Account ID

3. **Set Message Templates**:

   - Configure arrival message template
   - Configure departure message template
   - Use variables: `{{student_name}}`, `{{time}}`, `{{date}}`, `{{attendance_type}}`

4. **Test Configuration**:
   - Use the test feature to send a sample message
   - Verify API connectivity and template functionality

### 3. Import Student Contacts

1. **Prepare CSV File**:

   ```csv
   studentName,phoneNumber
   John Doe,+1234567890
   Jane Smith,+0987654321
   ```

2. **Import Process**:
   - Go to "Import Contacts"
   - Tap "Preview CSV" to validate your file first
   - Tap "Import CSV" to add contacts to the database
   - Review import results and fix any errors

### 4. Enable Notifications

1. **Configure Notification Types**:

   - In API Configuration, toggle arrival/departure notifications
   - Arrival notifications: sent when students arrive
   - Departure notifications: sent when students leave

2. **Test the Flow**:
   - Have a student scan their QR code
   - Check message logs to verify delivery
   - Verify the student/parent receives the message

## Usage

### Daily Operation

1. **Students Scan QR Codes**: Normal attendance process continues unchanged
2. **Automatic Messaging**: If student has a matching contact, WhatsApp message is sent
3. **Log Monitoring**: Check message logs periodically for delivery status

### Message Templates

**Default Templates**:

- Arrival: "Hello {{student_name}}, your arrival has been recorded at {{time}} on {{date}}."
- Departure: "Hello {{student_name}}, your departure has been recorded at {{time}} on {{date}}."

**Available Variables**:

- `{{student_name}}` - Student's full name
- `{{time}}` - Time of attendance (e.g., "2:30 PM")
- `{{date}}` - Date of attendance (e.g., "Oct 5, 2025")
- `{{attendance_type}}` - "arrival" or "departure"

### Troubleshooting

#### Common Issues

1. **Messages Not Sending**:

   - Check API configuration is correct
   - Verify template is approved by WhatsApp
   - Check student name matches exactly between QR code and contact list
   - Review message logs for specific error messages

2. **CSV Import Failures**:

   - Ensure CSV has required columns (studentName, phoneNumber)
   - Check phone number format (include country code)
   - Verify no empty fields in required columns

3. **Student Not Found**:
   - Student names must match exactly (case-insensitive)
   - Check student name spelling in both QR code and contact list
   - Ensure contact is marked as active

#### Error Messages

- **"Student not found"**: No matching contact for the student name
- **"Invalid phone number"**: Phone number format is incorrect
- **"Template not approved"**: WhatsApp template needs approval
- **"Invalid API key"**: WhatsApp Business API credentials are incorrect

### Message Log Status Meanings

- **Pending**: Message queued for sending
- **Sent**: Message sent to WhatsApp API successfully
- **Delivered**: WhatsApp confirmed message delivery
- **Failed**: Message sending failed (check error message)

## Technical Implementation

### Architecture

```
QR Scanner → Attendance Model → WhatsApp Service → Database Logging
                ↓
Student Contact Matching → Message Sending → Status Tracking
```

### Database Tables

1. **whatsapp_config**: API configuration and settings
2. **student_contacts**: Student name to phone number mapping
3. **message_logs**: All sent messages with status and timestamps

### Error Handling

- Attendance recording is never blocked by messaging failures
- All errors are logged for troubleshooting
- Graceful degradation when WhatsApp is unavailable

## Security Considerations

1. **API Key Storage**: API keys are stored locally in the device database
2. **Phone Number Privacy**: Phone numbers are only used for messaging
3. **Data Retention**: Message logs help with debugging but can be cleared
4. **No Data Transmission**: No attendance data is sent to external servers

## Support

For technical support or questions about WhatsApp Business integration:

1. Check message logs for specific error messages
2. Verify WhatsApp Business API setup with Facebook
3. Test with a single student before full deployment
4. Monitor delivery rates and adjust templates as needed

## Future Enhancements

Planned improvements:

- Message delivery confirmation webhook
- Bulk message sending for announcements
- Parent contact management (multiple contacts per student)
- Rich media message support (images, documents)
- Message scheduling and automation rules
