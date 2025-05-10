import 'package:flutter/material.dart';
import 'package:medapp/services/rapport_service.dart';
import 'package:go_router/go_router.dart';

// Constantes de couleurs pour le thème médical moderne
const Color primaryColor = Color(0xFF4FC3F7); // Bleu ciel
const Color accentColor = Color(0xFF03A9F4); // Bleu ciel plus foncé
const Color backgroundColor = Colors.white;
const Color textPrimaryColor = Color(0xFF2C3E50); // Gris foncé
const Color textSecondaryColor = Color(0xFF7F8C8D); // Gris moyen
const Color cardColor = Colors.white;

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final RapportService _rapportService = RapportService();
  late Future<List<Map<String, dynamic>>> _rapportsFuture;
  List<Map<String, dynamic>> _allRapports = [];
  List<Map<String, dynamic>> _filteredRapports = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRapports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRapports() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _rapportsFuture = _rapportService.getRapports();
      final rapports = await _rapportsFuture;

      setState(() {
        _allRapports = rapports;
        _filteredRapports = rapports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterRapports(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRapports = _allRapports;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredRapports = _allRapports.where((rapport) {
        final patientName = rapport["patientName"].toString().toLowerCase();
        return patientName.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _hasError
                    ? _buildErrorState()
                    : _filteredRapports.isEmpty
                        ? _buildEmptyState()
                        : _buildRapportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterRapports,
        decoration: InputDecoration(
          hintText: "Rechercher un patient...",
          hintStyle: TextStyle(color: textSecondaryColor),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterRapports('');
                  },
                  child: Icon(Icons.close, color: textSecondaryColor),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          SizedBox(height: 16),
          Text(
            "Erreur lors du chargement des rapports",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadRapports,
            icon: Icon(Icons.refresh, color: primaryColor),
            label: Text(
              "Réessayer",
              style: TextStyle(color: primaryColor),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // ignore: deprecated_member_use
              backgroundColor: primaryColor.withAlpha((0.1 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = _searchController.text.isEmpty
        ? "Aucun rapport trouvé"
        : "Aucun résultat pour \"${_searchController.text}\"";

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchController.text.isEmpty
                ? Icons.folder_open
                : Icons.search_off,
            size: 48,
            color: textSecondaryColor,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _filterRapports('');
              },
              icon: Icon(Icons.clear, color: primaryColor),
              label: Text(
                "Effacer la recherche",
                style: TextStyle(color: primaryColor),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // ignore: deprecated_member_use
                backgroundColor: primaryColor.withAlpha((0.1 * 255).toInt()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRapportsList() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _filteredRapports.length,
        itemBuilder: (context, index) {
          final rapport = _filteredRapports[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _showDetailsDialog(context, rapport);
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rapport["patientName"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Type d'examen: ${rapport["examType"]}",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Type de rapport: ${rapport["reportType"]}",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Date: ${rapport["date"]}",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> rapport) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Détails du Rapport",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            Icons.person, "Patient", rapport["patientName"]),
                        SizedBox(height: 12),
                        _buildDetailRow(Icons.medical_services_outlined,
                            "Type d'examen", rapport["examType"]),
                        SizedBox(height: 12),
                        _buildDetailRow(Icons.folder_outlined,
                            "Type de rapport", rapport["reportType"]),
                        SizedBox(height: 20),
                        Text(
                          "Contenu:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            rapport["content"],
                            style: TextStyle(
                              color: textPrimaryColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        "Fermer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
