import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/doctor_service.dart';
import '../services/auth_view_model.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_dialog.dart';
import '../services/chat_viewmodel.dart';
import 'news_view.dart';
import 'profile_view.dart';
import '../widgets/app_drawer.dart';

class IntegratedDoctorDashboard extends StatefulWidget {
  const IntegratedDoctorDashboard({super.key});

  @override
  _IntegratedDoctorDashboardState createState() =>
      _IntegratedDoctorDashboardState();
}

class _IntegratedDoctorDashboardState extends State<IntegratedDoctorDashboard>
    with SingleTickerProviderStateMixin {
  final DoctorService _doctorService = DoctorService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();

    // Initialize animation controller for the FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Fetch profile data when dashboard is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, this would fetch actual dashboard data
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      setState(() {
        _dashboardData = {
          "appointmentsToday": 5,
          "pendingAppointments": 3,
          "totalPatients": 127,
          "newPatientsThisWeek": 8,
          "pendingReports": 4,
          "recentPatients": [
            {
              "id": "1",
              "name": "John Doe",
              "condition": "Respiratory Infection"
            },
            {"id": "2", "name": "Jane Smith", "condition": "Annual Checkup"},
            {"id": "3", "name": "Alex Johnson", "condition": "Follow-up"},
          ]
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openAIAssistant() {
    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    // Animate the button press
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ChatViewModel(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const ChatDialog(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const NewsView();
      case 2:
        return ProfileView();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeCard(),

              const SizedBox(height: 20),

              // AI Assistant box
              _buildAIAssistantBox(),

              const SizedBox(height: 20),

              // Quick stats
              _buildStatsGrid(),

              const SizedBox(height: 20),

              // Quick access buttons
              _buildQuickAccessSection(),

              const SizedBox(height: 20),

              // Recent patients
              _buildRecentPatientsSection(),

              const SizedBox(height: 20),

              // Upcoming appointments
              _buildUpcomingAppointmentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final doctor = authViewModel.currentDoctor;
    final currentTime = TimeOfDay.now();
    String greeting;

    if (currentTime.hour < 12) {
      greeting = "Good Morning";
    } else if (currentTime.hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 30,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting,",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Dr. ${doctor?.name ?? 'Doctor'}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              onPressed: () => context.go('/doctor-profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: _openAIAssistant,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "AI Medical Assistant",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's help diagnose and\ntreat your patients",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.medical_services,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          "Today's Appointments",
          _dashboardData["appointmentsToday"].toString(),
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildStatCard(
          "Pending Appointments",
          _dashboardData["pendingAppointments"].toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          "Total Patients",
          _dashboardData["totalPatients"].toString(),
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          "New Patients This Week",
          _dashboardData["newPatientsThisWeek"].toString(),
          Icons.person_add,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate responsive sizes based on container width
      final iconSize = constraints.maxWidth * 0.12;
      final titleSize = constraints.maxWidth * 0.07;
      final valueSize = constraints.maxWidth * 0.12;

      // Dynamic padding based on available height
      final verticalPadding = constraints.maxHeight * 0.05;
      final horizontalPadding = constraints.maxWidth * 0.08;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          // Adjust padding to prevent overflow
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding.clamp(8.0, 16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // More flexible spacing
            mainAxisSize: MainAxisSize.min, // Minimize vertical space
            children: [
              Icon(
                icon,
                size: iconSize.clamp(16.0, 28.0), // Slightly smaller max size
                color: color,
              ),
              // Flexible spacing
              Flexible(
                child: SizedBox(height: constraints.maxHeight * 0.03),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize:
                      titleSize.clamp(10.0, 14.0), // Smaller text if needed
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Flexible spacing
              Flexible(
                child: SizedBox(height: constraints.maxHeight * 0.02),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize:
                      valueSize.clamp(16.0, 24.0), // Slightly smaller values
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickAccessButton(
                "Patients",
                Icons.people,
                Colors.blue,
                () => context.go('/patients'),
              ),
              _buildQuickAccessButton(
                "Appointments",
                Icons.calendar_today,
                Colors.green,
                () => context.go('/doctor-appointments'),
              ),
              _buildQuickAccessButton(
                "Prescriptions",
                Icons.medical_information,
                Colors.orange,
                () => context.go('/prescriptions'),
              ),
              _buildQuickAccessButton(
                "Radiology",
                Icons.image,
                Colors.purple,
                () => context.go('/radiology-reports'),
              ),
              _buildQuickAccessButton(
                "New Request",
                Icons.add_circle_outline,
                Colors.red,
                () => context.go('/request-radiology'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatientsSection() {
    final recentPatients = _dashboardData["recentPatients"] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Patients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/patients'),
              child: Text(
                "See All",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPatients.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final patient = recentPatients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    patient["name"][0],
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(patient["name"]),
                subtitle: Text(patient["condition"]),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    context.go('/patient-history', extra: patient);
                  },
                ),
                onTap: () {
                  context.go('/patient-history', extra: patient);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsSection() {
    // Mock upcoming appointments - in a real app, this would come from the API
    final upcomingAppointments = [
      {
        "id": "1",
        "patientName": "John Doe",
        "time": "10:00 AM",
        "date": "Today",
        "reason": "Follow-up"
      },
      {
        "id": "2",
        "patientName": "Jane Smith",
        "time": "11:30 AM",
        "date": "Today",
        "reason": "Annual Checkup"
      },
      {
        "id": "3",
        "patientName": "Mike Johnson",
        "time": "2:15 PM",
        "date": "Tomorrow",
        "reason": "Consultation"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Upcoming Appointments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/doctor-appointments'),
              child: Text(
                "See All",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingAppointments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final appointment = upcomingAppointments[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.access_time, color: Colors.blue),
                ),
                title: Text(appointment["patientName"] as String),
                subtitle:
                    Text("${appointment["date"]} at ${appointment["time"]}"),
                trailing: Text(
                  appointment["reason"] as String,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Show notifications
                  context.go('/notifications');
                },
              ),
              if (_dashboardData.containsKey('notifications') &&
                  _dashboardData['notifications']
                      .any((n) => n['read'] == false))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withAlpha((0.2 * 255).toInt()),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            onTap: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_outlined),
                activeIcon: Icon(Icons.newspaper),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_fabAnimationController.value * 0.1),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _openAIAssistant,
                backgroundColor: AppTheme.primaryColor,
                elevation: 4,
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
