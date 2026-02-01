import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/pages/subject_detail/subject_detail_controller.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/subjects/subject_modals.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';
import 'package:last_timer/routes/app_routes.dart';

class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({super.key});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late SubjectDetailController controller;
  bool _isWeakQuestionsExpanded = false;

  @override
  void initState() {
    super.initState();
    final subjectId = Get.arguments as int;
    controller = Get.put(
      SubjectDetailController(subjectId),
      tag: subjectId.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.subject.value?.subjectName ?? '분석')),
        actions: [
          IconButton(
            icon: const Icon(Icons.sticky_note_2_outlined),
            onPressed: () {
              final subject = controller.subject.value;
              if (subject != null) {
                Get.toNamed(
                  Routes.memos,
                  arguments: {
                    'subjectId': subject.id,
                    'subjectName': subject.subjectName,
                  },
                );
              }
            },
            tooltip: '메모 모아보기',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              final subject = controller.subject.value;
              if (subject != null) {
                _showSubjectOptions(context, subject);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final hasExams = controller.exams.isNotEmpty;

        if (!hasExams) {
          // [이슈 2] Empty state에는 버튼 없음 - 하단 고정 CTA 사용
          return _AnimatedEmptyState(
            icon: Icons.history_outlined,
            title: '기록이 없습니다',
            subtitle: '시작 버튼을 눌러 첫 기록을 남겨보세요',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats - 타입별 대시보드
            _buildDashboard(),
            const SizedBox(height: 24),

            // History header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.isMock ? '시험 히스토리' : '학습 히스토리',
                  style: AppTypography.headlineSmall,
                ),
                Text(
                  '${controller.totalExams}개',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam list
            ...controller.exams.asMap().entries.map((entry) {
              final index = entry.key;
              final exam = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExamHistoryCard(
                  title: exam.title,
                  questionCount: exam.questionCount,
                  totalTime: formatSeconds(exam.totalSeconds),
                  onTap: () => _goToRecordDetail(exam),
                  onDelete: () => controller.deleteExam(exam.id),
                  showSwipeHint: index == 0, // 첫 번째 카드에만 힌트 표시
                  hasMemo: exam.memos.isNotEmpty,
                ),
              );
            }),

            const SizedBox(height: 100),
          ],
        );
      }),
      // [이슈 2] 하단 고정 CTA - 항상 표시
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _PremiumFAB(
        label: controller.isMock ? '모의고사 시작' : '공부 시작',
        icon: controller.isMock
            ? Icons.timer_outlined
            : Icons.play_arrow_rounded,
        onPressed: () => Get.toNamed(Routes.timer),
      ),
    );
  }

  void _goToRecordDetail(ExamDb exam) {
    Get.toNamed(Routes.recordDetail, arguments: exam.id);
  }

  void _showSubjectOptions(BuildContext context, var subject) {
    AppMenuBottomSheet.show(
      options: [
        AppBottomSheetOption(
          icon: Icons.edit_outlined,
          label: '이름 수정',
          onTap: () {
            Get.back();
            _showRenameDialog(context, subject.id, subject.subjectName);
          },
        ),
        if (subject.isMock)
          AppBottomSheetOption(
            icon: Icons.settings_outlined,
            label: '시험 설정',
            onTap: () {
              Get.back();
              _showMockSettingsDialog(context, subject);
            },
          ),
        AppBottomSheetOption(
          icon: Icons.delete_outline,
          label: '과목 삭제',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          onTap: () {
            Get.back();
            _confirmDelete(context, subject.id);
          },
        ),
        AppBottomSheetOption(
          icon: Icons.sticky_note_2_outlined,
          label: '메모 모아보기',
          onTap: () {
            Get.back();
            Get.toNamed(
              Routes.memos,
              arguments: {
                'subjectId': subject.id,
                'subjectName': subject.subjectName,
              },
            );
          },
        ),
      ],
    );
  }

  void _showRenameDialog(
    BuildContext context,
    int id,
    String currentName,
  ) async {
    final newName = await AppInputDialog.show(
      title: '이름 수정',
      hint: '과목 이름',
      initialValue: currentName,
      confirmLabel: '저장',
    );
    if (newName != null && newName.isNotEmpty) {
      await Get.find<SubjectController>().renameSubject(id, newName);
    }
  }

  void _showMockSettingsDialog(BuildContext context, var subject) async {
    final result = await showModalBottomSheet<MockSettingsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MockSettingsSheet(subject: subject),
    );

    if (result != null) {
      await Get.find<SubjectController>().updateMockSettings(
        id: subject.id,
        timeSeconds: result.timeSeconds,
        questionCount: result.questionCount,
      );
    }
  }

  void _confirmDelete(BuildContext context, int id) async {
    final confirmed = await AppDialog.showConfirm(
      title: '과목을 삭제하시겠습니까?',
      message: '모든 시험 기록도 함께 삭제됩니다.',
      cancelLabel: '취소',
      confirmLabel: '삭제',
      isDanger: true,
    );
    if (confirmed) {
      await Get.find<SubjectController>().deleteSubject(id);
      Get.back(); // 상세 페이지에서 나감
    }
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.isMock
              ? _buildMockDashboard()
              : _buildPracticeDashboard(),
        ),
        const SizedBox(height: 24),
        _buildAdvancedInsights(),
      ],
    );
  }

  Widget _buildAdvancedInsights() {
    return Obx(() {
      if (controller.isMock && controller.topSlowQuestions.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('주요 취약 문항', style: AppTypography.headlineSmall),
            ),
            _buildWeakQuestionsGrid(),
            const SizedBox(height: 24),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildWeakQuestionsGrid() {
    return Obx(() {
      final items = controller.topSlowQuestions;

      return SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final entry = items[index];
            final isFirst = index == 0;

            return GestureDetector(
              onTap: () => _showQuestionAnalysis(entry.key),
              child: Container(
                margin: EdgeInsets.only(left: index == 0 ? 4 : 0, right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.error : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFirst
                        ? AppColors.error
                        : AppColors.error.withAlpha(40),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isFirst ? AppColors.error : Colors.black)
                          .withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFirst
                          ? Icons.priority_high_rounded
                          : Icons.timer_outlined,
                      size: 14,
                      color: isFirst ? Colors.white : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key}번',
                      style: AppTypography.labelMedium.copyWith(
                        color: isFirst ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: (isFirst ? Colors.white : AppColors.error)
                          .withAlpha(60),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatSeconds(entry.value.toInt()),
                      style: AppTypography.caption.copyWith(
                        color: isFirst
                            ? Colors.white.withAlpha(220)
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showQuestionAnalysis(int questionNum) {
    // 회차별 데이터 추출
    final exams = controller.exams.reversed.toList();
    final List<FlSpot> questionSpots = [];
    final List<FlSpot> avgSpots = [];

    for (int i = 0; i < exams.length; i++) {
      final exam = exams[i];
      // 문제 인덱스는 0-based
      if (exam.questionSeconds.length >= questionNum) {
        final sec = exam.questionSeconds[questionNum - 1];
        if (sec > 0) {
          questionSpots.add(FlSpot(i.toDouble(), sec.toDouble()));

          // 해당 회차의 전체 문항 평균 (해당 문항 제외한 나머지 평균이 더 정확하지만, 여기서는 전체 평균으로 대체)
          final totalAvg = exam.totalSeconds / exam.questionCount;
          avgSpots.add(FlSpot(i.toDouble(), totalAvg));
        }
      }
    }

    if (questionSpots.isEmpty) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$questionNum번 문항 상세 분석',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '전체 회차별 소요 시간 추이',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: AppColors.divider, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < exams.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${idx + 1}회',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatSeconds(value.toInt()),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // 이 문항 시간
                    LineChartBarData(
                      spots: questionSpots,
                      isCurved: true,
                      color: AppColors.error,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.error.withAlpha(20),
                      ),
                    ),
                    // 전체 평균 시간 (점선)
                    LineChartBarData(
                      spots: avgSpots,
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.error, '이 문항'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.accent, '회차별 평균', isDash: true),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isDash = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMockDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '평균 소요 시간',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatSeconds(controller.avgTotalSeconds.value.toInt()),
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 32,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMiniChart(),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 20),
              color: AppColors.divider,
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMetricItem(
                      Icons.assignment_rounded,
                      '총 시험',
                      '${controller.totalExams}회',
                    ),
                    const SizedBox(height: 16),
                    _buildMetricItem(
                      Icons.timer_rounded,
                      '최단기록',
                      formatSeconds(controller.minTotalSeconds.value.toInt()),
                    ),
                    const SizedBox(height: 16),
                    _buildMetricItem(
                      Icons.speed_rounded,
                      '문항평균',
                      formatSeconds(controller.avgLapSeconds.value.toInt()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 공부 시간',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatLongDuration(controller.totalStudySeconds.value),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 32,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn('총 세션', '${controller.totalExams}회'),
              ),
              Expanded(
                child: _buildStatColumn(
                  '문제 풀이',
                  '${controller.totalLapCount}문항',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '문항 평균',
                  formatSeconds(controller.avgLapSeconds.value.toInt()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniChart(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildMiniChart() {
    return Obx(() {
      final exams = controller.exams.reversed.toList();
      if (exams.length < 2) {
        return const SizedBox(
          height: 80,
          child: Center(
            child: Text(
              '추이를 보려면 기록이 더 필요합니다',
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ),
        );
      }

      final points = exams.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.totalSeconds.toDouble());
      }).toList();

      return SizedBox(
        height: 80,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                color: AppColors.accent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.accent.withAlpha(20),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.primary,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((s) {
                    return LineTooltipItem(
                      formatSeconds(s.y.toInt()),
                      const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.gray700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLongDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }
}

/// 프리미엄 FAB 버튼 - 그림자, 눌림 효과, 햅틱 피드백
class _PremiumFAB extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PremiumFAB({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB>
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
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(80),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 애니메이션 적용된 Empty State
class _AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AnimatedEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 40, color: AppColors.gray400),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
