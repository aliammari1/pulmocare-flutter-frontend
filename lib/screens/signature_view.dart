import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class SignatureView extends StatefulWidget {
  final String? existingSignature;
  const SignatureView({super.key, this.existingSignature});

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  late SignatureController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existingSignature != null
                    ? 'Update Signature'
                    : 'Add Signature',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          if (widget.existingSignature != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.secondaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(widget.existingSignature!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleClear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          await _handleSave();
                          if (mounted &&
                              context
                                  .read<AuthViewModel>()
                                  .errorMessage
                                  .isEmpty) {
                            context.pop(
                                context); // Close dialog after successful save
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Signature'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleClear() {
    _controller.clear();
  }

  Future<void> _handleSave() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = await _controller.toPngBytes();
      if (data == null) return;

      final base64String = base64Encode(data);

      await context.read<AuthViewModel>().updateSignature(base64String);

      if (mounted) {
        if (context.read<AuthViewModel>().errorMessage.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signature saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _handleClear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<AuthViewModel>().errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving signature: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
