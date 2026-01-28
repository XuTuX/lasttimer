import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/timer/timer_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late TimerController controller;
  late AnimationController _feedbackController;
  late Animation<Color?> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TimerController());

    // 탭 피드백 애니메이션
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _feedbackAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppColors.primary.withAlpha(30),
        ).animate(
          CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _onScreenTap() {
    if (!controller.isTimerRunning.value) {
      controller.startTimer();
      return;
    }

    // 탭 피드백 애니메이션
    HapticFeedback.lightImpact();
    _feedbackController.forward().then((_) => _feedbackController.reverse());
    controller.recordLap();
  }

  @override
  Widget build(BuildContext context) {
    final subjectController = Get.find<SubjectController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.isTimerRunning.value ||
            controller.timerElapsedSeconds.value > 0) {
          final action = await _showExitOptions();
          if (!mounted) return;
          if (action == 'save') {
            // ignore: use_build_context_synchronously
            _showSaveSheet(context);
          } else if (action == 'discard') {
            controller.resetTimer();
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: () async {
              if (controller.isTimerRunning.value ||
                  controller.timerElapsedSeconds.value > 0) {
                final action = await _showExitOptions();
                if (!context.mounted) return;
                if (action == 'save') {
                  _showSaveSheet(context);
                } else if (action == 'discard') {
                  controller.resetTimer();
                  Get.back();
                }
              } else {
                Get.back();
              }
            },
          ),
          title: Obx(() {
            final subjectId = subjectController.selectedSubjectId.value;
            final subject = subjectController.subjects.firstWhereOrNull(
              (s) => s.id == subjectId,
            );
            return Text(
              subject?.subjectName ?? '타이머',
              style: AppTypography.headlineSmall,
            );
          }),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Timer area - 전체 화면 탭 가능
              Expanded(
                child: Obx(() {
                  final isRunning = controller.isTimerRunning.value;
                  final isFinished = controller.isTimerFinished.value;
                  final isMock = controller.isMockMode;

                  return AnimatedBuilder(
                    animation: _feedbackAnimation,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: isFinished ? null : _onScreenTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: _feedbackAnimation.value,
                          child: Center(
                            child: _buildTimerDisplay(
                              isRunning: isRunning,
                              isFinished: isFinished,
                              isMock: isMock,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              // Controls - 시작/정지만 크게
              _buildControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay({
    required bool isRunning,
    required bool isFinished,
    required bool isMock,
  }) {
    return Obx(() {
      // 모의고사면 남은 시간, 아니면 경과 시간
      final displaySeconds = isMock
          ? controller.remainingSeconds
          : controller.timerElapsedSeconds.value;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 모의고사 진행 상태
          if (isMock && controller.mockTotalSeconds > 0) ...[
            _buildProgressIndicator(),
            const SizedBox(height: 24),
          ],

          // Main time
          Text(
            formatSeconds(displaySeconds),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 80,
              letterSpacing: -2,
              color: isFinished
                  ? AppColors.error
                  : isRunning
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),

          if (isMock && !isRunning && !isFinished)
            Text(
              '${controller.mockTotalSeconds ~/ 60}분 카운트다운',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

          const SizedBox(height: 16),

          // Current question badge - 크게 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isRunning
                  ? AppColors.primary.withAlpha(20)
                  : AppColors.gray100.withAlpha(150),
              borderRadius: BorderRadius.circular(24),
              border: isRunning
                  ? Border.all(color: AppColors.primary.withAlpha(50))
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  '문항 ${controller.currentQuestionNumber}',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isRunning
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatSeconds(controller.currentLapSeconds),
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 28,
                    color: isRunning
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Interaction Guide
          if (isFinished)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '시간 종료! 저장해주세요',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            )
          else
            AnimatedOpacity(
              opacity: isRunning ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                '화면을 탭하면 다음 문항',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
        ],
      );
    });
  }

  /// 모의고사 진행률 표시
  Widget _buildProgressIndicator() {
    return Obx(() {
      final progress = controller.mockTotalSeconds > 0
          ? controller.timerElapsedSeconds.value / controller.mockTotalSeconds
          : 0.0;

      return Container(
        width: 200,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: progress >= 0.9 ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 48, 60),
      child: Obx(() {
        final isRunning = controller.isTimerRunning.value;
        final hasTime = controller.timerElapsedSeconds.value > 0;
        final isFinished = controller.isTimerFinished.value;

        return Column(
          children: [
            // Main button - 시작/정지 토글
            SizedBox(
              width: 100,
              height: 100,
              child: TextButton(
                onPressed: isFinished
                    ? () => _showSaveSheet(context)
                    : () {
                        HapticFeedback.mediumImpact();
                        isRunning
                            ? controller.stopTimer()
                            : controller.startTimer();
                      },
                style: TextButton.styleFrom(
                  backgroundColor: isFinished
                      ? AppColors.error
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 8,
                  shadowColor:
                      (isFinished ? AppColors.error : AppColors.primary)
                          .withAlpha(120),
                ),
                child: Icon(
                  isFinished
                      ? Icons.save_rounded
                      : isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 48,
                ),
              ),
            ),

            // 저장 버튼 (시간이 있고 실행중이 아닐 때만)
            if (hasTime && !isRunning && !isFinished) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => _showSaveSheet(context),
                child: Text(
                  '저장하기',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Future<String?> _showExitOptions() async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('기록이 있습니다', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('저장하지 않으면 기록이 사라집니다.', style: AppTypography.bodySmall),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '저장하기',
                onPressed: () => Navigator.pop(context, 'save'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '저장하지 않고 나가기',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context, 'discard'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                '계속하기',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSaveSheet(BuildContext context) async {
    if (controller.isTimerRunning.value) controller.stopTimer();

    final titleController = TextEditingController();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('기록 저장', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                '${controller.laps.length + (controller.currentLapSeconds > 0 ? 1 : 0)}문항 · ${formatSeconds(controller.timerElapsedSeconds.value)}',
                style: AppTypography.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '제목 (예: 2024 모의고사)',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '저장',
                onPressed: () => Navigator.pop(context, titleController.text),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      controller.saveExam(result);
    }
  }
}
