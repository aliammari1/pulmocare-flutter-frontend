import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/radiology.dart';
import '../services/doctor_service.dart';
import '../widgets/app_drawer.dart';

class RadiologyReportsScreen extends StatefulWidget {
  const RadiologyReportsScreen({super.key});

  @override
  State<RadiologyReportsScreen> createState() => _RadiologyReportsScreenState();
}

class _RadiologyReportsScreenState extends State<RadiologyReportsScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<List<RadiologyReport>> _reportsFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _reportsFuture = _doctorService.getRadiologyReports();
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = _doctorService.getRadiologyReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports Radiologiques'),
        backgroundColor: const Color(0xFF050A30),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<RadiologyReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
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
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshReports,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_information,
                    color: Colors.grey,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun rapport radiologique trouvé',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/request-radiology');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                    ),
                    child: const Text('Demander un examen radiologique'),
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    context.go('/radiology-report/${report.id}');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Patient: ${report.patientName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rapport',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Radiologue: ${report.radiologistName}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Date du rapport: ${_dateFormat.format(report.reportDate!)}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Impression:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.impression.length > 100
                              ? '${report.impression.substring(0, 100)}...'
                              : report.impression,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('Voir détails'),
                              onPressed: () {
                                context.go('/radiology-report/${report.id}');
                              },
                            ),
                            if (report.imageUrls != null &&
                                report.imageUrls!.isNotEmpty)
                              TextButton.icon(
                                icon: const Icon(Icons.image),
                                label: const Text('Images'),
                                onPressed: () {
                                  context.go('/radiology-report/${report.id}');
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/request-radiology');
        },
        backgroundColor: const Color(0xFF4FC3F7),
        child: const Icon(Icons.add),
      ),
    );
  }
}
