import 'package:flutter/material.dart';
import '../theme/style_constants.dart'; // Update this import

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: StyleConstants.primaryColor.withAlpha((0.1 * 255).toInt()),
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
