import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_radio_view_model.dart';
import '../theme/app_theme.dart';

class ForgotPasswordRadioView extends StatefulWidget {
  const ForgotPasswordRadioView({super.key});

  @override
  _ForgotPasswordRadioViewState createState() =>
      _ForgotPasswordRadioViewState();
}

class _ForgotPasswordRadioViewState extends State<ForgotPasswordRadioView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _showAlert(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF81C9F3),
                  Color(0xFF35C5CF),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8EFF5).withAlpha((0.3 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Main Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_otpSent) ...[
                            TextFormField(
                              controller: _emailController,
                              validator: _validateEmail,
                              decoration: AppTheme.inputDecoration.copyWith(
                                labelText: 'Email',
                                prefixIcon:
                                    Icon(Icons.email, color: Color(0xFF81C9F3)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        try {
                                          await context
                                              .read<AuthRadioViewModel>()
                                              .forgotPassword(
                                                  _emailController.text);
                                          setState(() => _otpSent = true);
                                          _showAlert(
                                              'Success',
                                              'OTP has been sent to your email',
                                              true);
                                        } catch (e) {
                                          _showAlert(
                                              'Error', e.toString(), false);
                                        } finally {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF35C5CF),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Send OTP',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ],
                          if (_otpSent && !_otpVerified) ...[
                            TextFormField(
                              controller: _otpController,
                              validator: _validateOTP,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: AppTheme.inputDecoration.copyWith(
                                labelText: 'Enter OTP',
                                prefixIcon:
                                    Icon(Icons.pin, color: Color(0xFF81C9F3)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        try {
                                          bool verified = await context
                                              .read<AuthRadioViewModel>()
                                              .verifyOTP(
                                                _emailController.text,
                                                _otpController.text,
                                              );
                                          if (verified) {
                                            setState(() => _otpVerified = true);
                                            _showAlert(
                                                'Success',
                                                'OTP verified successfully',
                                                true);
                                          } else {
                                            _showAlert(
                                                'Error',
                                                'Invalid OTP. Please try again.',
                                                false);
                                          }
                                        } catch (e) {
                                          _showAlert(
                                              'Error', e.toString(), false);
                                        } finally {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF35C5CF),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Verify OTP',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ],
                          if (_otpVerified) ...[
                            TextFormField(
                              controller: _newPasswordController,
                              validator: _validatePassword,
                              obscureText: true,
                              decoration: AppTheme.inputDecoration.copyWith(
                                labelText: 'New Password',
                                prefixIcon:
                                    Icon(Icons.lock, color: Color(0xFF81C9F3)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        try {
                                          bool success = await context
                                              .read<AuthRadioViewModel>()
                                              .resetPassword(
                                                _emailController.text,
                                                _otpController.text,
                                                _newPasswordController.text,
                                              );
                                          if (success) {
                                            _showAlert(
                                                'Success',
                                                'Password reset successful',
                                                true);
                                            // Navigate to login page after successful reset
                                            Navigator.pushReplacementNamed(
                                                context, '/login');
                                          } else {
                                            _showAlert(
                                                'Error',
                                                'Failed to reset password',
                                                false);
                                          }
                                        } catch (e) {
                                          _showAlert(
                                              'Error', e.toString(), false);
                                        } finally {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF35C5CF),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Reset Password',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Error Message
                    Consumer<AuthRadioViewModel>(
                      builder: (context, authVM, child) {
                        return authVM.errorMessage.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha((0.1 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  authVM.errorMessage,
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
