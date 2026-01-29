import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    this.variant = AppCardVariant.elevated,
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
        border: variant == AppCardVariant.outlined
            ? Border.all(color: borderColor ?? AppColors.border, width: 1)
            : (variant == AppCardVariant.elevated
                  ? Border.all(
                      color: AppColors.gray100,
                      width: 0.5,
                    ) // 아주 흐릿한 경계선
                  : null),
        boxShadow: variant == AppCardVariant.elevated
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
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

class ExamHistoryCard extends StatelessWidget {
  final String title;
  final int questionCount;
  final String totalTime;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showSwipeHint;
  final bool hasMemo;

  const ExamHistoryCard({
    super.key,
    required this.title,
    required this.questionCount,
    required this.totalTime,
    this.onTap,
    this.onDelete,
    this.showSwipeHint = false,
    this.hasMemo = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onDelete == null) {
      return _buildCardContent();
    }

    return Slidable(
      key: ValueKey(title + totalTime),
      // iOS 스타일의 끝까지 밀기 액션 설정
      endActionPane: ActionPane(
        motion: const BehindMotion(), // 뒤에서 버튼이 나타나는 자연스러운 효과
        extentRatio: 0.25,
        dismissible: DismissiblePane(
          onDismissed: () => onDelete?.call(),
          // threshold 대신 closeOnCancel 등을 활용하거나 기본값 유지
        ),
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_rounded, size: 24),
                SizedBox(height: 4),
                Text(
                  '삭제',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildCardContent(),
          if (showSwipeHint)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: AppColors.gray300.withAlpha(150),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasMemo) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.sticky_note_2_rounded,
                        size: 16,
                        color: AppColors.accent.withAlpha(180),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$questionCount문항 · $totalTime',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.gray300, size: 20),
        ],
      ),
    );
  }
}
