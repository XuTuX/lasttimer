import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/utils/stats.dart';

class SubjectDetailController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  // Arguments
  final int subjectId;
  SubjectDetailController(this.subjectId);

  final exams = <ExamDb>[].obs;

  // Stats
  final totalExams = 0.obs;
  final avgTotalSeconds = 0.0.obs;
  final avgRecent7Seconds = 0.0.obs;
  final maxTotalSeconds = 0.0.obs;
  final minTotalSeconds = 0.0.obs;
  final avgLapSeconds = 0.0.obs;
  final lapStdDev = 0.0.obs;
  final stuckQuestions = <String>[].obs; // Format: "Exam X - Q# (Time)"

  @override
  void onInit() {
    super.onInit();
    _watchExams();
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
      totalExams.value = 0;
      avgTotalSeconds.value = 0;
      maxTotalSeconds.value = 0;
      minTotalSeconds.value = 0;
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

    // Stuck Questions (> Mean + 2*StdDev)
    final threshold = avgLapSeconds.value + (2 * stdDev);
    final stuck = <String>[];

    // Check all exams for stuck questions
    for (var i = 0; i < data.length; i++) {
      final exam = data[i];
      for (var q = 0; q < exam.questionSeconds.length; q++) {
        if (exam.questionSeconds[q] > threshold && threshold > 0) {
          stuck.add("${exam.title} - Q${q + 1} (${exam.questionSeconds[q]}s)");
        }
      }
    }
    stuckQuestions.value = stuck.take(5).toList(); // Top 5 recent stuck
  }

  Future<void> deleteExam(int examId) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.delete(examId);
    });
  }
}
