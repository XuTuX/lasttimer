import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/subject_detail/subject_detail_controller.dart';
import 'package:last_timer/routes/app_routes.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';

/// iPad-specific 2-column main layout
/// Left panel: Subject list with tabs (Mock/Practice)
/// Right panel: Subject detail (stats + exam history)
class IPadMainLayout extends StatefulWidget {
  const IPadMainLayout({super.key});

  @override
  State<IPadMainLayout> createState() => _IPadMainLayoutState();
}

class _IPadMainLayoutState extends State<IPadMainLayout>
    with TickerProviderStateMixin {
  final SubjectController subjectController = Get.find<SubjectController>();
  SubjectDetailController? detailController;
  late TabController _tabController;

  int? selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // 첫 번째 과목 자동 선택
    _autoSelectFirstSubject();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    // 탭이 바뀌면 해당 탭의 첫 번째 과목을 자동으로 선택하도록 수정
    final subjects = _tabController.index == 0
        ? subjectController.mockSubjects
        : subjectController.practiceSubjects;

    if (subjects.isNotEmpty) {
      _selectSubject(subjects.first);
    } else {
      setState(() {
        selectedSubjectId = null;
        detailController = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _autoSelectFirstSubject() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subjects = subjectController.mockSubjects.isNotEmpty
          ? subjectController.mockSubjects
          : subjectController.practiceSubjects;
      if (subjects.isNotEmpty && selectedSubjectId == null) {
        _selectSubject(subjects.first);
      }
    });
  }

  void _selectSubject(SubjectDb subject) {
    setState(() {
      selectedSubjectId = subject.id;
    });

    // 기존 컨트롤러 삭제 후 새로 생성
    if (detailController != null) {
      Get.delete<SubjectDetailController>(
        tag: detailController!.subjectId.toString(),
      );
    }

    detailController = Get.put(
      SubjectDetailController(subject.id),
      tag: subject.id.toString(),
    );

    subjectController.selectSubject(subject.id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPanelWidth = (screenWidth * 0.35).clamp(280.0, 400.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ======================================
          // LEFT PANEL - Subject List
          // ======================================
          Container(
            width: leftPanelWidth,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // iPad AppBar
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'MOMENTUM',
                          style: AppTypography.headlineMedium.copyWith(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        // Stats button
                        IconButton(
                          icon: const Icon(Icons.bar_chart_rounded),
                          color: AppColors.textSecondary,
                          onPressed: () => Get.toNamed(Routes.studyReport),
                        ),
                        // Add button
                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          color: AppColors.accent,
                          onPressed: () => _showAddDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '모의고사'),
                      Tab(text: '자율 학습'),
                    ],
                    indicatorWeight: 2.5,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: AppColors.accent),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subject list
                Expanded(
                  child: Obx(() {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSubjectList(
                          subjectController.mockSubjects,
                          isMock: true,
                        ),
                        _buildSubjectList(
                          subjectController.practiceSubjects,
                          isMock: false,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          // ======================================
          // RIGHT PANEL - Detail View
          // ======================================
          Expanded(
            child: selectedSubjectId != null && detailController != null
                ? _IPadDetailPanel(
                    controller: detailController!,
                    onStartTimer: () => Get.toNamed(Routes.timer),
                    onExamTap: (exam) =>
                        Get.toNamed(Routes.recordDetail, arguments: exam.id),
                  )
                : _buildEmptyDetailPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(List<SubjectDb> subjects, {required bool isMock}) {
    if (subjects.isEmpty) {
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
              isMock ? '등록된 모의고사가 없습니다' : '등록된 과목이 없습니다',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final isSelected = subject.id == selectedSubjectId;

        return _IPadSubjectTile(
          subject: subject,
          isSelected: isSelected,
          onTap: () => _selectSubject(subject),
          onLongPress: () => _showOptionsSheet(context, subject),
        );
      },
    );
  }

  Widget _buildEmptyDetailPanel() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '과목을 선택하세요',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '왼쪽 패널에서 과목을 탭하면\n상세 정보가 여기에 표시됩니다',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) async {
    final initialType = _tabController.index == 0
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
        await subjectController.addMockSubject(
          name: result.name,
          timeSeconds: result.timeSeconds!,
          questionCount: result.questionCount!,
        );
      } else {
        await subjectController.addPracticeSubject(result.name);
      }
      // 새로 추가된 과목 자동 선택
      _autoSelectFirstSubject();
    }
  }

  void _showOptionsSheet(BuildContext context, SubjectDb subject) {
    AppMenuBottomSheet.show(
      options: [
        AppBottomSheetOption(
          icon: Icons.edit_outlined,
          label: '이름 변경',
          onTap: () {
            Get.back();
            _showRenameDialog(context, subject.id, subject.subjectName);
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
            _confirmDelete(context, subject.id);
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
      subjectController.renameSubject(id, newName);
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
      await subjectController.updateMockSettings(
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
      subjectController.deleteSubject(id);
      if (selectedSubjectId == id) {
        setState(() {
          selectedSubjectId = null;
          detailController = null;
        });
      }
    }
  }
}

/// iPad Subject Tile - 왼쪽 패널용
class _IPadSubjectTile extends StatelessWidget {
  final SubjectDb subject;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _IPadSubjectTile({
    required this.subject,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accent.withAlpha(15) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // 선택 인디케이터
              Container(
                width: 4,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subject.isMock) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${(subject.mockTimeSeconds ?? 0) ~/ 60}분 · ${subject.mockQuestionCount ?? 0}문항',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isSelected ? AppColors.accent : AppColors.gray300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// iPad Detail Panel - 오른쪽 패널
class _IPadDetailPanel extends StatelessWidget {
  final SubjectDetailController controller;
  final VoidCallback onStartTimer;
  final void Function(ExamDb exam) onExamTap;

  const _IPadDetailPanel({
    required this.controller,
    required this.onStartTimer,
    required this.onExamTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 화면 크기에 따라 그리드 열 개수 조정
    final crossAxisCount = screenWidth > 1100 ? 3 : 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        title: Obx(
          () => Text(
            controller.subject.value?.subjectName ?? '',
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          // Start Timer Button
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _IPadStartButton(
              label: controller.isMock ? '모의고사 시작' : '공부 시작',
              onPressed: onStartTimer,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final hasExams = controller.exams.isNotEmpty;

        if (!hasExams) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_outlined,
                    size: 48,
                    color: AppColors.gray300,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '아직 기록이 없습니다',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '상단의 시작 버튼을 눌러 첫 학습을 시작해 보세요',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stats Section Header
              Row(
                children: [
                  Text(
                    '집중 분석',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '총 ${controller.totalExams}회의 기록',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Stats Grid - 컴팩트한 2x2 그리드
              _buildStatsGrid(),

              const SizedBox(height: 32),

              // 3. Recent History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '최근 기록',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textTertiary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '전체 보기',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. History Grid - 2~3열 그리드
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.2,
                ),
                itemCount: controller.exams.length > 6
                    ? 6
                    : controller.exams.length,
                itemBuilder: (context, index) {
                  final exam = controller.exams[index];
                  return _IPadHistoryTile(
                    title: exam.title,
                    questionCount: exam.questionCount,
                    totalTime: formatSeconds(exam.totalSeconds),
                    onTap: () => onExamTap(exam),
                  );
                },
              ),

              // 더 많은 기록이 있을 경우 리스트로 표시
              if (controller.exams.length > 6) ...[
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.exams.length - 6,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exam = controller.exams[index + 6];
                    return _IPadHistoryTile(
                      title: exam.title,
                      questionCount: exam.questionCount,
                      totalTime: formatSeconds(exam.totalSeconds),
                      onTap: () => onExamTap(exam),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    final List<_StatData> stats = controller.isMock
        ? [
            _StatData(
              '평균 소요 시간',
              formatSeconds(controller.avgTotalSeconds.value.toInt()),
              Icons.timer_outlined,
              AppColors.accent,
            ),
            _StatData(
              '총 시험 횟수',
              '${controller.totalExams}회',
              Icons.history,
              AppColors.textSecondary,
            ),
            _StatData(
              '최단 기록',
              formatSeconds(controller.minTotalSeconds.value.toInt()),
              Icons.speed,
              AppColors.textSecondary,
            ),
            _StatData(
              '문항당 평균',
              formatSeconds(controller.avgLapSeconds.value.toInt()),
              Icons.av_timer,
              AppColors.textSecondary,
            ),
          ]
        : [
            _StatData(
              '총 공부 시간',
              _formatLongDuration(controller.totalStudySeconds.value),
              Icons.auto_graph_rounded,
              AppColors.accent,
            ),
            _StatData(
              '총 세션',
              '${controller.totalExams}회',
              Icons.calendar_today_outlined,
              AppColors.textSecondary,
            ),
            _StatData(
              '누적 문항',
              '${controller.totalLapCount}문항',
              Icons.check_circle_outline,
              AppColors.textSecondary,
            ),
            _StatData(
              '문항 평균',
              formatSeconds(controller.avgLapSeconds.value.toInt()),
              Icons.access_time,
              AppColors.textSecondary,
            ),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: stats.map((data) => _buildStatCard(data)).toList(),
    );
  }

  Widget _buildStatCard(_StatData data) {
    final isAccent = data.color == AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAccent ? data.color.withAlpha(12) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccent ? data.color.withAlpha(40) : AppColors.border,
          width: isAccent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                data.icon,
                size: 14,
                color: isAccent ? data.color : AppColors.gray400,
              ),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: AppTypography.caption.copyWith(
                  color: isAccent ? data.color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: AppTypography.headlineLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLongDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) return '$hours시간 $minutes분';
    if (minutes > 0) return '$minutes분 $seconds초';
    return '$seconds초';
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatData(this.label, this.value, this.icon, this.color);
}

/// iPad 최근 기록 타일 - 컴팩트한 그리드용
class _IPadHistoryTile extends StatelessWidget {
  final String title;
  final int questionCount;
  final String totalTime;
  final VoidCallback? onTap;

  const _IPadHistoryTile({
    required this.title,
    required this.questionCount,
    required this.totalTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$questionCount문항 · $totalTime',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray300,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// iPad 전용 시작 버튼
class _IPadStartButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _IPadStartButton({required this.label, required this.onPressed});

  @override
  State<_IPadStartButton> createState() => _IPadStartButtonState();
}

class _IPadStartButtonState extends State<_IPadStartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
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

// ============================================================================
// BOTTOM SHEETS (재사용 - iPhone과 동일)
// ============================================================================

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
                _buildTypeTab('자율 학습', SubjectType.practice),
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
