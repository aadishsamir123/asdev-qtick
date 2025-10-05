import 'package:flutter/material.dart';
import '../services/csv_import_service.dart';
import '../services/database_service.dart';
import '../models/student_contact.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  bool _isLoading = false;
  List<StudentContact> _existingContacts = [];
  List<StudentContact> _filteredContacts = [];
  CsvValidationResult? _validationResult;
  CsvImportResult? _importResult;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExistingContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterContacts();
    });
  }

  void _filterContacts([String? query]) {
    final searchQuery = query ?? _searchQuery;
    setState(() {
      _searchQuery = searchQuery;
      if (_searchQuery.isEmpty) {
        _filteredContacts = List.from(_existingContacts);
      } else {
        _filteredContacts =
            _existingContacts.where((contact) {
              return contact.studentName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  contact.phoneNumber.contains(_searchQuery);
            }).toList();
      }
    });
  }

  Future<void> _loadExistingContacts() async {
    setState(() => _isLoading = true);

    try {
      final contacts = await DatabaseService().getAllStudentContacts();
      setState(() {
        _existingContacts = contacts;
        _filterContacts();
      });
    } catch (e) {
      _showErrorDialog('Error loading existing contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateCsvFile() async {
    setState(() => _isLoading = true);

    try {
      final result = await CsvImportService.validateCsvFile();
      if (result != null) {
        setState(() {
          _validationResult = result;
          _importResult = null; // Clear previous import results
        });

        if (!result.isValid) {
          _showErrorDialog(
            'CSV validation failed:\n${result.errors.join('\n')}',
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Error validating CSV file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCsvFile() async {
    setState(() => _isLoading = true);

    try {
      final result = await CsvImportService.pickAndImportCsvFile();
      if (result != null) {
        setState(() {
          _importResult = result;
          _validationResult = null; // Clear validation results
        });

        if (result.successfulImports.isNotEmpty) {
          // Save to database
          await DatabaseService().bulkInsertStudentContacts(
            result.successfulImports,
          );
          await _loadExistingContacts(); // Refresh the list

          _showSuccessDialog(
            'Import completed!\n'
            'Successfully imported: ${result.successCount} contacts\n'
            'Errors: ${result.errorCount}',
          );
        } else {
          _showErrorDialog(
            'No contacts were imported.\n${result.errors.join('\n')}',
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Error importing CSV file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllContacts() async {
    final confirmed = await _showConfirmationDialog(
      'Clear All Contacts',
      'Are you sure you want to delete all student contacts? This action cannot be undone.',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService().clearAllStudentContacts();
      await _loadExistingContacts();
      _showSuccessDialog('All contacts have been cleared.');
    } catch (e) {
      _showErrorDialog('Error clearing contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Manual Contact Management Methods
  Future<void> _addNewContact() async {
    final result = await _showContactDialog();
    if (result != null) {
      try {
        await DatabaseService().insertOrUpdateStudentContact(result);
        await _loadExistingContacts();
        _showSuccessDialog('Contact added successfully!');
      } catch (e) {
        _showErrorDialog('Error adding contact: $e');
      }
    }
  }

  Future<void> _editContact(StudentContact contact) async {
    final result = await _showContactDialog(contact: contact);
    if (result != null) {
      try {
        await DatabaseService().updateStudentContact(result);
        await _loadExistingContacts();
        _showSuccessDialog('Contact updated successfully!');
      } catch (e) {
        _showErrorDialog('Error updating contact: $e');
      }
    }
  }

  Future<void> _deleteContact(StudentContact contact) async {
    final confirmed = await _showConfirmationDialog(
      'Delete Contact',
      'Are you sure you want to delete ${contact.studentName}?',
    );

    if (confirmed == true) {
      try {
        await DatabaseService().deleteStudentContact(contact.id!);
        await _loadExistingContacts();
        _showSuccessDialog('Contact deleted successfully!');
      } catch (e) {
        _showErrorDialog('Error deleting contact: $e');
      }
    }
  }

  Future<StudentContact?> _showContactDialog({StudentContact? contact}) async {
    final nameController = TextEditingController(
      text: contact?.studentName ?? '',
    );
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isActive = contact?.isActive ?? true;

    return showDialog<StudentContact>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Student Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText:
                                '6512345678 (Singapore) or 911234567890 (India)',
                            helperText: 'International format without + prefix',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.trim().length < 8) {
                              return 'Phone number too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active'),
                          subtitle: const Text('Enable WhatsApp notifications'),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final now = DateTime.now();
                          final newContact = StudentContact(
                            id: contact?.id,
                            studentName: nameController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            isActive: isActive,
                            createdAt: contact?.createdAt ?? now,
                            updatedAt: now,
                          );
                          Navigator.pop(context, newContact);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(contact == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<bool?> _showConfirmationDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showCsvFormatHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('CSV Format Requirements'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Required Columns:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• studentName (or student_name, name)'),
                  const Text('• phoneNumber (or phone_number, phone, mobile)'),
                  const SizedBox(height: 16),
                  const Text(
                    'Example CSV format:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[100],
                    child: const Text(
                      'studentName,phoneNumber\n'
                      'John Doe,6512345678\n'
                      'Jane Smith,911234567890\n'
                      'Bob Johnson,442071234567',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Phone numbers in international format without + prefix',
                  ),
                  const Text(
                    '  Examples: 6512345678 (Singapore), 911234567890 (India)',
                  ),
                  const Text('• Invalid entries will be skipped'),
                  const Text(
                    '• Duplicate student names will overwrite existing contacts',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Student Contacts'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCsvFormatHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: 'CSV Format Help',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImportSection(),
                    const SizedBox(height: 24),
                    _buildResultsSection(),
                    const SizedBox(height: 24),
                    _buildExistingContactsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import from CSV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload a CSV file containing student names and phone numbers to enable WhatsApp notifications.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _validateCsvFile,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _importCsvFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_validationResult == null && _importResult == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_validationResult != null) ...[
              const Text(
                'CSV Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildValidationResults(),
            ],
            if (_importResult != null) ...[
              const Text(
                'Import Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildImportResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidationResults() {
    final result = _validationResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: result.isValid ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: result.isValid ? Colors.green : Colors.red,
            ),
          ),
          child: Row(
            children: [
              Icon(
                result.isValid ? Icons.check_circle : Icons.error,
                color: result.isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.isValid
                      ? 'CSV is valid and ready to import (${result.totalRows} rows)'
                      : 'CSV validation failed',
                  style: TextStyle(
                    color: result.isValid ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  result.errors
                      .map(
                        (error) => Text(
                          '• $error',
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],

        if (result.previewRows.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Preview (first 5 rows):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPreviewTable(result),
        ],
      ],
    );
  }

  Widget _buildPreviewTable(CsvValidationResult result) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children:
                result.headers
                    .map(
                      (header) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          header,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
          ),
          // Data rows
          ...result.previewRows.map(
            (row) => TableRow(
              children:
                  result.headers
                      .map(
                        (header) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(row[header]?.toString() ?? ''),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportResults() {
    final result = _importResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: result.hasErrors ? Colors.orange[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: result.hasErrors ? Colors.orange : Colors.green,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.hasErrors ? Icons.warning : Icons.check_circle,
                    color: result.hasErrors ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Import Summary',
                    style: TextStyle(
                      color:
                          result.hasErrors
                              ? Colors.orange[800]
                              : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('✓ Successfully imported: ${result.successCount} contacts'),
              if (result.hasErrors) Text('⚠ Errors: ${result.errorCount}'),
              Text('📊 Total rows processed: ${result.totalRows}'),
            ],
          ),
        ),

        if (result.hasErrors) ...[
          const SizedBox(height: 16),
          const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  result.errors
                      .map(
                        (error) => Text(
                          '• $error',
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExistingContactsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Existing Contacts (${_filteredContacts.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addNewContact,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_existingContacts.isNotEmpty)
                      TextButton.icon(
                        onPressed: _clearAllContacts,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            if (_existingContacts.isNotEmpty) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterContacts('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterContacts,
              ),
              const SizedBox(height: 16),
            ],

            if (_existingContacts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No contacts imported yet.\nImport a CSV file to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              contact.isActive ? Colors.green : Colors.grey,
                          child: Text(
                            contact.studentName.isNotEmpty
                                ? contact.studentName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(contact.studentName),
                        subtitle: Text(contact.phoneNumber),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editContact(contact);
                                break;
                              case 'delete':
                                _deleteContact(contact);
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                          child: Icon(
                            contact.isActive
                                ? Icons.more_vert
                                : Icons.pause_circle,
                            color:
                                contact.isActive ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
