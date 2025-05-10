import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/services/auth_view_model.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _dashboardData = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // In a real app, you would fetch this data from your API
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _dashboardData = {
          "upcomingAppointments": [
            {
              "id": "a1",
              "doctorName": "Dr. Ahmed Khelifi",
              "doctorSpecialty": "Dermatology",
              "date": "2025-04-29",
              "time": "10:30 AM",
              "status": "confirmed"
            },
            {
              "id": "a2",
              "doctorName": "Dr. Fatma Bouazizi",
              "doctorSpecialty": "Neurology",
              "date": "2025-05-03",
              "time": "2:15 PM",
              "status": "pending"
            }
          ],
          "recentPrescriptions": [
            {
              "id": "p1",
              "doctorName": "Dr. Mohamed Ben Salem",
              "date": "2025-04-22",
              "medications": [
                {
                  "name": "Amoxicillin",
                  "dosage": "500mg",
                  "frequency": "Every 8 hours",
                  "duration": "10 days"
                }
              ],
              "active": true
            },
            {
              "id": "p2",
              "doctorName": "Dr. Jane Smith",
              "date": "2025-04-15",
              "medications": [
                {
                  "name": "Ibuprofen",
                  "dosage": "400mg",
                  "frequency": "Every 6 hours as needed",
                  "duration": "5 days"
                },
                {
                  "name": "Loratadine",
                  "dosage": "10mg",
                  "frequency": "Daily",
                  "duration": "30 days"
                }
              ],
              "active": true
            }
          ],
          "recentExaminations": [
            {
              "id": "e1",
              "type": "Blood Test",
              "date": "2025-04-20",
              "result": "Normal",
              "doctorName": "Dr. Ahmed Khelifi"
            },
            {
              "id": "e2",
              "type": "X-Ray Chest",
              "date": "2025-04-18",
              "result": "Pending",
              "doctorName": "Dr. Leila Trabelsi"
            }
          ],
          "vitals": [
            {
              "name": "Blood Pressure",
              "value": "120/80",
              "date": "2025-04-25",
              "status": "normal"
            },
            {
              "name": "Heart Rate",
              "value": "76 bpm",
              "date": "2025-04-25",
              "status": "normal"
            },
            {
              "name": "Temperature",
              "value": "37.1°C",
              "date": "2025-04-25",
              "status": "normal"
            },
            {
              "name": "Oxygen Saturation",
              "value": "98%",
              "date": "2025-04-25",
              "status": "normal"
            }
          ],
          "notifications": [
            {
              "id": "n1",
              "title": "Appointment Reminder",
              "message":
                  "You have an appointment with Dr. Ahmed Khelifi tomorrow at 10:30 AM",
              "date": "2025-04-28",
              "read": false
            },
            {
              "id": "n2",
              "title": "Prescription Available",
              "message": "Your prescription for Loratadine is ready",
              "date": "2025-04-26",
              "read": true
            },
            {
              "id": "n3",
              "title": "New Test Result Available",
              "message": "Your blood test results are now available",
              "date": "2025-04-22",
              "read": true
            }
          ]
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Show notifications
                  context.push('/notifications');
                },
              ),
              if (_dashboardData.containsKey('notifications') &&
                  _dashboardData['notifications']
                      .any((n) => n['read'] == false))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Stay on dashboard
              break;
            case 1:
              context.push('/patient-appointments');
              break;
            case 2:
              context.push('/patient-records');
              break;
            case 3:
              context.push('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 24),
            _buildVitalsSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Upcoming Appointments'),
            _buildUpcomingAppointments(),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Medications'),
            _buildRecentMedications(),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Examinations'),
            _buildRecentExaminations(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    String name = authViewModel.isAuthenticated
        ? authViewModel.currentPatient?.name!.split(' ')[0] ?? 'Patient'
        : 'Patient';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s a summary of your health information',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsSection() {
    final vitals = _dashboardData['vitals'] as List;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.secondaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Vitals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Last updated: ${_formatDate(vitals[0]['date'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  1.5, // Increased from 2.0 to provide more height
            ),
            itemCount: vitals.length,
            itemBuilder: (context, index) {
              final vital = vitals[index];
              return Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8), // Adjusted padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vital['name'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        overflow:
                            TextOverflow.ellipsis, // Prevent text overflow
                      ),
                      const SizedBox(height: 6), // Increased spacing
                      Row(
                        children: [
                          Expanded(
                            // Wrap in Expanded to prevent overflow
                            child: Text(
                              vital['value'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusIndicator(vital['status']),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'normal':
        color = Colors.green;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'alert':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final appointments = _dashboardData['upcomingAppointments'] as List;

    if (appointments.isEmpty) {
      return _buildEmptyState('No upcoming appointments',
          'Schedule your next appointment with a doctor');
    }

    return Column(
      children: appointments.map((appointment) {
        final bool isConfirmed = appointment['status'] == 'confirmed';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor:
                  isConfirmed ? AppTheme.primaryColor : Colors.orange,
              child: Icon(
                isConfirmed ? Icons.event_available : Icons.pending,
                color: Colors.white,
              ),
            ),
            title: Text(
              appointment['doctorName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  appointment['doctorSpecialty'],
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Replaced Row with Wrap for better overflow handling
                Wrap(
                  spacing: 12, // Space between items
                  runSpacing: 4, // Space between lines
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min, // Take only needed width
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(appointment['date']),
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min, // Take only needed width
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment['time'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                isConfirmed ? 'Confirmed' : 'Pending',
                style: TextStyle(
                  color: isConfirmed ? Colors.green[700] : Colors.orange[800],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor:
                  isConfirmed ? Colors.green[50] : Colors.orange[50],
            ),
            onTap: () {
              context.push('/appointment/${appointment['id']}');
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentMedications() {
    final prescriptions = _dashboardData['recentPrescriptions'] as List;

    if (prescriptions.isEmpty) {
      return _buildEmptyState('No active medications',
          'Your prescribed medications will appear here');
    }

    return Column(
      children: prescriptions.map((prescription) {
        final medications = prescription['medications'] as List;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                title: Wrap(
                  // Changed from Row to Wrap
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8, // Horizontal spacing between elements
                  children: [
                    Flexible(
                      // Added Flexible to allow text to wrap if needed
                      child: Text(
                        'Prescribed by ${prescription['doctorName']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (prescription['active'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Date: ${_formatDate(prescription['date'])}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
              const Divider(),
              ...medications.map((medication) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align to top
                    children: [
                      const Icon(Icons.medication, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${medication['dosage']} - ${medication['frequency']}',
                              style: TextStyle(color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Duration: ${medication['duration']}',
                              style: TextStyle(color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.push('/prescription/${prescription['id']}');
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentExaminations() {
    final examinations = _dashboardData['recentExaminations'] as List;

    if (examinations.isEmpty) {
      return _buildEmptyState('No recent examinations',
          'Your examination results will appear here');
    }

    return Column(
      children: examinations.map((examination) {
        final bool isPending = examination['result'] == 'Pending';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isPending ? Colors.amber[100] : Colors.blue[100],
              child: Icon(
                _getExaminationTypeIcon(examination['type']),
                color: isPending ? Colors.amber[800] : Colors.blue[800],
              ),
            ),
            title: Text(
              examination['type'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Date: ${_formatDate(examination['date'])}'),
                const SizedBox(height: 2),
                Text('Doctor: ${examination['doctorName']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPending ? Colors.amber[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                examination['result'],
                style: TextStyle(
                  color: isPending ? Colors.amber[800] : Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              context.push('/examination/${examination['id']}');
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio:
              1.1, // Reduced from 1.2 to make cards slightly taller
          crossAxisSpacing: 8, // Reduced from 10
          mainAxisSpacing: 8, // Reduced from 10
          children: [
            _buildActionCard(
              'Book Appointment',
              Icons.calendar_month,
              Colors.blue,
              () => context.push('/book-appointment'),
            ),
            _buildActionCard(
              'Request Medication',
              Icons.medication,
              Colors.green,
              () => context.push('/medication-request'),
            ),
            _buildActionCard(
              'View Reports',
              Icons.description,
              Colors.purple,
              () => context.push('/patient-reports'),
            ),
            _buildActionCard(
              'Contact Doctor',
              Icons.message,
              Colors.orange,
              () => context.push('/contact-doctor'),
            ),
            _buildActionCard(
              'Find Specialist',
              Icons.search,
              Colors.teal,
              () => context.push('/find-specialist'),
            ),
            _buildActionCard(
              'Emergency',
              Icons.emergency,
              Colors.red,
              () => context.push('/emergency-contacts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1, // Reduced from 2
      margin: EdgeInsets.zero, // Remove default card margin
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8), // Add some vertical padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22, // Reduced from 24
                ),
              ),
              const SizedBox(height: 6), // Reduced from 8
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2, // Limit to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExaminationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'x-ray':
      case 'x-ray chest':
        return Icons.broken_image;
      case 'ct scan':
        return Icons.view_in_ar;
      case 'mri':
        return Icons.scanner;
      case 'ultrasound':
        return Icons.waves;
      case 'blood test':
        return Icons.bloodtype;
      default:
        return Icons.medical_services;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }
}
