import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities
/// iPad detection based on shortestSide (portrait/landscape safe)
class Responsive {
  // ============================================================================
  // BREAKPOINTS
  // ============================================================================

  /// iPad breakpoint: shortestSide >= 600dp
  static const double tabletBreakpoint = 600;

  /// Large iPad (12.9" Pro): shortestSide >= 1024dp
  static const double largeTabletBreakpoint = 1024;

  // ============================================================================
  // DEVICE TYPE DETECTION
  // ============================================================================

  /// Check if device is tablet (iPad)
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= tabletBreakpoint;
  }

  /// Check if device is large tablet (iPad Pro 12.9")
  static bool isLargeTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= largeTabletBreakpoint;
  }

  /// Check if device is phone (iPhone)
  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide >= largeTabletBreakpoint) {
      return DeviceType.largeTablet;
    } else if (shortestSide >= tabletBreakpoint) {
      return DeviceType.tablet;
    }
    return DeviceType.phone;
  }

  // ============================================================================
  // ORIENTATION
  // ============================================================================

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // ============================================================================
  // RESPONSIVE VALUES
  // ============================================================================

  /// Get value based on device type
  static T value<T>({
    required BuildContext context,
    required T phone,
    T? tablet,
    T? largeTablet,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.largeTablet:
        return largeTablet ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }
}

/// Device type enumeration
enum DeviceType { phone, tablet, largeTablet }

/// Extension for easy responsive widget building
extension ResponsiveContext on BuildContext {
  bool get isTablet => Responsive.isTablet(this);
  bool get isPhone => Responsive.isPhone(this);
  bool get isLargeTablet => Responsive.isLargeTablet(this);
  bool get isLandscape => Responsive.isLandscape(this);
  bool get isPortrait => Responsive.isPortrait(this);
  DeviceType get deviceType => Responsive.getDeviceType(this);

  /// Shorthand for responsive values
  T responsive<T>({required T phone, T? tablet, T? largeTablet}) {
    return Responsive.value<T>(
      context: this,
      phone: phone,
      tablet: tablet,
      largeTablet: largeTablet,
    );
  }
}
