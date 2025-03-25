import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import '../theme/app_theme.dart';
import 'dart:convert';

class PatientsView extends StatefulWidget {
  const PatientsView({super.key});

  @override
  _PatientsViewState createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String? _error;
  final Dio dio = DioHttpClient().dio;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response =
          await dio.get('${Config.apiBaseUrl}/patient/list');
      if (response.statusCode == 200) {
        setState(() {
          _patients = json.decode(response.data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load patients: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadPatients,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_patients.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.turquoise,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Patients Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.turquoise,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your patient list will appear here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/add-patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.turquoise,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Add New Patient',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        child: ListView.builder(
          itemCount: _patients.length + 1, // Add 1 for the button at the bottom
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            if (index == _patients.length) {
              // This is the last item, show the button
              return Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 72), // Added bottom padding for FAB
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/add-patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.turquoise,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }

            final patient = _patients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.turquoise.withOpacity(0.2),
                  child: Text(
                    patient['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.turquoise,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  patient['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(patient['email']),
                    if (patient['phoneNumber'] != null) ...[
                      const SizedBox(height: 2),
                      Text(patient['phoneNumber']),
                    ],
                  ],
                ),
                onTap: () {
                  // Navigate to patient details
                  Navigator.pushNamed(
                    context,
                    '/patient-details',
                    arguments: patient,
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-patient'),
        backgroundColor: AppTheme.turquoise,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
