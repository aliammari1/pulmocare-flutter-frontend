import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/models/doctor.dart';
import 'package:medapp/services/appointment_service.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  _PatientAppointmentsScreenState createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final doctorId = userData['user_id'] ?? '';
      // Load appointments from service
      final appointments =
          await _appointmentService.getDoctorAppointments(doctorId: doctorId);

      setState(() {
        _appointments = appointments.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.accepted:
        return '#4CAF50'; // Green
      case AppointmentStatus.pending:
        return '#FFC107'; // Amber
      case AppointmentStatus.cancelled:
        return '#F44336'; // Red
      case AppointmentStatus.completed:
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load appointments',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAppointments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 72,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Book an appointment with a doctor',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/book-appointment'),
                            icon: const Icon(Icons.add),
                            label: const Text('Book Appointment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final statusColor = _getStatusColor(appointment.status);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => context.push(
                              '/appointment/${appointment.id}',
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        child: Text(
                                          appointment.patientId,
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appointment.doctorId,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              appointment.reason ??
                                                  'No reason provided',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            int.parse(
                                              statusColor.replaceAll(
                                                  '#', '0xFF'),
                                            ),
                                          ).withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          appointment.status
                                              .toString()
                                              .split('.')
                                              .last,
                                          style: TextStyle(
                                            color: Color(
                                              int.parse(
                                                statusColor.replaceAll(
                                                    '#', '0xFF'),
                                              ),
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${appointment.scheduledTime.day}/${appointment.scheduledTime.month}/${appointment.scheduledTime.year}',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.access_time,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book-appointment'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
    );
  }
}
