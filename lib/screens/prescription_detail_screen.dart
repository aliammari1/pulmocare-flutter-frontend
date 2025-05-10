import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../services/doctor_service.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final String prescriptionId;

  const PrescriptionDetailScreen({
    super.key,
    required this.prescriptionId,
  });

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<Prescription> _prescriptionFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _prescriptionFuture =
        _doctorService.getPrescriptionDetails(widget.prescriptionId);
  }

  void _refreshPrescription() {
    setState(() {
      _prescriptionFuture =
          _doctorService.getPrescriptionDetails(widget.prescriptionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Prescription'),
        backgroundColor: const Color(0xFF050A30),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPrescription,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Prescription>(
          future: _prescriptionFuture,
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
                    const SizedBox(height: 10),
                    Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshPrescription,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text('Prescription non trouvée'),
              );
            }

            final prescription = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrescriptionHeader(prescription),
                  const SizedBox(height: 24),
                  _buildPatientInfoCard(prescription),
                  const SizedBox(height: 24),
                  _buildMedicationsSection(prescription),
                  const SizedBox(height: 24),
                  if (prescription.notes != null &&
                      prescription.notes!.isNotEmpty)
                    _buildNotesSection(prescription),
                  const SizedBox(height: 32),
                  _buildActionButtons(prescription),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrescriptionHeader(Prescription prescription) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prescription',
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
                    color: prescription.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    prescription.isActive ? 'Active' : 'Expirée',
                    style: TextStyle(
                      color: prescription.isActive
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.numbers, 'ID: ${prescription.id}'),
            _buildInfoRow(
              Icons.event_busy,
              'Expire le: ${_dateFormat.format(prescription.date)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(Prescription prescription) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Information Patient',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person,
              'Nom: ${prescription.patientName}',
            ),
            _buildInfoRow(
              Icons.badge,
              'ID Patient: ${prescription.patientId}',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.medical_services,
              'Médecin: ${prescription.doctorName}',
            ),
            _buildInfoRow(
              Icons.badge,
              'ID Médecin: ${prescription.doctorId}',
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
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(Prescription prescription) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Médicaments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...prescription.medications
                .map((item) => _buildMedicationItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(PrescriptionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.medication,
                  'Dosage: ${item.dosage}',
                ),
              ),
              Expanded(
                child: _buildInfoRow(
                  Icons.schedule,
                  'Fréquence: ${item.frequency}',
                ),
              ),
            ],
          ),
          _buildInfoRow(
            Icons.calendar_month,
            'Durée: ${item.duration} jour(s)',
          ),
          if (item.instructions != null && item.instructions!.isNotEmpty)
            _buildInfoRow(
              Icons.info_outline,
              'Instructions: ${item.instructions}',
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Prescription prescription) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              prescription.notes!,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Prescription prescription) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Renouveler'),
          onPressed: prescription.isActive
              ? null
              : () => _renewPrescription(prescription.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          label: const Text('Annuler'),
          onPressed: prescription.isActive
              ? () => _cancelPrescription(prescription.id)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Retour'),
          onPressed: () {
            context.go('/prescriptions');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _renewPrescription(String prescriptionId) async {
    try {
      await _doctorService.renewPrescription(prescriptionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription renouvelée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshPrescription();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du renouvellement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelPrescription(String prescriptionId) async {
    try {
      await _doctorService.cancelPrescription(prescriptionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshPrescription();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
