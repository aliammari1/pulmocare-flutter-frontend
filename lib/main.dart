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
import 'services/logging_service.dart';
import 'services/report_service.dart';
import 'providers/report_provider.dart';
import 'screens/reports/reports_list_screen.dart';
import 'services/auth_view_model.dart';
import 'services/chat_viewmodel.dart';
import 'screens/login_view.dart';
import 'screens/home_view_radio.dart';
import 'screens/home_view.dart';
import 'screens/entry_view.dart';
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

    // Initialize error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      getIt<LoggingService>().log(
        details.exception.toString(),
        LogLevel.error,
        error: details.exception,
        stackTrace: details.stack,
      );
    };

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
    // Handle errors outside of Flutter's error zone
    getIt<LoggingService>().log(
      'Uncaught error',
      LogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );
  });
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulmocare',
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const EntryView(),
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
      },
    );
  }
}

