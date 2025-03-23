import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppTheme.turquoise.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Appointments Coming Soon',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.turquoise.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
