import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/timer/timer_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';

class TimerPage extends GetView<TimerController> {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TimerController());
    final subjectController = Get.find<SubjectController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.isTimerRunning.value) {
          final quit = await _confirmQuit();
          if (quit) Get.back();
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
              if (controller.isTimerRunning.value) {
                final quit = await _confirmQuit();
                if (quit) Get.back();
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
              // Timer area - tappable - Expanded to take most of the screen
              Expanded(
                child: Obx(() {
                  final isRunning = controller.isTimerRunning.value;

                  return GestureDetector(
                    onTap: () {
                      if (isRunning) {
                        HapticFeedback.lightImpact();
                        controller.recordLap();
                      } else {
                        controller.startTimer();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main time - Large and central
                          Obx(
                            () => Text(
                              formatSeconds(
                                controller.timerElapsedSeconds.value,
                              ),
                              style: AppTypography.displayLarge.copyWith(
                                fontSize: 80,
                                letterSpacing: -2,
                                color: isRunning
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Current lap status badge
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray100.withAlpha(150),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '문항 ${controller.laps.length + 1}',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    formatSeconds(controller.currentLapSeconds),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Interaction Guide
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
                      ),
                    ),
                  );
                }),
              ),

              // Controls - Ultra minimal
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 60),
                child: Obx(() {
                  final isRunning = controller.isTimerRunning.value;
                  final hasTime = controller.timerElapsedSeconds.value > 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset (Only shown when paused and has time)
                      if (!isRunning && hasTime) ...[
                        _buildControlButton(
                          icon: Icons.refresh_rounded,
                          onPressed: controller.resetTimer,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 32),
                      ],

                      // Play/Pause (Primary Action)
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            isRunning
                                ? controller.stopTimer()
                                : controller.startTimer();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 8,
                            shadowColor: AppColors.primary.withAlpha(120),
                          ),
                          child: Icon(
                            isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 44,
                          ),
                        ),
                      ),

                      // Finish (Only shown when has time)
                      if (hasTime) ...[
                        const SizedBox(width: 32),
                        _buildControlButton(
                          icon: Icons.stop_rounded,
                          onPressed: () {
                            controller.stopTimer();
                            _showSaveDialog(context);
                          },
                          color: AppColors.error,
                          isOutlined: true,
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: 60,
      height: 60,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: AppColors.border, width: 1.5),
                shape: const CircleBorder(),
                foregroundColor: color,
              ),
              child: Icon(icon, size: 24),
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.gray100,
                shape: const CircleBorder(),
                foregroundColor: color,
              ),
              child: Icon(icon, size: 24),
            ),
    );
  }

  Future<bool> _confirmQuit() async {
    return await AppDialog.showConfirm(
      title: '타이머를 멈추시겠습니까?',
      message: '기록이 저장되지 않습니다.',
      cancelLabel: '계속',
      confirmLabel: '나가기',
    );
  }

  void _showSaveDialog(BuildContext context) async {
    if (controller.isTimerRunning.value) controller.stopTimer();

    final title = await AppInputDialog.show(
      title: '시험 저장',
      hint: '제목 (예: 2024 모의고사)',
      confirmLabel: '저장',
    );

    if (title != null && title.isNotEmpty) {
      controller.saveExam(title);
    }
  }
}
