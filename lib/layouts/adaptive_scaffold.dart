import 'package:flutter/material.dart';
import 'package:last_timer/utils/responsive.dart';

/// Adaptive scaffold that switches between phone and tablet layouts
/// Phone: Uses provided phoneChild directly
/// Tablet: Uses provided tabletChild (or defaults to phoneChild if not provided)
class AdaptiveScaffold extends StatelessWidget {
  /// Widget to show on phone (iPhone)
  final Widget phoneChild;

  /// Widget to show on tablet (iPad) - if null, uses phoneChild
  final Widget? tabletChild;

  const AdaptiveScaffold({
    super.key,
    required this.phoneChild,
    this.tabletChild,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isTablet && tabletChild != null) {
      return tabletChild!;
    }
    return phoneChild;
  }
}

/// Adaptive layout builder with more control
class AdaptiveLayoutBuilder extends StatelessWidget {
  /// Builder for phone layout
  final Widget Function(BuildContext context) phoneBuilder;

  /// Builder for tablet layout
  final Widget Function(BuildContext context)? tabletBuilder;

  /// Builder for large tablet layout
  final Widget Function(BuildContext context)? largeTabletBuilder;

  const AdaptiveLayoutBuilder({
    super.key,
    required this.phoneBuilder,
    this.tabletBuilder,
    this.largeTabletBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    switch (deviceType) {
      case DeviceType.largeTablet:
        if (largeTabletBuilder != null) {
          return largeTabletBuilder!(context);
        }
        if (tabletBuilder != null) {
          return tabletBuilder!(context);
        }
        return phoneBuilder(context);

      case DeviceType.tablet:
        if (tabletBuilder != null) {
          return tabletBuilder!(context);
        }
        return phoneBuilder(context);

      case DeviceType.phone:
        return phoneBuilder(context);
    }
  }
}
