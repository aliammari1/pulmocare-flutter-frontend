import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: AppTheme.turquoise.withAlpha((0.5 * 255).toInt()),
          ),
          const SizedBox(height: 16),
          Text(
            'Settings Coming Soon',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.turquoise.withAlpha((0.7 * 255).toInt()),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
