import 'package:flutter/material.dart';
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
        if (controller.exams.isEmpty) {
          return EmptyStates.exams(onStart: () => Get.toNamed(Routes.timer));
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

            // Exam list - dialog 대신 페이지 전환
            ...controller.exams.map(
              (exam) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExamHistoryCard(
                  title: exam.title,
                  questionCount: exam.questionCount,
                  totalTime: formatSeconds(exam.totalSeconds),
                  onTap: () => _goToRecordDetail(exam),
                  onDelete: () => controller.deleteExam(exam.id),
                ),
              ),
            ),

            const SizedBox(height: 100), // Spacing for floating button
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: ElevatedButton(
          onPressed: () => Get.toNamed(Routes.timer),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gray900,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: Colors.black.withAlpha(80),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.isMock
                    ? Icons.timer_outlined
                    : Icons.play_arrow_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                controller.isMock ? '모의고사 시작' : '공부 시작',
                style: const TextStyle(
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

  /// 기록 상세 페이지로 이동 (dialog 대신)
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
            '분석 대시보드',
            style: AppTypography.headlineMedium.copyWith(fontSize: 20),
          ),
        ),
        // 타입별 대시보드
        Obx(
          () => controller.isMock
              ? _buildMockDashboard()
              : _buildPracticeDashboard(),
        ),
      ],
    );
  }

  /// 모의고사 분석 대시보드
  Widget _buildMockDashboard() {
    return Column(
      children: [
        // Main Stats Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withAlpha(150)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side: Hero Stats
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
                          formatSeconds(
                            controller.avgTotalSeconds.value.toInt(),
                          ),
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 32,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Mini Bar Chart
                        _buildMiniChart(),
                      ],
                    ),
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  color: AppColors.divider,
                ),
                // Right Side: Metrics
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray50.withAlpha(100),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
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
                          AppColors.mint,
                          '총 시험',
                          '${controller.totalExams}회',
                        ),
                        const SizedBox(height: 16),
                        _buildMetricItem(
                          Icons.timer_rounded,
                          AppColors.sky,
                          '최단기록',
                          formatSeconds(
                            controller.minTotalSeconds.value.toInt(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMetricItem(
                          Icons.speed_rounded,
                          AppColors.lavender,
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
        ),
        const SizedBox(height: 16),

        // 상위 10% 오래 걸린 문항
        if (controller.topSlowQuestions.isNotEmpty) ...[
          _buildSlowQuestionsCard(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 일반공부 분석 대시보드
  Widget _buildPracticeDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 총 공부 시간
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

          // 지표들
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  '총 세션',
                  '${controller.totalExams}회',
                  Icons.library_books_outlined,
                  AppColors.mint,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '문제 풀이',
                  '${controller.totalLapCount}문항',
                  Icons.check_circle_outline,
                  AppColors.sky,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  '문항 평균',
                  formatSeconds(controller.avgLapSeconds.value.toInt()),
                  Icons.timer_outlined,
                  AppColors.lavender,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 최근 성적 추이
          _buildMiniChart(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildSlowQuestionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningLight.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withAlpha(40)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '상위 10% 오래 걸린 문항',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.topSlowQuestions.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.key}번',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatSeconds(entry.value.toInt()),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    const int maxSlots = 7;
    final recentExams = controller.exams
        .take(maxSlots)
        .toList()
        .reversed
        .toList();

    if (recentExams.isEmpty) {
      return const SizedBox.shrink();
    }

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
                    child: Tooltip(
                      message:
                          '${exam.title}\n${formatSeconds(exam.totalSeconds)}',
                      child: Container(
                        height: 45 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withAlpha(150),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
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

  /// 긴 시간 포맷 (시:분:초 또는 시간분)
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
