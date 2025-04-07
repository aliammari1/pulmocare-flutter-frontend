import 'package:flutter/material.dart';
import 'package:medapp/screens/ReportHomeScreen.dart';
import 'package:medapp/screens/Signup_screen.dart';
import 'package:medapp/services/auth_radio_view_model.dart';
import 'package:medapp/services/auth_view_model_patient.dart';
import 'package:medapp/screens/patients_view.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'screens/create_report_screen.dart';
import 'services/service_locator.dart';
import 'services/report_service.dart';
import 'providers/report_provider.dart';
import 'screens/reports/reports_list_screen.dart';
import 'services/auth_view_model.dart';
import 'services/chat_viewmodel.dart';
import 'screens/login_view.dart';
import 'screens/home_view_radio.dart';
import 'screens/home_view.dart';
import 'screens/entry_view.dart';
import 'screens/splash_screen.dart';
import 'screens/login_radio.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'package:medapp/screens/AppointmentsScreen.dart';
import 'package:medapp/screens/ArchiveScreen.dart';
import 'package:medapp/screens/RapportScreen.dart';
import 'package:medapp/screens/profile_radio.dart';
import 'package:medapp/screens/signup_view.dart';
import 'package:medapp/screens/signup_radio.dart';
import 'package:medapp/services/notification_provider.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup service locator
    await setupServiceLocator();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => ChatViewModel()),
          ChangeNotifierProvider(
            create: (_) => ReportProvider(getIt<ReportService>()),
          ),
          ChangeNotifierProvider(create: (_) => AuthRadioViewModel()),
          ChangeNotifierProvider(create: (_) => PatientAuthViewModel()),
          ChangeNotifierProvider(create: (_) => NotificationProvider())
        ],
        child: const MedicalApp(),
      ),
    );
  }, (error, stackTrace) {
    // Improved error handling
    debugPrint('Error in main: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class MedicalApp extends StatefulWidget {
  const MedicalApp({super.key});

  @override
  State<MedicalApp> createState() => _MedicalAppState();
}

class _MedicalAppState extends State<MedicalApp> {
  // Preload the EntryView
  final _entryViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Pre-build the EntryView to have it ready
    final entryView = EntryView(key: _entryViewKey);

    return MaterialApp(
      title: 'Pulmocare',
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeView(),
        '/homeRadio': (context) => const HomeViewRadio(),
        '/dashboard': (context) => const HomeScreen(),
        '/login': (context) => const LoginView(userType: 'default'),
        '/loginRadio': (context) => const LoginRadioView(),
        '/loginScreen': (context) => const LoginScreen(),
        '/signupView': (context) => const SignupView(),
        '/signupRadio': (context) => const SignupRadioView(),
        '/archiveScreen': (context) => ArchiveScreen(),
        '/rapportScreen': (context) => RapportScreen(),
        '/appointmentsScreen': (context) => const AppointmentsScreen(),
        '/profileRadio': (context) => const ProfileRadioView(),
        '/createReport': (context) => const CreateReportScreen(),
        '/reportsList': (context) => const ReportsListScreen(),
        "/add-patient": (context) => const PatientSignupView(),
        "/patients_doctor": (context) => const PatientsView(),
        '/entryView': (context) => entryView, // Use the pre-built instance
      },
      builder: (context, child) {
        // ErrorWidget customization to prevent red screen flashes
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // If in debug mode, show development error screen with reduced flashiness
          if (context != null) {
            return Container(
              color: Colors.transparent,
              child: Center(
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050A30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.7), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.amber, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'App is loading...',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (false) // Only in extreme debug cases
                          Text(
                            details.exception.toString(),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(color: Colors.transparent);
        };

        return child!;
      },
    );
  }
}
