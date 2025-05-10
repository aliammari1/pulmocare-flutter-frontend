import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Updated color palette with a modern medical aesthetic
  static const Color primaryColor =
      Color(0xFF0077B6); // Refined blue for professionalism
  static const Color secondaryColor =
      Color(0xFF00A8E8); // Brighter blue for accents
  static const Color accentColor =
      Color(0xFF4CC9F0); // Light blue for highlights
  static const Color backgroundColor =
      Color(0xFFF8FBFF); // Off-white with subtle blue tint
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE63946); // Cleaner red for errors
  static const Color successColor =
      Color(0xFF57CC99); // Mint green for success states
  static const Color warningColor = Color(0xFFFFC857); // Amber for warnings
  static const Color textPrimaryColor =
      Color(0xFF2C3E50); // Deep navy for primary text
  static const Color textSecondaryColor =
      Color(0xFF5D7184); // Slate for secondary text
  static const Color disabledColor =
      Color(0xFFE0E7EC); // Lighter gray for disabled states
  static const Color dividerColor =
      Color(0xFFEBF2FA); // Very light blue for dividers

  // Medical-specific colors
  static const Color pulmonaryColor =
      Color(0xFF4DB6AC); // Teal for respiratory care
  static const Color cardiologyColor = Color(0xFFEF5350); // Red for cardiology
  static const Color neurologyColor = Color(0xFF9575CD); // Purple for neurology
  static const Color immunologyColor =
      Color(0xFFFFB74D); // Orange for immunology

  // Typography scale - slightly adjusted for better readability
  static const double fontSizeXSmall = 11;
  static const double fontSizeSmall = 13;
  static const double fontSizeMedium = 15;
  static const double fontSizeLarge = 17;
  static const double fontSizeXLarge = 20;
  static const double fontSizeXXLarge = 24;
  static const double fontSizeDisplay = 32;

  // Border radius - refined for a more modern feel
  static const double borderRadiusSmall = 4;
  static const double borderRadiusMedium = 8;
  static const double borderRadiusLarge = 12;
  static const double borderRadiusXLarge = 16;
  static const double borderRadiusCircular = 100;

  // Spacing
  static const double spacingXXSmall = 2;
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;
  static const double spacingXXLarge = 48;

  // Refined elevation styles for a softer, more clinical look
  static List<BoxShadow> elevationLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 3,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];

  // Icon sizes
  static const double iconSizeXSmall = 12;
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;

  // Generate the app theme
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();

    // Use Nunito font for a friendlier, more approachable medical interface
    final textTheme = GoogleFonts.nunitoTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: dividerColor,
      disabledColor: disabledColor,
      textTheme: textTheme.copyWith(
        displayLarge: TextStyle(
          fontSize: fontSizeDisplay,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeMedium,
          color: textPrimaryColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeSmall,
          color: textPrimaryColor,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          elevation: 1,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          side: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: primaryColor,
          size: iconSizeMedium,
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        toolbarHeight: 64,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: TextStyle(
          fontSize: fontSizeXSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSizeXSmall,
        ),
        elevation: 4,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor,
        labelStyle: TextStyle(
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w500,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.4);
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: disabledColor,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: backgroundColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: errorColor,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: fontSizeSmall,
          color: textSecondaryColor,
        ),
        hintStyle: TextStyle(
          fontSize: fontSizeSmall,
          color: textSecondaryColor.withOpacity(0.7),
        ),
        errorStyle: TextStyle(
          fontSize: fontSizeXSmall,
          color: errorColor,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(spacingSmall),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        contentTextStyle: TextStyle(
          fontSize: fontSizeMedium,
          color: textPrimaryColor,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryColor,
        contentTextStyle: TextStyle(
          fontSize: fontSizeSmall,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        disabledColor: disabledColor,
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        labelStyle: TextStyle(
          fontSize: fontSizeSmall,
          color: textPrimaryColor,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: fontSizeSmall,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingXSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusCircular),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        textStyle: TextStyle(
          fontSize: fontSizeXSmall,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingLarge,
      ),
    );
  }

  // Modern medical card decoration
  static BoxDecoration cardDecoration({bool hasShadow = true}) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      boxShadow: hasShadow ? elevationLow : null,
      border: Border.all(
        color: dividerColor,
        width: 1,
      ),
    );
  }

  // Medical gradient decoration for call-to-action buttons
  static BoxDecoration gradientButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      boxShadow: elevationLow,
    );
  }

  // Refined medical card decoration
  static BoxDecoration medicalCardDecoration({
    Color? color,
    bool isActive = false,
    double borderRadius = borderRadiusMedium,
  }) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isActive ? primaryColor : dividerColor,
        width: isActive ? 1.5 : 1,
      ),
      boxShadow: isActive ? elevationMedium : elevationLow,
    );
  }

  // Custom input decoration for text fields - refined for medical forms
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    bool filled = true,
    Color? fillColor,
    BorderRadius? borderRadius,
    bool enabledBorder = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      isDense: isDense,
      filled: filled,
      fillColor: fillColor ?? backgroundColor,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingMedium,
          ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: textSecondaryColor,
              size: iconSizeMedium,
            )
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
        borderSide: enabledBorder
            ? BorderSide(color: dividerColor, width: 1)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: errorColor,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: errorColor,
          width: 1.5,
        ),
      ),
      errorStyle: TextStyle(
        fontSize: fontSizeXSmall,
        color: errorColor,
      ),
      labelStyle: TextStyle(
        fontSize: fontSizeSmall,
        color: textSecondaryColor,
      ),
      hintStyle: TextStyle(
        fontSize: fontSizeSmall,
        color: textSecondaryColor.withOpacity(0.7),
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: fontSizeSmall,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Medical tag/chip decoration
  static BoxDecoration medicalTagDecoration({required Color color}) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(borderRadiusCircular),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // Medical stat container
  static BoxDecoration medicalStatDecoration(
      {Color? color, bool isHighlighted = false}) {
    return BoxDecoration(
      color: color?.withOpacity(0.05) ?? backgroundColor,
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      border: Border.all(
        color: isHighlighted ? (color ?? primaryColor) : dividerColor,
        width: isHighlighted ? 1.5 : 1,
      ),
    );
  }

  // Get a color based on severity level (for vitals, etc)
  static Color getSeverityColor(int level) {
    switch (level) {
      case 0:
        return Colors.green.shade400; // Normal
      case 1:
        return warningColor; // Warning
      case 2:
        return errorColor; // Critical
      default:
        return textSecondaryColor; // Undefined
    }
  }
}

// Enhanced medical theme elements with modern healthcare UI elements
class MedicalThemeElements {
  // Modern medical icons for app's UI
  static const IconData medicalFile = Icons.description_outlined;
  static const IconData hospital = Icons.local_hospital_outlined;
  static const IconData appointment = Icons.event_available_outlined;
  static const IconData prescription = Icons.receipt_long_outlined;
  static const IconData patient = Icons.person_outlined;
  static const IconData doctor = Icons.medical_services_outlined;
  static const IconData laboratory = Icons.science_outlined;
  static const IconData heartRate = Icons.favorite_border_outlined;
  static const IconData bloodPressure = Icons.speed_outlined;
  static const IconData vaccine = Icons.vaccines_outlined;
  static const IconData lungIcon = Icons.air_outlined;
  static const IconData allergyIcon = Icons.coronavirus_outlined;
  static const IconData medicationIcon = Icons.medication_outlined;
  static const IconData recordsIcon = Icons.folder_outlined;
  static const IconData resultsIcon = Icons.analytics_outlined;

  // Modern medical action button
  static Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: color ?? AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: AppTheme.elevationLow,
          border: Border.all(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppTheme.iconSizeMedium,
                color: color ?? AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: textColor ?? AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated status indicator for patient/appointment status
  static Widget statusIndicator({
    required String label,
    required bool isActive,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    final color = isActive
        ? activeColor ?? AppTheme.successColor
        : inactiveColor ?? AppTheme.disabledColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.spacingXSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.fontSizeXSmall,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Modern medical data card for vital signs
  static Widget medicalDataCard({
    required String title,
    required String value,
    required String unit,
    String? subtitle,
    IconData? icon,
    Color? valueColor,
    int? severityLevel,
    bool showTrend = false,
    bool trendUp = false,
  }) {
    final displayColor = severityLevel != null
        ? AppTheme.getSeverityColor(severityLevel)
        : valueColor ?? AppTheme.textPrimaryColor;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
        boxShadow: AppTheme.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppTheme.iconSizeSmall,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: AppTheme.spacingSmall),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showTrend) ...[
                const Spacer(),
                Icon(
                  trendUp ? Icons.trending_up : Icons.trending_down,
                  color: trendUp ? AppTheme.successColor : AppTheme.errorColor,
                  size: AppTheme.iconSizeSmall,
                ),
              ],
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXXLarge,
                  fontWeight: FontWeight.bold,
                  color: displayColor,
                ),
              ),
              SizedBox(width: AppTheme.spacingXSmall),
              Text(
                unit,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppTheme.spacingXSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppTheme.fontSizeXSmall,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],

          // Add a severity indicator if a level was provided
          if (severityLevel != null) ...[
            SizedBox(height: AppTheme.spacingSmall),
            _buildSeverityIndicator(severityLevel),
          ],
        ],
      ),
    );
  }

  // Severity indicator bar
  static Widget _buildSeverityIndicator(int level) {
    final color = AppTheme.getSeverityColor(level);
    final label = level == 0 ? 'Normal' : (level == 1 ? 'Warning' : 'Critical');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.disabledColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusCircular),
          ),
          child: Row(
            children: [
              Flexible(
                flex: (level + 1) * 33,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusCircular),
                  ),
                ),
              ),
              Flexible(
                flex: 100 - ((level + 1) * 33),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacingXXSmall),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXSmall,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // Medical tag/chip
  static Widget medicalTag({
    required String label,
    Color? color,
    IconData? icon,
  }) {
    final tagColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXXSmall,
      ),
      decoration: AppTheme.medicalTagDecoration(color: tagColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppTheme.iconSizeXSmall,
              color: tagColor,
            ),
            SizedBox(width: AppTheme.spacingXXSmall),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.fontSizeXSmall,
              fontWeight: FontWeight.w500,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  // Medical timeline event
  static Widget timelineEvent({
    required String time,
    required String title,
    String? description,
    Color? color,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            time,
            style: TextStyle(
              fontSize: AppTheme.fontSizeXSmall,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color ?? AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 12,
                  color: color ?? AppTheme.primaryColor,
                )
              : null,
        ),
        SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: AppTheme.spacingXXSmall),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXSmall,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
              SizedBox(height: AppTheme.spacingSmall),
            ],
          ),
        ),
      ],
    );
  }
}
