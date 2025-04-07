import 'package:flutter/material.dart';
import 'package:medapp/services/rapport_service.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/services/notification_provider.dart';
import 'package:provider/provider.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({super.key});

  @override
  _RapportScreenState createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final RapportService _rapportService = RapportService();

  // Valeurs par défaut pour les listes déroulantes
  String _selectedExamType = 'Scanner';
  String _selectedReportType = 'Standard';

  // Liste des types d'examens disponibles
  final List<String> _examTypes = [
    'Scanner',
    'IRM',
    'Radiographie',
    'Échographie'
  ];

  // Modèles de rapports par type
  final Map<String, String> _reportTemplates = {
    'Standard': '''
INDICATION :
[À compléter]

TECHNIQUE :
Examen réalisé selon le protocole standard

RÉSULTATS :
[À compléter]

CONCLUSION :
[À compléter]
''',
    'Urgence': '''
MOTIF D'URGENCE :
[À compléter]

CONSTATATIONS :
[À compléter]

CONCLUSION URGENTE :
[À compléter]
'''
  };

  @override
  void initState() {
    super.initState();
    // Initialiser le contenu avec le modèle Standard par défaut
    _contentController.text = _reportTemplates[_selectedReportType] ?? '';
  }

  Future<void> _submitRapport() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _rapportService.ajouterRapport(
          patientName: _patientNameController.text,
          examType: _selectedExamType,
          reportType: _selectedReportType,
          content: _contentController.text,
        );

        // Ajoutez une notification
        context.read<NotificationProvider>().addRapportNotification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Rapport ajouté avec succès !"),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _patientNameController.clear();
        setState(() {
          _selectedExamType = 'Scanner';
          _selectedReportType = 'Standard';
          _contentController.text = _reportTemplates['Standard'] ?? '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text("Erreur lors de l'ajout du rapport"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.primaryColor.withAlpha((0.3 * 255).toInt()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.lightBlue,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  title: 'Informations du patient',
                  icon: Icons.person,
                  content: TextFormField(
                    controller: _patientNameController,
                    decoration: InputDecoration(
                      labelText: "Nom du patient",
                      hintText: "Entrez le nom complet du patient",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightBlue,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightBlue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Ce champ est obligatoire" : null,
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Type d\'Examen',
                  icon: Icons.medical_services,
                  content: DropdownButtonFormField<String>(
                    value: _selectedExamType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightBlue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.medical_services,
                        color: AppTheme.primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    isExpanded: true,
                    items: _examTypes.map((String type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedExamType = newValue;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_circle,
                      color: AppTheme.primaryColor,
                    ),
                    validator: (value) =>
                        value == null ? "Ce champ est obligatoire" : null,
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Type de Rapport',
                  icon: Icons.description,
                  content: DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightBlue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppTheme.primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    isExpanded: true,
                    items: _reportTemplates.keys.map((String type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedReportType = newValue;
                          _contentController.text =
                              _reportTemplates[newValue] ?? '';
                        });
                      }
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_circle,
                      color: AppTheme.primaryColor,
                    ),
                    validator: (value) =>
                        value == null ? "Ce champ est obligatoire" : null,
                  ),
                ),
                SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Contenu du Rapport',
                  icon: Icons.edit_document,
                  content: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightBlue,
                      ),
                    ),
                    child: TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 15,
                      validator: (value) =>
                          value!.isEmpty ? "Ce champ est obligatoire" : null,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitRapport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size(double.infinity, 54),
                    elevation: 3,
                    shadowColor: AppTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text(
                        "Valider le rapport",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
