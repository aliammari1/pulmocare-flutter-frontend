import 'package:flutter/material.dart';
import 'package:medapp/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'services/service_locator.dart';
import 'services/report_service.dart';
import 'providers/report_provider.dart';
import 'services/auth_view_model.dart';
import 'services/chat_viewmodel.dart';
import 'theme/app_theme.dart';
import 'package:medapp/services/notification_provider.dart';
import 'package:flutter/services.dart';
import 'providers/user_provider.dart';

void main() async {
  await runZonedGuarded(() async {
    debugPrint('DEBUG: Starting app initialization');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('DEBUG: Flutter binding initialized');

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surfaceColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Setup service locator
    await setupServiceLocator();
    debugPrint('DEBUG: Service locator setup complete');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => ChatViewModel()),
          ChangeNotifierProvider(
            create: (_) => ReportProvider(getIt<ReportService>()),
          ),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MedicalApp(),
      ),
    );
    debugPrint('DEBUG: App started with providers');
  }, (error, stackTrace) {
    // Improved error handling
    debugPrint('ERROR in main: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class MedicalApp extends StatefulWidget {
  const MedicalApp({super.key});

  @override
  State<MedicalApp> createState() => _MedicalAppState();
}

class _MedicalAppState extends State<MedicalApp> {
  @override
  void initState() {
    super.initState();
    // Initialize UserProvider data
    Future.delayed(Duration.zero, () {
      // Initialize UserProvider with data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.initUserData();

      // Sync with AuthViewModel if user is authenticated
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.isAuthenticated) {
        authViewModel.syncWithUserProvider(userProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PulmoCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme:
          AppTheme.lightTheme, // Using light theme for now for consistency
      themeMode:
          ThemeMode.light, // Forcing light mode for medical app reliability
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Apply text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: _ErrorHandlingWrapper(child: child!),
        );
      },
    );
  }
}

class _ErrorHandlingWrapper extends StatelessWidget {
  final Widget child;

  const _ErrorHandlingWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // ErrorWidget customization for a cleaner error experience
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: AppTheme.surfaceColor,
        child: Center(
          child: Opacity(
            opacity: 0.9,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              margin: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                boxShadow: AppTheme.elevationMedium,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: AppTheme.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    'Preparing Medical Data',
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeXLarge,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'Please wait while we load your medical information...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  CircularProgressIndicator(
                    color: AppTheme.secondaryColor,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    return child;
  }
}
