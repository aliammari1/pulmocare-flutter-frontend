import 'package:flutter/material.dart';
import '../screens/ordonnance_screen.dart';
import '../screens/pdf_actions_screen.dart';
import '../screens/ordonnances_list_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String newOrdonnance = '/new-ordonnance';
  static const String pdfActions = '/pdf-actions';
  static const String ordonnancesList = '/ordonnances-list';
  static const String myOrdonnances = '/mes-ordonnances';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case newOrdonnance:
        return MaterialPageRoute(
          builder: (_) => const OrdonnanceScreen(),
          settings: settings,
        );
      case pdfActions:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PdfActionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case ordonnancesList:
      case myOrdonnances:
        return MaterialPageRoute(
          builder: (_) => const OrdonnancesListScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const OrdonnanceScreen(),
        );
    }
  }
}
