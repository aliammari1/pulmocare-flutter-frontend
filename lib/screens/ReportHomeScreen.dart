import 'package:flutter/material.dart';
import 'package:medapp/screens/Signup_screen.dart';
import 'package:medapp/screens/create_report_screen.dart';
import 'package:medapp/screens/handwriting_screen.dart';
import 'package:medapp/screens/report_editor_screen.dart';
import 'package:medapp/screens/reports/reports_list_screen.dart';
import 'package:medapp/services/auth_radio_view_model.dart';
import 'package:medapp/services/auth_view_model_patient.dart';
import 'package:medapp/screens/patients_view.dart';
import 'package:medapp/services/report_service.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:medapp/screens/AppointmentsScreen.dart';
import 'package:medapp/screens/ArchiveScreen.dart';
import 'package:medapp/screens/RapportScreen.dart';
import 'package:medapp/screens/profile_radio.dart';
import 'package:medapp/screens/signup_view.dart';
import 'package:medapp/screens/signup_radio.dart';
import 'package:medapp/services/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardTab(),
    const ReportsListScreen(),
    const ProfileTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToCreateReport(context),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('New Report'),
            )
          : null,
    );
  }

  void _navigateToCreateReport(BuildContext context) {
    final reportService = Provider.of<ReportService>(context, listen: false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Provider<ReportService>.value(
          value: reportService,
          child: const CreateReportScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, color: Colors.white.withAlpha(230)),
            const SizedBox(width: 8),
            const Text('MediScribe',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderStats(),
          Expanded(
            child: _buildFeatureGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A5F7A),
            Color(0xFF2E8BC0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5F7A).withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Reports', '28', Icons.description_outlined),
          _buildVerticalDivider(),
          _buildStatItem('Pending', '5', Icons.pending_actions_outlined),
          _buildVerticalDivider(),
          _buildStatItem('Complete', '23', Icons.task_alt_outlined),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withAlpha(128),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      children: [
        _buildFeatureCard(
          context,
          'Create Report',
          'Start a new medical report',
          Icons.note_add,
          const Color(0xFFF0F7FA),
          () {
            final navigator = Navigator.of(context);
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const CreateReportScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'Smart Editor', // Updated name
          'AI-powered report editor', // Updated description
          Icons.edit_note, // Updated icon
          const Color(0xFFF0FAF0),
          () {
            final navigatorContext = context;
            final navigator = Navigator.of(context);
            navigator
                .push(
              MaterialPageRoute(
                builder: (context) => const ReportEditorScreen(
                  reportId: 'new',
                  patientName: 'New Patient',
                ),
              ),
            )
                .then((value) {
              if (value != null && navigatorContext.mounted) {
                ScaffoldMessenger.of(navigatorContext).showSnackBar(
                  SnackBar(
                    content: const Text('Report saved as draft'),
                    backgroundColor:
                        Theme.of(navigatorContext).colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          },
        ),
        _buildFeatureCard(
          context,
          'Handwriting',
          'Convert handwriting to text',
          Icons.draw,
          const Color(0xFFFFF8F0),
          () {
            final navigatorContext = context;
            final navigator = Navigator.of(context);
            navigator
                .push(
              MaterialPageRoute(
                builder: (context) => const HandwritingScreen(),
              ),
            )
                .then((value) {
              if (value != null && navigatorContext.mounted) {
                ScaffoldMessenger.of(navigatorContext).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Handwriting captured. Open Create Report to use it.'),
                    backgroundColor:
                        Theme.of(navigatorContext).colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          },
        ),
        _buildFeatureCard(
          context,
          'My Reports',
          'View and manage reports',
          Icons.folder_special,
          const Color(0xFFF5F0FA),
          () {
            // Navigate to reports tab
            final HomeScreen? homeScreen =
                context.findAncestorWidgetOfExactType<HomeScreen>();
            if (homeScreen != null) {
              final _HomeScreenState? state =
                  context.findAncestorStateOfType<_HomeScreenState>();
              state?._pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color backgroundColor,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(51),
              child: Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dr. Sarah Johnson',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Cardiologist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileSection(
              context,
              'Personal Information',
              [
                _buildInfoRow('Email', 'sarah.johnson@mediscribe.com'),
                _buildInfoRow('Phone', '+1 (555) 123-4567'),
                _buildInfoRow('License No.', 'MD-12345-678'),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSection(
              context,
              'Hospital Information',
              [
                _buildInfoRow('Hospital', 'City General Hospital'),
                _buildInfoRow('Department', 'Cardiology'),
                _buildInfoRow('Office', 'Room 305, Building B'),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileSection(
              context,
              'App Settings',
              [
                _buildSettingsRow('Dark Mode', false, (value) {}),
                _buildSettingsRow('Notifications', true, (value) {}),
                _buildSettingsRow('Auto-save Reports', true, (value) {}),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement sign out
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign out functionality not implemented.'),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
      String label, bool initialValue, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
