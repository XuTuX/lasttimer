import 'dart:async';
import 'package:get/get.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';

class TimerController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();
  final SubjectController _subjectController = Get.find<SubjectController>();

  final timerElapsedSeconds = 0.obs;
  final isTimerRunning = false.obs;
  final laps = <int>[].obs;
  final isSaving = false.obs;

  Timer? _timer;
  int _lastLapTotalSeconds = 0;
  DateTime? _startedAt;

  // Derived state for current lap time
  int get currentLapSeconds => timerElapsedSeconds.value - _lastLapTotalSeconds;

  void startTimer() {
    if (isTimerRunning.value) return;

    _startedAt ??= DateTime.now();
    isTimerRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerElapsedSeconds.value++;
    });
  }

  void stopTimer() {
    isTimerRunning.value = false;
    _timer?.cancel();
  }

  void resetTimer() {
    stopTimer();
    timerElapsedSeconds.value = 0;
    laps.clear();
    _lastLapTotalSeconds = 0;
    _startedAt = null;
  }

  void recordLap() {
    final lapTime = timerElapsedSeconds.value - _lastLapTotalSeconds;
    laps.add(lapTime);
    _lastLapTotalSeconds = timerElapsedSeconds.value;
  }

  Future<void> saveExam(String? titleInput) async {
    final subjectId = _subjectController.selectedSubjectId.value;
    if (subjectId == null) {
      Get.snackbar('오류', '과목이 선택되지 않았습니다.');
      return;
    }

    if (timerElapsedSeconds.value == 0) {
      Get.snackbar('경고', '기록된 시간이 없습니다.');
      return;
    }

    if (currentLapSeconds > 0) {
      recordLap();
    }

    isSaving.value = true;
    final now = DateTime.now();

    String title = titleInput?.trim() ?? "";
    if (title.isEmpty) {
      final dateStr = now.toString().substring(0, 10);
      title = "$dateStr 시험";
    }

    final newExam = ExamDb()
      ..subjectId = subjectId
      ..title = title
      ..totalSeconds = timerElapsedSeconds.value
      ..questionSeconds = List.from(laps)
      ..startedAt = _startedAt ?? now
      ..finishedAt = now
      ..createdAt = now;

    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.examDbs.put(newExam);
      });

      Get.back();
      Get.snackbar('성공', '시험 결과가 저장되었습니다.');
      resetTimer();
    } catch (e) {
      Get.snackbar('오류', '저장 실패: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
