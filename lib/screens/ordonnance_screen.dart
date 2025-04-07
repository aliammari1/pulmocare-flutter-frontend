import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../services/navigation_service.dart';
import '../models/medicament.dart';
import '../services/ordonnance_viewmodel.dart';
import '../widgets/signature_pad.dart';
import '../widgets/cachet_medecin.dart';
import '../models/ordonnance.dart';
import '../theme/style_constants.dart';

class OrdonnanceScreen extends StatefulWidget {
  const OrdonnanceScreen({super.key});

  @override
  State<OrdonnanceScreen> createState() => _OrdonnanceScreenState();
}

class _OrdonnanceScreenState extends State<OrdonnanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _medecinIdController = TextEditingController();
  final _searchController = TextEditingController();
  final _cliniqueController = TextEditingController();
  final _specialiteController = TextEditingController();
  List<Medicament> medicaments = [];
  Uint8List? _signature;
  Uint8List? _cachet;
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Ordonnance')),
      body: Consumer<OrdonnanceViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPatientInfo(),
                  const SizedBox(height: 20),
                  _buildMedicamentSearch(viewModel),
                  const SizedBox(height: 20),
                  _buildMedicamentsList(),
                  const SizedBox(height: 20),
                  _buildSignatureAndCachet(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLogoHeader(),
            const SizedBox(height: 20),
            _buildInfoField(
              controller: _patientIdController,
              label: 'ID Patient',
              hint: 'Entrez l\'ID du patient',
              icon: StyleConstants.patientIcon,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _medecinIdController,
              label: 'ID Médecin',
              hint: 'Entrez l\'ID du médecin',
              icon: StyleConstants.medecinIdIcon,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _cliniqueController,
              label: 'Clinique',
              hint: 'Nom de la clinique',
              icon: StyleConstants.cliniqueIcon,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              controller: _specialiteController,
              label: 'Spécialité',
              hint: 'Spécialité du médecin',
              icon: StyleConstants.specialiteIcon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 60,
            width: 60,
          ),
          const SizedBox(height: 8),
          const Text(
            'Nouvelle Ordonnance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StyleConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
  }) {
    return Container(
      decoration: StyleConstants.textFieldDecoration,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: StyleConstants.primaryColor),
          suffixIcon: required
              ? const Icon(Icons.star,
                  size: 8, color: StyleConstants.errorColor)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: StyleConstants.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: required
            ? (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null
            : null,
      ),
    );
  }

  Widget _buildMedicamentSearch(OrdonnanceViewModel viewModel) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de recherche élégante
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un médicament...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: isSearching
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(6),
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onChanged: (value) => _searchMedicaments(value, viewModel),
              ),
            ),
            const SizedBox(height: 16),

            // Résultats de recherche
            if (viewModel.searchResults?.isNotEmpty ?? false)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: viewModel.searchResults!.length,
                  itemBuilder: (context, index) {
                    final med = viewModel.searchResults![index];
                    return _buildMedicamentCard(med);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicamentCard(Medicament med) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMedicamentDetails(med),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (med.laboratoire != null)
                          Text(
                            med.laboratoire!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildAddButton(med),
                ],
              ),
              const SizedBox(height: 8),
              if (med.dosage != null) ...[
                _buildInfoRow(Icons.medical_services, 'Dosage:', med.dosage!),
              ],
              if (med.posologie != null) ...[
                const SizedBox(height: 4),
                _buildInfoRow(Icons.schedule, 'Posologie:', med.posologie!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(Medicament med) {
    final bool isAdded = medicaments.any((m) => m.name == med.name);
    return Material(
      color: isAdded ? Colors.green : Colors.blue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _addMedicament(med),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAdded ? Icons.check : Icons.add,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                isAdded ? 'Ajouté' : 'Ajouter',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[300]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _searchMedicaments(String value, OrdonnanceViewModel viewModel) async {
    if (value.isEmpty) {
      viewModel.clearResults();
      return;
    }

    setState(() => isSearching = true);
    await viewModel.fetchMedicaments(value);
    setState(() => isSearching = false);
  }

  void _showMedicamentDetails(Medicament med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(med.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Usage', med.usage),
              _infoRow('Dosage', med.dosage),
              _infoRow('Route', med.route),
              _infoRow('Posologie', med.posologie),
              _infoRow('Laboratoire', med.laboratoire),
              if (med.warning != null) ...[
                const Divider(),
                const Text('Avertissements:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(med.warning!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildMedicamentsList() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Médicaments Prescrits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (medicaments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucun médicament sélectionné',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicaments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildMedicamentItem(medicaments[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicamentItem(Medicament med) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du médicament
                    Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (med.laboratoire != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Laboratoire: ${med.laboratoire}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(med),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Détails du médicament
          _buildDetailRow('Dosage', med.dosage),
          _buildDetailRow('Posologie', med.posologie),
          if (med.route != null)
            _buildDetailRow('Voie d\'administration', med.route),
          if (med.warning != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      med.warning!,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Medicament med) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous retirer ${med.name} de l\'ordonnance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() => medicaments.remove(med));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${med.name} retiré de l\'ordonnance'),
                  action: SnackBarAction(
                    label: 'Annuler',
                    onPressed: () => setState(() => medicaments.add(med)),
                  ),
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureAndCachet() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text('Signature'),
              const SizedBox(height: 8),
              SignaturePad(
                onSigned: (data) {
                  setState(() => _signature = data);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              const Text('Cachet'),
              const SizedBox(height: 8),
              CachetMedecin(
                imageBytes: _cachet,
                onSelect: (Uint8List bytes) {
                  setState(() => _cachet = bytes);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(StyleConstants.saveIcon),
          label: const Text('Sauvegarder'),
          onPressed: _saveOrdonnance,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleConstants.primaryColor,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(StyleConstants.ordonnanceIcon),
          label: const Text('Mes Ordonnances'),
          onPressed: () => Navigator.pushNamed(context, '/ordonnances-list'),
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleConstants.secondaryColor,
          ),
        ),
      ],
    );
  }

  void _saveOrdonnance() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      NavigationService.showTransitionDialog(context);

      final ordonnance = Ordonnance(
        patientId: _patientIdController.text,
        medecinId: _medecinIdController.text,
        clinique: _cliniqueController.text,
        specialite: _specialiteController.text,
        medicaments: medicaments,
        date: DateTime.now(),
        signature: _signature,
        cachet: _cachet,
      );

      final viewModel = context.read<OrdonnanceViewModel>();
      final success = await viewModel.createOrdonnance(ordonnance);

      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialogue de transition

        if (success) {
          await NavigationService.navigateToPdfActions(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la création de l\'ordonnance'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialogue de transition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addMedicament(Medicament medicament) {
    setState(() {
      // Vérifier si le médicament n'est pas déjà dans la liste
      if (!medicaments.any((med) => med.name == medicament.name)) {
        medicaments.add(medicament);
        _searchController.clear();
        context.read<OrdonnanceViewModel>().clearResults();

        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicament.name} ajouté à l\'ordonnance'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Annuler',
              textColor: Colors.white,
              onPressed: () {
                setState(() => medicaments.remove(medicament));
              },
            ),
          ),
        );
      } else {
        // Afficher un message d'erreur si le médicament existe déjà
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicament.name} est déjà dans l\'ordonnance'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
}
