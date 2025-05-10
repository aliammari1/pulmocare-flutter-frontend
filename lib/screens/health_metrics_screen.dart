import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  String _selectedTimeRange = 'Week';
  String _selectedMetric = 'Respiratory Rate';
  final bool _isLoading = false;
  final PageController _pageController = PageController();
  final List<String> _timeRanges = ['Day', 'Week', 'Month', '3 Months', 'Year'];

  // Metrics data
  final Map<String, List<Map<String, dynamic>>> _metricsData = {
    'Respiratory Rate': [
      // Values for the past week (breaths per minute)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 16},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 18},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 17},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 16},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 19},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 18},
      {'date': DateTime.now(), 'value': 17},
    ],
    'Blood Oxygen': [
      // Values for the past week (SpO2 percentage)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 96},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 97},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 95},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 96},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 94},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 95},
      {'date': DateTime.now(), 'value': 97},
    ],
    'Heart Rate': [
      // Values for the past week (beats per minute)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 68},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 72},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 75},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 70},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 73},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 71},
      {'date': DateTime.now(), 'value': 69},
    ],
    'Blood Pressure': [
      // Values for the past week (systolic/diastolic)
      {
        'date': DateTime.now().subtract(const Duration(days: 6)),
        'systolic': 126,
        'diastolic': 82
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'systolic': 124,
        'diastolic': 80
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'systolic': 130,
        'diastolic': 85
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'systolic': 128,
        'diastolic': 84
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'systolic': 122,
        'diastolic': 78
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'systolic': 126,
        'diastolic': 80
      },
      {'date': DateTime.now(), 'systolic': 124, 'diastolic': 79},
    ],
    'Peak Flow': [
      // Values for the past week (L/min)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 480},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 500},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 490},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 470},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 485},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 495},
      {'date': DateTime.now(), 'value': 505},
    ],
    'Weight': [
      // Values for the past week (kg)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 78.2},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 78.0},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 77.8},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 77.7},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 77.9},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 77.5},
      {'date': DateTime.now(), 'value': 77.6},
    ],
    'Temperature': [
      // Values for the past week (°C)
      {'date': DateTime.now().subtract(const Duration(days: 6)), 'value': 36.7},
      {'date': DateTime.now().subtract(const Duration(days: 5)), 'value': 36.5},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'value': 36.8},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'value': 37.1},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'value': 36.9},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'value': 36.6},
      {'date': DateTime.now(), 'value': 36.7},
    ],
  };

  // Information about each metric
  final Map<String, Map<String, dynamic>> _metricInfo = {
    'Respiratory Rate': {
      'icon': Icons.air,
      'unit': 'breaths/min',
      'normalRange': '12-20',
      'color': Colors.blue,
      'description':
          'Number of breaths per minute. Increased rate may indicate respiratory issues.',
      'lastValue': 17,
      'trend': 'stable',
      'warning': null,
    },
    'Blood Oxygen': {
      'icon': Icons.bloodtype,
      'unit': '%',
      'normalRange': '95-100',
      'color': Colors.red,
      'description':
          'Oxygen saturation (SpO2) measures the amount of oxygen in your blood.',
      'lastValue': 97,
      'trend': 'improving',
      'warning': null,
    },
    'Heart Rate': {
      'icon': Icons.favorite,
      'unit': 'bpm',
      'normalRange': '60-100',
      'color': Colors.pink,
      'description':
          'Number of heartbeats per minute. Varies with activity and health status.',
      'lastValue': 69,
      'trend': 'stable',
      'warning': null,
    },
    'Blood Pressure': {
      'icon': Icons.speed,
      'unit': 'mmHg',
      'normalRange': '< 120/80',
      'color': Colors.purple,
      'description':
          'Force of blood against artery walls. Reported as systolic/diastolic.',
      'lastValue': '124/79',
      'trend': 'improving',
      'warning': 'Slightly elevated',
    },
    'Peak Flow': {
      'icon': Icons.air_rounded,
      'unit': 'L/min',
      'normalRange': '400-600',
      'color': Colors.teal,
      'description':
          'Maximum speed of expiration. Important measure for asthma and COPD monitoring.',
      'lastValue': 505,
      'trend': 'improving',
      'warning': null,
    },
    'Weight': {
      'icon': Icons.monitor_weight,
      'unit': 'kg',
      'normalRange': '75-80',
      'color': Colors.brown,
      'description':
          'Body weight. Stable weight is important for COPD management.',
      'lastValue': 77.6,
      'trend': 'stable',
      'warning': null,
    },
    'Temperature': {
      'icon': Icons.thermostat,
      'unit': '°C',
      'normalRange': '36.1-37.2',
      'color': Colors.orange,
      'description': 'Body temperature. Fever may indicate infection.',
      'lastValue': 36.7,
      'trend': 'stable',
      'warning': null,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Metrics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Information',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareMetrics,
            tooltip: 'Share with Doctor',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMetricsCarousel(),
                _buildTimeRangeSelector(),
                Expanded(child: _buildChart()),
                _buildSummary(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMetricDialog,
        tooltip: 'Add New Reading',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMetricsCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _metricInfo.length,
        onPageChanged: (index) {
          setState(() {
            _selectedMetric = _metricInfo.keys.elementAt(index);
          });
        },
        itemBuilder: (context, index) {
          final metric = _metricInfo.keys.elementAt(index);
          final info = _metricInfo[metric]!;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMetric = metric;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedMetric == metric
                    ? info['color'].withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedMetric == metric
                      ? info['color']
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        info['icon'],
                        color: info['color'],
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        metric,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        info['lastValue'].toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: info['color'],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info['unit'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTrendIcon(info['trend']),
                    ],
                  ),
                  Text(
                    'Normal Range: ${info['normalRange']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icon(Icons.trending_up, color: Colors.green[700], size: 20);
      case 'worsening':
        return Icon(Icons.trending_down, color: Colors.red[700], size: 20);
      case 'stable':
        return Icon(Icons.trending_flat, color: Colors.blue[700], size: 20);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Time Range:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeRanges.map((range) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(range),
                      selected: _selectedTimeRange == range,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTimeRange = range;
                          });
                        }
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: _metricInfo[_selectedMetric]!['color']
                          .withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final info = _metricInfo[_selectedMetric]!;
    final data = _metricsData[_selectedMetric]!;

    if (_selectedMetric == 'Blood Pressure') {
      return _buildBloodPressureChart(data, info);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: _getInterval(),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= data.length) return const Text('');
                  final date = data[value.toInt()]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 35,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          minX: 0,
          maxX: data.length - 1.0,
          minY: _getMinValue() * 0.95,
          maxY: _getMaxValue() * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length, (index) {
                return FlSpot(
                  index.toDouble(),
                  (data[index]['value'] as num).toDouble(),
                );
              }),
              isCurved: true,
              color: info['color'],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: info['color'],
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: info['color'].withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final index = flSpot.x.toInt();
                  if (index >= 0 && index < data.length) {
                    final value = data[index]['value'];
                    final date = data[index]['date'] as DateTime;
                    return LineTooltipItem(
                      '${DateFormat('MM/dd').format(date)}: $value ${info['unit']}',
                      const TextStyle(color: Colors.white),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart(
      List<Map<String, dynamic>> data, Map<String, dynamic> info) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= data.length) return const Text('');
                  final date = data[value.toInt()]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!),
          ),
          minX: 0,
          maxX: data.length - 1.0,
          minY: 60, // Minimum diastolic value
          maxY: 150, // Maximum systolic value
          lineBarsData: [
            // Systolic line
            LineChartBarData(
              spots: List.generate(data.length, (index) {
                return FlSpot(
                  index.toDouble(),
                  (data[index]['systolic'] as num).toDouble(),
                );
              }),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.red,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Diastolic line
            LineChartBarData(
              spots: List.generate(data.length, (index) {
                return FlSpot(
                  index.toDouble(),
                  (data[index]['diastolic'] as num).toDouble(),
                );
              }),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.blue,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final index = flSpot.x.toInt();
                  if (index >= 0 && index < data.length) {
                    final date = data[index]['date'] as DateTime;
                    final isSystemic = barSpot.barIndex == 0;
                    final value = isSystemic
                        ? data[index]['systolic']
                        : data[index]['diastolic'];
                    final type = isSystemic ? 'Systolic' : 'Diastolic';
                    return LineTooltipItem(
                      '$type: $value mmHg\n${DateFormat('MM/dd').format(date)}',
                      TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isSystemic ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final info = _metricInfo[_selectedMetric]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMetric,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info['description'],
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                'Normal Range',
                info['normalRange'],
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryItem(
                'Last Reading',
                '${info['lastValue']} ' + info['unit'],
                Icons.access_time,
                Colors.blue,
              ),
              if (info['warning'] != null)
                _buildSummaryItem(
                  'Warning',
                  info['warning'],
                  Icons.warning_amber_rounded,
                  Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMetricDialog() {
    double? newValue;
    int? systolicValue;
    int? diastolicValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New $_selectedMetric Reading'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedMetric != 'Blood Pressure') ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText:
                          'New Value (${_metricInfo[_selectedMetric]!['unit']})',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      newValue = double.tryParse(value);
                    },
                  ),
                ] else ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Systolic Value (mmHg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      systolicValue = int.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Diastolic Value (mmHg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      diastolicValue = int.tryParse(value);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Normal Range: ${_metricInfo[_selectedMetric]!['normalRange']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                // Validate and save the new reading
                if (_selectedMetric == 'Blood Pressure') {
                  if (systolicValue != null && diastolicValue != null) {
                    _saveNewReading(systolicValue, diastolicValue);
                    context.pop();
                  }
                } else {
                  if (newValue != null) {
                    _saveNewReading(newValue);
                    context.pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNewReading(dynamic value, [int? diastolicValue]) {
    // In a real app, this would save to a database or API
    setState(() {
      final now = DateTime.now();

      if (_selectedMetric == 'Blood Pressure' && diastolicValue != null) {
        _metricsData[_selectedMetric]!.add({
          'date': now,
          'systolic': value,
          'diastolic': diastolicValue,
        });
        _metricInfo[_selectedMetric]!['lastValue'] = '$value/$diastolicValue';
      } else {
        _metricsData[_selectedMetric]!.add({
          'date': now,
          'value': value,
        });
        _metricInfo[_selectedMetric]!['lastValue'] = value;
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New $_selectedMetric reading saved'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Health Metrics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Track Your Health',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your health metrics help you and your doctor monitor your condition. Regular tracking can identify trends and potential issues early.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Available Metrics',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ..._metricInfo.entries.map((entry) {
                  final metric = entry.key;
                  final info = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(info['icon'], color: info['color'], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$metric (${info['normalRange']} ${info['unit']})',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Consult with your healthcare provider about any concerning trends or readings outside the normal range.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _shareMetrics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Health Metrics'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Choose a healthcare provider to share your health metrics with:'),
                SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(child: Text('SJ')),
                  title: Text('Dr. Sarah Johnson'),
                  subtitle: Text('Pulmonologist'),
                ),
                ListTile(
                  leading: CircleAvatar(child: Text('RC')),
                  title: Text('Dr. Robert Chen'),
                  subtitle: Text('Respiratory Specialist'),
                ),
                ListTile(
                  leading: CircleAvatar(child: Text('ER')),
                  title: Text('Dr. Emily Rodriguez'),
                  subtitle: Text('Primary Care Physician'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            ElevatedButton(
              child: Text('Share with Selected'),
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Health metrics shared with your doctor'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  double _getMinValue() {
    if (_selectedMetric == 'Blood Pressure') return 60;

    final data = _metricsData[_selectedMetric]!;
    double minValue = double.infinity;

    for (var item in data) {
      final value = (item['value'] as num).toDouble();
      if (value < minValue) {
        minValue = value;
      }
    }

    return minValue;
  }

  double _getMaxValue() {
    if (_selectedMetric == 'Blood Pressure') return 150;

    final data = _metricsData[_selectedMetric]!;
    double maxValue = double.negativeInfinity;

    for (var item in data) {
      final value = (item['value'] as num).toDouble();
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return maxValue;
  }

  double _getInterval() {
    switch (_selectedMetric) {
      case 'Respiratory Rate':
        return 1;
      case 'Blood Oxygen':
        return 1;
      case 'Heart Rate':
        return 5;
      case 'Blood Pressure':
        return 10;
      case 'Peak Flow':
        return 20;
      case 'Weight':
        return 0.5;
      case 'Temperature':
        return 0.5;
      default:
        return 1;
    }
  }
}
