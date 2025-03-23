import 'package:flutter/material.dart';
import 'package:medapp/services/doctor_service.dart';

// Constantes de couleurs pour le thème médical moderne
const Color primaryColor = Color(0xFF4FC3F7); // Bleu ciel
const Color accentColor = Color(0xFF03A9F4); // Bleu ciel plus foncé
const Color backgroundColor = Colors.white;
const Color textPrimaryColor = Color(0xFF2C3E50); // Gris foncé
const Color textSecondaryColor = Color(0xFF7F8C8D); // Gris moyen
const Color cardColor = Colors.white;

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final DoctorService _doctorService = DoctorService();
  late Future<List<Map<String, dynamic>>> _doctorsFuture;
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _doctorsFuture = _doctorService.getDoctors();
      final doctors = await _doctorsFuture;

      setState(() {
        _allDoctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterDoctors(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDoctors = _allDoctors;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        final doctorName = doctor["name"].toString().toLowerCase();
        final doctorSpecialty = doctor["specialty"].toString().toLowerCase();
        return doctorName.contains(lowercaseQuery) ||
            doctorSpecialty.contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Doctors",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _hasError
                    ? _buildErrorState()
                    : _filteredDoctors.isEmpty
                        ? _buildEmptyState()
                        : _buildDoctorsList(),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterDoctors,
        decoration: InputDecoration(
          hintText: "Rechercher un docteur...",
          hintStyle: TextStyle(color: textSecondaryColor),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterDoctors('');
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
            "Erreur lors du chargement des docteurs",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadDoctors,
            icon: Icon(Icons.refresh, color: primaryColor),
            label: Text(
              "Réessayer",
              style: TextStyle(color: primaryColor),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: primaryColor.withOpacity(0.1),
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
        ? "Aucun docteur trouvé"
        : "Aucun résultat pour \"${_searchController.text}\"";

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchController.text.isEmpty
                ? Icons.person_off
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
                _filterDoctors('');
              },
              icon: Icon(Icons.clear, color: primaryColor),
              label: Text(
                "Effacer la recherche",
                style: TextStyle(color: primaryColor),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: primaryColor.withOpacity(0.1),
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

  Widget _buildDoctorsList() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _filteredDoctors[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  _showDetailsDialog(context, doctor);
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: doctor["profile_image"] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  doctor["profile_image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: primaryColor,
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: primaryColor,
                                size: 24,
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  doctor["name"] ?? "Nom non disponible",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (doctor["is_verified"] == true)
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Spécialité: ${doctor["specialty"] ?? "Non spécifiée"}",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Adresse: ${doctor["address"] ?? "Non spécifiée"}",
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Téléphone: ${doctor["phone_number"] ?? "Non spécifié"}",
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

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                "Dr. ${doctor["name"]}",
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              if (doctor["is_verified"] == true)
                Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 20,
                ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem(
                    "Spécialité", doctor["specialty"] ?? "Non spécifiée"),
                _buildDetailItem(
                    "Adresse", doctor["address"] ?? "Non spécifiée"),
                _buildDetailItem(
                    "Téléphone", doctor["phone_number"] ?? "Non spécifié"),
                _buildDetailItem("Email", doctor["email"] ?? "Non spécifié"),
                if (doctor["profile_image"] != null) ...[
                  SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      doctor["profile_image"],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          color: primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Fermer",
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textSecondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
