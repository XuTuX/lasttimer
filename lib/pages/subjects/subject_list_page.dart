import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/routes/app_routes.dart';
import 'package:last_timer/utils/design_tokens.dart';

class SubjectListPage extends GetView<SubjectController> {
  const SubjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('과목'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: () => _showAddDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        if (controller.subjects.isEmpty) {
          return EmptyStates.subjects(onAdd: () => _showAddDialog(context));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.subjects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final subject = controller.subjects[index];
            return SubjectCard(
              name: subject.subjectName,
              index: index,
              onTap: () {
                controller.selectSubject(subject.id);
                Get.toNamed(Routes.subjectDetail, arguments: subject.id);
              },
              onLongPress: () =>
                  _showOptionsSheet(context, subject.id, subject.subjectName),
            );
          },
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context) async {
    final name = await AppInputDialog.show(
      title: '새 과목',
      hint: '과목 이름',
      confirmLabel: '추가',
    );
    if (name != null && name.isNotEmpty) {
      controller.addSubject(name);
    }
  }

  void _showOptionsSheet(BuildContext context, int id, String currentName) {
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
