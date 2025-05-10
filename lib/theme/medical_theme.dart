import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A professional medical theme system for healthcare applications
/// This theme uses a calming, trustworthy color palette that instills confidence
/// while maintaining accessibility standards
class MedicalTheme {
  // Primary color palette
  static const Color primaryBlue = Color(0xFF2C6BED); // Doctor primary
  static const Color primaryTeal = Color(0xFF35A8CF); // Patient primary
  static const Color primaryPurple = Color(0xFF7B2AD6); // Radiologist primary

  // Secondary color palette
  static const Color secondaryBlue = Color(0xFF2794DA);
  static const Color secondaryTeal = Color(0xFF4DCFE1);
  static const Color secondaryPurple = Color(0xFF9F5EE2);

  // Neutral colors
  static const Color neutralDark = Color(0xFF2A3247); // Text primary
  static const Color neutralMedium = Color(0xFF546E7A); // Text secondary
  static const Color neutralLight = Color(0xFF6B7691); // Subtitles
  static const Color neutralBg = Color(0xFFF8FAFC); // Background

  // Accent colors - for success, error, warning
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color infoBlue = Color(0xFF2196F3);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMedium = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFFE2E8F0);

  // Get theme data based on role
  static ThemeData getThemeForRole(String role) {
    switch (role) {
      case 'doctor':
        return _buildTheme(primaryBlue, secondaryBlue);
      case 'patient':
        return _buildTheme(primaryTeal, secondaryTeal);
      case 'radiologist':
        return _buildTheme(primaryPurple, secondaryPurple);
      default:
        return _buildTheme(primaryTeal, secondaryTeal);
    }
  }

  // Build a complete theme with the right color combinations and typography
  static ThemeData _buildTheme(Color primary, Color secondary) {
    // Base theme
    final ThemeData base = ThemeData.light();

    // Use Poppins as the base font
    final textTheme = _buildMedicalTextTheme(base.textTheme);

    return base.copyWith(
      // Colors
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        background: neutralBg,
        error: errorRed,
      ),
      scaffoldBackgroundColor: neutralBg,

      // Text theme
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // Component themes
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceLight,
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: neutralDark,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: primary.withOpacity(0.2),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shadowColor: primary.withOpacity(0.4),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Outline button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: surfaceDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: surfaceDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorRed, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: neutralMedium,
        ),
        hintStyle: TextStyle(
          color: neutralLight,
          fontSize: 14,
        ),
        errorStyle: TextStyle(
          color: errorRed,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: surfaceLight,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: neutralDark,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: neutralMedium,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMedium,
        selectedColor: primary.withOpacity(0.2),
        secondarySelectedColor: primary,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        labelStyle: TextStyle(
          color: neutralDark,
          fontSize: 14,
        ),
        secondaryLabelStyle: TextStyle(
          color: primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: neutralLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
      ),

      // Tab bar theme
      tabBarTheme: TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: neutralLight,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.2),
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.15),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 12,
          pressedElevation: 8,
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: 24,
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: neutralMedium, width: 1.5),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: primary.withOpacity(0.15),
        linearTrackColor: primary.withOpacity(0.15),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: neutralDark,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Build text theme with medical-appropriate typography
  static TextTheme _buildMedicalTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base.copyWith(
      // Display styles
      displayLarge: base.displayLarge!.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
        color: neutralDark,
      ),
      displayMedium: base.displayMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
        color: neutralDark,
      ),
      displaySmall: base.displaySmall!.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: neutralDark,
      ),

      // Headline styles
      headlineLarge: base.headlineLarge!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
        height: 1.3,
        color: neutralDark,
      ),
      headlineMedium: base.headlineMedium!.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.3,
        color: neutralDark,
      ),
      headlineSmall: base.headlineSmall!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
        color: neutralDark,
      ),

      // Title styles
      titleLarge: base.titleLarge!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: neutralDark,
      ),
      titleMedium: base.titleMedium!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: neutralDark,
      ),
      titleSmall: base.titleSmall!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: neutralDark,
      ),

      // Body styles
      bodyLarge: base.bodyLarge!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.2,
        height: 1.5,
        color: neutralMedium,
      ),
      bodyMedium: base.bodyMedium!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.15,
        height: 1.5,
        color: neutralMedium,
      ),
      bodySmall: base.bodySmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.1,
        height: 1.5,
        color: neutralLight,
      ),

      // Label styles
      labelLarge: base.labelLarge!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: neutralDark,
      ),
      labelMedium: base.labelMedium!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: neutralMedium,
      ),
      labelSmall: base.labelSmall!.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: neutralLight,
      ),
    ));
  }

  // Helper method for creating box shadow
  static List<BoxShadow> getShadow({
    Color? color,
    double opacity = 0.1,
    double blurRadius = 8,
    double spreadRadius = 0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: (color ?? neutralDark).withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }

  // Helper method for creating gradient
  static LinearGradient getGradient(Color primary, Color secondary) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, secondary],
    );
  }
}

// Extension methods for convenience
extension MedicalContextExtension on BuildContext {
  ThemeData get medicalTheme => Theme.of(this);
  TextTheme get textTheme => medicalTheme.textTheme;
  ColorScheme get colorScheme => medicalTheme.colorScheme;

  Color get primaryColor => medicalTheme.primaryColor;
  Color get secondaryColor => medicalTheme.colorScheme.secondary;
  Color get errorColor => medicalTheme.colorScheme.error;

  // Screen size helpers
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Padding helpers
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get paddingTop => padding.top;
  double get paddingBottom => padding.bottom;

  // Screen size breakpoints
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isLargeScreen => screenWidth >= 900;
}
