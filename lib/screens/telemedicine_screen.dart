import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final List<Map<String, dynamic>> _upcomingConsultations = [
    {
      'doctorName': 'Dr. Sarah Johnson',
      'specialty': 'Pulmonologist',
      'date': DateTime.now().add(const Duration(days: 2)),
      'time': '10:30 AM',
      'status': 'Confirmed',
      'avatar': 'assets/docteur.png',
    },
    {
      'doctorName': 'Dr. Michael Chen',
      'specialty': 'Cardiologist',
      'date': DateTime.now().add(const Duration(days: 5)),
      'time': '2:15 PM',
      'status': 'Pending',
      'avatar': 'assets/docteur (1).png',
    },
  ];

  final List<Map<String, dynamic>> _pastConsultations = [
    {
      'doctorName': 'Dr. David Wilson',
      'specialty': 'General Practitioner',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'time': '9:00 AM',
      'notes': 'Discussed symptoms and prescribed antibiotics',
      'avatar': 'assets/docteur.png',
    },
    {
      'doctorName': 'Dr. Emily Rodriguez',
      'specialty': 'Dermatologist',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'time': '3:45 PM',
      'notes': 'Follow-up consultation on treatment progress',
      'avatar': 'assets/docteur (1).png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Telemedicine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            _buildSectionTitle('Upcoming Consultations'),
            ..._upcomingConsultations.map(
                (consultation) => _buildUpcomingConsultationCard(consultation)),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildSectionTitle('Past Consultations'),
            ..._pastConsultations.map(
                (consultation) => _buildPastConsultationCard(consultation)),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleConsultationDialog(),
        label: const Text('Schedule Consultation'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF81C9F3), Color(0xFF35C5CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_call, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Virtual Consultations',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Consult with your doctor from the comfort of your home',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpcomingConsultationCard(Map<String, dynamic> consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(consultation['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation['doctorName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        consultation['specialty'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: consultation['status'] == 'Confirmed'
                        ? Colors.green[100]
                        : Colors.amber[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    consultation['status'],
                    style: TextStyle(
                      color: consultation['status'] == 'Confirmed'
                          ? Colors.green[800]
                          : Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(consultation['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  consultation['time'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Add functionality to reschedule appointment
                    _showRescheduleDialog(consultation);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Reschedule'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality to join consultation
                    _showJoinConsultationDialog(consultation);
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastConsultationCard(Map<String, dynamic> consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(consultation['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation['doctorName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        consultation['specialty'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(consultation['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  consultation['time'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consultation Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    consultation['notes'],
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Add functionality to view detailed notes
                  },
                  icon: const Icon(Icons.description),
                  label: const Text('View Report'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality to book follow-up
                    _showBookFollowUpDialog(consultation);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Book Follow-up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            Icons.health_and_safety,
            'Symptom Checker',
            () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            Icons.help_outline,
            'Get Help',
            () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            Icons.history,
            'View History',
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleConsultationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Schedule New Consultation'),
          content: const Text(
              'This feature will open a screen to schedule a new telemedicine consultation with a doctor.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Feature coming soon!'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reschedule Consultation'),
          content: Text(
              'Do you want to reschedule your consultation with ${consultation['doctorName']}?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Reschedule requested'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinConsultationDialog(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Virtual Consultation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Ready to join consultation with ${consultation['doctorName']}?'),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                      'Please ensure your camera and microphone work properly'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Find a quiet place with good lighting'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_call),
              label: const Text('Join Now'),
              onPressed: () {
                context.pop();
                // Navigate to the video call screen with the consultation information
                context.go('/video-call', extra: consultation);
              },
            ),
          ],
        );
      },
    );
  }

  void _showBookFollowUpDialog(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Follow-up Consultation'),
          content: Text(
              'Would you like to book a follow-up consultation with ${consultation['doctorName']}?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Follow-up consultation requested'),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
              child: const Text('Book Follow-up'),
            ),
          ],
        );
      },
    );
  }
}
