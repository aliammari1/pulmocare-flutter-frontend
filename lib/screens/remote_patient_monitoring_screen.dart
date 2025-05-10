import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RemotePatientMonitoringScreen extends StatefulWidget {
  const RemotePatientMonitoringScreen({Key? key}) : super(key: key);

  @override
  _RemotePatientMonitoringScreenState createState() =>
      _RemotePatientMonitoringScreenState();
}

class _RemotePatientMonitoringScreenState
    extends State<RemotePatientMonitoringScreen> {
  final List<Patient> _patients = [
    Patient(
      id: 'P001',
      name: 'John Smith',
      age: 65,
      condition: 'COPD',
      priority: Priority.high,
      metrics: {
        'Blood Pressure': '135/85',
        'Heart Rate': '89',
        'Oxygen Saturation': '94%',
        'Temperature': '37.2°C',
        'Respiratory Rate': '18',
      },
    ),
    Patient(
      id: 'P002',
      name: 'Maria Garcia',
      age: 58,
      condition: 'Asthma',
      priority: Priority.medium,
      metrics: {
        'Blood Pressure': '125/75',
        'Heart Rate': '72',
        'Oxygen Saturation': '97%',
        'Temperature': '36.8°C',
        'Respiratory Rate': '16',
      },
    ),
    Patient(
      id: 'P003',
      name: 'Robert Johnson',
      age: 72,
      condition: 'Cystic Fibrosis',
      priority: Priority.medium,
      metrics: {
        'Blood Pressure': '142/88',
        'Heart Rate': '78',
        'Oxygen Saturation': '95%',
        'Temperature': '36.9°C',
        'Respiratory Rate': '17',
      },
    ),
    Patient(
      id: 'P004',
      name: 'Emily Wilson',
      age: 42,
      condition: 'Sleep Apnea',
      priority: Priority.low,
      metrics: {
        'Blood Pressure': '118/72',
        'Heart Rate': '68',
        'Oxygen Saturation': '98%',
        'Temperature': '36.7°C',
        'Respiratory Rate': '14',
      },
    ),
    Patient(
      id: 'P005',
      name: 'Michael Brown',
      age: 69,
      condition: 'Pulmonary Fibrosis',
      priority: Priority.high,
      metrics: {
        'Blood Pressure': '145/92',
        'Heart Rate': '92',
        'Oxygen Saturation': '92%',
        'Temperature': '37.4°C',
        'Respiratory Rate': '22',
      },
    ),
  ];

  List<Patient> _filteredPatients = [];
  String _selectedFilter = 'All Patients';
  int _selectedPatientIndex = 0;
  bool _isRealTimeMonitoring = true;
  Timer? _dataUpdateTimer;
  final List<FlSpot> _heartRateData = [];
  final List<FlSpot> _oxygenData = [];
  final Random _random = Random();
  DateTime _startTime = DateTime.now().subtract(const Duration(minutes: 30));

  @override
  void initState() {
    super.initState();
    _filteredPatients = List.from(_patients);
    _generateInitialData();
    _startDataSimulation();
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  void _generateInitialData() {
    _heartRateData.clear();
    _oxygenData.clear();

    final Patient patient = _filteredPatients[_selectedPatientIndex];
    final baseHeartRate = int.parse(patient.metrics['Heart Rate']!);
    final baseOxygen =
        int.parse(patient.metrics['Oxygen Saturation']!.replaceAll('%', ''));

    // Generate 30 minutes of past data, 1 point per minute
    for (int i = 0; i < 30; i++) {
      final time = _startTime.add(Duration(minutes: i));
      final heartRateVariation = _random.nextInt(7) - 3; // -3 to +3
      final oxygenVariation = _random.nextInt(3) - 1; // -1 to +1

      _heartRateData.add(FlSpot(
        i.toDouble(),
        (baseHeartRate + heartRateVariation).toDouble(),
      ));

      _oxygenData.add(FlSpot(
        i.toDouble(),
        (baseOxygen + oxygenVariation).toDouble(),
      ));
    }
  }

  void _startDataSimulation() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isRealTimeMonitoring && mounted) {
        setState(() {
          final Patient patient = _filteredPatients[_selectedPatientIndex];
          final baseHeartRate = int.parse(patient.metrics['Heart Rate']!);
          final baseOxygen = int.parse(
              patient.metrics['Oxygen Saturation']!.replaceAll('%', ''));

          if (_heartRateData.length >= 60) {
            _heartRateData.removeAt(0);
            _oxygenData.removeAt(0);

            // Shift x values
            for (int i = 0; i < _heartRateData.length; i++) {
              _heartRateData[i] = FlSpot(i.toDouble(), _heartRateData[i].y);
              _oxygenData[i] = FlSpot(i.toDouble(), _oxygenData[i].y);
            }
          }

          final heartRateVariation = _random.nextInt(7) - 3; // -3 to +3
          final oxygenVariation = _random.nextInt(3) - 1; // -1 to +1

          _heartRateData.add(FlSpot(
            _heartRateData.isEmpty ? 0 : _heartRateData.last.x + 1,
            (baseHeartRate + heartRateVariation).toDouble(),
          ));

          _oxygenData.add(FlSpot(
            _oxygenData.isEmpty ? 0 : _oxygenData.last.x + 1,
            (baseOxygen + oxygenVariation).toDouble(),
          ));

          // Update patient metrics
          patient.metrics['Heart Rate'] =
              (baseHeartRate + heartRateVariation).toString();
          patient.metrics['Oxygen Saturation'] =
              '${baseOxygen + oxygenVariation}%';
          patient.metrics['Respiratory Rate'] =
              (int.parse(patient.metrics['Respiratory Rate']!) +
                      _random.nextInt(3) -
                      1)
                  .toString();
        });
      }
    });
  }

  void _filterPatients(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All Patients') {
        _filteredPatients = List.from(_patients);
      } else {
        Priority priority;
        switch (filter) {
          case 'High Priority':
            priority = Priority.high;
            break;
          case 'Medium Priority':
            priority = Priority.medium;
            break;
          case 'Low Priority':
            priority = Priority.low;
            break;
          default:
            priority = Priority.medium;
        }
        _filteredPatients =
            _patients.where((p) => p.priority == priority).toList();
      }

      // Reset selected patient if needed
      if (_selectedPatientIndex >= _filteredPatients.length) {
        _selectedPatientIndex = 0;
      }

      _generateInitialData();
    });
  }

  void _selectPatient(int index) {
    setState(() {
      _selectedPatientIndex = index;
      _generateInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Color(0xFF0B4F6C);
    final accentColor = Color(0xFF40BCD8);
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate patient list width - adapt to smaller screens
    final patientListWidth = screenWidth < 600 ? screenWidth * 0.3 : 300.0;

    _ensureDataExists(); // Make sure we have data to display

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Patient Monitoring'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isRealTimeMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isRealTimeMonitoring = !_isRealTimeMonitoring;
              });
            },
            tooltip: _isRealTimeMonitoring
                ? 'Pause monitoring'
                : 'Resume monitoring',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateInitialData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: screenWidth < 600
                  ? // Use a column layout on small screens
                  Column(
                      children: [
                        // Patient list as horizontal items on small screens
                        SizedBox(
                          height: 120,
                          child: _buildPatientListHorizontal(),
                        ),
                        // Patient details with full width
                        Expanded(
                          child: _filteredPatients.isNotEmpty
                              ? _buildPatientMonitoring(true)
                              : Center(
                                  child: Text(
                                    'No patients match the selected filter',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                        ),
                      ],
                    )
                  : // Use a row layout on larger screens
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient list
                        Container(
                          width: patientListWidth,
                          color: Colors.grey[100],
                          child: _buildPatientList(),
                        ),

                        // Patient details and charts
                        Expanded(
                          child: _filteredPatients.isNotEmpty
                              ? _buildPatientMonitoring(false)
                              : Center(
                                  child: Text(
                                    'No patients match the selected filter',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add_alert),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Set Alert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Metric',
                    ),
                    items: [
                      'Heart Rate',
                      'Oxygen Saturation',
                      'Respiratory Rate',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Threshold',
                      hintText: 'e.g. 120 for heart rate',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Alert set successfully'),
                        backgroundColor: accentColor,
                      ),
                    );
                  },
                  child: const Text('SET ALERT'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Set alert',
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All Patients'),
              selected: _selectedFilter == 'All Patients',
              onSelected: (_) => _filterPatients('All Patients'),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('High Priority'),
              selected: _selectedFilter == 'High Priority',
              onSelected: (_) => _filterPatients('High Priority'),
              backgroundColor: Colors.red[100],
              selectedColor: Colors.red[200],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Medium Priority'),
              selected: _selectedFilter == 'Medium Priority',
              onSelected: (_) => _filterPatients('Medium Priority'),
              backgroundColor: Colors.amber[100],
              selectedColor: Colors.amber[200],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Low Priority'),
              selected: _selectedFilter == 'Low Priority',
              onSelected: (_) => _filterPatients('Low Priority'),
              backgroundColor: Colors.green[100],
              selectedColor: Colors.green[200],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: _selectedPatientIndex == index
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          elevation: _selectedPatientIndex == index ? 3 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _priorityColor(patient.priority),
              child: Text(
                patient.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(patient.name),
            subtitle: Text(
              '${patient.age} years • ${patient.condition}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: _buildPriorityIndicator(patient.priority),
            onTap: () => _selectPatient(index),
          ),
        );
      },
    );
  }

  // New horizontal list for small screens
  Widget _buildPatientListHorizontal() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          color: _selectedPatientIndex == index
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          elevation: _selectedPatientIndex == index ? 3 : 1,
          child: InkWell(
            onTap: () => _selectPatient(index),
            child: Container(
              width: 120, // Reduced width for better fit
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: _priorityColor(patient.priority),
                    child: Text(
                      patient.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${patient.age} yr',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    patient.condition,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientMonitoring([bool isSmallScreen = false]) {
    if (_filteredPatients.isEmpty) return Container();

    final Patient patient = _filteredPatients[_selectedPatientIndex];
    final theme = Theme.of(context);
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient header
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    _priorityColor(patient.priority),
                                child: Text(
                                  patient.name.substring(0, 1),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: theme.textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${patient.id} • Age: ${patient.age}',
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Condition: ${patient.condition}',
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildPriorityBadge(patient.priority),
                        ],
                      )
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: _priorityColor(patient.priority),
                            child: Text(
                              patient.name.substring(0, 1),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${patient.id} • Age: ${patient.age} • Condition: ${patient.condition}',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          _buildPriorityBadge(patient.priority),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Current vitals
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Vitals',
                          style: theme.textTheme.titleSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isRealTimeMonitoring
                                ? Colors.green[100]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isRealTimeMonitoring
                                    ? Icons.fiber_manual_record
                                    : Icons.pause,
                                color: _isRealTimeMonitoring
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isRealTimeMonitoring
                                    ? 'Live Monitoring'
                                    : 'Paused',
                                style: TextStyle(
                                  color: _isRealTimeMonitoring
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Wrap with even spacing and responsive sizing
                    Wrap(
                      spacing: 8, // Reduced spacing
                      runSpacing: 12, // Increased vertical spacing between rows
                      alignment: WrapAlignment.start,
                      children: patient.metrics.entries.map((entry) {
                        // Calculate fully responsive width based on screen size
                        double cardWidth;
                        if (screenWidth < 400) {
                          // Very small screens - full width
                          cardWidth =
                              screenWidth - 64; // Full width minus padding
                        } else if (screenWidth < 600) {
                          // Small screens - 2 per row
                          cardWidth = (screenWidth - 64) / 2 -
                              4; // Two per row with spacing
                        } else {
                          // Larger screens - 3 or more per row
                          cardWidth = (screenWidth - 80) /
                              3; // Three per row with spacing
                        }
                        cardWidth =
                            cardWidth.clamp(100.0, 200.0); // Set min/max bounds

                        return _buildVitalCard(
                            entry.key, entry.value, cardWidth);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Charts
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vitals Trend',
                      style: isSmallScreen
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: isSmallScreen ? 200 : 250,
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: LineChart(
                        _heartRateLineChartData(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: isSmallScreen ? 200 : 250,
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: LineChart(
                        _oxygenLineChartData(),
                      ),
                    ),
                    if (_heartRateData.isEmpty || _oxygenData.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: isSmallScreen
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildActionButton(
                          icon: Icons.message,
                          label: isSmallScreen ? 'Message' : 'Message Patient',
                          onPressed: () {},
                          isPrimary: true,
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildActionButton(
                          icon: Icons.video_call,
                          label: isSmallScreen ? 'Video' : 'Video Consultation',
                          onPressed: () {},
                          isPrimary: true,
                          isSecondary: true,
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildActionButton(
                          icon: Icons.history,
                          label: 'History',
                          onPressed: () {},
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildActionButton(
                          icon: Icons.summarize,
                          label: isSmallScreen ? 'Report' : 'Download Report',
                          onPressed: () {},
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, [double width = 150]) {
    Color color;
    IconData icon;

    switch (title) {
      case 'Heart Rate':
        color = Colors.red;
        icon = Icons.favorite;
        break;
      case 'Oxygen Saturation':
        color = Colors.blue;
        icon = Icons.air;
        break;
      case 'Blood Pressure':
        color = Colors.purple;
        icon = Icons.speed;
        break;
      case 'Temperature':
        color = Colors.orange;
        icon = Icons.thermostat;
        break;
      case 'Respiratory Rate':
        color = Colors.teal;
        icon = Icons.waves;
        break;
      default:
        color = Colors.grey;
        icon = Icons.medical_services;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20, // Slightly smaller for better fit
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _heartRateLineChartData() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Make sure we have data to display
    if (_heartRateData.isEmpty) {
      // Return empty chart data if no data is available
      return LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [],
      );
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} BPM',
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(
            'Time (min)',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          axisNameSize: isSmallScreen ? 16 : 20,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: isSmallScreen ? 10 : 5, // Fewer labels on small screens
            getTitlesWidget: (value, meta) {
              if ((isSmallScreen && value % 10 != 0) ||
                  (!isSmallScreen && value % 5 != 0)) {
                return const Text('');
              }

              final now = DateTime.now();
              final time = now.subtract(
                  Duration(minutes: (30 - value.toInt()).clamp(0, 30)));
              return Text(
                DateFormat('HH:mm').format(time),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 8 : 9,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            'HR (BPM)',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          axisNameSize: isSmallScreen ? 16 : 20,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: isSmallScreen ? 25 : 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 8 : 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
            color: const Color(0xff37434d).withOpacity(0.3), width: 1),
      ),
      minX: 0,
      maxX: 30,
      minY: 50,
      maxY: 120,
      lineBarsData: [
        LineChartBarData(
          spots: _heartRateData,
          isCurved: true,
          curveSmoothness: 0.3,
          color: Colors.red,
          barWidth: isSmallScreen ? 2 : 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show:
                !_isRealTimeMonitoring, // Show dots when not in real-time mode
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Colors.red,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.3),
                Colors.red.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _oxygenLineChartData() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Make sure we have data to display
    if (_oxygenData.isEmpty) {
      // Return empty chart data if no data is available
      return LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [],
      );
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()}%',
                const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(
            'Time (min)',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          axisNameSize: isSmallScreen ? 16 : 20,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: isSmallScreen ? 10 : 5, // Fewer labels on small screens
            getTitlesWidget: (value, meta) {
              if ((isSmallScreen && value % 10 != 0) ||
                  (!isSmallScreen && value % 5 != 0)) {
                return const Text('');
              }

              final now = DateTime.now();
              final time = now.subtract(
                  Duration(minutes: (30 - value.toInt()).clamp(0, 30)));
              return Text(
                DateFormat('HH:mm').format(time),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 8 : 9,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            isSmallScreen ? 'O₂ (%)' : 'Oxygen Saturation (%)',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          axisNameSize: isSmallScreen ? 16 : 20,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: isSmallScreen ? 25 : 30,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 8 : 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
            color: const Color(0xff37434d).withOpacity(0.3), width: 1),
      ),
      minX: 0,
      maxX: 30,
      minY: 90,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: _oxygenData,
          isCurved: true,
          curveSmoothness: 0.3,
          color: Colors.blue,
          barWidth: isSmallScreen ? 2 : 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show:
                !_isRealTimeMonitoring, // Show dots when not in real-time mode
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Colors.blue,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red[700]!;
      case Priority.medium:
        return Colors.amber[700]!;
      case Priority.low:
        return Colors.green[700]!;
    }
  }

  Widget _buildPriorityIndicator(Priority priority) {
    Color color = _priorityColor(priority);
    IconData icon;

    switch (priority) {
      case Priority.high:
        icon = Icons.priority_high;
        break;
      case Priority.medium:
        icon = Icons.remove_circle_outline;
        break;
      case Priority.low:
        icon = Icons.check_circle_outline;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _buildPriorityBadge(Priority priority) {
    String label;
    Color color;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    switch (priority) {
      case Priority.high:
        label = isSmallScreen ? 'HIGH' : 'HIGH PRIORITY';
        color = Colors.red[700]!;
        break;
      case Priority.medium:
        label = isSmallScreen ? 'MEDIUM' : 'MEDIUM PRIORITY';
        color = Colors.amber[700]!;
        break;
      case Priority.low:
        label = isSmallScreen ? 'LOW' : 'LOW PRIORITY';
        color = Colors.green[700]!;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 16, vertical: isSmallScreen ? 4 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority == Priority.high
                ? Icons.warning
                : priority == Priority.medium
                    ? Icons.info
                    : Icons.check,
            color: color,
            size: isSmallScreen ? 14 : 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isSecondary = false,
    bool isSmallScreen = false,
  }) {
    final theme = Theme.of(context);
    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: isSecondary
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 6 : 10,
            ),
          )
        : OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 6 : 10,
            ),
          );

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isSmallScreen ? 16 : 20),
        label: Text(
          label,
          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
        ),
        style: buttonStyle,
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isSmallScreen ? 16 : 20),
        label: Text(
          label,
          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
        ),
        style: buttonStyle,
      );
    }
  }

  // Add this method to ensure we have data before displaying charts
  void _ensureDataExists() {
    if (_heartRateData.isEmpty || _oxygenData.isEmpty) {
      _generateInitialData();
    }
  }
}

enum Priority { high, medium, low }

class Patient {
  final String id;
  final String name;
  final int age;
  final String condition;
  final Priority priority;
  final Map<String, String> metrics;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.priority,
    required this.metrics,
  });
}
