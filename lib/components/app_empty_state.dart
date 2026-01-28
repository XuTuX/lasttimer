import 'package:flutter/material.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/components/app_button.dart';

/// Minimal empty state
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset empty states
class EmptyStates {
  static Widget subjects({VoidCallback? onAdd}) => AppEmptyState(
    icon: Icons.folder_outlined,
    title: '과목이 없습니다',
    message: '과목을 추가해서 시작하세요',
    actionLabel: '과목 추가',
    onAction: onAdd,
  );

  static Widget exams({VoidCallback? onStart}) => AppEmptyState(
    icon: Icons.history_outlined,
    title: '기록이 없습니다',
    message: '시험을 시작해서 기록을 남기세요',
    actionLabel: '시험 시작',
    onAction: onStart,
  );

  static Widget laps() =>
      const AppEmptyState(icon: Icons.flag_outlined, title: '기록이 없습니다');
}
