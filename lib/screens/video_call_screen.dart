import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> consultation;

  const VideoCallScreen({
    Key? key,
    required this.consultation,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isConnecting = true;
  Timer? _connectingTimer;
  Timer? _callDurationTimer;
  Timer? _cameraSimulationTimer;
  int _callDurationInSeconds = 0;
  double _patientCameraOpacity = 0.0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Simulate connecting to the call
    _connectingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          // Start the call duration timer once connected
          _callDurationTimer =
              Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() {
                _callDurationInSeconds++;
              });
            }
          });

          // Simulate camera initializing with a slight delay
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _isCameraInitialized = true;
                _patientCameraOpacity = 1.0;
              });
            }
          });

          // Simulate slight camera movements for realism
          _cameraSimulationTimer =
              Timer.periodic(const Duration(milliseconds: 500), (timer) {
            if (mounted && _isCameraInitialized && !_isCameraOff) {
              setState(() {
                // Just trigger a rebuild with very subtle changes that won't be visible
                // This creates the illusion of a live camera feed
                _patientCameraOpacity = 0.99 + (Random().nextDouble() * 0.01);
              });
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _connectingTimer?.cancel();
    _callDurationTimer?.cancel();
    _cameraSimulationTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Doctor's camera (main view)
          _isConnecting
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Image.asset(
                  'assets/docteur.png',
                  fit: BoxFit.cover,
                ),

          // UI elements overlay
          SafeArea(
            child: Column(
              children: [
                // Call info bar at the top
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.consultation['doctorName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            widget.consultation['specialty'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(_callDurationInSeconds),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Patient's self-view (small overlay)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _isCameraOff ? Colors.grey[800] : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isCameraOff
                          ? const Center(
                              child: Icon(
                                Icons.videocam_off,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          : _isCameraInitialized
                              ? AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: _patientCameraOpacity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        Colors.blue.withOpacity(0.05),
                                        BlendMode.srcATop,
                                      ),
                                      child: Image.asset(
                                        'assets/avatar-des-utilisateurs.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),

                // Camera access permission indicator
                if (!_isCameraInitialized && !_isConnecting && !_isCameraOff)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 175),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Accessing camera...",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                // Call control buttons
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? Colors.red : Colors.white,
                        onPressed: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isMuted
                                  ? 'Microphone muted'
                                  : 'Microphone unmuted'),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  _isMuted ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                      _buildCircularButton(
                        icon:
                            _isCameraOff ? Icons.videocam_off : Icons.videocam,
                        color: _isCameraOff ? Colors.red : Colors.white,
                        onPressed: () {
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                            if (!_isCameraOff) {
                              // Simulate camera turning on with slight delay
                              _isCameraInitialized = false;
                              Future.delayed(const Duration(milliseconds: 800),
                                  () {
                                if (mounted) {
                                  setState(() {
                                    _isCameraInitialized = true;
                                    _patientCameraOpacity = 1.0;
                                  });
                                }
                              });
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isCameraOff
                                  ? 'Camera turned off'
                                  : 'Camera turned on'),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  _isCameraOff ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                      _buildCircularButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        backgroundColor: Colors.red,
                        iconColor: Colors.white,
                        size: 70,
                        onPressed: () => _confirmEndCall(),
                      ),
                      _buildCircularButton(
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color: _isSpeakerOn ? Colors.white : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _isSpeakerOn = !_isSpeakerOn;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isSpeakerOn
                                  ? 'Speaker turned on'
                                  : 'Speaker turned off'),
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  _isSpeakerOn ? Colors.green : Colors.grey,
                            ),
                          );
                        },
                      ),
                      _buildCircularButton(
                        icon: Icons.switch_camera,
                        color: Colors.white,
                        onPressed: () {
                          // Simulate camera switching
                          if (!_isCameraOff) {
                            setState(() {
                              _isCameraInitialized = false;
                            });

                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (mounted) {
                                setState(() {
                                  _isCameraInitialized = true;
                                });
                              }
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera switched'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connection quality indicator
          if (!_isConnecting)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.network_wifi,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Good connection',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    Color? iconColor,
    double size = 50,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: iconColor ?? color,
          size: size * 0.5,
        ),
      ),
    );
  }

  Future<void> _confirmEndCall() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => context.pop(true),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      context.pop();

      // Show follow-up dialog after call ends
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCallSummaryDialog();
        });
      }
    }
  }

  void _showCallSummaryDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${widget.consultation['doctorName']}'),
            const SizedBox(height: 8),
            Text('Duration: ${_formatDuration(_callDurationInSeconds)}'),
            const SizedBox(height: 16),
            const Text('How would you rate this consultation?'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Thank you for your ${index + 1}-star rating!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star),
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
