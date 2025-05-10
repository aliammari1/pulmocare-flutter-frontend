import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({super.key});

  @override
  _PatientAppointmentScreenState createState() =>
      _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen>
    with SingleTickerProviderStateMixin {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Appointment data
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];
  List<Map<String, dynamic>> _availableDoctors = [];
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _loadAppointmentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // In a real app, you would fetch this data from your API
      await Future.delayed(const Duration(seconds: 1));

      // Mock upcoming appointments
      final upcomingAppointments = [
        {
          "id": "a1",
          "doctorName": "Dr. Ahmed Khelifi",
          "doctorSpecialty": "Dermatology",
          "date": "2025-04-29",
          "time": "10:30 AM",
          "status": "confirmed",
          "location": "Main Clinic, Room 203",
          "reason": "Annual skin check",
          "notes": ""
        },
        {
          "id": "a2",
          "doctorName": "Dr. Fatma Bouazizi",
          "doctorSpecialty": "Neurology",
          "date": "2025-05-03",
          "time": "2:15 PM",
          "status": "pending",
          "location": "North Medical Center",
          "reason": "Recurring headaches",
          "notes": "Please bring previous medical records"
        }
      ];

      // Mock past appointments
      final pastAppointments = [
        {
          "id": "a3",
          "doctorName": "Dr. Mohamed Ben Salem",
          "doctorSpecialty": "Orthopedic Surgery",
          "date": "2025-03-15",
          "time": "11:00 AM",
          "status": "completed",
          "location": "South Clinic",
          "reason": "Follow-up for ankle injury",
          "notes": "",
          "diagnosis": "Healing well, continue physical therapy",
          "prescription": "Pain medication provided"
        },
        {
          "id": "a4",
          "doctorName": "Dr. Jane Smith",
          "doctorSpecialty": "Cardiology",
          "date": "2025-02-20",
          "time": "9:45 AM",
          "status": "completed",
          "location": "Heart Center",
          "reason": "Blood pressure check",
          "notes": "",
          "diagnosis": "Mild hypertension",
          "prescription": "Prescribed lifestyle changes"
        },
        {
          "id": "a5",
          "doctorName": "Dr. Leila Trabelsi",
          "doctorSpecialty": "Pediatrics",
          "date": "2025-01-10",
          "time": "3:30 PM",
          "status": "no_show",
          "location": "Children's Clinic",
          "reason": "Annual checkup",
          "notes": "Missed appointment"
        }
      ];

      // Mock available doctors
      final availableDoctors = [
        {
          "id": "d123",
          "name": "Dr. Ahmed Khelifi",
          "specialty": "Dermatology",
          "avatar": "https://randomuser.me/api/portraits/men/55.jpg",
          "rating": 4.8,
          "patients": 1200,
          "experience": 12,
          "availability": [
            {
              "date": "2025-04-28",
              "slots": ["9:30 AM", "11:00 AM", "2:30 PM"]
            },
            {
              "date": "2025-04-29",
              "slots": ["10:30 AM", "3:00 PM"]
            },
            {
              "date": "2025-04-30",
              "slots": ["9:00 AM", "11:30 AM", "4:00 PM"]
            },
          ]
        },
        {
          "id": "d124",
          "name": "Dr. Fatma Bouazizi",
          "specialty": "Neurology",
          "avatar": "https://randomuser.me/api/portraits/women/28.jpg",
          "rating": 4.9,
          "patients": 950,
          "experience": 15,
          "availability": [
            {
              "date": "2025-04-28",
              "slots": ["10:00 AM", "3:30 PM"]
            },
            {
              "date": "2025-05-02",
              "slots": ["11:30 AM", "1:00 PM", "4:30 PM"]
            },
            {
              "date": "2025-05-03",
              "slots": ["9:30 AM", "2:15 PM"]
            },
          ]
        },
        {
          "id": "d125",
          "name": "Dr. Mohamed Ben Salem",
          "specialty": "Orthopedic Surgery",
          "avatar": "https://randomuser.me/api/portraits/men/32.jpg",
          "rating": 4.7,
          "patients": 1050,
          "experience": 10,
          "availability": [
            {
              "date": "2025-04-29",
              "slots": ["8:30 AM", "1:30 PM"]
            },
            {
              "date": "2025-05-01",
              "slots": ["10:30 AM", "2:00 PM", "4:30 PM"]
            },
            {
              "date": "2025-05-04",
              "slots": ["9:00 AM", "11:30 AM", "3:00 PM"]
            },
          ]
        },
        {
          "id": "d127",
          "name": "Dr. Jane Smith",
          "specialty": "Cardiology",
          "avatar": "https://randomuser.me/api/portraits/women/65.jpg",
          "rating": 4.9,
          "patients": 1300,
          "experience": 18,
          "availability": [
            {
              "date": "2025-04-30",
              "slots": ["9:00 AM", "11:30 AM", "2:00 PM"]
            },
            {
              "date": "2025-05-02",
              "slots": ["10:00 AM", "1:30 PM", "3:30 PM"]
            },
            {
              "date": "2025-05-05",
              "slots": ["8:30 AM", "10:30 AM", "4:00 PM"]
            },
          ]
        },
        {
          "id": "d126",
          "name": "Dr. Leila Trabelsi",
          "specialty": "Pediatrics",
          "avatar": "https://randomuser.me/api/portraits/women/42.jpg",
          "rating": 4.8,
          "patients": 2000,
          "experience": 14,
          "availability": [
            {
              "date": "2025-04-28",
              "slots": ["10:00 AM", "1:00 PM", "3:30 PM"]
            },
            {
              "date": "2025-05-03",
              "slots": ["9:30 AM", "11:00 AM", "2:30 PM"]
            },
            {
              "date": "2025-05-06",
              "slots": ["10:30 AM", "1:30 PM", "4:00 PM"]
            },
          ]
        }
      ];

      // Create events map for calendar
      final events = <DateTime, List<dynamic>>{};
      for (var appointment in [...upcomingAppointments, ...pastAppointments]) {
        final date = DateTime.parse(appointment['date'] as String);
        if (events[DateTime(date.year, date.month, date.day)] == null) {
          events[DateTime(date.year, date.month, date.day)] = [];
        }
        events[DateTime(date.year, date.month, date.day)]!.add(appointment);
      }

      // Add doctor availability to events
      for (var doctor in availableDoctors) {
        for (var availability in doctor['availability'] as List<dynamic>) {
          final date = DateTime.parse(availability['date'] as String);
          if (events[DateTime(date.year, date.month, date.day)] == null) {
            events[DateTime(date.year, date.month, date.day)] = [];
          }
          events[DateTime(date.year, date.month, date.day)]!.add({
            'type': 'availability',
            'doctorId': doctor['id'],
            'doctorName': doctor['name'],
            'slots': availability['slots']
          });
        }
      }

      setState(() {
        _upcomingAppointments = upcomingAppointments;
        _pastAppointments = pastAppointments;
        _availableDoctors = availableDoctors;
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Appointments'),
            Tab(text: 'Book Appointment'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsTab(),
                    _buildBookAppointmentTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAppointmentData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
        _buildAppointmentCalendar(),
        const Divider(height: 1),
        _buildSelectedDayAppointments(),
      ],
    );
  }

  Widget _buildAppointmentCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2026, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: _getEventsForDay,
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
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
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSelectedDayAppointments() {
    if (_selectedDay == null) return const SizedBox();

    final events = _getEventsForDay(_selectedDay!);
    final appointments =
        events.where((e) => e['type'] != 'availability').toList();

    if (appointments.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 72,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No appointments for ${DateFormat.yMMMMd().format(_selectedDay!)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.add),
                label: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date = DateTime.parse(appointment['date']);
    final formattedDate = DateFormat.yMMMMd().format(date);
    final status = appointment['status'];

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'no_show':
        statusColor = Colors.red[900]!;
        statusIcon = Icons.remove_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  _formatAppointmentStatus(status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['doctorName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            appointment['doctorSpecialty'],
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAppointmentDetail(Icons.event, 'Date', formattedDate),
                _buildAppointmentDetail(
                    Icons.access_time, 'Time', appointment['time']),
                _buildAppointmentDetail(
                    Icons.location_on, 'Location', appointment['location']),
                if (appointment['reason'].isNotEmpty)
                  _buildAppointmentDetail(Icons.medical_information, 'Reason',
                      appointment['reason']),
                if (status == 'completed' && appointment['diagnosis'] != null)
                  _buildAppointmentDetail(
                      Icons.note, 'Diagnosis', appointment['diagnosis']),
                if (appointment['notes'].isNotEmpty)
                  _buildAppointmentDetail(
                      Icons.comment, 'Notes', appointment['notes']),
              ],
            ),
          ),
          const Divider(height: 1),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: _buildActionButtons(appointment),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> appointment) {
    final status = appointment['status'];
    final List<Widget> buttons = [];

    if (status == 'confirmed' || status == 'pending') {
      buttons.add(
        TextButton(
          child: const Text('Reschedule'),
          onPressed: () => _showRescheduleDialog(appointment),
        ),
      );

      buttons.add(
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red[700]),
          ),
          onPressed: () => _showCancelDialog(appointment),
        ),
      );
    }

    if (status == 'completed') {
      buttons.add(
        TextButton(
          child: const Text('View Details'),
          onPressed: () => context.push('/appointment/${appointment['id']}'),
        ),
      );
    }

    if (buttons.isEmpty) {
      buttons.add(
        TextButton(
          child: const Text('View'),
          onPressed: () => context.push('/appointment/${appointment['id']}'),
        ),
      );
    }

    return buttons;
  }

  Widget _buildBookAppointmentTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search doctors, specialties...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        _buildSpecialtyFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _availableDoctors[index];
              return _buildDoctorCard(doctor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyFilter() {
    final specialties = [
      'All',
      'Dermatology',
      'Cardiology',
      'Neurology',
      'Orthopedics',
      'Pediatrics',
      'Psychiatry',
      'Ophthalmology',
      'ENT'
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          final isSelected = index == 0; // Just for UI demonstration

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                // Implement specialty filter
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(doctor['avatar']),
            ),
            title: Text(
              doctor['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(doctor['specialty']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor['rating']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text('${doctor['patients']} patients'),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.work,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text('${doctor['experience']} yrs'),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAvailabilityChips(doctor),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  context.push('/doctor-profile/${doctor['id']}');
                },
                child: const Text('View Profile'),
              ),
              ElevatedButton(
                onPressed: () => _showBookingDialog(doctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChips(Map<String, dynamic> doctor) {
    final availability = doctor['availability'] as List;
    if (availability.isEmpty) {
      return const Text('No availability in the next days');
    }

    return Wrap(
      spacing: 8,
      children: availability.take(3).map<Widget>((slot) {
        final date = DateTime.parse(slot['date']);
        final formattedDate = DateFormat('MMM d').format(date);
        final availableSlots = slot['slots'].length;

        return Chip(
          avatar: const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.event_available,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          label: Text('$formattedDate ($availableSlots slots)'),
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        );
      }).toList(),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: const SingleChildScrollView(
          child: Text(
              'This feature is coming soon. Would you like to call the clinic to reschedule?'),
        ),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => context.pop(),
          ),
          TextButton(
            child: const Text('Yes, Call Clinic'),
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling clinic...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this appointment?'),
              const SizedBox(height: 16),
              Text(
                'Appointment: ${appointment['doctorName']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Date: ${DateFormat.yMMMMd().format(DateTime.parse(appointment['date']))} at ${appointment['time']}'),
              const SizedBox(height: 16),
              const Text(
                  'Please note that cancellations less than 24 hours before the appointment may incur a fee.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('No, Keep It'),
            onPressed: () => context.pop(),
          ),
          TextButton(
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red[700]),
            ),
            onPressed: () {
              // Cancel the appointment
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled')),
              );
              // Refresh the list
              _loadAppointmentData();
            },
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(doctor['avatar']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          doctor['specialty'],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a date and time for your appointment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildBookingCalendar(doctor),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  // Show confirmation dialog or navigate to appointment details
                  _showBookingConfirmation(doctor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCalendar(Map<String, dynamic> doctor) {
    // This is a simplified version just for demonstration
    final availability = doctor['availability'] as List;

    return SizedBox(
      height: 300,
      child: DefaultTabController(
        length: availability.length,
        child: Column(
          children: [
            TabBar(
              tabs: availability.map<Widget>((slot) {
                final date = DateTime.parse(slot['date']);
                final formattedDate = DateFormat('MMM d').format(date);
                final dayName = DateFormat('E').format(date);

                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayName),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
            ),
            Expanded(
              child: TabBarView(
                children: availability.map<Widget>((slot) {
                  final slots = slot['slots'] as List;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final time = slots[index];

                      return GestureDetector(
                        onTap: () {
                          // Selected time
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(8),
                            color: index ==
                                    0 // Just for demo, first slot is selected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                fontWeight: index == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: index == 0
                                    ? AppTheme.primaryColor
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmation(Map<String, dynamic> doctor) {
    // This is just for demonstration purposes
    final selectedDate = doctor['availability'][0]['date'];
    final selectedTime = doctor['availability'][0]['slots'][0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your appointment has been successfully booked!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildConfirmationDetail('Doctor', doctor['name']),
              _buildConfirmationDetail('Specialty', doctor['specialty']),
              _buildConfirmationDetail('Date',
                  DateFormat.yMMMMd().format(DateTime.parse(selectedDate))),
              _buildConfirmationDetail('Time', selectedTime),
              const SizedBox(height: 16),
              const Text(
                'A confirmation email has been sent to your registered email address.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Add to Calendar'),
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to calendar')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              context.pop();
              _loadAppointmentData(); // Refresh to show the new appointment
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: true,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Upcoming'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Past'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Confirmed'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Date Range'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'From',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'To',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Reset'),
            onPressed: () => context.pop(),
          ),
          ElevatedButton(
            child: const Text('Apply'),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  String _formatAppointmentStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status;
    }
  }
}
