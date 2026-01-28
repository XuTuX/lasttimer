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
      appBar: AppBar(title: const Text('분석')),
      body: Obx(() {
        if (controller.exams.isEmpty) {
          return EmptyStates.exams(onStart: () => Get.toNamed(Routes.timer));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats
            _buildStatsSection(),
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
            ...controller.exams.map(
              (exam) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExamHistoryCard(
                  title: exam.title,
                  questionCount: exam.questionCount,
                  totalTime: formatSeconds(exam.totalSeconds),
                  onTap: () => _showExamDetail(exam),
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
              const Icon(Icons.play_arrow_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                '새 시험 시작',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
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
        // Unified Dashboard Card - Refined to look like a premium widget
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withAlpha(150)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side: Hero Stats & Trend Chart
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '평균 소요 시간',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatSeconds(
                            controller.avgTotalSeconds.value.toInt(),
                          ),
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 36,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        // Mini Bar Chart with baseline
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '최근 성적 추이',
                              style: AppTypography.caption.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 60,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // Chart Baseline
                                  Container(
                                    height: 1,
                                    color: AppColors.divider,
                                    margin: const EdgeInsets.only(bottom: 0),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: _buildMiniChart(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Elegant Vertical Divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  color: AppColors.divider,
                ),
                // Right Side: Beautiful Metrics List
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray50.withAlpha(100),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
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
                        const SizedBox(height: 20),
                        _buildMetricItem(
                          Icons.timer_rounded,
                          AppColors.sky,
                          '최단기록',
                          formatSeconds(
                            controller.minTotalSeconds.value.toInt(),
                          ),
                        ),
                        const SizedBox(height: 20),
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
      ],
    );
  }

  List<Widget> _buildMiniChart() {
    const int maxSlots = 7;
    final recentExams = controller.exams
        .take(maxSlots)
        .toList()
        .reversed
        .toList();

    if (recentExams.isEmpty) {
      return [
        Expanded(
          child: Center(
            child: Text(
              '기록이 없습니다',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ];
    }

    final maxVal = recentExams
        .map((e) => e.totalSeconds)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);

    return List.generate(maxSlots, (index) {
      final dataIndex = index - (maxSlots - recentExams.length);

      if (dataIndex >= 0) {
        final exam = recentExams[dataIndex];
        // Ensure bars have a minimum visible height and don't touch the top
        final heightFactor = (maxVal > 0)
            ? (exam.totalSeconds / maxVal).clamp(0.2, 0.9)
            : 0.2;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: '${exam.title}\n${formatSeconds(exam.totalSeconds)}',
                child: Container(
                  width: 12, // More slender bars
                  height: 50 * heightFactor,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withAlpha(180),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      } else {
        return const Expanded(child: SizedBox.shrink());
      }
    });
  }

  Widget _buildMetricItem(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Row(
      children: [
        // Colored Icon Container
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 13,
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

  void _showExamDetail(ExamDb exam) {
    Get.dialog(ExamDetailDialog(exam: exam));
  }
}

class ExamDetailDialog extends StatelessWidget {
  final ExamDb exam;
  const ExamDetailDialog({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final avg = exam.questionSeconds.isEmpty
        ? 0.0
        : exam.questionSeconds.reduce((a, b) => a + b) / exam.questionCount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
      backgroundColor: AppColors.surface,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 480, maxWidth: 340),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exam.title, style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${exam.questionCount}문항 · ${formatSeconds(exam.totalSeconds)} · 평균 ${formatSeconds(avg.toInt())}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),

            // Local Stuck Questions Summary Highlight
            if (exam.questionSeconds.any((sec) => sec > (avg * 1.5))) ...[
              Text(
                '시간 지연 문항',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exam.questionSeconds
                    .asMap()
                    .entries
                    .where((e) => e.value > (avg * 1.5))
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: AppRadius.xsRadius,
                          border: Border.all(
                            color: AppColors.error.withAlpha(40),
                          ),
                        ),
                        child: Text(
                          '${e.key + 1}번',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Divider(height: 1),
            const SizedBox(height: 12),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exam.questionSeconds.length,
                itemBuilder: (context, index) {
                  final sec = exam.questionSeconds[index];
                  final isSlow = sec > (avg * 1.5);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Text(
                          formatSeconds(sec),
                          style: AppTypography.bodyLarge.copyWith(
                            color: isSlow
                                ? AppColors.warning
                                : AppColors.textPrimary,
                            fontWeight: isSlow
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        if (isSlow) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: '닫기',
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
