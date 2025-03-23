import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/face_auth_service.dart';

class FaceLoginScreen extends StatefulWidget {
  final String email;
  const FaceLoginScreen({super.key, required this.email});

  @override
  State<FaceLoginScreen> createState() => _FaceLoginScreenState();
}

class _FaceLoginScreenState extends State<FaceLoginScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FaceAuthService _faceAuthService = FaceAuthService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _processImage() async {
    if (_isProcessing) return;
    final scaffoldContext = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isProcessing = true);

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final success = await _faceAuthService.verifyFace(widget.email, image);

      if (mounted) {
        if (success) {
          navigator.pushReplacementNamed('/profile');
        } else {
          scaffoldContext.showSnackBar(
            const SnackBar(content: Text('Face verification failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldContext.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Login')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processImage,
                    child:
                        Text(_isProcessing ? 'Processing...' : 'Verify Face'),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
