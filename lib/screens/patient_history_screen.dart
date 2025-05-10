import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/doctor_service.dart';

class PatientHistoryScreen extends StatefulWidget {
  final String patientId;

  const PatientHistoryScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen>
    with SingleTickerProviderStateMixin {
  final DoctorService _doctorService = DoctorService();
  late Future<Map<String, dynamic>> _patientHistoryFuture;
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _patientHistoryFuture = _doctorService.getPatientHistory(widget.patientId);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshPatientHistory() {
    setState(() {
      _patientHistoryFuture =
          _doctorService.getPatientHistory(widget.patientId);
    });
  }

  void _notifyPatient() async {
    final notificationData = {
      'title': 'Message de votre médecin',
      'message':
          'Veuillez consulter votre historique médical pour des mises à jour importantes.',
      'type': 'medical_update',
    };

    try {
      await _doctorService.notifyPatient(widget.patientId, notificationData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi de la notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique du Patient'),
        backgroundColor: const Color(0xFF050A30),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPatientHistory,
          ),
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: _notifyPatient,
            tooltip: 'Notifier le patient',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Résumé'),
            Tab(text: 'Consultations'),
            Tab(text: 'Prescriptions'),
            Tab(text: 'Radiologie'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _patientHistoryFuture,
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
                    onPressed: _refreshPatientHistory,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Historique du patient non trouvé'),
            );
          }

          final patientHistory = snapshot.data!;
          final patientInfo = patientHistory['patient'] as Map<String, dynamic>;
          final consultations =
              patientHistory['consultations'] as List<dynamic>;
          final prescriptions =
              patientHistory['prescriptions'] as List<dynamic>;
          final radiologyReports =
              patientHistory['radiologyReports'] as List<dynamic>;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(patientInfo, consultations.length,
                  prescriptions.length, radiologyReports.length),
              _buildConsultationsTab(consultations),
              _buildPrescriptionsTab(prescriptions),
              _buildRadiologyTab(radiologyReports),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(Map<String, dynamic> patientInfo,
      int consultationsCount, int prescriptionsCount, int radiologyCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoCard(patientInfo),
          const SizedBox(height: 24),
          _buildStatisticsCard(
              consultationsCount, prescriptionsCount, radiologyCount),
          const SizedBox(height: 24),
          if (patientInfo.containsKey('medicalConditions'))
            _buildMedicalConditionsCard(patientInfo['medicalConditions']),
          const SizedBox(height: 24),
          if (patientInfo.containsKey('allergies'))
            _buildAllergiesCard(patientInfo['allergies']),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(Map<String, dynamic> patientInfo) {
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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${patientInfo['firstName']} ${patientInfo['lastName']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${patientInfo['id']}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.cake,
                'Date de naissance: ${_formatDateString(patientInfo['dateOfBirth'])}'),
            _buildInfoRow(Icons.wc, 'Genre: ${patientInfo['gender']}'),
            _buildInfoRow(Icons.phone, 'Téléphone: ${patientInfo['phone']}'),
            _buildInfoRow(Icons.email, 'Email: ${patientInfo['email']}'),
            if (patientInfo.containsKey('blood_type'))
              _buildInfoRow(Icons.bloodtype,
                  'Groupe sanguin: ${patientInfo['blood_type']}'),
            if (patientInfo.containsKey('height'))
              _buildInfoRow(
                  Icons.height, 'Taille: ${patientInfo['height']} cm'),
            if (patientInfo.containsKey('weight'))
              _buildInfoRow(
                  Icons.monitor_weight, 'Poids: ${patientInfo['weight']} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
      int consultationsCount, int prescriptionsCount, int radiologyCount) {
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
              'Résumé Médical',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.calendar_month,
                    consultationsCount.toString(), 'Consultations'),
                _buildStatItem(Icons.medication, prescriptionsCount.toString(),
                    'Prescriptions'),
                _buildStatItem(
                    Icons.image, radiologyCount.toString(), 'Examens Radio'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalConditionsCard(List<dynamic> conditions) {
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
              'Conditions Médicales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...conditions.map((condition) {
              final conditionMap = condition as Map<String, dynamic>;
              return ListTile(
                leading:
                    const Icon(Icons.medical_information, color: Colors.red),
                title: Text(conditionMap['name']),
                subtitle: Text(
                    'Diagnostiqué: ${_formatDateString(conditionMap['diagnosedDate'])}'),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesCard(List<dynamic> allergies) {
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
              'Allergies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...allergies.map((allergy) => ListTile(
                  leading: const Icon(Icons.dangerous, color: Colors.orange),
                  title: Text(allergy['name']),
                  subtitle: Text('Sévérité: ${allergy['severity']}'),
                  dense: true,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationsTab(List<dynamic> consultations) {
    if (consultations.isEmpty) {
      return const Center(
        child: Text('Aucune consultation trouvée'),
      );
    }

    return ListView.builder(
      itemCount: consultations.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final consultation = consultations[index] as Map<String, dynamic>;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
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
                    Text(
                      _formatDateString(consultation['date']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                        consultation['type'] ?? 'Consultation',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person,
                  'Médecin: ${consultation['doctorName']}',
                ),
                if (consultation.containsKey('symptoms') &&
                    consultation['symptoms'] != null)
                  _buildInfoRow(
                    Icons.sick,
                    'Symptômes: ${consultation['symptoms']}',
                  ),
                if (consultation.containsKey('diagnosis') &&
                    consultation['diagnosis'] != null)
                  _buildInfoRow(
                    Icons.medical_information,
                    'Diagnostic: ${consultation['diagnosis']}',
                  ),
                if (consultation.containsKey('notes') &&
                    consultation['notes'] != null)
                  const SizedBox(height: 8),
                if (consultation.containsKey('notes') &&
                    consultation['notes'] != null)
                  const Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (consultation.containsKey('notes') &&
                    consultation['notes'] != null)
                  const SizedBox(height: 4),
                if (consultation.containsKey('notes') &&
                    consultation['notes'] != null)
                  Text(consultation['notes']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsTab(List<dynamic> prescriptions) {
    if (prescriptions.isEmpty) {
      return const Center(
        child: Text('Aucune prescription trouvée'),
      );
    }

    return ListView.builder(
      itemCount: prescriptions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final prescription = prescriptions[index] as Map<String, dynamic>;
        final isActive = prescription['isActive'] ?? false;
        final items = prescription['items'] as List<dynamic>;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
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
                    Text(
                      'Prescription ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Expirée',
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person,
                  'Prescrit par: ${prescription['doctorName']}',
                ),
                _buildInfoRow(
                  Icons.date_range,
                  'Date: ${_formatDateString(prescription['createdAt'])}',
                ),
                _buildInfoRow(
                  Icons.event_busy,
                  'Expire le: ${_formatDateString(prescription['expiresAt'])}',
                ),
                const Divider(),
                const Text(
                  'Médicaments:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final medicationItem = item as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${medicationItem['medicationName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '${medicationItem['dosage']}, ${medicationItem['frequency']}, ${medicationItem['duration']} jour(s)',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (medicationItem.containsKey('instructions') &&
                            medicationItem['instructions'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'Instructions: ${medicationItem['instructions']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                if (prescription.containsKey('notes') &&
                    prescription['notes'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(prescription['notes']),
                    ],
                  ),
                const SizedBox(height: 8),
                if (prescription['id'] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Voir détails'),
                        onPressed: () {
                          context.go('/prescription/${prescription['id']}');
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadiologyTab(List<dynamic> radiologyReports) {
    if (radiologyReports.isEmpty) {
      return const Center(
        child: Text('Aucun rapport radiologique trouvé'),
      );
    }

    return ListView.builder(
      itemCount: radiologyReports.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final report = radiologyReports[index] as Map<String, dynamic>;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
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
                    Text(
                      'Rapport ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                        report['type'] ?? 'Radiologie',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person_outline,
                  'Radiologue: ${report['radiologistName']}',
                ),
                _buildInfoRow(
                  Icons.date_range,
                  'Date: ${_formatDateString(report['reportDate'])}',
                ),
                if (report.containsKey('bodyPart') &&
                    report['bodyPart'] != null)
                  _buildInfoRow(
                    Icons.accessibility_new,
                    'Partie du corps: ${report['bodyPart']}',
                  ),
                const Divider(height: 24),
                if (report.containsKey('findings') &&
                    report['findings'] != null)
                  const Text(
                    'Constatations:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (report.containsKey('findings') &&
                    report['findings'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      report['findings'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (report.containsKey('impression') &&
                    report['impression'] != null)
                  const Text(
                    'Impression:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (report.containsKey('impression') &&
                    report['impression'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      report['impression'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (report['id'] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text('Voir détails'),
                        onPressed: () {
                          context.go('/radiology-report/${report['id']}');
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF050A30),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
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

  String _formatDateString(dynamic dateString) {
    if (dateString == null) return 'Non spécifié';
    try {
      final date = DateTime.parse(dateString);
      return _dateFormat.format(date);
    } catch (e) {
      return dateString.toString();
    }
  }
}
