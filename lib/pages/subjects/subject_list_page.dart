import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/components/components.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/subjects/subject_modals.dart';
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
          title: const Text('MOMENTUM'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '모의고사'),
              Tab(text: '자율 학습'),
            ],
            indicatorWeight: 2.5,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
            indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(width: 3, color: AppColors.accent),
              borderRadius: BorderRadius.circular(2),
            ),
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
        floatingActionButton: Builder(
          builder: (context) => _PremiumFAB(
            label: '새 과목 추가',
            icon: Icons.add_rounded,
            onPressed: () => _showAddDialog(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList(List<SubjectDb> subjects, {required bool isMock}) {
    if (subjects.isEmpty) {
      // [이슈 2] Empty state 내부에서는 버튼 제거 (문구만 표시)
      return _AnimatedEmptyState(
        icon: isMock ? Icons.timer_outlined : Icons.book_outlined,
        title: isMock ? '등록된 모의고사가 없습니다' : '등록된 과목이 없습니다',
        subtitle: '하단 버튼을 눌러 새 과목을 추가해보세요',
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

    final result = await showModalBottomSheet<AddSubjectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubjectSheet(initialType: initialType),
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
          label: '이름 수정',
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
      title: '이름 수정',
      hint: '과목 이름',
      initialValue: currentName,
      confirmLabel: '저장',
    );
    if (newName != null && newName.isNotEmpty) {
      controller.renameSubject(id, newName);
    }
  }

  void _showMockSettingsDialog(BuildContext context, SubjectDb subject) async {
    final result = await showModalBottomSheet<MockSettingsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MockSettingsSheet(subject: subject),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      borderRadius: 20, // 더 둥글게
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
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLongPress,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.gray300,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 프리미엄 FAB 버튼 - 그림자, 눌림 효과, 햅틱 피드백
class _PremiumFAB extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PremiumFAB({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
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
}

/// 애니메이션 적용된 Empty State
class _AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AnimatedEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 40, color: AppColors.gray400),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
