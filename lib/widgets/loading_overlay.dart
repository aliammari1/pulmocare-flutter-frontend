import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? overlayColor;
  final double opacity;
  final Widget? loadingIndicator;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
    this.opacity = 0.5,
    this.loadingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: _buildLoadingOverlay(context),
          ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: (overlayColor ?? Colors.black).withOpacity(opacity),
      child: Center(
        child: loadingIndicator ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please wait...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
