import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/routes/app_routes.dart';
import 'package:last_timer/utils/design_tokens.dart';

class SubjectListPage extends GetView<SubjectController> {
  const SubjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('과목'),
          bottom: TabBar(
            onTap: (index) => controller.selectedTabIndex.value = index,
            tabs: const [
              Tab(text: '모의고사'),
              Tab(text: '공부'),
            ],
            labelStyle: AppTypography.labelLarge,
            unselectedLabelStyle: AppTypography.bodyMedium,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, size: 22),
              onPressed: () => _showAddDialog(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              // 모의고사 탭
              _buildSubjectList(controller.mockSubjects, isMock: true),
              // 일반공부 탭
              _buildSubjectList(controller.practiceSubjects, isMock: false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSubjectList(List<SubjectDb> subjects, {required bool isMock}) {
    if (subjects.isEmpty) {
      return EmptyStates.subjects(
        onAdd: () => _showAddDialog(
          Get.context!,
          forceType: isMock ? SubjectType.mock : SubjectType.practice,
        ),
        message: isMock ? '모의고사 과목이 없습니다' : '공부 과목이 없습니다',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _SubjectCardWithMeta(
          subject: subject,
          index: index,
          onTap: () {
            controller.selectSubject(subject.id);
            Get.toNamed(Routes.subjectDetail, arguments: subject.id);
          },
          onLongPress: () => _showOptionsSheet(
            context,
            subject.id,
            subject.subjectName,
            subject,
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, {SubjectType? forceType}) async {
    final result = await showModalBottomSheet<_AddSubjectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSubjectSheet(forceType: forceType),
    );

    if (result != null) {
      if (result.type == SubjectType.mock) {
        await controller.addMockSubject(
          name: result.name,
          timeSeconds: result.timeSeconds!,
          questionCount: result.questionCount!,
        );
      } else {
        await controller.addPracticeSubject(result.name);
      }
    }
  }

  void _showOptionsSheet(
    BuildContext context,
    int id,
    String currentName,
    SubjectDb subject,
  ) {
    AppMenuBottomSheet.show(
      options: [
        AppBottomSheetOption(
          icon: Icons.edit_outlined,
          label: '이름 변경',
          onTap: () {
            Get.back();
            _showRenameDialog(context, id, currentName);
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
          label: '삭제',
          iconColor: AppColors.error,
          textColor: AppColors.error,
          onTap: () {
            Get.back();
            _confirmDelete(context, id);
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
      title: '이름 변경',
      hint: '과목 이름',
      initialValue: currentName,
      confirmLabel: '저장',
    );
    if (newName != null && newName.isNotEmpty) {
      controller.renameSubject(id, newName);
    }
  }

  void _showMockSettingsDialog(BuildContext context, SubjectDb subject) async {
    final result = await showModalBottomSheet<_MockSettingsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MockSettingsSheet(subject: subject),
    );

    if (result != null) {
      await controller.updateMockSettings(
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
      controller.deleteSubject(id);
    }
  }
}

/// 과목 카드 (메타 정보 포함)
class _SubjectCardWithMeta extends StatelessWidget {
  final SubjectDb subject;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SubjectCardWithMeta({
    required this.subject,
    required this.index,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentByIndex(index);

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                subject.isMock ? Icons.timer_outlined : Icons.book_outlined,
                color: accentColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subject.subjectName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (subject.isMock)
                  Text(
                    '${(subject.mockTimeSeconds ?? 0) ~/ 60}분 · ${subject.mockQuestionCount ?? 0}문항',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  )
                else
                  Text(
                    '스톱워치 모드',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.gray300,
            size: 14,
          ),
        ],
      ),
    );
  }
}

/// 과목 추가 결과
class _AddSubjectResult {
  final String name;
  final SubjectType type;
  final int? timeSeconds;
  final int? questionCount;

  _AddSubjectResult({
    required this.name,
    required this.type,
    this.timeSeconds,
    this.questionCount,
  });
}

/// 과목 추가 바텀시트
class _AddSubjectSheet extends StatefulWidget {
  final SubjectType? forceType;

  const _AddSubjectSheet({this.forceType});

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  late SubjectType selectedType;
  final nameController = TextEditingController();
  final timeController = TextEditingController(text: '80');
  final questionController = TextEditingController(text: '45');

  @override
  void initState() {
    super.initState();
    selectedType = widget.forceType ?? SubjectType.mock;
  }

  @override
  void dispose() {
    nameController.dispose();
    timeController.dispose();
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text('새 과목', style: AppTypography.headlineMedium),
            const SizedBox(height: 24),

            // Type selection (탭에서 강제 지정된 경우 표시 안함)
            if (widget.forceType == null) ...[
              Text('과목 타입', style: AppTypography.labelMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: '모의고사',
                      icon: Icons.timer_outlined,
                      isSelected: selectedType == SubjectType.mock,
                      onTap: () =>
                          setState(() => selectedType = SubjectType.mock),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: '일반공부',
                      icon: Icons.book_outlined,
                      isSelected: selectedType == SubjectType.practice,
                      onTap: () =>
                          setState(() => selectedType = SubjectType.practice),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Name field
            Text('과목 이름', style: AppTypography.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '예: 국어',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mock exam settings
            if (selectedType == SubjectType.mock) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('시험 시간 (분)', style: AppTypography.labelMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: timeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '80',
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('문항 수', style: AppTypography.labelMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: questionController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '45',
                            filled: true,
                            fillColor: AppColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: AppButton(label: '추가', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('오류', '과목 이름을 입력하세요');
      return;
    }

    if (selectedType == SubjectType.mock) {
      final time = int.tryParse(timeController.text) ?? 80;
      final count = int.tryParse(questionController.text) ?? 45;

      Navigator.of(context).pop(
        _AddSubjectResult(
          name: name,
          type: SubjectType.mock,
          timeSeconds: time * 60,
          questionCount: count,
        ),
      );
    } else {
      Navigator.of(
        context,
      ).pop(_AddSubjectResult(name: name, type: SubjectType.practice));
    }
  }
}

/// 타입 선택 버튼
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 모의고사 설정 결과
class _MockSettingsResult {
  final int timeSeconds;
  final int questionCount;

  _MockSettingsResult({required this.timeSeconds, required this.questionCount});
}

/// 모의고사 설정 바텀시트
class _MockSettingsSheet extends StatefulWidget {
  final SubjectDb subject;

  const _MockSettingsSheet({required this.subject});

  @override
  State<_MockSettingsSheet> createState() => _MockSettingsSheetState();
}

class _MockSettingsSheetState extends State<_MockSettingsSheet> {
  late TextEditingController timeController;
  late TextEditingController questionController;

  @override
  void initState() {
    super.initState();
    final timeMinutes = (widget.subject.mockTimeSeconds ?? 0) ~/ 60;
    timeController = TextEditingController(text: timeMinutes.toString());
    questionController = TextEditingController(
      text: (widget.subject.mockQuestionCount ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    timeController.dispose();
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text('시험 설정', style: AppTypography.headlineMedium),
          Text(widget.subject.subjectName, style: AppTypography.bodySmall),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('시험 시간 (분)', style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: timeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('문항 수', style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: questionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '저장',
              onPressed: () {
                final time = int.tryParse(timeController.text) ?? 80;
                final count = int.tryParse(questionController.text) ?? 45;

                Navigator.of(context).pop(
                  _MockSettingsResult(
                    timeSeconds: time * 60,
                    questionCount: count,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
