import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/doctor.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/theme/app_theme.dart';

class FindSpecialistScreen extends StatefulWidget {
  const FindSpecialistScreen({super.key});

  @override
  _FindSpecialistScreenState createState() => _FindSpecialistScreenState();
}

class _FindSpecialistScreenState extends State<FindSpecialistScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _allDoctors =
      []; // Updated type from Map<String, dynamic> to Doctor
  List<Doctor> _filteredDoctors =
      []; // Updated type from Map<String, dynamic> to Doctor
  String _selectedSpecialty = 'All Specialties';
  List<String> _specialties = ['All Specialties'];
  bool _isLoading = true;
  bool _hasError = false;
  String? _error;

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
      final doctors = await _doctorService.getDoctors();

      // Extract unique specialties
      final specialties = <String>{'All Specialties'};
      for (final doctor in doctors.items) {
        if (doctor.specialty != null && doctor.specialty.isNotEmpty) {
          specialties.add(doctor.specialty);
        }
      }

      setState(() {
        _allDoctors = doctors.items;
        _filteredDoctors = doctors.items;
        _specialties = specialties.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      if (_selectedSpecialty == 'All Specialties') {
        if (query.isEmpty) {
          _filteredDoctors = _allDoctors;
        } else {
          final lowercaseQuery = query.toLowerCase();
          _filteredDoctors = _allDoctors.where((doctor) {
            final doctorName = (doctor.name ?? "").toLowerCase();
            final doctorSpecialty = doctor.specialty.toLowerCase();
            return doctorName.contains(lowercaseQuery) ||
                doctorSpecialty.contains(lowercaseQuery);
          }).toList();
        }
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredDoctors = _allDoctors.where((doctor) {
          final doctorName = (doctor.name ?? "").toLowerCase();
          final doctorSpecialty = doctor.specialty;

          final matchesSpecialty = doctorSpecialty == _selectedSpecialty;
          final matchesSearch = query.isEmpty ||
              doctorName.contains(lowercaseQuery) ||
              doctorSpecialty.toLowerCase().contains(lowercaseQuery);

          return matchesSpecialty && matchesSearch;
        }).toList();
      }
    });
  }

  void _onSpecialtyChanged(String? specialty) {
    if (specialty == null) return;
    setState(() {
      _selectedSpecialty = specialty;
      _filterDoctors(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Specialist'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSpecialtyFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? _buildErrorView()
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterDoctors,
        decoration: InputDecoration(
          hintText: "Search doctors...",
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterDoctors('');
                  },
                  child: const Icon(Icons.clear, color: Colors.grey),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSpecialtyFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = _selectedSpecialty == specialty;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (_) => _onSpecialtyChanged(specialty),
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error loading specialists",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? "Unknown error occurred",
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDoctors,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No specialists found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try different search terms'
                : 'No specialists available for the selected criteria',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => _showDoctorDetails(doctor),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor image
                  _buildDoctorAvatar(doctor),
                  const SizedBox(width: 16),

                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and verification
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctor.name ?? "Unknown",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (doctor.isVerified == true)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Specialty
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Address
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                doctor.address ?? "No address provided",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Phone
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              doctor.phone ?? "No phone provided",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.message_outlined,
                                    size: 16),
                                label: const Text('Contact'),
                                onPressed: () => context.push(
                                  '/contact-doctor',
                                  extra: {'doctorId': doctor.id},
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon:
                                    const Icon(Icons.calendar_today, size: 16),
                                label: const Text('Book'),
                                onPressed: () => context.push(
                                  '/book-appointment',
                                  extra: {'doctorId': doctor.id},
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorAvatar(Doctor doctor) {
    return Hero(
      tag: 'doctor-${doctor.id}',
      child: CircleAvatar(
        radius: 40,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        backgroundImage: doctor.profilePicture != null
            ? NetworkImage(doctor.profilePicture!)
            : null,
        child: doctor.name == null
            ? Text(
                doctor.name ?? "?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              )
            : null,
      ),
    );
  }

  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor header with image
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Background color
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),

                      // Doctor avatar
                      Positioned(
                        bottom: 20,
                        child: Hero(
                          tag: 'doctor-${doctor.id}',
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: doctor.profilePicture != null
                                ? NetworkImage(doctor.profilePicture!)
                                : null,
                            child: doctor.profilePicture == null
                                ? Text(
                                    (doctor.name != null &&
                                            doctor.name!.isNotEmpty)
                                        ? doctor.name![0]
                                        : "?",
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Close button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Doctor info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Name and verification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              doctor.name ?? "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (doctor.isVerified == true)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Specialty
                        Text(
                          doctor.specialty ?? "General",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Contact info
                        _buildDetailItem(
                          Icons.location_on_outlined,
                          "Address",
                          doctor.address ?? "Not provided",
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          Icons.phone_outlined,
                          "Phone",
                          doctor.phone ?? "Not provided",
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          Icons.email_outlined,
                          "Email",
                          doctor.email ?? "Not provided",
                        ),
                        const SizedBox(height: 32),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.message_outlined),
                                label: const Text('Contact'),
                                onPressed: () {
                                  context.pop();
                                  context.push(
                                    '/contact-doctor',
                                    extra: {'doctorId': doctor.id},
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Book Appointment'),
                                onPressed: () {
                                  context.pop();
                                  context.push(
                                    '/book-appointment',
                                    extra: {'doctorId': doctor.id},
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
