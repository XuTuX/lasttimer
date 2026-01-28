import 'dart:async';
import 'package:get/get.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';

class TimerController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();
  final SubjectController _subjectController = Get.find<SubjectController>();

  // 타이머 상태
  final timerElapsedSeconds = 0.obs;
  final isTimerRunning = false.obs;
  final laps = <int>[].obs;
  final isSaving = false.obs;

  // 타이머 완료 (모의고사 카운트다운 종료 또는 문항 완료)
  final isTimerFinished = false.obs;

  // [이슈 6] 조기 종료 사유
  final finishReason = ''.obs;

  Timer? _timer;
  int _lastLapTotalSeconds = 0;
  DateTime? _startedAt;

  // 현재 랩 시간
  int get currentLapSeconds => timerElapsedSeconds.value - _lastLapTotalSeconds;

  /// 현재 선택된 과목
  SubjectDb? get selectedSubject => _subjectController.selectedSubject;

  /// 모의고사 모드인지
  bool get isMockMode => selectedSubject?.isMock ?? false;

  /// 모의고사 총 시간 (초)
  int get mockTotalSeconds => selectedSubject?.mockTimeSeconds ?? 0;

  /// 모의고사 문항 수
  int get mockQuestionCount => selectedSubject?.mockQuestionCount ?? 0;

  /// 모의고사 남은 시간 (카운트다운)
  int get remainingSeconds {
    if (!isMockMode) return 0;
    return (mockTotalSeconds - timerElapsedSeconds.value).clamp(
      0,
      mockTotalSeconds,
    );
  }

  /// 현재 문항 번호 (1부터 시작)
  int get currentQuestionNumber => laps.length + 1;

  /// 완료된 문항 수
  int get completedQuestions => laps.length;

  void startTimer() {
    if (isTimerRunning.value) return;
    if (isTimerFinished.value) return;

    _startedAt ??= DateTime.now();
    isTimerRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerElapsedSeconds.value++;

      // 모의고사 카운트다운 체크
      if (isMockMode && timerElapsedSeconds.value >= mockTotalSeconds) {
        _onMockTimeUp();
      }
    });
  }

  void stopTimer() {
    isTimerRunning.value = false;
    _timer?.cancel();
  }

  /// 모의고사 시간 종료 시 호출
  void _onMockTimeUp() {
    stopTimer();
    isTimerFinished.value = true;
    finishReason.value = '시간 종료';

    // 현재 진행 중인 문항 기록
    if (currentLapSeconds > 0) {
      recordLap();
    }

    // [수정] 남은 문항들을 0초로 기록하여 분석에 포함
    final remainingCount = mockQuestionCount - laps.length;
    if (remainingCount > 0) {
      for (int i = 0; i < remainingCount; i++) {
        laps.add(0);
      }
    }
  }

  /// [이슈 6] 모의고사 문항 완료 시 호출
  void _onMockQuestionsComplete() {
    stopTimer();
    isTimerFinished.value = true;
    finishReason.value = '전체 문항 완료';
  }

  /// [이슈 6] 조기 종료 (사용자 선택)
  void finishEarly() {
    if (currentLapSeconds > 0) {
      recordLap();
    }
    stopTimer();
    isTimerFinished.value = true;
    if (isMockMode) {
      finishReason.value = '조기 종료 ($completedQuestions문항)';
    } else {
      finishReason.value = '공부 완료 ($completedQuestions문항)';
    }
  }

  void resetTimer() {
    stopTimer();
    timerElapsedSeconds.value = 0;
    laps.clear();
    _lastLapTotalSeconds = 0;
    _startedAt = null;
    isTimerFinished.value = false;
    finishReason.value = '';
  }

  void recordLap() {
    final lapTime = timerElapsedSeconds.value - _lastLapTotalSeconds;
    if (lapTime > 0) {
      laps.add(lapTime);
      _lastLapTotalSeconds = timerElapsedSeconds.value;

      // [이슈 6] 모의고사 문항 완료 체크
      if (isMockMode &&
          mockQuestionCount > 0 &&
          laps.length >= mockQuestionCount) {
        _onMockQuestionsComplete();
      }
    }
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

    // [수정] 모의고사인 경우 남은 문항들을 0초로 채움
    if (isMockMode) {
      final remainingCount = mockQuestionCount - laps.length;
      if (remainingCount > 0) {
        for (int i = 0; i < remainingCount; i++) {
          laps.add(0);
        }
      }
    }

    isSaving.value = true;
    final now = DateTime.now();

    String title = titleInput?.trim() ?? "";
    if (title.isEmpty) {
      final dateStr = now.toString().substring(0, 10);
      title = "$dateStr ${isMockMode ? '모의고사' : '공부'}";
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
      resetTimer();
    } catch (e) {
      // Error handling without snackbar
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
