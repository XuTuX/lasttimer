import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for consistent styling across the app
/// Premium black & white minimal aesthetic

// ============================================================================
// COLORS - Clean black & white palette
// ============================================================================

class AppColors {
  // Primary - Charcoal/Black as main accent
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFFF5F5F5);
  static const Color primaryDark = Color(0xFF000000);

  // Accent - Emerald Green for 3% highlights (interactive elements)
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFFD1FAE5);
  static const Color accentDark = Color(0xFF059669);

  // Neutrals - True grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFFA0A0A0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status - Muted tones
  static const Color success = accent;
  static const Color successLight = accentLight;
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Chart/Data colors (muted, monochrome-friendly)
  static const Color mint = Color(0xFF6B7B7B);
  static const Color sky = Color(0xFF5C6B7A);
  static const Color lavender = Color(0xFF7B6B8A);
  static const Color lemon = Color(0xFF8A8B6B);

  // Utility
  static const Color divider = Color(0xFFEEEEEE);
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color overlay = Color(0x1A000000);
  static const Color border = Color(0xFFE5E5E5);

  /// Get accent color by index (for subject cards) - monochrome palette
  static Color accentByIndex(int index) {
    const accents = [gray800, gray600, gray700, gray500, gray900];
    return accents[index % accents.length];
  }

  static Color accentLightByIndex(int index) {
    const accents = [gray100, gray50, gray100, gray50, gray200];
    return accents[index % accents.length];
  }
}

// ============================================================================
// TYPOGRAPHY - Clean, modern
// ============================================================================

class AppTypography {
  // Display - Timer numbers
  static TextStyle displayLarge = GoogleFonts.montserrat(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle displayMedium = GoogleFonts.montserrat(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Headings
  static TextStyle headlineLarge = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // Button
  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  static TextStyle buttonSmall = GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );
}

// ============================================================================
// SPACING
// ============================================================================

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);

  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);

  static const EdgeInsets dialogPadding = EdgeInsets.all(20);

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );
}

// ============================================================================
// BORDER RADIUS - Consistent
// ============================================================================

class AppRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double full = 100;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

// ============================================================================
// SHADOWS - Minimal
// ============================================================================

class AppShadows {
  static List<BoxShadow> get none => [];

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withAlpha(6),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> colored(Color color, {double opacity = 0.15}) => [
    BoxShadow(
      color: color.withAlpha((255 * opacity).round()),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

// ============================================================================
// ANIMATION DURATIONS
// ============================================================================

class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration xslow = Duration(milliseconds: 500);
}

// ============================================================================
// SIZES
// ============================================================================

class AppSizes {
  static const double touchTargetMin = 44;
  static const double buttonHeight = 44;
  static const double buttonHeightSmall = 36;
  static const double iconButtonSize = 40;
  static const double iconButtonSizeLarge = 56;

  static const double iconSmall = 16;
  static const double iconMedium = 18;
  static const double iconDefault = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 28;

  static const double fabSize = 52;
  static const double fabSizeLarge = 64;

  static const double sheetHandleWidth = 32;
  static const double sheetHandleHeight = 4;
}
