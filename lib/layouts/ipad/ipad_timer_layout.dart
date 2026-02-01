import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/timer/timer_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';

/// iPad-specific timer layout
/// Wider layout with larger timer display and side panel for lap times
class IPadTimerLayout extends StatefulWidget {
  const IPadTimerLayout({super.key});

  @override
  State<IPadTimerLayout> createState() => _IPadTimerLayoutState();
}

class _IPadTimerLayoutState extends State<IPadTimerLayout>
    with TickerProviderStateMixin {
  late TimerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TimerController());
  }

  @override
  Widget build(BuildContext context) {
    final subjectController = Get.find<SubjectController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final showLapPanel = screenWidth > 900; // 충분히 넓을 때만 랩 패널 표시

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

              if (!isFinished && !isRunning && hasStarted) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AppButton(
                    label: controller.isMockMode ? '종료' : '저장',
                    variant: AppButtonVariant.danger,
                    size: AppButtonSize.small,
                    onPressed: () => _showSaveSheet(context),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            // Progress bar for mock mode
            if (controller.isMockMode) _buildTopProgressBar(),

            Expanded(
              child: Row(
                children: [
                  // ================================
                  // MAIN TIMER AREA
                  // ================================
                  Expanded(
                    flex: showLapPanel ? 3 : 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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

                  // ================================
                  // LAP TIMES PANEL (if wide enough)
                  // ================================
                  if (showLapPanel)
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        border: Border(
                          left: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      child: _buildLapPanel(),
                    ),
                ],
              ),
            ),

            // Bottom controls
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
      _showSaveSheet(context);
    } else {
      Get.back();
    }
  }

  Widget _buildTopProgressBar() {
    return Obx(() {
      final progress = controller.mockTotalSeconds > 0
          ? controller.timerElapsedSeconds.value / controller.mockTotalSeconds
          : 0.0;
      return Container(
        width: double.infinity,
        height: 3,
        color: AppColors.gray100,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            color: progress > 0.9 ? AppColors.error : AppColors.accent,
          ),
        ),
      );
    });
  }

  Widget _buildTimerContent() {
    return Obx(() {
      final isFinished = controller.isTimerFinished.value;
      final displaySec = controller.isMockMode
          ? controller.remainingSeconds
          : controller.timerElapsedSeconds.value;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question number
          if (!isFinished) ...[
            Text(
              'QUESTION ${controller.currentQuestionNumber.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
                color: AppColors.textTertiary.withAlpha(180),
              ),
            ),
            const SizedBox(height: 40),
          ],

          // Main time display (larger for iPad)
          _RollingTimeDisplay(
            seconds: displaySec,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 120, // 더 크게
              fontWeight: FontWeight.w200,
              color: isFinished ? AppColors.gray300 : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 28),

          // Current lap time
          if (!isFinished)
            Opacity(
              opacity: controller.isTimerRunning.value ? 1 : 0.4,
              child: _RollingTimeDisplay(
                seconds: controller.currentLapSeconds,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 48, // iPad에서 더 크게
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),

          // Summary when finished
          if (isFinished) _buildSummaryTable(),
        ],
      );
    });
  }

  Widget _buildLapPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('문항별 시간', style: AppTypography.headlineSmall),
              Obx(
                () => Text(
                  '${controller.completedQuestions}문항',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Lap list
        Expanded(
          child: Obx(() {
            final laps = controller.laps;
            if (laps.isEmpty) {
              return Center(
                child: Text(
                  '화면을 탭하여\n문항을 기록하세요',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: laps.length,
              itemBuilder: (context, index) {
                final lap = laps[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatSeconds(lap),
                        style: AppTypography.bodyLarge.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Container(height: 1, width: 60, color: AppColors.gray200),
          const SizedBox(height: 32),
          Text(
            controller.finishReason.value,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(value, style: AppTypography.headlineSmall.copyWith(fontSize: 24)),
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(60, 24, 60, 36 + bottomPadding),
      child: Obx(() {
        final isRunning = controller.isTimerRunning.value;
        final isFinished = controller.isTimerFinished.value;

        if (isFinished) {
          return _PremiumSaveButton(onPressed: () => _showSaveSheet(context));
        }

        return _PlayPauseButton(
          isRunning: isRunning,
          size: 80, // iPad에서 더 크게
          onPressed: () {
            HapticFeedback.mediumImpact();
            isRunning ? controller.stopTimer() : controller.startTimer();
          },
        );
      }),
    );
  }

  void _showSaveSheet(BuildContext context) async {
    if (controller.isTimerRunning.value) controller.stopTimer();
    final titleController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: EdgeInsets.only(
                left: 40,
                right: 40,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                top: 40,
              ),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.large,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('기록 저장', style: AppTypography.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '기록 제목 입력',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.gray50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: '저장 완료',
                      onPressed: () =>
                          Navigator.pop(context, titleController.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: '저장하지 않고 나가기',
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.pop(context, '__DISCARD__'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      if (result == '__DISCARD__') {
        controller.resetTimer();
        Get.back();
      } else {
        controller.saveExam(result);
      }
    }
  }
}

/// Rolling time display widget
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

        if (isSeparator) {
          return Text(char, style: style);
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.2),
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
          child: Text(char, key: ValueKey('time_${index}_$char'), style: style),
        );
      }),
    );
  }
}

/// Play/Pause button with size parameter for iPad
class _PlayPauseButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onPressed;
  final double size;

  const _PlayPauseButton({
    required this.isRunning,
    required this.onPressed,
    this.size = 72,
  });

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
          width: widget.size,
          height: widget.size,
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
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Icon(
              widget.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey(widget.isRunning),
              size: widget.size * 0.45,
              color: widget.isRunning ? AppColors.textPrimary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium save button
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
          constraints: const BoxConstraints(maxWidth: 400),
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
