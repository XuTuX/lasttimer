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

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  late TimerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TimerController());
  }

  @override
  Widget build(BuildContext context) {
    final subjectController = Get.find<SubjectController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => _handleBackPress(),
          ),
          title: Obx(() {
            final subject = subjectController.selectedSubject;
            return Text(
              subject?.subjectName ?? '타이머',
              style: AppTypography.labelLarge.copyWith(letterSpacing: -0.5),
            );
          }),
          centerTitle: true,
          actions: [
            Obx(() {
              final isRunning = controller.isTimerRunning.value;
              final hasStarted = controller.timerElapsedSeconds.value > 0;
              final isFinished = controller.isTimerFinished.value;

              // [수정] 실행 중일 때는 숨기고, 일시정지 상태에서만 '종료' 버튼 노출
              if (!isFinished &&
                  !isRunning &&
                  hasStarted &&
                  controller.isMockMode) {
                return TextButton(
                  onPressed: () => _confirmFinishEarly(),
                  child: Text(
                    '종료',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // 1. 최상단 슬림 진행바 (모의고사 전용)
            if (controller.isMockMode) _buildTopProgressBar(),

            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 2. 전체 화면 탭 영역 (InkWell로 고급스러운 피드백)
                  Material(
                    color: Colors.transparent,
                    child: Obx(
                      () => InkWell(
                        onTap: controller.isTimerFinished.value
                            ? null
                            : _handleScreenTap,
                        splashColor: AppColors.gray200.withAlpha(50),
                        highlightColor: Colors.transparent,
                        child: Center(child: _buildTimerContent()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. 하단 컨트롤 버튼
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  void _handleScreenTap() {
    if (!controller.isTimerRunning.value) {
      if (!controller.isTimerFinished.value) {
        controller.startTimer();
      }
      return;
    }
    HapticFeedback.lightImpact();
    controller.recordLap();
  }

  Future<void> _handleBackPress() async {
    if (controller.timerElapsedSeconds.value > 0 &&
        !controller.isTimerFinished.value) {
      final action = await _showExitOptions();
      if (!mounted) return;
      if (action == 'save') {
        _showSaveSheet(context);
      } else if (action == 'discard') {
        controller.resetTimer();
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  /// 최상단 진행바 (가느다란 선)
  Widget _buildTopProgressBar() {
    return Obx(() {
      final progress = controller.mockTotalSeconds > 0
          ? controller.timerElapsedSeconds.value / controller.mockTotalSeconds
          : 0.0;
      return Container(
        width: double.infinity,
        height: 2,
        color: AppColors.gray100,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            color: progress > 0.9 ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      );
    });
  }

  /// 메인 타이머 컨텐츠 (계층형)
  Widget _buildTimerContent() {
    return Obx(() {
      final isFinished = controller.isTimerFinished.value;
      final displaySec = controller.isMockMode
          ? controller.remainingSeconds
          : controller.timerElapsedSeconds.value;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 문항 번호 (은은하게 상단에)
          if (!isFinished) ...[
            Text(
              'QUESTION ${controller.currentQuestionNumber.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.textTertiary.withAlpha(180),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 메인 시간 (가장 크게)
          _RollingTimeDisplay(
            seconds: displaySec,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 84,
              fontWeight: FontWeight.w200, // 더 얇고 세련되게
              color: isFinished ? AppColors.gray300 : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 16),

          // 현재 문항 소요 시간 (메인 시간 아래에 작게)
          if (!isFinished)
            Opacity(
              opacity: controller.isTimerRunning.value ? 1 : 0.4,
              child: _RollingTimeDisplay(
                seconds: controller.currentLapSeconds,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),

          // 종료 요약 데이터
          if (isFinished) _buildSummaryTable(),
        ],
      );
    });
  }

  Widget _buildSummaryTable() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(height: 1, width: 40, color: AppColors.gray200),
          const SizedBox(height: 24),
          Text(
            controller.finishReason.value,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'TOTAL LAPS',
                '${controller.completedQuestions}',
              ),
              _buildSummaryItem(
                'TOTAL TIME',
                formatSeconds(controller.timerElapsedSeconds.value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.headlineSmall.copyWith(fontSize: 20)),
      ],
    );
  }

  /// 하단 컨트롤바
  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 64),
      child: Obx(() {
        final isRunning = controller.isTimerRunning.value;
        final isFinished = controller.isTimerFinished.value;

        if (isFinished) {
          return SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '기록 저장',
              onPressed: () => _showSaveSheet(context),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            isRunning ? controller.stopTimer() : controller.startTimer();
          },
          child: AnimatedContainer(
            duration: AppDurations.medium,
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isRunning ? Colors.transparent : AppColors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(
                color: isRunning ? AppColors.gray200 : AppColors.textPrimary,
                width: 1.5,
              ),
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 32,
              color: isRunning ? AppColors.textPrimary : Colors.white,
            ),
          ),
        );
      }),
    );
  }

  // 기존 헬퍼 메서드들 (생략하지 않고 유지)
  Future<void> _confirmFinishEarly() async {
    final confirmed = await AppDialog.showConfirm(
      title: '시험을 종료할까요?',
      message: '현재까지 기록된 내용으로 시험을 조기 종료합니다.',
      confirmLabel: '종료',
      cancelLabel: '계속하기',
    );
    if (confirmed) controller.finishEarly();
  }

  Future<String?> _showExitOptions() async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('저장되지 않은 기록이 있습니다', style: AppTypography.headlineMedium),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '기록 저장하고 나가기',
                onPressed: () => Navigator.pop(context, 'save'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '저장하지 않기',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context, 'discard'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
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
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('기록 저장', style: AppTypography.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: '기록 제목 입력'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '저장 완료',
                onPressed: () => Navigator.pop(context, titleController.text),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null) controller.saveExam(result);
  }
}

/// [이슈 4] 숫자가 바뀔 때 위아래로 부드럽게 전환되는 애니메이션 위젯
class _RollingTimeDisplay extends StatelessWidget {
  final int seconds;
  final TextStyle style;

  const _RollingTimeDisplay({required this.seconds, required this.style});

  @override
  Widget build(BuildContext context) {
    final timeStr = formatSeconds(seconds);
    final characters = timeStr.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(characters.length, (index) {
        final char = characters[index];
        final isSeparator = char == ':';

        // 구분자(:)는 애니메이션 없이 고정
        if (isSeparator) {
          return Text(char, style: style);
        }

        // 숫자만 개별적으로 애니메이션
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.2), // 살짝 아래에서
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          // 핵심: 위치(index)와 값(char)을 조합한 키를 사용하여
          // 값이 바뀔 때만 해당 위치의 숫자만 애니메이션됨
          child: Text(char, key: ValueKey('time_${index}_$char'), style: style),
        );
      }),
    );
  }
}
