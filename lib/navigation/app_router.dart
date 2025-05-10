import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/user.dart';
import 'package:medapp/screens/appointment_detail_screen.dart';
import 'package:medapp/screens/book_appointment_screen.dart';
import 'package:medapp/screens/contact_doctor_screen.dart';
import 'package:medapp/screens/create_prescription_screen.dart';
import 'package:medapp/screens/emergency_contacts_screen.dart';
import 'package:medapp/screens/examination_detail_screen.dart';
import 'package:medapp/screens/find_specialist_screen.dart';
import 'package:medapp/screens/integrated_doctor_dashboard.dart';
import 'package:medapp/screens/notifications_screen.dart';
import 'package:medapp/screens/patient_appointments_screen.dart';
import 'package:medapp/screens/patient_reports_screen.dart';
// Doctor screens
import 'package:medapp/screens/ai_diagnosis_dashboard_screen.dart';
import 'package:medapp/screens/patient_timeline_explorer_screen.dart';
import 'package:medapp/screens/voice_to_prescription_screen.dart';
import 'package:medapp/screens/remote_patient_monitoring_screen.dart';
import 'package:medapp/screens/anatomical_viewer_screen.dart';
// Radiologist screens
import 'package:medapp/screens/ai_image_analysis_screen.dart';
import 'package:medapp/screens/collaborative_review_board_screen.dart';
import 'package:medapp/screens/advanced_visualization_lab_screen.dart';
import 'package:medapp/screens/educational_case_builder_screen.dart';
// Patient screens
import 'package:medapp/screens/symptom_tracker_screen.dart';
import 'package:medapp/screens/medication_manager_screen.dart';
import 'package:medapp/screens/virtual_waiting_room_screen.dart';
import 'package:medapp/screens/recovery_progress_screen.dart';
import 'package:medapp/screens/health_literacy_screen.dart';
// All users screens
import 'package:medapp/screens/communication_hub_screen.dart';
import 'package:medapp/screens/community_support_screen.dart';
import 'package:medapp/screens/wellness_recommendation_screen.dart';
import 'package:medapp/screens/document_vault_screen.dart';
import 'package:medapp/screens/emergency_info_card_screen.dart';
import 'package:provider/provider.dart';
import '../screens/entry_view.dart';
import '../screens/login_view.dart';
import '../screens/splash_screen.dart';
import '../screens/patients_view.dart';
import '../screens/signup_view.dart';
import '../screens/profile_view.dart';
import '../screens/settings_view.dart';
import '../screens/news_view.dart';
import '../screens/ArchiveScreen.dart';
import '../screens/RapportScreen.dart';
import '../screens/create_report_screen.dart';
import '../screens/DoctorScreen.dart';
import '../screens/add_patient_screen.dart';
import '../screens/prescriptions_screen.dart';
import '../screens/prescription_detail_screen.dart';
import '../screens/radiology_reports_screen.dart';
import '../screens/radiology_report_detail_screen.dart';
import '../screens/radiology_request_screen.dart';
import '../screens/patient_history_screen.dart';
import '../screens/doctor_profile_screen.dart';
import '../screens/doctor_appointments_screen.dart';
import '../services/auth_view_model.dart';
import '../screens/radiologist_dashboard.dart';
import '../screens/radiology_examination_list_screen.dart';
import '../screens/patient_dashboard.dart';
import '../screens/patient_medical_records_screen.dart';
import '../screens/forgot_password_view.dart';
import 'package:medapp/screens/telemedicine_screen.dart';
import 'package:medapp/screens/video_call_screen.dart';
import 'package:medapp/screens/lab_results_screen.dart';
import 'package:medapp/screens/health_metrics_screen.dart';
import 'package:medapp/screens/medical_documents_screen.dart';
import 'package:medapp/screens/advanced_image_analysis_screen.dart';
import 'package:medapp/screens/exam_comparison_screen.dart';
import 'package:medapp/screens/radiology_knowledge_base_screen.dart';
import 'package:medapp/screens/collaborative_case_screen.dart';
import 'package:medapp/screens/treatment_timeline_screen.dart';
import 'package:medapp/screens/clinical_decision_support_screen.dart';
import 'package:medapp/screens/team_collaboration_screen.dart';
import 'package:medapp/screens/follow_up_scheduler_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,

    // Enhanced redirect logic with better user type checking
    redirect: (BuildContext context, GoRouterState state) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final isLoggedIn = authViewModel.isAuthenticated;
      final userRole = authViewModel.role;
      final currentPath = state.matchedLocation;

      // Public routes - accessible without authentication
      final publicRoutes = [
        '/splash',
        '/entryView',
        '/login',
        '/register',
        '/register',
        '/forgot-password'
      ];

      // Check if the current path is a public route
      final isPublicRoute = publicRoutes.contains(currentPath);

      // Routes that should only be accessible to doctors
      final doctorRoutes = [
        '/doctor-dashboard',
        '/doctor-profile',
        '/doctor-appointments',
        '/doctors',
        '/patients',
        '/add-patient',
        '/patient-details',
        '/patient-history',
        '/prescriptions',
        '/prescription',
        '/create-prescription',
        '/request-radiology',
        '/treatment-timeline',
        '/clinical-decision-support',
        '/team-collaboration',
        '/follow-up-scheduler',
      ];

      // Routes that should only be accessible to radiologists
      final radiologistRoutes = [
        '/radiologist-dashboard',
        '/radiology-reports',
        '/radiology-report',
        '/radiology-examinations',
        '/radiology-examination',
        '/advanced-image-analysis',
        '/exam-comparison',
        '/radiology-knowledge-base',
        '/collaborative-case',
      ];

      // Routes that should only be accessible to patients
      final patientRoutes = [
        '/patient-dashboard',
        '/patient-records',
        '/patient-appointments',
        '/appointment',
        '/book-appointment',
        '/patient-reports',
        '/contact-doctor',
        '/find-specialist',
        '/emergency-contacts',
        '/examination',
        // New patient routes
        '/telemedicine',
        '/video-call',
        '/lab-results',
        '/health-metrics',
        '/medical-documents',
      ];

      // 1. If not logged in but trying to access protected route, redirect to entry view
      if (!isLoggedIn && !isPublicRoute) {
        return '/entryView';
      }

      // 2. If logged in but trying to access public route, redirect to appropriate dashboard
      if (isLoggedIn && isPublicRoute) {
        print("Role: $userRole");

        switch (userRole) {
          case 'doctor':
            return '/doctor-dashboard';
          case 'radiologist':
            return '/radiologist-dashboard';
          case 'patient':
            return '/patient-dashboard';
          default:
            // If role is empty or undefined, redirect to entry view to force re-login
            if (userRole.isEmpty) {
              print(
                  "Warning: User is authenticated but role is empty. Forcing re-login.");
              // Clear auth data and redirect to entry view
              Provider.of<AuthViewModel>(context, listen: false)
                  .logout(context);
              return '/entryView';
            }
            return '/entryView'; // Fallback if role is undefined but not empty
        }
      }

      // 3. Check for user type-specific access restrictions
      if (isLoggedIn) {
        // FIXED: Don't redirect doctors away from doctor routes
        if (userRole == 'doctor' &&
            patientRoutes.any((route) =>
                currentPath == route || currentPath.startsWith("$route/"))) {
          return '/doctor-dashboard';
        }

        if (userRole == 'radiologist' &&
            (doctorRoutes.any((route) =>
                    currentPath == route ||
                    currentPath.startsWith("$route/")) ||
                patientRoutes.any((route) =>
                    currentPath == route ||
                    currentPath.startsWith("$route/")))) {
          return '/radiologist-dashboard';
        }

        if (userRole == 'patient' &&
            (doctorRoutes.any((route) =>
                    currentPath == route ||
                    currentPath.startsWith("$route/")) ||
                radiologistRoutes.any((route) =>
                    currentPath == route ||
                    currentPath.startsWith("$route/")))) {
          return '/patient-dashboard';
        }
      }

      // Allow navigation to proceed
      return null;
    },

    routes: [
      // ========== PUBLIC ROUTES ==========
      // Splash and entry routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/entryView',
        builder: (context, state) => const EntryView(),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.extra as UserRole;
          return LoginView(role: role);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.extra as UserRole;
          return SignupView(role: role);
        },
      ),

      // ========== DOCTOR ROUTES ==========
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const IntegratedDoctorDashboard(),
      ),
      GoRoute(
        path: '/doctor-profile',
        builder: (context, state) => const DoctorProfileScreen(),
      ),
      GoRoute(
        path: '/doctor-appointments',
        builder: (context, state) => const DoctorAppointmentsScreen(),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const DoctorScreen(),
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const PatientsView(),
      ),
      GoRoute(
        path: '/add-patient',
        builder: (context, state) => const AddPatientScreen(),
      ),
      GoRoute(
        path: '/patient-details',
        builder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          return DoctorScreen(patientId: patient?['id']?.toString() ?? '');
        },
      ),
      GoRoute(
        path: '/patient-history/:id',
        builder: (context, state) {
          final patientId = state.pathParameters['id'] ?? '';
          return PatientHistoryScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/patient-history',
        builder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          final patientId = patient?['id']?.toString() ?? '';
          return PatientHistoryScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/prescriptions',
        builder: (context, state) => const PrescriptionsScreen(),
      ),
      GoRoute(
        path: '/prescription/:id',
        builder: (context, state) {
          final prescriptionId = state.pathParameters['id'] ?? '';
          return PrescriptionDetailScreen(prescriptionId: prescriptionId);
        },
      ),
      GoRoute(
        path: '/create-prescription',
        builder: (context, state) => const CreatePrescriptionScreen(),
      ),
      GoRoute(
        path: '/create-prescription/:id',
        builder: (context, state) {
          final prescriptionId = state.pathParameters['id'] ?? '';
          return PrescriptionDetailScreen(prescriptionId: prescriptionId);
        },
      ),
      GoRoute(
        path: '/create-report',
        builder: (context, state) => const CreateReportScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => RapportScreen(),
      ),
      GoRoute(
        path: '/request-radiology',
        builder: (context, state) => const RadiologyRequestScreen(),
      ),
      GoRoute(
        path: '/archiveScreen',
        builder: (context, state) => ArchiveScreen(),
      ),
      // New doctor routes
      GoRoute(
        path: '/treatment-timeline/:patientId',
        builder: (context, state) {
          final patientId = state.pathParameters['patientId'] ?? '';
          return TreatmentTimelineScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/clinical-decision-support',
        builder: (context, state) => const ClinicalDecisionSupportScreen(),
      ),
      GoRoute(
        path: '/team-collaboration',
        builder: (context, state) => const TeamCollaborationScreen(),
      ),
      GoRoute(
        path: '/follow-up-scheduler',
        builder: (context, state) => const FollowUpSchedulerScreen(),
      ),
      // Innovative doctor screens
      GoRoute(
        path: '/ai-diagnosis-dashboard',
        builder: (context, state) => const AIDiagnosisDashboardScreen(),
      ),
      GoRoute(
        path: '/patient-timeline',
        builder: (context, state) => const PatientTimelineExplorerScreen(),
      ),
      GoRoute(
        path: '/patient-timeline/:patientId',
        builder: (context, state) {
          final patientId = state.pathParameters['patientId'] ?? '';
          return PatientTimelineExplorerScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/voice-to-prescription',
        builder: (context, state) => const VoiceToPrescriptionScreen(),
      ),
      GoRoute(
        path: '/remote-patient-monitoring',
        builder: (context, state) => const RemotePatientMonitoringScreen(),
      ),
      GoRoute(
        path: '/anatomical-viewer',
        builder: (context, state) => const AnatomicalViewerScreen(),
      ),

      // ========== RADIOLOGIST ROUTES ==========
      GoRoute(
        path: '/radiologist-dashboard',
        builder: (context, state) => const RadiologistDashboard(),
      ),
      GoRoute(
        path: '/radiology-reports',
        builder: (context, state) => const RadiologyReportsScreen(),
      ),
      GoRoute(
        path: '/radiology-report/:id',
        builder: (context, state) {
          final reportId = state.pathParameters['id'] ?? '';
          return RadiologyReportDetailScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: '/radiology-examinations',
        builder: (context, state) => const RadiologyExaminationListScreen(),
      ),
      GoRoute(
        path: '/article-detail',
        builder: (context, state) => ArticleDetailScreen(
          article: state.extra as Map<String, dynamic>,
        ),
      ),
      GoRoute(
        path: '/category-articles',
        builder: (context, state) => CategoryArticlesScreen(
          category: state.extra as Map<String, dynamic>,
        ),
      ),
      GoRoute(
        path: '/radiology-examination/:id',
        builder: (context, state) {
          final examinationId = state.pathParameters['id'] ?? '';
          // If id is 'new', it's a new examination
          if (examinationId == 'new') {
            return const RadiologyExaminationListScreen(); // Replace with RadiologyExaminationFormScreen when created
          }
          return const RadiologyExaminationListScreen(); // Replace with RadiologyExaminationDetailScreen when created
        },
      ),
      // New radiologist routes
      GoRoute(
        path: '/advanced-image-analysis',
        builder: (context, state) => const AdvancedImageAnalysisScreen(),
      ),
      GoRoute(
        path: '/exam-comparison/:examId',
        builder: (context, state) {
          final examId = state.pathParameters['examId'] ?? '';
          return ExamComparisonScreen(examId: examId);
        },
      ),
      GoRoute(
        path: '/radiology-knowledge-base',
        builder: (context, state) => const RadiologyKnowledgeBaseScreen(),
      ),
      GoRoute(
        path: '/collaborative-case/:caseId',
        builder: (context, state) {
          final caseId = state.pathParameters['caseId'] ?? '';
          return CollaborativeCaseScreen(caseId: caseId);
        },
      ),
      // Innovative radiologist screens
      GoRoute(
        path: '/ai-image-analysis',
        builder: (context, state) => const AIImageAnalysisScreen(),
      ),
      GoRoute(
        path: '/collaborative-review-board',
        builder: (context, state) => const CollaborativeReviewBoardScreen(),
      ),
      GoRoute(
        path: '/advanced-visualization-lab',
        builder: (context, state) => const AdvancedVisualizationLabScreen(),
      ),
      GoRoute(
        path: '/educational-case-builder',
        builder: (context, state) => const EducationalCaseBuilderScreen(),
      ),

      // ========== PATIENT ROUTES ==========
      GoRoute(
        path: '/patient-dashboard',
        builder: (context, state) => const PatientDashboard(),
      ),
      GoRoute(
        path: '/patient-records',
        builder: (context, state) => const PatientMedicalRecordsScreen(),
      ),
      GoRoute(
        path: '/patient-appointments',
        builder: (context, state) => const PatientAppointmentsScreen(),
      ),
      GoRoute(
        path: '/appointment/:id',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id'] ?? '';
          return AppointmentDetailScreen(appointmentId: appointmentId);
        },
      ),
      GoRoute(
        path: '/book-appointment',
        builder: (context, state) => const BookAppointmentScreen(),
      ),
      GoRoute(
        path: '/patient-reports',
        builder: (context, state) => const PatientReportsScreen(),
      ),
      GoRoute(
        path: '/contact-doctor',
        builder: (context, state) => const ContactDoctorScreen(),
      ),
      GoRoute(
        path: '/find-specialist',
        builder: (context, state) => const FindSpecialistScreen(),
      ),
      GoRoute(
        path: '/emergency-contacts',
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: '/examination/:id',
        builder: (context, state) {
          final examinationId = state.pathParameters['id'] ?? '';
          return ExaminationDetailScreen(examinationId: examinationId);
        },
      ),
      // New patient routes
      GoRoute(
        path: '/telemedicine',
        builder: (context, state) => const TelemedicineScreen(),
      ),
      GoRoute(
        path: '/video-call',
        builder: (context, state) {
          final consultation = state.extra as Map<String, dynamic>;
          return VideoCallScreen(consultation: consultation);
        },
      ),
      GoRoute(
        path: '/lab-results',
        builder: (context, state) => const LabResultsScreen(),
      ),
      GoRoute(
        path: '/health-metrics',
        builder: (context, state) => const HealthMetricsScreen(),
      ),
      GoRoute(
        path: '/medical-documents',
        builder: (context, state) => const MedicalDocumentsScreen(),
      ),

      // Innovative patient screens
      GoRoute(
        path: '/symptom-tracker',
        builder: (context, state) => const SymptomTrackerScreen(),
      ),
      GoRoute(
        path: '/medication-manager',
        builder: (context, state) => const MedicationManagerScreen(),
      ),
      GoRoute(
        path: '/virtual-waiting-room',
        builder: (context, state) => const VirtualWaitingRoomScreen(),
      ),
      GoRoute(
        path: '/recovery-progress',
        builder: (context, state) => const RecoveryProgressScreen(),
      ),
      GoRoute(
        path: '/health-literacy',
        builder: (context, state) => const HealthLiteracyScreen(),
      ),

      // ========== COMMON ROUTES ==========
      // These routes are accessible by all authenticated users
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsView(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Innovative common screens for all users
      GoRoute(
        path: '/communication-hub',
        builder: (context, state) => const CommunicationHubScreen(),
      ),
      GoRoute(
        path: '/community-support',
        builder: (context, state) => const CommunitySupportScreen(),
      ),
      GoRoute(
        path: '/wellness-recommendation',
        builder: (context, state) => const WellnessRecommendationScreen(),
      ),
      GoRoute(
        path: '/document-vault',
        builder: (context, state) => const DocumentVaultScreen(),
      ),
      GoRoute(
        path: '/emergency-info-card',
        builder: (context, state) => const EmergencyInfoCardScreen(),
      ),
    ],

    // Error page for handling navigation errors or 404 cases
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF050A30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Navigation Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Page not found: ${state.fullPath}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final authViewModel =
                    Provider.of<AuthViewModel>(context, listen: false);
                if (authViewModel.isAuthenticated) {
                  if (authViewModel.role == 'doctor') {
                    context.go('/doctor-dashboard');
                  } else if (authViewModel.role == 'radiologist') {
                    context.go('/radiologist-dashboard');
                  } else {
                    context.go('/patient-dashboard');
                  }
                } else {
                  context.go('/entryView');
                }
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
