import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/ordonnance_viewmodel.dart';
import 'pdf_actions_screen.dart';
import 'package:go_router/go_router.dart';

class OrdonnancesListScreen extends StatefulWidget {
  const OrdonnancesListScreen({super.key});

  @override
  State<OrdonnancesListScreen> createState() => _OrdonnancesListScreenState();
}

class _OrdonnancesListScreenState extends State<OrdonnancesListScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OrdonnanceViewModel>();
      final medecinId = viewModel.ordonnance?.medecinId;

      if (medecinId == null || medecinId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez d\'abord créer une ordonnance'),
            backgroundColor: Colors.orange,
          ),
        );
        context.pushReplacementNamed('/new-ordonnance');
        return;
      }

      viewModel.loadMedecinOrdonnances(medecinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ordonnances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final viewModel = context.read<OrdonnanceViewModel>();
              final medecinId = viewModel.ordonnance?.medecinId;
              if (medecinId != null && medecinId.isNotEmpty) {
                viewModel.loadMedecinOrdonnances(medecinId);
              }
            },
          ),
        ],
      ),
      body: Consumer<OrdonnanceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          final ordonnances = viewModel.medecinOrdonnances;
          if (ordonnances == null || ordonnances.isEmpty) {
            return const Center(child: Text('Aucune ordonnance trouvée'));
          }

          return ListView.builder(
            itemCount: ordonnances.length,
            itemBuilder: (context, index) {
              final ordonnance = ordonnances[index];
              final date = DateTime.parse(ordonnance['date'].toString());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.description, color: Colors.blue),
                  ),
                  title: Text('Patient: ${ordonnance['patient_id']}'),
                  subtitle: Text(dateFormat.format(date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () async {
                      final pdfBytes =
                          await viewModel.generatePdfFromData(ordonnance);
                      if (pdfBytes != null && context.mounted) {
                        // context.push(
                        //   MaterialPageRoute(
                        //     builder: (context) => const PdfActionsScreen(),
                        //   ),
                        // );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('/new-ordonnance');
        },
        tooltip: 'Nouvelle ordonnance',
        child: const Icon(Icons.add),
      ),
    );
  }
}
