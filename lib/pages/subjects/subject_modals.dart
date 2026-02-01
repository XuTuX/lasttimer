import 'package:flutter/material.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/utils/design_tokens.dart';

class AddSubjectResult {
  final String name;
  final SubjectType type;
  final int? timeSeconds;
  final int? questionCount;

  AddSubjectResult({
    required this.name,
    required this.type,
    this.timeSeconds,
    this.questionCount,
  });
}

class AddSubjectSheet extends StatefulWidget {
  final SubjectType initialType;

  const AddSubjectSheet({super.key, required this.initialType});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: HandleBar()),
              const SizedBox(height: 16),
              Text('과목 추가', style: AppTypography.headlineLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTypeTab('모의고사', SubjectType.mock),
                  const SizedBox(width: 8),
                  _buildTypeTab('자율 학습', SubjectType.practice),
                ],
              ),
              const SizedBox(height: 20),
              Text('과목 이름', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                style: AppTypography.bodyLarge,
                decoration: const InputDecoration(
                  hintText: '예: 수능 수학, 영어 회화',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              if (selectedType == SubjectType.mock) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('시험 시간 (분)', style: AppTypography.labelMedium),
                          const SizedBox(height: 6),
                          TextField(
                            controller: timeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '80',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
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
                          const SizedBox(height: 6),
                          TextField(
                            controller: questionController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '45',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: AppButton(label: '과목 생성하기', onPressed: _submit),
              ),
            ],
          ),
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
            color: isSelected ? AppColors.accent : AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
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
        AddSubjectResult(
          name: name,
          type: SubjectType.mock,
          timeSeconds: time * 60,
          questionCount: count,
        ),
      );
    } else {
      Navigator.pop(
        context,
        AddSubjectResult(name: name, type: SubjectType.practice),
      );
    }
  }
}

class MockSettingsResult {
  final int timeSeconds;
  final int questionCount;
  MockSettingsResult({required this.timeSeconds, required this.questionCount});
}

class MockSettingsSheet extends StatefulWidget {
  final SubjectDb subject;
  const MockSettingsSheet({super.key, required this.subject});
  @override
  State<MockSettingsSheet> createState() => _MockSettingsSheetState();
}

class _MockSettingsSheetState extends State<MockSettingsSheet> {
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: HandleBar()),
            const SizedBox(height: 16),
            Text('시험 설정 변경', style: AppTypography.headlineLarge),
            Text(widget.subject.subjectName, style: AppTypography.bodySmall),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('시험 시간 (분)', style: AppTypography.labelMedium),
                      const SizedBox(height: 6),
                      TextField(
                        controller: timeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                      const SizedBox(height: 6),
                      TextField(
                        controller: questionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: '설정 저장하기',
                onPressed: () {
                  final time = int.tryParse(timeController.text) ?? 80;
                  final count = int.tryParse(questionController.text) ?? 45;
                  Navigator.pop(
                    context,
                    MockSettingsResult(
                      timeSeconds: time * 60,
                      questionCount: count,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HandleBar extends StatelessWidget {
  const HandleBar({super.key});
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
