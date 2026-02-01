import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/pages/record_detail/record_detail_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';
import 'package:last_timer/utils/stats.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key});

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late RecordDetailController controller;
  late TextEditingController memoController;

  @override
  void initState() {
    super.initState();
    final examId = Get.arguments as int;
    controller = Get.put(
      RecordDetailController(examId),
      tag: examId.toString(),
    );
    memoController = TextEditingController();
  }

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('히스토리 상세'),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined, color: Colors.orange),
              onPressed: () => _injectMockData(),
              tooltip: '디버그: 모의 데이터 주입',
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: _showMoreOptions,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final exam = controller.exam.value;
        if (exam == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // [이슈] 가장 정교한 분석을 위한 표준편차(Z-Score) 기반 5단계 분류
        final nonZeroTimes = exam.questionSeconds
            .where((s) => s > 0)
            .map((e) => e.toDouble())
            .toList();
        final mean = StatsUtils.calculateMean(nonZeroTimes);
        final stdDev = StatsUtils.calculateStdDev(nonZeroTimes);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 상단: 제목/날짜/총 시간
            _buildHeader(exam, mean),
            const SizedBox(height: 24),

            // 중단: 문항별 시간 리스트
            _buildQuestionList(exam, mean, stdDev),
            const SizedBox(height: 24),

            // 하단: 메모 필드
            _buildMemoSection(),
            const SizedBox(height: 40),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ExamDb exam, double avg) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exam.title, style: AppTypography.headlineLarge),
          const SizedBox(height: 8),
          Text(
            dateFormat.format(exam.finishedAt),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('총 시간', formatSeconds(exam.totalSeconds)),
              const SizedBox(width: 24),
              _buildStatItem('문항 수', '${exam.questionCount}문항'),
              const SizedBox(width: 24),
              _buildStatItem('평균', formatSeconds(avg.toInt())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildQuestionList(ExamDb exam, double mean, double stdDev) {
    // 5단계 카운트
    int veryFastCount = 0;
    int fastCount = 0;
    int slowCount = 0;
    int verySlowCount = 0;
    int unsolvedCount = 0;

    // [개선] 목표 페이스 임계값 계산
    final targetThreshold =
        (controller.subject.value?.mockTimeSeconds ?? 0) /
        (controller.subject.value?.mockQuestionCount ?? 1);

    for (final sec in exam.questionSeconds) {
      if (sec == 0) {
        unsolvedCount++;
      } else {
        final zScore = stdDev > 0 ? (sec - mean) / stdDev : 0.0;
        if (zScore < -1.2) {
          veryFastCount++;
        } else if (zScore < -0.6) {
          fastCount++;
        } else if (zScore > 0.6) {
          // Z-Score상 느리더라도 목표 페이스(threshold)보다 빠르면 '느림' 태그 제외
          if (sec < targetThreshold) continue;

          if (zScore > 1.2) {
            verySlowCount++;
          } else {
            slowCount++;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('문항별 소요 시간', style: AppTypography.headlineSmall),
              // 요약 배지
              Row(
                children: [
                  if (unsolvedCount > 0)
                    _buildBadge('미풀이 $unsolvedCount', AppColors.gray500),
                  if (unsolvedCount > 0 &&
                      (veryFastCount + fastCount + slowCount + verySlowCount >
                          0))
                    const SizedBox(width: 8),
                  if (veryFastCount > 0)
                    _buildBadge('매우 빠름 $veryFastCount', AppColors.success),
                  if (veryFastCount > 0 &&
                      (fastCount + slowCount + verySlowCount > 0))
                    const SizedBox(width: 8),
                  if (fastCount > 0)
                    _buildBadge(
                      '빠름 $fastCount',
                      AppColors.success.withAlpha(120),
                    ),
                  if (fastCount > 0 && (slowCount + verySlowCount > 0))
                    const SizedBox(width: 8),
                  if (slowCount > 0)
                    _buildBadge(
                      '느림 $slowCount',
                      AppColors.warning.withAlpha(120),
                    ),
                  if (slowCount > 0 && verySlowCount > 0)
                    const SizedBox(width: 8),
                  if (verySlowCount > 0)
                    _buildBadge('매우 느림 $verySlowCount', AppColors.error),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exam.questionSeconds.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final sec = exam.questionSeconds[index];
              final isUnsolved = sec == 0;

              String? tag;
              Color? tagColor;
              Color? itemBg;

              if (!isUnsolved) {
                final zScore = stdDev > 0 ? (sec - mean) / stdDev : 0.0;
                final targetThreshold =
                    (controller.subject.value?.mockTimeSeconds ?? 0) /
                    (controller.subject.value?.mockQuestionCount ?? 1);

                if (zScore < -1.2) {
                  tag = '매우 빠름';
                  tagColor = AppColors.success;
                  itemBg = AppColors.success.withAlpha(15);
                } else if (zScore < -0.6) {
                  tag = '빠름';
                  tagColor = AppColors.success.withAlpha(180);
                  itemBg = AppColors.success.withAlpha(10);
                } else if (zScore > 0.6 && sec >= targetThreshold) {
                  // 목표 페이스보다 느릴 때만 '느림/매우 느림' 표시
                  if (zScore > 1.2) {
                    tag = '매우 느림';
                    tagColor = AppColors.error;
                    itemBg = AppColors.error.withAlpha(15);
                  } else {
                    tag = '느림';
                    tagColor = AppColors.warning;
                    itemBg = AppColors.warning.withAlpha(15);
                  }
                }
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: itemBg ?? Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: AppColors.gray100, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isUnsolved ? '-' : formatSeconds(sec),
                      style: AppTypography.bodyLarge.copyWith(
                        color: isUnsolved
                            ? AppColors.textTertiary
                            : (tagColor ?? AppColors.textPrimary),
                        fontWeight: tag != null ? FontWeight.w600 : null,
                      ),
                    ),
                    const Spacer(),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor!.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.caption.copyWith(
                            color: tagColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('메모', style: AppTypography.headlineSmall),
              Obx(
                () => Text(
                  '총 ${controller.memos.length}개',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 기존 메모 리스트
        Obx(
          () => Column(
            children: controller.memos.asMap().entries.map((entry) {
              final index = entry.key;
              final memoText = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '메모 #${index + 1}',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.deleteMemo(index),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memoText,
                        style: AppTypography.bodyMedium.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 새 메모 입력창
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: memoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '메모를 추가로 남겨보세요...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTypography.bodyLarge.copyWith(height: 1.6),
              ),
              const SizedBox(height: 12),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: controller.isSaving.value ? '저장 중...' : '새 메모 등록하기',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.medium,
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final text = memoController.text;
                            if (text.trim().isNotEmpty) {
                              await controller.addMemo(text);
                              memoController.clear();
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMoreOptions() {
    AppMenuBottomSheet.show(
      options: [
        AppBottomSheetOption(
          icon: Icons.edit_outlined,
          label: '이름 수정',
          onTap: () {
            Get.back();
            _showRenameDialog();
          },
        ),
        AppBottomSheetOption(
          icon: Icons.delete_outline,
          label: '삭제',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          onTap: () {
            Get.back();
            _confirmDelete();
          },
        ),
      ],
    );
  }

  void _showRenameDialog() async {
    final currentTitle = controller.exam.value?.title ?? '';
    final newTitle = await AppInputDialog.show(
      title: '이름 수정',
      hint: '히스토리 이름',
      initialValue: currentTitle,
      confirmLabel: '저장',
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      await controller.renameExam(newTitle);
    }
  }

  void _confirmDelete() async {
    final confirmed = await AppDialog.showConfirm(
      title: '기록을 삭제하시겠습니까?',
      message: '삭제된 기록은 복구할 수 없습니다.',
      cancelLabel: '취소',
      confirmLabel: '삭제',
      isDanger: true,
    );
    if (confirmed) {
      controller.deleteExam();
    }
  }

  /// [디버그 전용] UI 확인을 위한 데이터 주입
  void _injectMockData() {
    final exam = controller.exam.value;
    if (exam == null) return;

    // 현재 문항들을 기반으로 무작위 시간 설정
    final List<int> mockSeconds = List.generate(exam.questionSeconds.length, (
      i,
    ) {
      if (i % 7 == 0) return 0; // 미풀이
      if (i % 5 == 0) return 300; // 매우 느림 (5분)
      if (i % 3 == 0) return 10; // 빠름
      return 60; // 보통
    });

    exam.questionSeconds = mockSeconds;
    exam.totalSeconds = mockSeconds.fold(0, (a, b) => a + b);
    controller.exam.value = exam;
    controller.exam.refresh();
  }
}
