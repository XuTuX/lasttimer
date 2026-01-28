import 'package:flutter/material.dart';
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
      Get.snackbar(
        '저장 완료',
        '메모가 저장되었습니다.',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '저장 실패',
        '다시 시도해 주세요.',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
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
    Get.snackbar(
      '삭제 완료',
      '기록이 삭제되었습니다.',
      backgroundColor: const Color(0xFF424242),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
