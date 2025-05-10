import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final role = authViewModel.role; // 'doctor', 'radiologist', or 'patient'
    final isAuthenticated = authViewModel.isAuthenticated;

    return SafeArea(
        child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81C9F3), Color(0xFF35C5CF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.medical_services,
                      size: 30, color: Color(0xFF35C5CF)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pulmocare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete Medical Solution',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).toInt()),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Show different navigation options based on user type
          if (isAuthenticated) ...[
            // DOCTOR NAVIGATION
            if (role == 'doctor') ...[
              _buildNavSection(context, 'Doctor Navigation'),
              _buildNavItem(
                  context, 'Dashboard', Icons.dashboard, '/doctor-dashboard'),
              _buildNavItem(
                  context, 'My Profile', Icons.person, '/doctor-profile'),
              _buildNavItem(
                  context, 'Appointments', Icons.event, '/doctor-appointments'),
              _buildNavItem(context, 'Doctor List', Icons.people, '/doctors'),
              _buildNavItem(context, 'Patients', Icons.people, '/patients'),
              _buildNavItem(
                  context, 'Add Patient', Icons.person_add, '/add-patient'),
              _buildNavItem(context, 'Prescriptions', Icons.medical_services,
                  '/prescriptions'),
              _buildNavItem(context, 'Create Prescription', Icons.add_circle,
                  '/create-prescription'),
              _buildNavItem(context, 'Reports', Icons.assignment, '/report'),
              _buildNavItem(
                  context, 'Create Report', Icons.note_add, '/create-report'),
              _buildNavItem(context, 'Request Radiology', Icons.biotech,
                  '/request-radiology'),
              _buildNavItem(
                  context, 'Archive', Icons.archive, '/archiveScreen'),
              // Doctor navigation items
              _buildNavItem(context, 'Treatment Timeline', Icons.timeline,
                  '/treatment-timeline/all'),
              _buildNavItem(context, 'Clinical Decision Support',
                  Icons.psychology, '/clinical-decision-support'),
              _buildNavItem(context, 'Team Collaboration', Icons.groups,
                  '/team-collaboration'),
              _buildNavItem(context, 'Follow-up Scheduler',
                  Icons.calendar_month, '/follow-up-scheduler'),

              // Innovative doctor screens
              _buildNavSection(context, 'Advanced Tools'),
              _buildNavItem(context, 'AI Diagnosis Assistant', Icons.smart_toy,
                  '/ai-diagnosis-dashboard'),
              _buildNavItem(context, 'Patient Timeline', Icons.timeline,
                  '/patient-timeline'),
              _buildNavItem(context, 'Voice Prescriptions', Icons.mic,
                  '/voice-to-prescription'),
              _buildNavItem(context, 'Remote Monitoring', Icons.monitor_heart,
                  '/remote-patient-monitoring'),
              _buildNavItem(context, '3D Anatomical Viewer', Icons.view_in_ar,
                  '/anatomical-viewer'),
              const Divider(),
            ]

            // RADIOLOGIST NAVIGATION
            else if (role == 'radiologist') ...[
              _buildNavSection(context, 'Radiologist Navigation'),
              _buildNavItem(context, 'Dashboard', Icons.dashboard,
                  '/radiologist-dashboard'),
              _buildNavItem(context, 'My Profile', Icons.person, '/profile'),
              _buildNavItem(context, 'Radiology Reports', Icons.description,
                  '/radiology-reports'),
              _buildNavItem(context, 'Examinations', Icons.biotech,
                  '/radiology-examinations'),

              // New radiologist navigation items
              _buildNavItem(context, 'Advanced Image Analysis',
                  Icons.image_search, '/advanced-image-analysis'),
              _buildNavItem(context, 'Exam Comparison', Icons.compare,
                  '/exam-comparison/all'),
              _buildNavItem(context, 'Knowledge Base', Icons.menu_book,
                  '/radiology-knowledge-base'),
              _buildNavItem(context, 'Collaborative Cases', Icons.people_alt,
                  '/collaborative-case/all'),

              // Innovative radiologist screens
              _buildNavSection(context, 'Advanced Tools'),
              _buildNavItem(context, 'AI Image Analysis Suite', Icons.biotech,
                  '/ai-image-analysis'),
              _buildNavItem(context, 'Collaborative Review', Icons.groups_2,
                  '/collaborative-review-board'),
              _buildNavItem(context, 'Advanced Visualization',
                  Icons.new_releases, '/advanced-visualization-lab'),
              _buildNavItem(context, 'Educational Case Builder', Icons.school,
                  '/educational-case-builder'),
              const Divider(),
            ]

            // PATIENT NAVIGATION
            else if (role == 'patient') ...[
              _buildNavSection(context, 'Patient Navigation'),
              _buildNavItem(
                  context, 'Dashboard', Icons.dashboard, '/patient-dashboard'),
              _buildNavItem(context, 'My Profile', Icons.person, '/profile'),
              _buildNavItem(context, 'Medical Records', Icons.folder_special,
                  '/patient-records'),
              _buildNavItem(context, 'Appointments', Icons.event,
                  '/patient-appointments'),
              _buildNavItem(context, 'Book Appointment',
                  Icons.add_circle_outline, '/book-appointment'),
              _buildNavItem(
                  context, 'My Reports', Icons.description, '/patient-reports'),
              _buildNavItem(
                  context, 'Contact Doctor', Icons.message, '/contact-doctor'),
              _buildNavItem(
                  context, 'Find Specialist', Icons.search, '/find-specialist'),
              _buildNavItem(context, 'Emergency Contacts', Icons.emergency,
                  '/emergency-contacts'),

              // New patient navigation items
              _buildNavItem(
                  context, 'Telemedicine', Icons.video_call, '/telemedicine'),
              _buildNavItem(
                  context, 'Lab Results', Icons.science, '/lab-results'),
              _buildNavItem(context, 'Health Metrics', Icons.monitor_heart,
                  '/health-metrics'),
              _buildNavItem(context, 'My Documents', Icons.file_present,
                  '/medical-documents'),

              // Innovative patient screens
              _buildNavSection(context, 'Health Tools'),
              _buildNavItem(context, 'Symptom Tracker', Icons.note_add,
                  '/symptom-tracker'),
              _buildNavItem(context, 'Medication Manager', Icons.medication,
                  '/medication-manager'),
              _buildNavItem(context, 'Virtual Waiting Room', Icons.queue,
                  '/virtual-waiting-room'),
              _buildNavItem(context, 'Recovery Progress', Icons.trending_up,
                  '/recovery-progress'),
              _buildNavItem(context, 'Health Library', Icons.menu_book,
                  '/health-literacy'),
              const Divider(),
            ],

            // Common items for all authenticated users
            _buildNavSection(context, 'Common'),
            _buildNavItem(context, 'Notifications', Icons.notifications,
                '/notifications'),
            _buildNavItem(context, 'Settings', Icons.settings, '/settings'),
            _buildNavItem(context, 'News', Icons.newspaper, '/news'),

            // New common tools for all users
            _buildNavItem(
                context, 'Communication Hub', Icons.chat, '/communication-hub'),
            _buildNavItem(context, 'Community Support', Icons.support,
                '/community-support'),
            _buildNavItem(context, 'Wellness Recommendations', Icons.recommend,
                '/wellness-recommendation'),
            _buildNavItem(context, 'Document Vault', Icons.folder_special,
                '/document-vault'),
            _buildNavItem(context, 'Emergency Info Card', Icons.emergency,
                '/emergency-info-card'),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => _showLogoutDialog(context),
            ),
          ]

          // If not authenticated, show login options
          else ...[
            _buildNavSection(context, 'Login'),
            _buildNavItem(
                context, 'Doctor Login', Icons.medical_information, '/login',
                extra: 'doctor'),
            _buildNavItem(
                context, 'Radiologist Login', Icons.mediation, '/loginRadio'),
            _buildNavItem(context, 'Patient Login', Icons.personal_injury,
                '/loginPatient'),
            _buildNavItem(context, 'Forgot Password', Icons.lock_reset,
                '/forgot-password'),
            const Divider(),
            _buildNavSection(context, 'Register'),
            _buildNavItem(context, 'Doctor Registration',
                Icons.app_registration, '/register'),
            _buildNavItem(context, 'Patient Registration',
                Icons.app_registration, '/register'),
          ],
        ],
      ),
    ));
  }

  Widget _buildNavSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, IconData icon, String route,
      {Object? extra}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () {
        context.pop(); // Close drawer first
        if (extra != null) {
          context.push(route, extra: extra);
        } else {
          context.push(route);
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => context.pop(ctx),
          ),
          TextButton(
            child: const Text('Yes, Logout'),
            onPressed: () async {
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Call logout method from AuthViewModel
                await context.read<AuthViewModel>().logout(context);

                // Close loading indicator and dialogs
                if (context.mounted) {
                  context.pop(); // Close loading indicator
                  context.pop(ctx); // Close logout confirmation dialog
                  context.pop(); // Close drawer

                  // Navigate to entry view
                  context.go('/entryView');

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Handle logout errors
                if (context.mounted) {
                  context.pop(); // Close loading indicator
                  context.pop(ctx); // Close logout confirmation dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
