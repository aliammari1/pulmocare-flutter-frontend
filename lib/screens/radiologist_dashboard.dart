import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:medapp/services/auth_view_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class RadiologistDashboard extends StatefulWidget {
  const RadiologistDashboard({super.key});

  @override
  _RadiologistDashboardState createState() => _RadiologistDashboardState();
}

class _RadiologistDashboardState extends State<RadiologistDashboard>
    with SingleTickerProviderStateMixin {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _dashboardData = {};
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // In a real app, you would fetch this data from your API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for dashboard
      setState(() {
        _dashboardData = {
          "pendingExaminations": [
            {
              "id": "e1",
              "patientName": "Ahmed Ben Ali",
              "patientId": "P10045",
              "age": 45,
              "gender": "Male",
              "type": "X-Ray",
              "bodyPart": "Chest",
              "requestingDoctor": "Dr. Jane Smith",
              "priority": "urgent",
              "requestedAt": "2025-04-25T10:30:00",
              "scheduledFor": "2025-04-26T14:15:00",
              "clinicalInfo":
                  "Suspected pneumonia, persistent cough for 2 weeks"
            },
            {
              "id": "e2",
              "patientName": "Fatma Bouazizi",
              "patientId": "P10236",
              "age": 67,
              "gender": "Female",
              "type": "MRI",
              "bodyPart": "Brain",
              "requestingDoctor": "Dr. Mohamed Ben Salem",
              "priority": "routine",
              "requestedAt": "2025-04-24T15:45:00",
              "scheduledFor": "2025-04-27T09:00:00",
              "clinicalInfo":
                  "Recurring headaches, evaluation for potential vascular abnormalities"
            },
            {
              "id": "e3",
              "patientName": "Youssef Trabelsi",
              "patientId": "P10198",
              "age": 32,
              "gender": "Male",
              "type": "CT Scan",
              "bodyPart": "Abdomen",
              "requestingDoctor": "Dr. Ahmed Khelifi",
              "priority": "high",
              "requestedAt": "2025-04-25T09:15:00",
              "scheduledFor": "2025-04-26T16:30:00",
              "clinicalInfo": "Abdominal pain, suspected appendicitis"
            },
            {
              "id": "e4",
              "patientName": "Leila Ben Salah",
              "patientId": "P10387",
              "age": 58,
              "gender": "Female",
              "type": "Ultrasound",
              "bodyPart": "Thyroid",
              "requestingDoctor": "Dr. Fatma Bouazizi",
              "priority": "routine",
              "requestedAt": "2025-04-23T14:00:00",
              "scheduledFor": "2025-04-28T11:45:00",
              "clinicalInfo":
                  "Enlarged thyroid, follow-up from previous abnormal bloodwork"
            },
            {
              "id": "e5",
              "patientName": "Omar Ghanmi",
              "patientId": "P10412",
              "age": 8,
              "gender": "Male",
              "type": "X-Ray",
              "bodyPart": "Right arm",
              "requestingDoctor": "Dr. Leila Trabelsi",
              "priority": "urgent",
              "requestedAt": "2025-04-25T16:30:00",
              "scheduledFor": "2025-04-26T09:30:00",
              "clinicalInfo": "Suspected fracture after falling while playing"
            }
          ],
          "completedExaminations": [
            {
              "id": "e6",
              "patientName": "Sami Belhadj",
              "patientId": "P10128",
              "age": 52,
              "gender": "Male",
              "type": "CT Scan",
              "bodyPart": "Chest",
              "requestingDoctor": "Dr. Jane Smith",
              "completedAt": "2025-04-25T14:30:00",
              "diagnosis": "No evidence of pulmonary embolism",
              "status": "finalized"
            },
            {
              "id": "e7",
              "patientName": "Amina Sahli",
              "patientId": "P10189",
              "age": 35,
              "gender": "Female",
              "type": "MRI",
              "bodyPart": "Knee",
              "requestingDoctor": "Dr. Mohamed Ben Salem",
              "completedAt": "2025-04-25T11:15:00",
              "diagnosis": "Meniscal tear, grade II",
              "status": "finalized"
            },
            {
              "id": "e8",
              "patientName": "Karim Neji",
              "patientId": "P10256",
              "age": 41,
              "gender": "Male",
              "type": "X-Ray",
              "bodyPart": "Lumbar spine",
              "requestingDoctor": "Dr. Ahmed Khelifi",
              "completedAt": "2025-04-24T16:45:00",
              "diagnosis": "Degenerative changes at L4-L5",
              "status": "preliminary"
            }
          ],
          "weeklyStats": {
            "examinations": [12, 9, 15, 10, 14, 8, 6],
            "reports": [10, 8, 14, 9, 12, 7, 5]
          },
          "examinationTypes": {
            "xray": 45,
            "ct": 28,
            "mri": 18,
            "ultrasound": 15,
            "mammography": 9,
            "fluoroscopy": 5
          },
          "notifications": [
            {
              "id": "n1",
              "title": "Urgent examination request",
              "message": "New urgent X-Ray requested for patient Omar Ghanmi",
              "time": "30 minutes ago",
              "read": false
            },
            {
              "id": "n2",
              "title": "System maintenance",
              "message":
                  "Scheduled system maintenance tonight from 2 AM to 4 AM",
              "time": "2 hours ago",
              "read": true
            },
            {
              "id": "n3",
              "title": "Report query",
              "message":
                  "Dr. Mohamed Ben Salem has questions about MRI report #R-2025-156",
              "time": "Yesterday",
              "read": false
            }
          ]
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radiologist Dashboard'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showNotificationsDialog();
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
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              context.push('/profileRadio');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.push('/radiology-examinations');
              break;
            case 2:
              context.push('/radiology-reports');
              break;
            case 3:
              context.push('/profileRadio');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Examinations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildActivityOverviewSection(),
          const SizedBox(height: 24),
          _buildTabSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    String name = "Radiologist";

    if (authViewModel.isAuthenticated && authViewModel.currentUser != null) {
      name = authViewModel.currentUser!.name!.split(' ')[0];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Make this section responsive
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 300) {
                  // Wide layout - row with space between
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting, $name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(now),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout - stack in column
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$greeting, $name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(now),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Make status cards row wrap with flexible layout
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildStatusCard(
                  'Pending',
                  _dashboardData['pendingExaminations'].length.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatusCard(
                  'Completed',
                  _dashboardData['completedExaminations'].length.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatusCard(
                  'Urgent',
                  _dashboardData['pendingExaminations']
                      .where((e) => e['priority'] == 'urgent')
                      .length
                      .toString(),
                  Icons.priority_high,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Use LayoutBuilder to make chart responsive
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth > 400 ? 200 : 250,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildActivityChart(context),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Wrap in SingleChildScrollView to handle horizontal overflow in small screens
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 400
                ? MediaQuery.of(context).size.width -
                    32 // Standard width minus padding
                : 400, // Minimum width to ensure chart is visible
            child: _buildExaminationTypesCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    // Add debug prints to track the error
    debugPrint(
        'DEBUG: Starting _buildActivityChart with data: ${_dashboardData['weeklyStats']}');

    int totalExams = 0;
    try {
      // Fix the reduce operation by ensuring proper integer type handling
      if (_dashboardData['weeklyStats']['examinations'] != null &&
          (_dashboardData['weeklyStats']['examinations'] as List).isNotEmpty) {
        debugPrint(
            'DEBUG: About to process examinations list: ${_dashboardData['weeklyStats']['examinations']}');
        debugPrint(
            'DEBUG: List type: ${_dashboardData['weeklyStats']['examinations'].runtimeType}');

        var castedList =
            (_dashboardData['weeklyStats']['examinations'] as List<dynamic>)
                .cast<int>();
        debugPrint('DEBUG: Casted list: $castedList');

        totalExams = castedList.reduce((int a, int b) {
          debugPrint('DEBUG: Reducing $a + $b');
          return a + b;
        });
        debugPrint('DEBUG: Total exams after reduce: $totalExams');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR in chart processing: $e');
      debugPrint('Stack trace: $stackTrace');
      totalExams = 0;
    }

    // Continue with remaining chart code
    final weeklyStats = _dashboardData['weeklyStats'];
    final examinations = weeklyStats['examinations'] as List;
    final reports = weeklyStats['reports'] as List;

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make this row responsive to prevent overflow
        LayoutBuilder(
          builder: (context, constraints) {
            // Check if we have enough space for side-by-side layout
            if (constraints.maxWidth > 400) {
              // Wider layout - use row with spaceBetween
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min, // Only take needed space
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Exams', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade300,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Reports', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              );
            } else {
              // Narrower layout - stack vertically
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min, // Only take needed space
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Exams', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade300,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Reports', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: (examinations)
                      .cast<int>() // Explicitly cast values to int
                      .fold<int>(
                          0, (int max, int item) => item > max ? item : max)
                      .toDouble() *
                  1.2,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
              barGroups: List.generate(
                days.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: examinations[index].toDouble(),
                      color: AppTheme.primaryColor,
                      width: 8,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: reports[index].toDouble(),
                      color: Colors.orange.shade300,
                      width: 8,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExaminationTypesCard() {
    final examinationTypes = _dashboardData['examinationTypes'];
    final total = examinationTypes.values
        .fold<int>(0, (int sum, dynamic count) => sum + (count as int));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Examination Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: examinationTypes['xray'].toDouble(),
                            title: '',
                            color: Colors.blue,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: examinationTypes['ct'].toDouble(),
                            title: '',
                            color: Colors.green,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: examinationTypes['mri'].toDouble(),
                            title: '',
                            color: Colors.red,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: examinationTypes['ultrasound'].toDouble(),
                            title: '',
                            color: Colors.purple,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: examinationTypes['mammography'].toDouble(),
                            title: '',
                            color: Colors.orange,
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: examinationTypes['fluoroscopy'].toDouble(),
                            title: '',
                            color: Colors.teal,
                            radius: 50,
                          ),
                        ],
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartLegendItem('X-Ray', Colors.blue,
                            examinationTypes['xray'], total),
                        _buildChartLegendItem('CT Scan', Colors.green,
                            examinationTypes['ct'], total),
                        _buildChartLegendItem(
                            'MRI', Colors.red, examinationTypes['mri'], total),
                        _buildChartLegendItem('Ultrasound', Colors.purple,
                            examinationTypes['ultrasound'], total),
                        _buildChartLegendItem('Mammography', Colors.orange,
                            examinationTypes['mammography'], total),
                        _buildChartLegendItem('Fluoroscopy', Colors.teal,
                            examinationTypes['fluoroscopy'], total),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegendItem(
      String label, Color color, int count, int total) {
    final percentage = (count / total * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const Spacer(),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pending Examinations'),
              Tab(text: 'Completed Examinations'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
          ),
        ),
        // Use layoutBuilder to make tab content responsive
        LayoutBuilder(builder: (context, constraints) {
          // Dynamic height based on screen size
          double height = constraints.maxWidth > 600 ? 450 : 400;
          return SizedBox(
            height: height,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingExaminations(),
                _buildCompletedExaminations(),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPendingExaminations() {
    final pendingExaminations = _dashboardData['pendingExaminations'] as List;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: pendingExaminations.length,
      itemBuilder: (context, index) {
        final examination = pendingExaminations[index];
        final priority = examination['priority'] as String;
        Color priorityColor;

        switch (priority) {
          case 'urgent':
            priorityColor = Colors.red;
            break;
          case 'high':
            priorityColor = Colors.orange;
            break;
          default:
            priorityColor = Colors.green;
        }

        final scheduledDate = DateTime.parse(examination['scheduledFor']);
        final formattedDate = DateFormat('MMM d, yyyy').format(scheduledDate);
        final formattedTime = DateFormat('h:mm a').format(scheduledDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: priorityColor.withOpacity(0.3),
              width: priority == 'urgent' ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: priorityColor.withOpacity(0.2),
              child: Icon(
                _getExaminationIcon(examination['type']),
                color: priorityColor,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${examination['type']} - ${examination['bodyPart']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Patient: ${examination['patientName']} (${examination['age']}${examination['gender'] == 'Male' ? 'M' : 'F'})',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Requested by: ${examination['requestingDoctor']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedDate at $formattedTime',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              // Navigate to examination details
              context.push('/radiology-examination/${examination['id']}');
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedExaminations() {
    final completedExaminations =
        _dashboardData['completedExaminations'] as List;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: completedExaminations.length,
      itemBuilder: (context, index) {
        final examination = completedExaminations[index];
        final status = examination['status'] as String;
        final isFinalized = status == 'finalized';

        final completedDate = DateTime.parse(examination['completedAt']);
        final formattedDate = DateFormat('MMM d, yyyy').format(completedDate);
        final formattedTime = DateFormat('h:mm a').format(completedDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isFinalized
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              child: Icon(
                _getExaminationIcon(examination['type']),
                color: isFinalized ? Colors.green : Colors.orange,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${examination['type']} - ${examination['bodyPart']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFinalized
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isFinalized ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Patient: ${examination['patientName']} (${examination['age']}${examination['gender'] == 'Male' ? 'M' : 'F'})',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Diagnosis: ${examination['diagnosis']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedDate at $formattedTime',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              context.push('/radiology-report/${examination['id']}');
            },
          ),
        );
      },
    );
  }

  IconData _getExaminationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'x-ray':
        return Icons.broken_image;
      case 'ct scan':
      case 'ct':
        return Icons.view_in_ar;
      case 'mri':
        return Icons.panorama;
      case 'ultrasound':
        return Icons.waves;
      case 'mammography':
        return Icons.scatter_plot;
      case 'fluoroscopy':
        return Icons.video_camera_back;
      default:
        return Icons.medical_services;
    }
  }

  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Removes default padding
                  itemCount: _dashboardData['notifications'].length,
                  itemBuilder: (context, index) {
                    final notification = _dashboardData['notifications'][index];
                    final isUnread = notification['read'] == false;

                    return Column(
                      children: [
                        ListTile(
                          dense: true, // Makes the ListTile more compact
                          leading: CircleAvatar(
                            radius: 18, // Slightly smaller avatar
                            backgroundColor: isUnread
                                ? AppTheme.primaryColor.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            child: Icon(
                              isUnread
                                  ? Icons.notifications_active
                                  : Icons.notifications,
                              color: isUnread
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                              size: 18, // Smaller icon
                            ),
                          ),
                          title: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14, // Slightly smaller text
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['message'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Mark as read
                            setState(() {
                              notification['read'] = true;
                            });
                            context.pop();
                            // Handle notification tap
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
              InkWell(
                onTap: () {
                  // Mark all as read
                  setState(() {
                    for (var notification in _dashboardData['notifications']) {
                      notification['read'] = true;
                    }
                  });
                  context.pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
