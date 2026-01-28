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
          title: const Text('과목 목록'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '모의고사'),
              Tab(text: '일반공부'),
            ],
            labelStyle: AppTypography.labelLarge,
            unselectedLabelStyle: AppTypography.labelMedium,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              _buildSubjectList(controller.mockSubjects, isMock: true),
              _buildSubjectList(controller.practiceSubjects, isMock: false),
            ],
          );
        }),
        // [이슈 2] 하단 고정 CTA - Empty State 유무와 상관없이 고정 노출 (중복 제거)
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: ElevatedButton(
            onPressed: () => _showAddDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.black.withAlpha(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 8),
                Text('새 과목 추가', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList(List<SubjectDb> subjects, {required bool isMock}) {
    if (subjects.isEmpty) {
      // [이슈 2] Empty state 내부에서는 버튼 제거 (문구만 표시)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMock ? Icons.timer_outlined : Icons.book_outlined,
              size: 48,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              isMock ? '등록된 모의고사가 없습니다' : '등록된 공부 과목이 없습니다',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text('하단 버튼을 눌러 새 과목을 추가해보세요', style: AppTypography.bodySmall),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // FAB 공간 확보
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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

  void _showAddDialog(BuildContext context) async {
    // TabController를 통해 현재 탭의 타입을 기본값으로 설정
    final tabController = DefaultTabController.of(context);
    final initialType = tabController.index == 0
        ? SubjectType.mock
        : SubjectType.practice;

    final result = await showModalBottomSheet<_AddSubjectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSubjectSheet(initialType: initialType),
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
    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 16,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subject.subjectName,
                  style: AppTypography.headlineMedium.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subject.isMock)
                  Text(
                    '${(subject.mockTimeSeconds ?? 0) ~/ 60}분 · ${subject.mockQuestionCount ?? 0}문항',
                    style: AppTypography.bodySmall,
                  )
                else
                  const Text('일반공부 · 스톱워치', style: AppTypography.bodySmall),
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

class _AddSubjectSheet extends StatefulWidget {
  final SubjectType initialType;

  const _AddSubjectSheet({required this.initialType});

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
    selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('새 과목 추가', style: AppTypography.headlineLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildTypeTab('모의고사', SubjectType.mock),
                const SizedBox(width: 12),
                _buildTypeTab('일반공부', SubjectType.practice),
              ],
            ),
            const SizedBox(height: 32),
            Text('과목 이름', style: AppTypography.labelMedium),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(hintText: '예: 수능 수학, 영어 회화'),
            ),
            const SizedBox(height: 24),
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
                          decoration: const InputDecoration(hintText: '80'),
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
                          decoration: const InputDecoration(hintText: '45'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: AppButton(label: '과목 생성하기', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, SubjectType type) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    if (selectedType == SubjectType.mock) {
      final time = int.tryParse(timeController.text) ?? 80;
      final count = int.tryParse(questionController.text) ?? 45;
      Navigator.pop(
        context,
        _AddSubjectResult(
          name: name,
          type: SubjectType.mock,
          timeSeconds: time * 60,
          questionCount: count,
        ),
      );
    } else {
      Navigator.pop(
        context,
        _AddSubjectResult(name: name, type: SubjectType.practice),
      );
    }
  }
}

class _MockSettingsResult {
  final int timeSeconds;
  final int questionCount;
  _MockSettingsResult({required this.timeSeconds, required this.questionCount});
}

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
  Widget build(BuildContext context) {
    return Container(
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
          const Center(child: _HandleBar()),
          const SizedBox(height: 24),
          Text('시험 설정 변경', style: AppTypography.headlineLarge),
          Text(widget.subject.subjectName, style: AppTypography.bodySmall),
          const SizedBox(height: 32),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '설정 저장하기',
              onPressed: () {
                final time = int.tryParse(timeController.text) ?? 80;
                final count = int.tryParse(questionController.text) ?? 45;
                Navigator.pop(
                  context,
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

class _HandleBar extends StatelessWidget {
  const _HandleBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
