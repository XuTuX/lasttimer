import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_timer/utils/design_tokens.dart';

enum AppButtonVariant { primary, secondary, text, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return AnimatedContainer(
      duration: AppDurations.fast,
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: Material(
        color: _getBackgroundColor(isDisabled),
        borderRadius: AppRadius.mdRadius,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          borderRadius: AppRadius.mdRadius,
          splashColor: _getSplashColor(),
          child: Container(
            padding: _getPadding(),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdRadius,
              border: _getBorder(isDisabled),
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _getTextColor(isDisabled),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: _getIconSize(),
                      color: _getTextColor(isDisabled),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: _getTextStyle(isDisabled)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppSizes.buttonHeight;
      case AppButtonSize.large:
        return AppSizes.buttonHeight + 4;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 18;
    }
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled && variant != AppButtonVariant.text) {
      return AppColors.gray200;
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.gray100;
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.error;
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) return AppColors.textTertiary;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.text:
        return AppColors.textSecondary;
    }
  }

  Color _getSplashColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white.withAlpha(30);
      case AppButtonVariant.secondary:
      case AppButtonVariant.text:
        return AppColors.gray300.withAlpha(50);
    }
  }

  Border? _getBorder(bool isDisabled) {
    if (variant == AppButtonVariant.secondary && !isDisabled) {
      return Border.all(color: AppColors.border, width: 1);
    }
    return null;
  }

  TextStyle _getTextStyle(bool isDisabled) {
    final baseStyle = size == AppButtonSize.small
        ? AppTypography.buttonSmall
        : AppTypography.button;
    return baseStyle.copyWith(color: _getTextColor(isDisabled));
  }
}

/// Circular icon button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? label;
  final bool showShadow;
  final bool showBorder;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 20,
    this.label,
    this.showShadow = false,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = iconColor ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: showBorder ? Border.all(color: AppColors.border) : null,
            boxShadow: showShadow ? AppShadows.subtle : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
              customBorder: const CircleBorder(),
              splashColor: Colors.white.withAlpha(20),
              child: Center(
                child: Icon(icon, color: fg, size: iconSize),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
