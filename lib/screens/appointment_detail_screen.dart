import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/services/appointment_service.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  _AppointmentDetailScreenState createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();
  bool _isLoading = true;
  Appointment? _appointment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final appointment =
          await _appointmentService.getAppointmentDetails(widget.appointmentId);

      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment() async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);

      await _appointmentService.rejectAppointment(widget.appointmentId);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Appointment canceled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel appointment: $_error'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Appointment Details'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load appointment details',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAppointmentDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _appointment == null
                  ? const Center(
                      child: Text('Appointment not found'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _appointment!.status ==
                                            AppointmentStatus.accepted
                                        ? Icons.check_circle
                                        : _appointment!.status ==
                                                AppointmentStatus.pending
                                            ? Icons.schedule
                                            : _appointment!.status ==
                                                    AppointmentStatus.completed
                                                ? Icons.done_all
                                                : Icons.cancel,
                                    color: Color(
                                      int.parse(
                                        _getStatusColor(_appointment!.status)
                                            .replaceAll('#', '0xFF'),
                                      ),
                                    ),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status: ${_appointment!.status.toString().split('.').last}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          _appointment!.isVirtual
                                              ? 'Virtual Appointment'
                                              : 'In-Person Appointment',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date and time card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date & Time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('EEEE, MMMM d, yyyy').format(
                                            _appointment!.scheduledTime),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('h:mm a').format(
                                            _appointment!.scheduledTime),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Doctor info card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Doctor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.2),
                                        radius: 24,
                                        child: Text(
                                          _appointment!.doctorId,
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _appointment!.doctorId,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            // You can add more doctor info here if available
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => context
                                            .push('/contact-doctor', extra: {
                                          'doctorId': _appointment!.doctorId,
                                          'doctorName': _appointment!.doctorId
                                        }),
                                        icon: const Icon(Icons.message),
                                        color: AppTheme.primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reason card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reason for Visit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _appointment!.reason ??
                                        "No reason provided",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Notes card (if any)
                          if ((_appointment!.notes ?? "No notes") !=
                              "No notes") ...[
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Additional Notes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _appointment!.notes ??
                                          "No notes provided",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Action buttons
                          if (_appointment!.status ==
                                  AppointmentStatus.pending ||
                              _appointment!.status ==
                                  AppointmentStatus.accepted) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _appointment!.status !=
                                        AppointmentStatus.cancelled
                                    ? _cancelAppointment
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel Appointment',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }
}
