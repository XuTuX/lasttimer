import 'package:flutter/material.dart';
import 'package:last_timer/utils/design_tokens.dart';

enum AppCardVariant { elevated, outlined, flat }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.outlined,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: variant != AppCardVariant.flat
            ? Border.all(color: borderColor ?? AppColors.border, width: 1)
            : null,
        boxShadow: variant == AppCardVariant.elevated
            ? AppShadows.subtle
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.gray200.withAlpha(50),
          highlightColor: AppColors.gray100.withAlpha(50),
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Subject card - clean list style
class SubjectCard extends StatelessWidget {
  final String name;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? examCount;

  const SubjectCard({
    super.key,
    required this.name,
    required this.index,
    this.onTap,
    this.onLongPress,
    this.examCount,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentByIndex(index);

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon Box - Inspired by the sample image
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (examCount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$examCount Exams recorded',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.gray300,
            size: 14,
          ),
        ],
      ),
    );
  }
}

/// Stat card - minimal
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headlineSmall),
        ],
      ),
    );
  }
}

/// Exam history card - clean
class ExamHistoryCard extends StatelessWidget {
  final String title;
  final int questionCount;
  final String totalTime;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showSwipeHint;

  const ExamHistoryCard({
    super.key,
    required this.title,
    required this.questionCount,
    required this.totalTime,
    this.onTap,
    this.onDelete,
    this.showSwipeHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title + totalTime),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      confirmDismiss: (_) async => true,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.error.withAlpha(0),
              AppColors.error.withAlpha(230),
            ],
          ),
          borderRadius: AppRadius.lgRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              '삭제',
              style: AppTypography.labelMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          AppCard(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$questionCount문항 · $totalTime',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
              ],
            ),
          ),
          // 스와이프 힌트 (선택적)
          if (showSwipeHint && onDelete != null)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 10,
                        color: AppColors.textTertiary,
                      ),
                      Text(
                        '스와이프',
                        style: AppTypography.caption.copyWith(
                          fontSize: 9,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
