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
              // Timer area - tappable
              Expanded(
                child: Obx(() {
                  final isRunning = controller.isTimerRunning.value;

                  return GestureDetector(
                    onTap: isRunning
                        ? () {
                            HapticFeedback.lightImpact();
                            controller.recordLap();
                          }
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main time
                        Obx(
                          () => Text(
                            formatSeconds(controller.timerElapsedSeconds.value),
                            style: AppTypography.displayLarge,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Current lap
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: AppRadius.fullRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '문항 ${controller.laps.length + 1}',
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  formatSeconds(controller.currentLapSeconds),
                                  style: AppTypography.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isRunning) ...[
                          const SizedBox(height: 20),
                          Text('화면을 탭하면 다음 문항', style: AppTypography.caption),
                        ],
                      ],
                    ),
                  );
                }),
              ),

              // Recent laps
              Obx(() {
                if (controller.laps.isEmpty) return const SizedBox.shrink();

                final recentLaps = controller.laps.length > 3
                    ? controller.laps.sublist(controller.laps.length - 3)
                    : controller.laps.toList();
                final startIndex = controller.laps.length > 3
                    ? controller.laps.length - 3
                    : 0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: AppRadius.lgRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('최근 기록', style: AppTypography.labelMedium),
                          GestureDetector(
                            onTap: () => _showLapsSheet(context),
                            child: Text(
                              '전체 (${controller.laps.length})',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...recentLaps.asMap().entries.map((entry) {
                        final idx = startIndex + entry.key;
                        final lap = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text('${idx + 1}', style: AppTypography.caption),
                              const SizedBox(width: 12),
                              Text(
                                formatSeconds(lap),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Obx(() {
                  final isRunning = controller.isTimerRunning.value;
                  final hasTime = controller.timerElapsedSeconds.value > 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left: Lap or Reset
                      SizedBox(
                        width: 60,
                        child: hasTime
                            ? AppIconButton(
                                icon: isRunning
                                    ? Icons.flag_outlined
                                    : Icons.refresh,
                                backgroundColor: AppColors.gray100,
                                iconColor: AppColors.textSecondary,
                                size: 48,
                                iconSize: 20,
                                showBorder: true,
                                label: isRunning ? '랩' : '초기화',
                                onPressed: isRunning
                                    ? controller.recordLap
                                    : controller.resetTimer,
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Center: Play/Pause
                      AppIconButton(
                        icon: isRunning ? Icons.pause : Icons.play_arrow,
                        backgroundColor: AppColors.primary,
                        iconColor: Colors.white,
                        size: 64,
                        iconSize: 28,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          isRunning
                              ? controller.stopTimer()
                              : controller.startTimer();
                        },
                      ),

                      // Right: Stop
                      SizedBox(
                        width: 60,
                        child: hasTime
                            ? AppIconButton(
                                icon: Icons.stop,
                                backgroundColor: AppColors.gray100,
                                iconColor: AppColors.error,
                                size: 48,
                                iconSize: 20,
                                showBorder: true,
                                label: '종료',
                                onPressed: () {
                                  controller.stopTimer();
                                  _showSaveDialog(context);
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
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

  void _showLapsSheet(BuildContext context) {
    AppBottomSheet.show(
      title: '기록',
      isScrollControlled: true,
      maxHeight: MediaQuery.of(context).size.height * 0.6,
      child: Obx(() {
        if (controller.laps.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: AppEmptyState(icon: Icons.flag_outlined, title: '기록이 없습니다'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: controller.laps.length,
          itemBuilder: (context, index) {
            final lapTime = controller.laps[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('${index + 1}', style: AppTypography.bodySmall),
                  ),
                  Text(formatSeconds(lapTime), style: AppTypography.bodyLarge),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
