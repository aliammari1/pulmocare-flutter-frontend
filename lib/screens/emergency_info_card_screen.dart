import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class EmergencyInfoCardScreen extends StatefulWidget {
  const EmergencyInfoCardScreen({super.key});

  @override
  State<EmergencyInfoCardScreen> createState() =>
      _EmergencyInfoCardScreenState();
}

class _EmergencyInfoCardScreenState extends State<EmergencyInfoCardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  // User emergency info
  final Map<String, dynamic> _userEmergencyInfo = {
    'name': 'Alex Johnson',
    'date_of_birth': '15/06/1985',
    'blood_type': 'A+',
    'allergies': ['Penicillin', 'Peanuts'],
    'conditions': 'Asthma, Hypertension',
    'medications': 'Albuterol, Lisinopril',
    'emergencyContacts': [
      {
        'name': 'Sarah Johnson',
        'relationship': 'Spouse',
        'phone': '+1 (555) 123-4567',
      },
      {
        'name': 'David Johnson',
        'relationship': 'Brother',
        'phone': '+1 (555) 987-6543',
      }
    ],
    'organDonor': true,
    'livingWill': true,
    'cardId': 'EC-12345-AJ',
    'lastUpdated': '10/04/2023',
  };

  // Text controllers for form fields
  late final TextEditingController _nameController;
  late final TextEditingController _date_of_birthController;
  late final TextEditingController _blood_typeController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _medicationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userEmergencyInfo['name']);
    _date_of_birthController =
        TextEditingController(text: _userEmergencyInfo['date_of_birth']);
    _blood_typeController =
        TextEditingController(text: _userEmergencyInfo['blood_type']);
    _allergiesController = TextEditingController(
        text: _userEmergencyInfo['allergies'] is List
            ? _userEmergencyInfo['allergies'].join(', ')
            : _userEmergencyInfo['allergies'] ?? '');
    _conditionsController =
        TextEditingController(text: _userEmergencyInfo['conditions']);
    _medicationsController =
        TextEditingController(text: _userEmergencyInfo['medications']);

    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate data loading from server
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save the data to the map (in real app, would save to database)
      setState(() {
        _userEmergencyInfo['name'] = _nameController.text;
        _userEmergencyInfo['date_of_birth'] = _date_of_birthController.text;
        _userEmergencyInfo['blood_type'] = _blood_typeController.text;
        _userEmergencyInfo['allergies'] = _allergiesController.text.isEmpty
            ? []
            : _allergiesController.text
                .split(',')
                .where((e) => e.trim().isNotEmpty)
                .map((e) => e.trim())
                .toList();
        _userEmergencyInfo['conditions'] = _conditionsController.text;
        _userEmergencyInfo['medications'] = _medicationsController.text;
        _userEmergencyInfo['lastUpdated'] = _getCurrentDate();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  void _shareEmergencyCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented soon'),
      ),
    );
  }

  void _generateQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: CustomPaint(
                painter: QRCodePainter(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan this code to quickly access emergency information',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR code saved to gallery'),
                ),
              );
            },
            child: const Text('SAVE TO GALLERY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Info Card'),
        actions: [
          if (!_isLoading && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Information',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing ? _buildEditForm() : _buildEmergencyCard(),
            ),
      floatingActionButton: _isLoading || _isEditing
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'qr_code',
                  onPressed: _generateQRCode,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.qr_code),
                  tooltip: 'Generate QR Code',
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'share',
                  onPressed: _shareEmergencyCard,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.share),
                  tooltip: 'Share Emergency Card',
                ),
              ],
            ),
    );
  }

  Widget _buildEmergencyCard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ID: ${_userEmergencyInfo['cardId']}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Name', _userEmergencyInfo['name']),
                  _buildInfoRow(
                      'Date of Birth', _userEmergencyInfo['date_of_birth']),
                  _buildInfoRow('Blood Type', _userEmergencyInfo['blood_type']),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medical_information, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Medical Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Allergies', _userEmergencyInfo['allergies']),
                  _buildInfoRow(
                      'Medical Conditions', _userEmergencyInfo['conditions']),
                  _buildInfoRow(
                      'Current Medications', _userEmergencyInfo['medications']),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatusChip(
                          'Organ Donor', _userEmergencyInfo['organDonor']),
                      _buildStatusChip(
                          'Has Living Will', _userEmergencyInfo['livingWill']),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.contact_phone, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ..._userEmergencyInfo['emergencyContacts']
                      .map<Widget>((contact) {
                    return _buildContactCard(contact);
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Last Updated: ${_userEmergencyInfo['lastUpdated']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emergency,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 8),
              Text(
                'EMERGENCY INFORMATION CARD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'IN CASE OF EMERGENCY, PLEASE REFER TO THIS INFORMATION',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    // Convert list to string if needed
    final String displayValue =
        value is List ? value.join(', ') : value?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, String> contact) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contact['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                contact['relationship']!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(contact['phone']!),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.call, size: 16),
                label: const Text('Call'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${contact['name']}...'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool status) {
    return Chip(
      label: Text(label),
      avatar: Icon(
        status ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: status ? Colors.green : Colors.red,
      ),
      backgroundColor:
          status ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      labelStyle: TextStyle(
        color: status ? Colors.green.shade800 : Colors.red.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Emergency Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            _buildTextField(
              label: 'Date of Birth (DD/MM/YYYY)',
              controller: _date_of_birthController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }
                // Could add more validation for date format
                return null;
              },
            ),
            _buildTextField(
              label: 'Blood Type',
              controller: _blood_typeController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your blood type';
                }
                return null;
              },
            ),
            _buildTextField(
              label: 'Allergies',
              controller: _allergiesController,
              maxLines: 2,
              helper: 'Separate multiple allergies with commas',
            ),
            _buildTextField(
              label: 'Medical Conditions',
              controller: _conditionsController,
              maxLines: 2,
              helper: 'Separate multiple conditions with commas',
            ),
            _buildTextField(
              label: 'Current Medications',
              controller: _medicationsController,
              maxLines: 2,
              helper: 'Separate multiple medications with commas',
            ),
            const SizedBox(height: 16),
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Emergency contacts would be editable here
            // For simplicity, we'll just show a placeholder
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Emergency contact editing will be added in a future update',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Organ Donor'),
                const Spacer(),
                Switch(
                  value: _userEmergencyInfo['organDonor'],
                  onChanged: (value) {
                    setState(() {
                      _userEmergencyInfo['organDonor'] = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text('Has Living Will'),
                const Spacer(),
                Switch(
                  value: _userEmergencyInfo['livingWill'],
                  onChanged: (value) {
                    setState(() {
                      _userEmergencyInfo['livingWill'] = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _toggleEditing,
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? helper,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: helper,
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _date_of_birthController.dispose();
    _blood_typeController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }
}

// Simple mock QR code painter
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final padding = size.width * 0.1;
    final qrSize = size.width - (padding * 2);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(padding, padding, qrSize, qrSize),
      paint..color = Colors.black,
    );

    // QR code pattern (simplified)
    final blockSize = qrSize / 25;
    final rng = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
        // Position detection patterns (corners)
        if ((i < 7 && j < 7) || (i < 7 && j >= 18) || (i >= 18 && j < 7)) {
          // Outer square
          if (i < 7 && j < 7) {
            if ((i == 0 || i == 6 || j == 0 || j == 6) ||
                (i >= 2 && i <= 4 && j >= 2 && j <= 4)) {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.black,
              );
            } else {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.white,
              );
            }
          } else if (i < 7 && j >= 18) {
            if ((i == 0 || i == 6 || j == 18 || j == 24) ||
                (i >= 2 && i <= 4 && j >= 20 && j <= 22)) {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.black,
              );
            } else {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.white,
              );
            }
          } else if (i >= 18 && j < 7) {
            if ((i == 18 || i == 24 || j == 0 || j == 6) ||
                (i >= 20 && i <= 22 && j >= 2 && j <= 4)) {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.black,
              );
            } else {
              canvas.drawRect(
                Rect.fromLTWH(
                  padding + i * blockSize,
                  padding + j * blockSize,
                  blockSize,
                  blockSize,
                ),
                paint..color = Colors.white,
              );
            }
          }
        }
        // Random pattern for the rest of the QR code
        else {
          if (rng.nextBool()) {
            canvas.drawRect(
              Rect.fromLTWH(
                padding + i * blockSize,
                padding + j * blockSize,
                blockSize,
                blockSize,
              ),
              paint..color = Colors.white,
            );
          }
        }
      }
    }

    // Add a small icon in the center
    final iconSize = qrSize * 0.15;
    final iconPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(padding + qrSize / 2, padding + qrSize / 2),
        width: iconSize,
        height: iconSize,
      ));
    canvas.drawPath(iconPath, paint..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
