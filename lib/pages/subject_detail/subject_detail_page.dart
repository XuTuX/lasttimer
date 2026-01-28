import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/pages/subject_detail/subject_detail_controller.dart';
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
                Text('기록', style: AppTypography.headlineSmall),
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

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '분석',
            style: AppTypography.headlineMedium.copyWith(fontSize: 20),
          ),
        ),
        Obx(
          () => controller.isMock
              ? _buildMockDashboard()
              : _buildPracticeDashboard(),
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
    const int maxSlots = 7;
    final recentExams = controller.exams
        .take(maxSlots)
        .toList()
        .reversed
        .toList();

    if (recentExams.isEmpty) return const SizedBox.shrink();

    final maxVal = recentExams
        .map((e) => e.totalSeconds)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 추이',
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(maxSlots, (index) {
              final dataIndex = index - (maxSlots - recentExams.length);
              if (dataIndex >= 0) {
                final exam = recentExams[dataIndex];
                final heightFactor = (maxVal > 0)
                    ? (exam.totalSeconds / maxVal).clamp(0.2, 0.95)
                    : 0.2;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height: 45 * heightFactor,
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }
              return const Expanded(child: SizedBox.shrink());
            }),
          ),
        ),
      ],
    );
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
