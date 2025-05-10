import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../services/doctor_service.dart';
import '../theme/app_theme.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  _PrescriptionsScreenState createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = false;
  String? _errorMessage;
  List<Prescription> _prescriptions = [];
  List<Prescription> _filteredPrescriptions = [];
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final prescriptions = await _doctorService.getDoctorPrescriptions();

      if (mounted) {
        setState(() {
          _prescriptions = prescriptions;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredPrescriptions = _prescriptions.where((prescription) {
        // Apply search query
        final matchesSearch = prescription.patientName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            prescription.id.toLowerCase().contains(_searchQuery.toLowerCase());

        // Apply status filter
        final matchesStatus = _statusFilter == 'All' ||
            prescription.status.toString().toLowerCase() ==
                _statusFilter.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showStatusFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const Divider(),
              for (String status in [
                'All',
                'Active',
                'Completed',
                'Cancelled',
                'Expired'
              ])
                ListTile(
                  leading: Icon(
                    _statusFilter == status
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _statusFilter == status
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  title: Text(status),
                  onTap: () {
                    setState(() {
                      _statusFilter = status;
                      _applyFilters();
                    });
                    context.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prescriptions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.push("/doctor-dashboard"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showStatusFilterBottomSheet,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrescriptions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => context.push('/create-prescription'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search prescriptions',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              ),
            ),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Active'),
                  _buildFilterChip('Completed'),
                  _buildFilterChip('Cancelled'),
                ],
              ),
            ),

            // Status indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Status: $_statusFilter',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredPrescriptions.length} prescriptions',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Prescription List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _filteredPrescriptions.isEmpty
                          ? _buildEmptyState()
                          : _buildPrescriptionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _statusFilter == label;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _statusFilter = selected ? label : 'All';
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading prescriptions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage ?? 'Unknown error'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPrescriptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
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
            Icons.healing,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty && _statusFilter == 'All'
                ? 'No prescriptions found'
                : 'No matching prescriptions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty && _statusFilter == 'All'
                ? 'Create a new prescription to get started'
                : 'Try adjusting your filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _statusFilter != 'All')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _statusFilter = 'All';
                  _applyFilters();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    return RefreshIndicator(
      onRefresh: _loadPrescriptions,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredPrescriptions.length,
        itemBuilder: (context, index) {
          final prescription = _filteredPrescriptions[index];
          return _buildPrescriptionCard(prescription);
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    Color statusColor;
    IconData statusIcon;

    switch (prescription.status.toString().toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'expired':
        statusColor = Colors.orange;
        statusIcon = Icons.timer_off;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
    }

    final medicationCount = prescription.medications.length;
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/prescription/${prescription.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${prescription.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prescription.status.toString(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$medicationCount medication${medicationCount != 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatter.format(prescription.date),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/prescription/${prescription.id}'),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
