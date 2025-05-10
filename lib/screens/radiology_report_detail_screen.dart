import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/radiology.dart';
import '../services/doctor_service.dart';

class RadiologyReportDetailScreen extends StatefulWidget {
  final String reportId;

  const RadiologyReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<RadiologyReportDetailScreen> createState() =>
      _RadiologyReportDetailScreenState();
}

class _RadiologyReportDetailScreenState
    extends State<RadiologyReportDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<RadiologyReport> _reportFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _reportFuture = _doctorService.getRadiologyReportById(widget.reportId);
  }

  void _refreshReport() {
    setState(() {
      _reportFuture = _doctorService.getRadiologyReportById(widget.reportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Rapport Radiologique'),
        backgroundColor: const Color(0xFF050A30),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReport,
          ),
        ],
      ),
      body: FutureBuilder<RadiologyReport>(
        future: _reportFuture,
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
                    onPressed: _refreshReport,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Rapport radiologique non trouvé'),
            );
          }

          final report = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader(report),
                const SizedBox(height: 24),
                _buildPersonnelInfoCard(report),
                const SizedBox(height: 24),
                _buildFindingsSection(report),
                const SizedBox(height: 24),
                _buildImpressionSection(report),
                const SizedBox(height: 24),
                if (report.recommendation != null &&
                    report.recommendation!.isNotEmpty)
                  _buildRecommendationSection(report),
                const SizedBox(height: 24),
                if (report.imageUrls != null && report.imageUrls!.isNotEmpty)
                  _buildImagesSection(report),
                const SizedBox(height: 32),
                _buildActionButtons(report),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportHeader(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rapport Radiologique',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
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
            _buildInfoRow(Icons.numbers, 'ID Rapport: ${report.id}'),
            _buildInfoRow(
                Icons.numbers_outlined, 'ID Examen: ${report.examinationId}'),
            _buildInfoRow(
              Icons.date_range,
              'Date du rapport: ${_dateFormat.format(report.reportDate!)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelInfoCard(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person,
              'Patient: ${report.patientName}',
            ),
            _buildInfoRow(
              Icons.badge,
              'ID Patient: ${report.patientId}',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.medical_services,
              'Médecin traitant: ${report.doctorName}',
            ),
            _buildInfoRow(
              Icons.badge,
              'ID Médecin: ${report.doctorId}',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.person_outline,
              'Radiologue: ${report.radiologistName}',
            ),
            _buildInfoRow(
              Icons.badge,
              'ID Radiologue: ${report.radiologistId}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingsSection(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Constatations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.findings,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpressionSection(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Impression',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.impression,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommandations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.recommendation!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(RadiologyReport report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: report.imageUrls!.length,
                itemBuilder: (context, index) {
                  final imageUrl = report.imageUrls![index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to full screen image view
                      // Will be implemented later
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(RadiologyReport report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Retour aux rapports'),
          onPressed: () {
            context.go('/radiology-reports');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF050A30),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Historique du patient'),
          onPressed: () {
            // Navigate to patient history
            context.go('/patient-history/${report.patientId}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
