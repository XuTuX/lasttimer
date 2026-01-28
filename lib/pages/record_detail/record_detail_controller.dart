import 'package:get/get.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';

class RecordDetailController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  final int examId;
  RecordDetailController(this.examId);

  final exam = Rxn<ExamDb>();
  final memo = ''.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExam();
  }

  Future<void> _loadExam() async {
    final loaded = await _isarService.isar.examDbs.get(examId);
    if (loaded != null) {
      exam.value = loaded;
      memo.value = loaded.memo ?? '';
    }
  }

  /// 메모 저장
  Future<void> saveMemo(String newMemo) async {
    final currentExam = exam.value;
    if (currentExam == null) return;

    isSaving.value = true;
    try {
      currentExam.memo = newMemo.trim().isEmpty ? null : newMemo.trim();
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.examDbs.put(currentExam);
      });
      memo.value = newMemo;
      Get.snackbar('저장됨', '메모가 저장되었습니다.');
    } catch (e) {
      Get.snackbar('오류', '메모 저장 실패: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// 기록 삭제
  Future<void> deleteExam() async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.examDbs.delete(examId);
    });
    Get.back();
    Get.snackbar('삭제됨', '기록이 삭제되었습니다.');
  }
}
