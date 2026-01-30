import 'package:get/get.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';

class RecordDetailController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  final int examId;
  RecordDetailController(this.examId);

  final exam = Rxn<ExamDb>();
  final memos = <String>[].obs;
  final isSaving = false.obs;
  final saveSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExam();
  }

  Future<void> _loadExam() async {
    final loaded = await _isarService.isar.examDbs.get(examId);
    if (loaded != null) {
      exam.value = loaded;
      memos.value = List<String>.from(loaded.memos);
    }
  }

  /// 메모 추가
  Future<void> addMemo(String text) async {
    final currentExam = exam.value;
    if (currentExam == null || text.trim().isEmpty) return;

    isSaving.value = true;
    try {
      final newMemo = text.trim();
      currentExam.memos.add(newMemo);

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.examDbs.put(currentExam);
      });

      memos.value = List<String>.from(currentExam.memos);

      // 저장 성공 시각적 피드백
      saveSuccess.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        saveSuccess.value = false;
      });
    } finally {
      isSaving.value = false;
    }
  }

  /// 메모 삭제 (필요시)
  Future<void> deleteMemo(int index) async {
    final currentExam = exam.value;
    if (currentExam == null) return;

    currentExam.memos.removeAt(index);
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.put(currentExam);
    });
    memos.value = List<String>.from(currentExam.memos);
  }

  /// 기록 이름 변경
  Future<void> renameExam(String newTitle) async {
    final currentExam = exam.value;
    if (currentExam == null) return;

    currentExam.title = newTitle.trim();
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.put(currentExam);
    });
    exam.value = currentExam;
    exam.refresh(); // UI 갱신 강제
  }

  /// 기록 삭제
  Future<void> deleteExam() async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.delete(examId);
    });
    Get.back();
  }
}
