import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/radiology.dart';
import '../services/doctor_service.dart';
import 'dart:developer' as developer;

class RadiologyRequestScreen extends StatefulWidget {
  const RadiologyRequestScreen({super.key});

  @override
  State<RadiologyRequestScreen> createState() => _RadiologyRequestScreenState();
}

class _RadiologyRequestScreenState extends State<RadiologyRequestScreen> {
  final DoctorService _doctorService = DoctorService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _bodyPartController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  RadiologyType _selectedType = RadiologyType.xray;
  String _selectedUrgencyLevel = 'routine';

  bool _isLoading = false;

  final List<String> _urgencyLevels = ['routine', 'urgent', 'emergency'];

  @override
  void dispose() {
    _patientIdController.dispose();
    _patientNameController.dispose();
    _bodyPartController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final examinationData = {
      'patientId': _patientIdController.text,
      'patientName': _patientNameController.text,
      'type': _selectedType.toString().split('.').last,
      'bodyPart': _bodyPartController.text,
      'reason': _reasonController.text,
      'notes': _notesController.text,
      'urgencyLevel': _selectedUrgencyLevel,
    };

    try {
      final result = await _doctorService.requestRadiologyExam(examinationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande d\'examen radiologique créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to radiology reports screen
        context.go('/radiology-reports');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de la demande: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRadiologyTypeName(RadiologyType type) {
    switch (type) {
      case RadiologyType.xray:
        return 'Radiographie (Rayons X)';
      case RadiologyType.ultrasound:
        return 'Échographie';
      case RadiologyType.mri:
        return 'IRM (Imagerie par Résonance Magnétique)';
      case RadiologyType.ct:
        return 'Scanner CT';
      case RadiologyType.petScan:
        return 'PET Scan';
      case RadiologyType.mammogram:
        return 'Mammographie';
      case RadiologyType.other:
        return 'Autre';
    }
  }

  String _getUrgencyLevelName(String level) {
    switch (level) {
      case 'routine':
        return 'Routine';
      case 'urgent':
        return 'Urgent';
      case 'emergency':
        return 'Urgence';
      default:
        return 'Routine';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      developer.log('Attempting to build RadiologyRequestScreen',
          name: 'RadiologyRequestScreen');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Demande d\'examen radiologique'),
          backgroundColor: const Color(0xFF050A30),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
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
                                'Information Patient',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF050A30),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _patientIdController,
                                decoration: InputDecoration(
                                  labelText: 'ID du patient',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.badge),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'L\'ID du patient est requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _patientNameController,
                                decoration: InputDecoration(
                                  labelText: 'Nom du patient',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le nom du patient est requis';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
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
                                'Informations de l\'examen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF050A30),
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<RadiologyType>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: 'Type d\'examen',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon:
                                      const Icon(Icons.medical_services),
                                  isCollapsed:
                                      false, // Ensure it's not collapsed
                                ),
                                isExpanded:
                                    true, // Make dropdown take full width
                                menuMaxHeight:
                                    300, // Set maximum height for the menu
                                items: RadiologyType.values.map((type) {
                                  return DropdownMenuItem<RadiologyType>(
                                    value: type,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                      ),
                                      child: Text(
                                        _getRadiologyTypeName(type),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedType = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Le type d\'examen est requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _bodyPartController,
                                decoration: InputDecoration(
                                  labelText: 'Partie du corps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon:
                                      const Icon(Icons.accessibility_new),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La partie du corps est requise';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedUrgencyLevel,
                                decoration: InputDecoration(
                                  labelText: 'Niveau d\'urgence',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.priority_high),
                                ),
                                items: _urgencyLevels.map((level) {
                                  return DropdownMenuItem<String>(
                                    value: level,
                                    child: Text(_getUrgencyLevelName(level)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedUrgencyLevel = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _reasonController,
                                decoration: InputDecoration(
                                  labelText: 'Raison de l\'examen',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.help_outline),
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La raison de l\'examen est requise';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Notes supplémentaires',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.note),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3F7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Soumettre la demande',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            context.go('/radiology-reports');
                          },
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Exception in RadiologyRequestScreen.build: $e',
        name: 'RadiologyRequestScreen',
        error: e,
        stackTrace: stackTrace,
      );

      // Return a fallback UI that shows the error
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error Loading'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text('Error loading radiology request screen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Error: $e', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
