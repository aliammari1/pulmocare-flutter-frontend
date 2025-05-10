import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../services/ordonnance_viewmodel.dart';
import 'package:go_router/go_router.dart';

class PdfActionsScreen extends StatefulWidget {
  const PdfActionsScreen({super.key});

  @override
  State<PdfActionsScreen> createState() => _PdfActionsScreenState();
}

class _PdfActionsScreenState extends State<PdfActionsScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final TextEditingController emailController = TextEditingController();
  List<dynamic>? ordonnances;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    // نستخدم addPostFrameCallback لتأخير تحميل البيانات حتى بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrdonnances();
    });
  }

  Future<void> _loadOrdonnances() async {
    if (!mounted) return;

    final viewModel = Provider.of<OrdonnanceViewModel>(context, listen: false);
    if (viewModel.ordonnance?.medecinId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await viewModel.loadMedecinOrdonnances(viewModel.ordonnance!.medecinId);

      if (mounted) {
        setState(() {
          ordonnances = viewModel.medecinOrdonnances;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pushReplacementNamed('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pushReplacementNamed('/'),
          ),
          title: const Text('Gestion des PDFs'),
          elevation: 0,
        ),
        body: Hero(
          tag: 'pdf-content',
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<OrdonnanceViewModel>(
      builder: (context, ordonnanceViewModel, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSuccessCard(),
                const SizedBox(height: 20),
                _buildActionsGrid(ordonnanceViewModel),
                const SizedBox(height: 20),
                _buildOrdonnancesList(ordonnanceViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordonnance créée avec succès!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const Text(
                    'Vous pouvez maintenant gérer votre ordonnance',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsGrid(OrdonnanceViewModel viewModel) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions pour l\'ordonnance actuelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.visibility,
                  label: 'Aperçu',
                  color: Colors.blue,
                  onPressed: () => _previewCurrentPdf(context, viewModel),
                ),
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Télécharger',
                  color: Colors.green,
                  onPressed: () => _downloadCurrentPdf(context, viewModel),
                ),
                _buildActionButton(
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.orange,
                  onPressed: () => _showEmailDialog(context, viewModel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdonnancesList(OrdonnanceViewModel viewModel) {
    if (ordonnances == null || ordonnances!.isEmpty) {
      return const Center(
        child: Text('Aucune ordonnance disponible'),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: ordonnances!.length,
        itemBuilder: (context, index) {
          final ordonnance = ordonnances![index];
          return _buildOrdonnanceItem(ordonnance, viewModel);
        },
      ),
    );
  }

  Widget _buildOrdonnanceItem(
      dynamic ordonnance, OrdonnanceViewModel viewModel) {
    final date = DateTime.parse(ordonnance['date']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.description, color: Colors.blue),
        ),
        title: Text('Patient: ${ordonnance['patient_id']}'),
        subtitle: Text(dateFormat.format(date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _previewPdf(context, viewModel, ordonnance),
              tooltip: 'Aperçu',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () => _downloadPdf(context, viewModel, ordonnance),
              tooltip: 'Télécharger',
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.orange),
              onPressed: () =>
                  _showSendEmailDialog(context, viewModel, ordonnance),
              tooltip: 'Envoyer',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSendEmailDialog(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
  ) async {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;

    // Tenter de récupérer l'email du patient
    final patientEmail =
        await viewModel.getPatientEmail(ordonnance['patient_id']);
    if (patientEmail.isNotEmpty) {
      emailController.text = patientEmail['email'] ?? '';
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Colors.blue),
              SizedBox(width: 8),
              Text('Envoyer l\'ordonnance'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient ID: ${ordonnance['patient_id']}'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email du patient',
                  hintText: 'exemple@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  errorText: !viewModel.isValidEmail(emailController.text) &&
                          emailController.text.isNotEmpty
                      ? 'Email invalide'
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(isLoading ? 'Envoi...' : 'Envoyer'),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!viewModel.isValidEmail(emailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez saisir un email valide'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      context.pop();
                      await _sendOrdonnanceToPacient(
                        context,
                        viewModel,
                        ordonnance,
                        emailController.text,
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOrdonnanceToPacient(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
    String email,
  ) async {
    try {
      // Afficher l'indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Générer le PDF
      final pdfBytes = await viewModel.generatePdfFromData(ordonnance);

      if (pdfBytes != null) {
        await viewModel.sendOrdonnancePdfToEmail(
            email, pdfBytes, ordonnance['patient_id']);

        if (context.mounted) {
          context.pop(); // Fermer l'indicateur de chargement
          _showSuccessDialog(context, 'Email envoyé avec succès à $email');
        }
      } else {
        throw Exception('Impossible de générer le PDF');
      }
    } catch (e) {
      if (context.mounted) {
        context.pop(); // Fermer l'indicateur de chargement
        _showErrorDialog(context, 'Erreur lors de l\'envoi: $e');
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Future<void> _previewCurrentPdf(
      BuildContext context, OrdonnanceViewModel viewModel) async {
    try {
      final pdfBytes = await viewModel.downloadOrdonnancePdf();
      if (pdfBytes != null) {
        await Printing.layoutPdf(
          onLayout: (_) => pdfBytes,
          name: 'Aperçu - Ordonnance',
        );

        // Sauvegarder automatiquement le PDF بعد la prévisualisation
        final filename = await viewModel.saveCurrentOrdonnancePdf();
        if (filename != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF sauvegardé automatiquement')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'aperçu: $e')),
        );
      }
    }
  }

  Future<void> _downloadCurrentPdf(
      BuildContext context, OrdonnanceViewModel viewModel) async {
    try {
      final pdfBytes = await viewModel.downloadOrdonnancePdf();
      if (pdfBytes != null) {
        // Sauvegarder et partager le PDF
        final filename = await viewModel.saveCurrentOrdonnancePdf();
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: filename ?? 'ordonnance.pdf',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF téléchargé avec succès')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e')),
        );
      }
    }
  }

  Future<void> _showEmailDialog(
      BuildContext context, OrdonnanceViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Envoyer l\'ordonnance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email du patient',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Envoyer'),
            onPressed: () async {
              if (emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez saisir un email')),
                );
                return;
              }

              context.pop();
              await _sendEmailToPacient(context, viewModel);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmailToPacient(
      BuildContext context, OrdonnanceViewModel viewModel) async {
    try {
      final success =
          await viewModel.sendOrdonnanceToPatient(emailController.text);

      if (!mounted) return;

      if (success) {
        _showSuccessDialog(
            context, 'Email envoyé avec succès à ${emailController.text}');
      } else {
        _showErrorDialog(context, 'Échec de l\'envoi de l\'email');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Erreur: ${e.toString()}');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Succès'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAllOrdonnances(
      BuildContext context, OrdonnanceViewModel viewModel) {
    if (viewModel.ordonnance?.medecinId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID du médecin non disponible')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.folder_special, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mes Ordonnances'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: FutureBuilder<List<dynamic>>(
            future: viewModel
                .loadDoctorOrdonnances(viewModel.ordonnance!.medecinId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final ordonnances = snapshot.data ?? [];
              return ListView.builder(
                itemCount: ordonnances.length,
                itemBuilder: (context, index) {
                  final ord = ordonnances[index];
                  final date = DateTime.parse(ord['date']);
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text('Patient: ${ord['patient_id']}'),
                    subtitle: Text(dateFormat.format(date)),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        context.pop();
                        _previewPdf(context, viewModel, ord);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _previewPdf(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
  ) async {
    try {
      // Afficher un indicateur de chargement
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Récupérer les données complètes de l'ordonnance
      final ordonnanceDetails =
          await viewModel.getSingleOrdonnance(ordonnance['_id']);

      if (ordonnanceDetails == null) {
        throw Exception('Impossible de récupérer les détails de l\'ordonnance');
      }

      final pdfBytes = await viewModel.generatePdfFromData(ordonnanceDetails);

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        context.pop();
      }

      if (pdfBytes != null && context.mounted) {
        await Printing.layoutPdf(
          onLayout: (_) => pdfBytes,
          name: 'Ordonnance ${ordonnance['patient_id']}',
          format: PdfPageFormat.a4,
        );
      } else {
        throw Exception('Impossible de générer le PDF');
      }
    } catch (e) {
      // Fermer l'indicateur de chargement si toujours affiché
      if (context.mounted && context.canPop()) {
        context.pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
  ) async {
    try {
      final pdfBytes = await viewModel.generatePdfFromData(ordonnance);
      if (pdfBytes != null) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename:
              'ordonnance_${ordonnance['patient_id']}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF téléchargé avec succès')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erreur: Impossible de générer le PDF')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e')),
        );
      }
    }
  }

  Future<void> _downloadAllPdfs(
    BuildContext context,
    OrdonnanceViewModel viewModel,
  ) async {
    try {
      // Afficher un indicateur de progression
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement des PDFs en cours...')),
      );

      final ordonnances = await viewModel.loadDoctorOrdonnances(
        viewModel.ordonnance?.medecinId ?? '',
      );

      int successCount = 0;
      for (var ordonnance in ordonnances) {
        try {
          final pdfBytes = await viewModel.generatePdfFromData(ordonnance);
          if (pdfBytes != null) {
            await Printing.sharePdf(
              bytes: pdfBytes,
              filename:
                  'ordonnance_${ordonnance['patient_id']}_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
            successCount++;
          }
        } catch (e) {
          print('Erreur lors du téléchargement du PDF: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount PDFs téléchargés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPrintPreview(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
  ) async {
    try {
      final pdfBytes = await viewModel.generatePdfFromData(ordonnance);
      if (pdfBytes != null) {
        await Printing.layoutPdf(
          onLayout: (_) => pdfBytes,
          name: 'Aperçu - Ordonnance ${ordonnance['patient_id']}',
          format: PdfPageFormat.a4,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'aperçu: $e')),
        );
      }
    }
  }

  Future<void> _printOrdonnance(
    BuildContext context,
    OrdonnanceViewModel viewModel,
    dynamic ordonnance,
  ) async {
    try {
      final pdfBytes = await viewModel.generatePdfFromData(ordonnance);
      if (pdfBytes != null) {
        await Printing.layoutPdf(
          onLayout: (_) => pdfBytes,
          name: 'Ordonnance ${ordonnance['patient_id']}',
          format: PdfPageFormat.a4,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'impression: $e')),
        );
      }
    }
  }
}
