import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          _buildNavSection(context, 'Main Navigation'),
          _buildNavItem(context, 'Home', Icons.home, '/home'),
          _buildNavItem(context, 'Dashboard', Icons.dashboard, '/dashboard'),
          _buildNavItem(context, 'Reports', Icons.assignment, '/rapportScreen'),
          _buildNavItem(
              context, 'Appointments', Icons.event, '/appointmentsScreen'),
          _buildNavItem(context, 'Archives', Icons.archive, '/archiveScreen'),
          const Divider(),
          _buildNavSection(context, 'Account'),
          _buildNavItem(context, 'Profile', Icons.person, '/profileRadio'),
          _buildNavItem(
              context, 'Doctor Login', Icons.medical_information, '/login',
              arguments: {'userType': 'doctor'}),
          _buildNavItem(
              context, 'Radiologist Login', Icons.mediation, '/loginRadio'),
          _buildNavItem(
              context, 'Patient Login', Icons.personal_injury, '/loginScreen'),
          const Divider(),
          _buildNavSection(context, 'Tools'),
          _buildNavItem(
              context, 'Create Report', Icons.note_add, '/createReport'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
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
      {Map<String, dynamic>? arguments}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        if (arguments != null) {
          Navigator.pushNamed(context, route, arguments: arguments);
        } else {
          Navigator.pushNamed(context, route);
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
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Yes, Logout'),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
