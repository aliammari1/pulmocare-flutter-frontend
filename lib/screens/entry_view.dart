import 'package:flutter/material.dart';
import 'package:medapp/screens/login_screen.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/screens/login_radio.dart';
import 'login_view.dart';

class EntryView extends StatelessWidget {
  const EntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF81C9F3), Color(0xFF35C5CF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.medical_services,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pulmocare',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              _buildLoginButton(
                context,
                'Sign in as Doctor',
                Icons.medical_information,
                'doctor',
              ),
              const SizedBox(height: 16),
              _buildLoginButton(
                context,
                'Sign in as Radiologist',
                Icons.mediation,
                'radiologist',
              ),
              const SizedBox(height: 16),
              _buildLoginButton(
                context,
                'Sign in as Patient',
                Icons.person,
                'patient',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context, String text, IconData icon, String userType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: () {
          switch (userType) {
            case 'doctor':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginView(userType: userType),
                ),
              );
              break;
            case 'radiologist':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginRadioView(),
                ),
              );
              break;
            case 'patient':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
              break;
            default:
              return;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.turquoise),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.turquoise,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
