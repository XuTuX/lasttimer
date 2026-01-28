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

            // Stuck questions
            if (controller.stuckQuestions.isNotEmpty) ...[
              _buildStuckQuestions(),
              const SizedBox(height: 24),
            ],

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

            const SizedBox(height: 80),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 48,
          child: TextButton(
            onPressed: () => Get.toNamed(Routes.timer),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.gray900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '시험 시작',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('통계', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: '시험 횟수',
                value: '${controller.totalExams}회',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                label: '평균 시간',
                value: formatSeconds(controller.avgTotalSeconds.value.toInt()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: '최단 기록',
                value: formatSeconds(controller.minTotalSeconds.value.toInt()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                label: '문항당 평균',
                value: formatSeconds(controller.avgLapSeconds.value.toInt()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStuckQuestions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.warning.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '시간이 오래 걸린 문항',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: controller.stuckQuestions
                .map(
                  (q) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(30),
                      borderRadius: AppRadius.xsRadius,
                    ),
                    child: Text(
                      q,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
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
            const SizedBox(height: 16),
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
