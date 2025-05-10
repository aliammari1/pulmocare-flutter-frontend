import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class VirtualWaitingRoomScreen extends StatefulWidget {
  final String? doctorId;
  final String? appointmentId;

  const VirtualWaitingRoomScreen({
    Key? key,
    this.doctorId,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<VirtualWaitingRoomScreen> createState() =>
      _VirtualWaitingRoomScreenState();
}

class _VirtualWaitingRoomScreenState extends State<VirtualWaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  Timer? _positionTimer;
  Timer? _updateTimer;
  int _estimatedWaitMinutes = 0;
  int _queuePosition = 0;
  final bool _isVideoConsultation = true;
  bool _showPreparing = false;
  Map<String, dynamic>? _doctorInfo;
  Map<String, dynamic>? _appointmentInfo;
  late AnimationController _pulseAnimationController;
  bool _documentsFilled = false;
  bool _questionnaireFilled = false;
  bool _paymentConfirmed = true;
  List<String> _activities = [];
  final List<String> _tips = [
    "Make sure you're in a quiet place with good internet connection",
    "Have your medication list ready to discuss with your doctor",
    "Write down any questions you'd like to ask during your consultation",
    "Make sure the room is well-lit so the doctor can see you clearly",
    "Try to join from a private space where you can speak freely",
    "Have any relevant medical documents or test results accessible",
  ];

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fetchWaitingRoomData();

    // Simulate queue updates
    _updateTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _updateQueuePosition();
    });

    // Simulate doctor preparation when queue position is 1
    _positionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_queuePosition == 1 && !_showPreparing) {
        setState(() {
          _showPreparing = true;
        });

        // After 5 seconds, show doctor is ready
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _notifyDoctorReady();
          }
        });
      }
    });
  }

  Future<void> _fetchWaitingRoomData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - in real app this would come from your API
      final Random random = Random();
      _queuePosition = random.nextInt(3) + 1; // Position 1-3
      _estimatedWaitMinutes =
          _queuePosition * 5 + random.nextInt(3); // Estimate wait time

      setState(() {
        _isLoading = false;
        _doctorInfo = {
          "id": widget.doctorId ?? "D-123456",
          "name": "Dr. Sophie Williams",
          "specialty": "Pulmonology",
          "profileImage": "https://randomuser.me/api/portraits/women/44.jpg",
          "rating": 4.8,
        };

        _appointmentInfo = {
          "id": widget.appointmentId ?? "A-789012",
          "scheduledTime":
              DateTime.now().add(Duration(minutes: _estimatedWaitMinutes)),
          "type": "Video Consultation",
          "reason": "Respiratory Examination",
        };
      });

      // Log activity
      _addActivity("You've entered the virtual waiting room");

      // Check for missing prerequisites
      _checkPrerequisites();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = "Error loading waiting room: $e";
        print(_errorMessage);
      });
    }
  }

  void _checkPrerequisites() {
    // In a real app, fetch these from your backend
    setState(() {
      _documentsFilled = Random().nextBool();
      _questionnaireFilled = Random().nextBool();
    });

    if (!_documentsFilled) {
      _addActivity("Please complete your medical history form", isAlert: true);
    }

    if (!_questionnaireFilled) {
      _addActivity("Pre-appointment questionnaire incomplete", isAlert: true);
    }
  }

  void _addActivity(String activity, {bool isAlert = false}) {
    setState(() {
      _activities.insert(0, activity);
    });

    if (isAlert) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(activity),
          backgroundColor:
              isAlert ? AppTheme.warningColor : AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          action: isAlert
              ? SnackBarAction(
                  label: 'Complete',
                  textColor: Colors.white,
                  onPressed: () {
                    _completeRequiredAction(activity);
                  },
                )
              : null,
        ),
      );
    }
  }

  void _completeRequiredAction(String activity) {
    if (activity.contains('medical history')) {
      setState(() {
        _documentsFilled = true;
      });
      _addActivity("Medical history form completed");
    } else if (activity.contains('questionnaire')) {
      setState(() {
        _questionnaireFilled = true;
      });
      _addActivity("Pre-appointment questionnaire completed");
    }
  }

  void _updateQueuePosition() {
    if (_queuePosition > 1) {
      setState(() {
        _queuePosition -= 1;
        _estimatedWaitMinutes = max(1, _estimatedWaitMinutes - 3);
      });
      _addActivity("Your position in line has been updated to $_queuePosition");
    }
  }

  void _notifyDoctorReady() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.video_call, color: AppTheme.successColor),
            const SizedBox(width: 8),
            const Text("Doctor is Ready!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Dr. ${_doctorInfo?['name'] ?? 'Your doctor'} is ready to see you now."),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // In a real app, this would navigate to the video call screen
                context.push(
                  '/video-call',
                  extra: {
                    'doctorName': _doctorInfo?['name'] ?? 'Doctor',
                    'appointmentType': 'Video Consultation',
                  },
                );
              },
              child: const Text("Join Call Now"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _updateTimer?.cancel();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Waiting Room'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showTipsDialog();
            },
            tooltip: 'Tips',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _isError
                ? _buildErrorState()
                : _buildWaitingRoom(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Entering virtual waiting room...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchWaitingRoomData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingRoom() {
    return Column(
      children: [
        // Status section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _showPreparing
              ? _buildDoctorPreparingStatus()
              : _buildQueuePositionStatus(),
        ),

        // Doctor information
        _buildDoctorSection(),

        // Appointment information and status
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildAppointmentDetails(),
                const SizedBox(height: 24),
                _buildRequiredActions(),
                const SizedBox(height: 24),
                _buildActivityFeed(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueuePositionStatus() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Position in Queue: $_queuePosition',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Estimated Wait: ~$_estimatedWaitMinutes minutes',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: 1 - (_queuePosition / 5), // Assuming max position is 5
          backgroundColor: AppTheme.disabledColor,
          color: AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildDoctorPreparingStatus() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimationController,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(
                        0.3 + 0.2 * _pulseAnimationController.value),
                    spreadRadius: 2 + 2 * _pulseAnimationController.value,
                    blurRadius: 3 + 3 * _pulseAnimationController.value,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Doctor is preparing for your visit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ),
        const Icon(Icons.video_call, color: AppTheme.successColor),
      ],
    );
  }

  Widget _buildDoctorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: _doctorInfo?['profileImage'] != null
                ? NetworkImage(_doctorInfo!['profileImage'])
                : null,
            child: _doctorInfo?['profileImage'] == null
                ? const Icon(Icons.person, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorInfo?['name'] ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _doctorInfo?['specialty'] ?? 'Specialist',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_doctorInfo?['rating'] ?? '4.5'} ★',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isVideoConsultation
                      ? AppTheme.secondaryColor.withOpacity(0.1)
                      : AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isVideoConsultation
                        ? AppTheme.secondaryColor.withOpacity(0.5)
                        : AppTheme.warningColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVideoConsultation ? Icons.videocam : Icons.phone,
                      size: 16,
                      color: _isVideoConsultation
                          ? AppTheme.secondaryColor
                          : AppTheme.warningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isVideoConsultation ? 'Video' : 'Audio',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isVideoConsultation
                            ? AppTheme.secondaryColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    // Format date and time
    final appointmentTime = _appointmentInfo?['scheduledTime'];
    final formattedDate = appointmentTime != null
        ? '${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year}'
        : 'Today';
    final formattedTime = appointmentTime != null
        ? '${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}'
        : 'Soon';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAppointmentInfoRow(
              Icons.calendar_today_outlined,
              'Date',
              formattedDate,
            ),
            const Divider(height: 24),
            _buildAppointmentInfoRow(
              Icons.access_time_outlined,
              'Scheduled Time',
              formattedTime,
            ),
            const Divider(height: 24),
            _buildAppointmentInfoRow(
              Icons.medical_services_outlined,
              'Reason',
              _appointmentInfo?['reason'] ?? 'Consultation',
            ),
            const Divider(height: 24),
            _buildAppointmentInfoRow(
              Icons.videocam_outlined,
              'Appointment Type',
              _appointmentInfo?['type'] ?? 'Video Consultation',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
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
      ],
    );
  }

  Widget _buildRequiredActions() {
    if (_documentsFilled && _questionnaireFilled && _paymentConfirmed) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.warningColor.withOpacity(0.5),
        ),
      ),
      color: AppTheme.warningColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: AppTheme.warningColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Required Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_documentsFilled)
              _buildActionItem(
                'Complete medical history form',
                'Required for your first visit',
                () {
                  setState(() {
                    _documentsFilled = true;
                  });
                  _addActivity('Medical history form completed');
                },
              ),
            if (!_questionnaireFilled)
              _buildActionItem(
                'Fill out pre-appointment questionnaire',
                'Helps your doctor prepare for your visit',
                () {
                  setState(() {
                    _questionnaireFilled = true;
                  });
                  _addActivity('Pre-appointment questionnaire completed');
                },
              ),
            if (!_paymentConfirmed)
              _buildActionItem(
                'Confirm payment information',
                'Required to proceed with appointment',
                () {
                  setState(() {
                    _paymentConfirmed = true;
                  });
                  _addActivity('Payment information confirmed');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      String title, String subtitle, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.warningColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(40, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No activity yet',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Column(
            children: _activities
                .map((activity) => _buildActivityItem(activity))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildActivityItem(String activity) {
    final bool isAlert =
        activity.contains('Please') || activity.contains('incomplete');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isAlert
                  ? AppTheme.warningColor.withOpacity(0.1)
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                isAlert
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_none,
                size: 16,
                color: isAlert ? AppTheme.warningColor : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity,
              style: TextStyle(
                fontSize: 14,
                color:
                    isAlert ? AppTheme.warningColor : AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
            SizedBox(width: 10),
            Text('Tips for Your Visit'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_tips[index])),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
