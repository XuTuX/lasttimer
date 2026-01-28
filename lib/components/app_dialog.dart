import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/components/app_button.dart';

/// Clean dialog styling
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final String? cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDanger;
  final bool isLoading;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.iconColor,
    this.cancelLabel,
    this.confirmLabel = '확인',
    this.onCancel,
    this.onConfirm,
    this.isDanger = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(title, style: AppTypography.headlineMedium),

            // Message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: AppTypography.bodyMedium),
            ],

            // Custom content
            if (content != null) ...[const SizedBox(height: 16), content!],

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelLabel != null) ...[
                  AppButton(
                    label: cancelLabel!,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    onPressed: onCancel ?? () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                ],
                AppButton(
                  label: confirmLabel,
                  variant: isDanger
                      ? AppButtonVariant.danger
                      : AppButtonVariant.primary,
                  size: AppButtonSize.small,
                  onPressed: onConfirm,
                  isLoading: isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> showConfirm({
    required String title,
    String? message,
    IconData? icon,
    String cancelLabel = '취소',
    String confirmLabel = '확인',
    bool isDanger = false,
  }) async {
    return await Get.dialog<bool>(
          AppDialog(
            title: title,
            message: message,
            icon: icon,
            cancelLabel: cancelLabel,
            confirmLabel: confirmLabel,
            isDanger: isDanger,
            onConfirm: () => Get.back(result: true),
            onCancel: () => Get.back(result: false),
          ),
        ) ??
        false;
  }

  static Future<bool> showDeleteConfirm({
    String title = '삭제하시겠습니까?',
    String message = '삭제 후 복구할 수 없습니다.',
  }) async {
    return await showConfirm(
      title: title,
      message: message,
      cancelLabel: '취소',
      confirmLabel: '삭제',
      isDanger: true,
    );
  }
}

/// Input dialog
class AppInputDialog extends StatelessWidget {
  final String title;
  final String? hint;
  final String? initialValue;
  final IconData? prefixIcon;
  final String cancelLabel;
  final String confirmLabel;
  final void Function(String value)? onConfirm;

  const AppInputDialog({
    super.key,
    required this.title,
    this.hint,
    this.initialValue,
    this.prefixIcon,
    this.cancelLabel = '취소',
    this.confirmLabel = '확인',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: AppSpacing.dialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, size: 18)
                    : null,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) onConfirm?.call(value);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: confirmLabel,
                  size: AppButtonSize.small,
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onConfirm?.call(controller.text);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> show({
    required String title,
    String? hint,
    String? initialValue,
    IconData? prefixIcon,
    String cancelLabel = '취소',
    String confirmLabel = '확인',
  }) async {
    String? result;
    await Get.dialog(
      AppInputDialog(
        title: title,
        hint: hint,
        initialValue: initialValue,
        prefixIcon: prefixIcon,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        onConfirm: (value) {
          result = value;
          Get.back();
        },
      ),
    );
    return result;
  }
}
