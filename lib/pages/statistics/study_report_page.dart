import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/utils/design_tokens.dart';
import 'package:last_timer/utils/seconds_format.dart';
import 'package:last_timer/components/components.dart';

class StudyReportPage extends GetView<SubjectController> {
  const StudyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('학습 통계'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalStatsSection(),
            const SizedBox(height: 24),
            Text(
              '주간 학습 분석',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 24),
            _buildStreakSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalStatsSection() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                label: '오늘 학습',
                value: formatSeconds(controller.todayTotalSeconds.value),
                icon: Icons.today_rounded,
                iconColor: AppColors.accent,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.gray100,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _StatItem(
                label: '주간 평균',
                value: formatSeconds(_calculateWeeklyAverage()),
                icon: Icons.analytics_outlined,
                iconColor: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateWeeklyAverage() {
    final list = controller.weeklySeconds;
    if (list.isEmpty) return 0;
    final total = list.fold<int>(0, (sum, val) => sum + val);
    return total ~/ list.length;
  }

  Widget _buildChartCard() {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
      borderRadius: 24,
      child: Column(
        children: [
          SizedBox(height: 200, child: _WeeklyChart()),
          const SizedBox(height: 16),
          Text(
            '지난 7일간의 학습량 변화입니다.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 연속 학습 기록',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${controller.currentStreak.value}일째 열공 중!',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends GetView<SubjectController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weekSeconds = controller.weeklySeconds;
      final maxVal = weekSeconds.fold<int>(0, (m, v) => v > m ? v : m);

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal == 0 ? 3600 : maxVal.toDouble() * 1.3,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.gray900,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  formatSeconds(rod.toY.toInt()),
                  AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= 7) return const SizedBox();

                  String label = '';
                  if (index == 6) {
                    label = '오늘';
                  } else {
                    final date = DateTime.now().subtract(
                      Duration(days: 6 - index),
                    );
                    label = '${date.month}/${date.day}';
                  }

                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        color: index == 6
                            ? AppColors.accent
                            : AppColors.textTertiary,
                        fontWeight: index == 6
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: maxVal == 0
                    ? 1800
                    : (maxVal / 3).clamp(600, 7200).toDouble(),
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final minutes = value ~/ 60;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${minutes}m',
                      style: AppTypography.caption.copyWith(
                        fontSize: 9,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal == 0
                ? 1800
                : (maxVal / 3).clamp(600, 7200).toDouble(),
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.gray100, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < weekSeconds.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weekSeconds[i].toDouble(),
                    color: i == 6 ? AppColors.accent : AppColors.gray200,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxVal == 0 ? 3600 : maxVal.toDouble() * 1.3,
                      color: AppColors.gray50,
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
