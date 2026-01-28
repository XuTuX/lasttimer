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

              // [수정] 실행 중일 때는 숨기고, 일시정지 상태에서만 즉시 '저장' 시트로 이동
              if (!isFinished && !isRunning && hasStarted) {
                return TextButton(
                  onPressed: () => _showSaveSheet(context),
                  child: Text(
                    controller.isMockMode ? '종료' : '저장',
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
                color: AppColors.textTertiary.withAlpha(180),
              ),
            ),
            const SizedBox(height: 32),
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

          const SizedBox(height: 20),

          // 현재 문항 소요 시간 (메인 시간 아래에 작게)
          if (!isFinished)
            Opacity(
              opacity: controller.isTimerRunning.value ? 1 : 0.4,
              child: _RollingTimeDisplay(
                seconds: controller.currentLapSeconds,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(40, 20, 40, 32 + bottomPadding),
      child: Obx(() {
        final isRunning = controller.isTimerRunning.value;
        final isFinished = controller.isTimerFinished.value;

        if (isFinished) {
          return _PremiumSaveButton(onPressed: () => _showSaveSheet(context));
        }

        return _PlayPauseButton(
          isRunning: isRunning,
          onPressed: () {
            HapticFeedback.mediumImpact();
            isRunning ? controller.stopTimer() : controller.startTimer();
          },
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Column(
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
                Text('기록을 어떻게 할까요?', style: AppTypography.headlineMedium),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: '기록 저장하고 종료',
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
                const SizedBox(height: 8),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.gray400),
                onPressed: () => Navigator.pop(context),
              ),
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

/// 프리미엄 재생/일시정지 버튼
class _PlayPauseButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onPressed;

  const _PlayPauseButton({required this.isRunning, required this.onPressed});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: widget.isRunning
                ? Colors.transparent
                : AppColors.textPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isRunning
                  ? AppColors.gray300
                  : AppColors.textPrimary,
              width: 2,
            ),
            boxShadow: widget.isRunning
                ? []
                : [
                    BoxShadow(
                      color: AppColors.textPrimary.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Icon(
              widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey(widget.isRunning),
              size: 32,
              color: widget.isRunning ? AppColors.textPrimary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 프리미엄 저장 버튼
class _PremiumSaveButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PremiumSaveButton({required this.onPressed});

  @override
  State<_PremiumSaveButton> createState() => _PremiumSaveButtonState();
}

class _PremiumSaveButtonState extends State<_PremiumSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '기록 저장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
