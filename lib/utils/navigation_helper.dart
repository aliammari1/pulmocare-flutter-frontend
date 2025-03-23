import 'package:flutter/material.dart';
import '../screens/report_editor_screen.dart';

class NavigationHelper {
  /// Opens the report editor screen and returns the edited text
  static Future<String?> openReportEditor({
    required BuildContext context,
    required String reportId,
    required String patientName,
    String initialContent = '',
  }) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportEditorScreen(
          initialContent: initialContent,
          reportId: reportId,
          patientName: patientName,
        ),
      ),
    );
  }
}
