import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';

class StudyReportPage extends GetView<SubjectController> {
  const StudyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('학습 리포트'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            color: AppColors.textSecondary,
            onPressed: () => _showShareSheet(context),
          ),
        ],
      ),
      body: _MonthlyCalendarView(),
    );
  }

  void _showShareSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      '공유 기능',
      '곧 인스타그램 스토리 공유 기능이 추가됩니다!',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.gray900,
      colorText: Colors.white,
    );
  }
}

class _MonthlyCalendarView extends GetView<SubjectController> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    return Obx(() {
      final dailyStats = _calculateDailyStats(currentMonth);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월 헤더
            _MonthHeader(month: currentMonth),
            const SizedBox(height: 20),
            // 요일 헤더
            _WeekdayHeader(),
            const SizedBox(height: 8),
            // 캘린더 그리드
            _CalendarGrid(month: currentMonth, dailyStats: dailyStats),
            const SizedBox(height: 24),
            // 이번 달 요약
            _MonthlySummary(dailyStats: dailyStats),
          ],
        ),
      );
    });
  }

  Map<int, _DayStats> _calculateDailyStats(DateTime month) {
    final stats = <int, _DayStats>{};
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dayExams = controller.exams.where((e) {
        final examDate = DateTime(
          e.finishedAt.year,
          e.finishedAt.month,
          e.finishedAt.day,
        );
        return examDate.isAtSameMomentAs(date);
      }).toList();

      if (dayExams.isNotEmpty) {
        final totalSeconds = dayExams.fold<int>(
          0,
          (sum, e) => sum + e.totalSeconds,
        );
        final totalQuestions = dayExams.fold<int>(
          0,
          (sum, e) => sum + e.questionCount,
        );
        stats[day] = _DayStats(
          seconds: totalSeconds,
          questions: totalQuestions,
        );
      }
    }

    return stats;
  }
}

class _DayStats {
  final int seconds;
  final int questions;

  _DayStats({required this.seconds, required this.questions});
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;

  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return Text(
      '${month.year}년 ${monthNames[month.month - 1]}',
      style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, _DayStats> dailyStats;

  const _CalendarGrid({required this.month, required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == month.year && today.month == month.month;

    final cells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final stats = dailyStats[day];
      final isToday = isCurrentMonth && today.day == day;
      final isFuture = isCurrentMonth && day > today.day;

      cells.add(
        _DayCell(day: day, stats: stats, isToday: isToday, isFuture: isFuture),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final _DayStats? stats;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    this.stats,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final hasStudy = stats != null && stats!.seconds > 0;

    return Container(
      decoration: BoxDecoration(
        color: hasStudy ? AppColors.accent.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isFuture
                  ? AppColors.textTertiary
                  : (hasStudy ? AppColors.accent : AppColors.textPrimary),
            ),
          ),
          if (hasStudy) ...[
            const SizedBox(height: 4),
            Text(
              _formatTime(stats!.seconds),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            Text(
              '${stats!.questions}문제',
              style: TextStyle(fontSize: 8, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

class _MonthlySummary extends StatelessWidget {
  final Map<int, _DayStats> dailyStats;

  const _MonthlySummary({required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    final totalSeconds = dailyStats.values.fold<int>(
      0,
      (sum, s) => sum + s.seconds,
    );
    final totalQuestions = dailyStats.values.fold<int>(
      0,
      (sum, s) => sum + s.questions,
    );
    final studyDays = dailyStats.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: '공부한 날', value: '$studyDays일'),
          _SummaryItem(label: '총 시간', value: _formatTotalTime(totalSeconds)),
          _SummaryItem(label: '푼 문제', value: '$totalQuestions문제'),
        ],
      ),
    );
  }

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}시간';
    }
    return '${mins}분';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
