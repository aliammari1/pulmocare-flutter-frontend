import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/services/appointment_service.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  _DoctorAppointmentsScreenState createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = false;
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<Appointment> _allAppointments = [];
  List<Appointment> _filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final doctorId = userData['user_id'] ?? '';

      // Load appointments from the service
      final appointments = await _appointmentService.getDoctorAppointments(doctorId: doctorId);

      setState(() {
        _allAppointments = appointments.items;
        _filterAppointmentsByDate(_selectedDay);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading appointments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAppointmentsByDate(DateTime date) {
    setState(() {
      _filteredAppointments = _allAppointments.where((appointment) {
        return isSameDay(appointment.scheduledTime, date);
      }).toList();
    });
  }

  void _filterAppointmentsByStatus(int tabIndex) {
    final filteredByDate = _allAppointments.where((appointment) {
      return isSameDay(appointment.scheduledTime, _selectedDay);
    }).toList();

    setState(() {
      switch (tabIndex) {
        case 0: // All
          _filteredAppointments = filteredByDate;
          break;
        case 1: // Pending
          _filteredAppointments = filteredByDate
              .where((appointment) => appointment.status == 'pending')
              .toList();
          break;
        case 2: // Confirmed
          _filteredAppointments = filteredByDate
              .where((appointment) => appointment.status == 'confirmed')
              .toList();
          break;
      }
    });
  }

  Future<void> _acceptAppointment(String appointmentId) async {
    setState(() => _isLoading = true);

    try {
      final updatedAppointment =
          await _appointmentService.acceptAppointment(appointmentId);

      setState(() {
        final index = _allAppointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _allAppointments[index] = updatedAppointment;
          _filterAppointmentsByStatus(_tabController.index);
        }
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment accepted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectAppointment(String appointmentId) async {
    setState(() => _isLoading = true);

    try {
      await _appointmentService.rejectAppointment(appointmentId);

      setState(() {
        _allAppointments.removeWhere((a) => a.id == appointmentId);
        _filterAppointmentsByStatus(_tabController.index);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => context.go("/doctor-dashboard"),
        ),
        title: const Text(
          "Appointments",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4, // Added elevation for better visibility
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              onTap: _filterAppointmentsByStatus,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Confirmed"),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          _buildCalendar(),

          // Appointment list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? _buildEmptyState()
                    : _buildAppointmentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 180)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) {
          return _allAppointments
              .where((appointment) => isSameDay(appointment.scheduledTime, day))
              .toList();
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _filterAppointmentsByStatus(_tabController.index);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: TextStyle(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No appointments found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try selecting a different date or tab",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _filteredAppointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final bool isPending = appointment.status == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPending
              ? Colors.orange.withOpacity(0.5)
              : Colors.green.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        leading: CircleAvatar(
          backgroundColor: isPending
              ? Colors.orange.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          child: Icon(
            isPending ? Icons.schedule : Icons.check_circle,
            color: isPending ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          appointment.patientId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(appointment.scheduledTime),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  appointment.reason as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isPending
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isPending ? 'Pending' : 'Confirmed',
            style: TextStyle(
              color: isPending ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          // More details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _buildDetailRow('Patient ID', appointment.patientId),
              _buildDetailRow('Notes', appointment.notes as String),

              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectAppointment(appointment.id),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptAppointment(appointment.id),
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // View patient history button
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    context.push('/patient-history/${appointment.patientId}'),
                icon: const Icon(Icons.person),
                label: const Text('View Patient History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
