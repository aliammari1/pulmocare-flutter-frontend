import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  // Navigate to a new route that replaces the current route
  static void navigateTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Navigate to a new route and push it on top of the current route
  static void pushTo(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Navigate to a route by name (if you have named routes)
  static void navigateToNamed(BuildContext context, String name,
      {Map<String, String>? params, Object? extra}) {
    context.goNamed(name, pathParameters: params ?? {}, extra: extra);
  }

  // Navigate to a named route on top of current route
  static void pushNamed(BuildContext context, String name,
      {Map<String, String>? params, Object? extra}) {
    context.pushNamed(name, pathParameters: params ?? {}, extra: extra);
  }

  // Check if can go back
  static bool canGoBack(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  // Replace the current route with a new one
  static void replaceTo(BuildContext context, String route, {Object? extra}) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    }
    context.go(route, extra: extra);
  }

  // Helper method to navigate with a transition
  static Future<T?> pushWithTransition<T extends Object?>(
    BuildContext context,
    String route, {
    Object? extra,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
  }) async {
    return context.push<T>(
      route,
      extra: extra,
    );
  }

  // Show a dialog with transition
  static Future<T?> showTransitionDialog<T>(BuildContext context,
      {Widget? dialog}) async {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return dialog ?? const Center(child: CircularProgressIndicator());
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            child: child,
          ),
        );
      },
    );
  }

  // Navigate to PDF actions screen
  static Future<void> navigateToPdfActions(BuildContext context) async {
    context.go('/pdf-actions');
  }

  // Navigate with slide animation
  static void navigateWithSlideAnimation(BuildContext context, String route,
      {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Navigate to a route, replacing the current screen
  static void navigateAndReplace(BuildContext context, String route,
      {Object? extra}) {
    context.go(route, extra: extra);
  }

  // Go back to previous route
  static void goBack(BuildContext context) {
    context.pop();
  }

  // Go back to previous screen or navigate to entry view if can't go back
  static void goBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/entryView');
    }
  }

  // Navigate to home screen and clear navigation stack
  static void navigateToHome(BuildContext context) {
    context.go('/home');
  }

  // Show a dialog with custom content
  static Future<T?> showCustomDialog<T>(BuildContext context, Widget content) {
    return showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: content,
        );
      },
    );
  }

  // Show a snackbar with a message
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
