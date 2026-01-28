import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/utils/design_tokens.dart';

/// Clean bottom sheet
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? maxHeight;
  final bool showHandle;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.maxHeight,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 12),
            Container(
              width: AppSizes.sheetHandleWidth,
              height: AppSizes.sheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title!, style: AppTypography.headlineSmall),
              ),
            ),
          ] else if (showHandle) ...[
            const SizedBox(height: 8),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    String? title,
    required Widget child,
    double? maxHeight,
    bool isScrollControlled = false,
    bool showHandle = true,
  }) {
    return Get.bottomSheet<T>(
      AppBottomSheet(
        title: title,
        maxHeight: maxHeight,
        showHandle: showHandle,
        child: child,
      ),
      isScrollControlled: isScrollControlled,
    );
  }
}

/// Option item for menus
class AppBottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AppBottomSheetOption({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Menu sheet
class AppMenuBottomSheet extends StatelessWidget {
  final String? title;
  final List<AppBottomSheetOption> options;

  const AppMenuBottomSheet({super.key, this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [...options, const SizedBox(height: 16)],
      ),
    );
  }

  static Future<void> show({
    String? title,
    required List<AppBottomSheetOption> options,
  }) {
    return Get.bottomSheet(AppMenuBottomSheet(title: title, options: options));
  }
}
