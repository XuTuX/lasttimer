import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/utils/stats.dart';

class SubjectDetailController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  // Arguments
  final int subjectId;
  SubjectDetailController(this.subjectId);

  final subject = Rxn<SubjectDb>();
  final exams = <ExamDb>[].obs;

  // 공통 Stats
  final totalExams = 0.obs;
  final avgTotalSeconds = 0.0.obs;
  final avgRecent7Seconds = 0.0.obs;
  final maxTotalSeconds = 0.0.obs;
  final minTotalSeconds = 0.0.obs;
  final avgLapSeconds = 0.0.obs;
  final lapStdDev = 0.0.obs;

  // 모의고사 전용 Stats
  final topSlowQuestions = <MapEntry<int, double>>[].obs; // 상위 10% 느린 문항
  final questionTrimmedMeans = <int, double>{}.obs; // 문항별 절사평균

  // 자율 학습 전용 Stats
  final totalStudySeconds = 0.obs; // 총 공부 시간
  final totalLapCount = 0.obs; // 총 문제 풀이 수

  @override
  void onInit() {
    super.onInit();
    _loadSubject();
    _watchExams();
  }

  bool get isMock => subject.value?.isMock ?? false;
  bool get isPractice => subject.value?.isPractice ?? true;

  Future<void> _loadSubject() async {
    subject.value = await _isarService.isar.subjectDbs.get(subjectId);
  }

  void _watchExams() {
    final stream = _isarService.isar.examDbs
        .filter()
        .subjectIdEqualTo(subjectId)
        .watch(fireImmediately: true);

    stream.listen((event) {
      // Sort by newest first
      event.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      exams.value = event;
      _calculateStats(event);
    });
  }

  void _calculateStats(List<ExamDb> data) {
    if (data.isEmpty) {
      _resetStats();
      return;
    }

    totalExams.value = data.length;

    // Total Seconds Stats
    final allTotals = data.map((e) => e.totalSeconds).toList();
    avgTotalSeconds.value = StatsUtils.calculateMean(allTotals);
    maxTotalSeconds.value = allTotals
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();
    minTotalSeconds.value = allTotals
        .reduce((curr, next) => curr < next ? curr : next)
        .toDouble();

    // Recent 7
    final recent7 = data.take(7).map((e) => e.totalSeconds).toList();
    avgRecent7Seconds.value = StatsUtils.calculateMean(recent7);

    // Lap Stats
    final allLaps = data.expand((e) => e.questionSeconds).toList();
    avgLapSeconds.value = StatsUtils.calculateMean(allLaps);
    final stdDev = StatsUtils.calculateStdDev(allLaps);
    lapStdDev.value = stdDev;

    // 타입별 계산
    if (subject.value?.isMock ?? false) {
      _calculateMockStats(data);
    } else {
      _calculatePracticeStats(data);
    }
  }

  /// 모의고사 전용 분석 지표 계산
  void _calculateMockStats(List<ExamDb> data) {
    // 문항별 시간 집계
    final questionSecondsList = data.map((e) => e.questionSeconds).toList();
    final aggregated = StatsUtils.aggregateQuestionTimes(questionSecondsList);

    // [디자인 판단을 위해 임시로 threshold를 0으로 설정하여 모든 문항이 표시되게 함]
    const double threshold = 0.0;

    // 상위 10% 오래 걸린 문항
    topSlowQuestions.value = StatsUtils.getTopSlowQuestions(
      aggregated,
      topPercent: 0.10,
      minThreshold: threshold,
    );

    // 문항별 절사 평균 (30%)
    questionTrimmedMeans.value = StatsUtils.getQuestionTrimmedMeans(
      aggregated,
      trimPercent: 0.30,
    );
  }

  /// 자율 학습 전용 분석 지표 계산
  void _calculatePracticeStats(List<ExamDb> data) {
    // 총 공부 시간
    totalStudySeconds.value = data.fold<int>(
      0,
      (sum, e) => sum + e.totalSeconds,
    );

    // 총 문제 풀이 수
    totalLapCount.value = data.fold<int>(0, (sum, e) => sum + e.questionCount);
  }

  void _resetStats() {
    totalExams.value = 0;
    avgTotalSeconds.value = 0;
    maxTotalSeconds.value = 0;
    minTotalSeconds.value = 0;
    avgRecent7Seconds.value = 0;
    avgLapSeconds.value = 0;
    lapStdDev.value = 0;
    topSlowQuestions.clear();
    questionTrimmedMeans.clear();
    totalStudySeconds.value = 0;
    totalLapCount.value = 0;
  }

  Future<void> deleteExam(int examId) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.delete(examId);
    });
  }
}
