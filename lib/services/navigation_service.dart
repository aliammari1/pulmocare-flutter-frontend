import 'package:flutter/material.dart';

class NavigationService {
  static Future<void> navigateToPdfActions(
    BuildContext context, {
    bool withAnimation = true,
  }) async {
    if (withAnimation) {
      await Navigator.pushNamed(context, '/pdf-actions');
    } else {
      await Navigator.pushReplacementNamed(context, '/pdf-actions');
    }
  }

  static void showTransitionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TransitionDialog(),
    );
  }
}

class TransitionDialog extends StatelessWidget {
  const TransitionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Préparation de votre ordonnance...'),
          ],
        ),
      ),
    );
  }
}
