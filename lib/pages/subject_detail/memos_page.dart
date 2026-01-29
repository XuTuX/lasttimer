import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/pages/subject_detail/subject_detail_controller.dart';
import 'package:last_timer/routes/app_routes.dart';
import 'package:last_timer/utils/design_tokens.dart';

class MemosPage extends StatelessWidget {
  const MemosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SubjectDetailController가 이미 생성되어 있을 것으로 예상 (tag와 함께)
    final args = Get.arguments as Map<String, dynamic>;
    final int subjectId = args['subjectId'];
    final String subjectName = args['subjectName'];

    final controller = Get.find<SubjectDetailController>(
      tag: subjectId.toString(),
    );

    return Scaffold(
      appBar: AppBar(title: Text('$subjectName - 메모')),
      body: Obx(() {
        final memoExams = controller.exams
            .where((e) => e.memos.isNotEmpty)
            .toList();

        if (memoExams.isEmpty) {
          return const Center(
            child: AppEmptyState(
              icon: Icons.note_alt_outlined,
              title: '저장된 메모가 없습니다',
              message: '히스토리 상세에서 메모를 남겨보세요',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: memoExams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final exam = memoExams[index];
            return _MemoCard(exam: exam);
          },
        );
      }),
    );
  }
}

class _MemoCard extends StatelessWidget {
  final ExamDb exam;

  const _MemoCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return AppCard(
      onTap: () => Get.toNamed(Routes.recordDetail, arguments: exam.id),
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exam.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateFormat.format(exam.finishedAt),
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exam.memos
              .take(2)
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray100),
                    ),
                    child: Text(
                      m,
                      style: AppTypography.bodyMedium.copyWith(
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          if (exam.memos.length > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                '...외 ${exam.memos.length - 2}개의 메모가 더 있습니다',
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '자세히 보기',
                style: AppTypography.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
