import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/database/exam_db.dart';

class SubjectController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  final subjects = <SubjectDb>[].obs;
  final selectedTabIndex = 0.obs;
  final selectedSubjectId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _watchSubjects();
  }

  void _watchSubjects() {
    _isarService.isar.subjectDbs.where().watch(fireImmediately: true).listen((
      event,
    ) {
      subjects.value = event;
    });
  }

  List<SubjectDb> get mockSubjects =>
      subjects.where((s) => s.isMock).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<SubjectDb> get practiceSubjects =>
      subjects.where((s) => s.isPractice).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  SubjectDb? get selectedSubject =>
      subjects.firstWhereOrNull((s) => s.id == selectedSubjectId.value);

  void selectSubject(int id) {
    selectedSubjectId.value = id;
  }

  /// [이슈 1] 이름 중복 체크 (타입 내에서만)
  bool isNameDuplicate(String name, SubjectType type, {int? excludeId}) {
    return subjects.any(
      (s) =>
          s.type == type &&
          s.subjectName.toLowerCase() == name.toLowerCase() &&
          s.id != excludeId,
    );
  }

  /// 모의고사 과목 추가
  Future<void> addMockSubject({
    required String name,
    required int timeSeconds,
    required int questionCount,
  }) async {
    // [이슈 1] 중복 체크
    if (isNameDuplicate(name, SubjectType.mock)) {
      Get.snackbar('오류', '모의고사 탭에 이미 같은 이름의 과목이 있습니다.');
      return;
    }

    final newSubject = SubjectDb()
      ..subjectName = name
      ..type = SubjectType.mock
      ..mockTimeSeconds = timeSeconds
      ..mockQuestionCount = questionCount
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.subjectDbs.put(newSubject);
    });
  }

  /// 자율 학습 과목 추가
  Future<void> addPracticeSubject(String name) async {
    // [이슈 1] 중복 체크
    if (isNameDuplicate(name, SubjectType.practice)) {
      Get.snackbar('오류', '자율 학습 탭에 이미 같은 이름의 과목이 있습니다.');
      return;
    }

    final newSubject = SubjectDb()
      ..subjectName = name
      ..type = SubjectType.practice
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.subjectDbs.put(newSubject);
    });
  }

  /// 이름 변경
  Future<void> renameSubject(int id, String newName) async {
    final subject = await _isarService.isar.subjectDbs.get(id);
    if (subject == null) return;

    // [이슈 1] 중복 체크 (자신 제외)
    if (isNameDuplicate(newName, subject.type, excludeId: id)) {
      Get.snackbar('오류', '해당 타입에 이미 같은 이름의 과목이 있습니다.');
      return;
    }

    await _isarService.isar.writeTxn(() async {
      subject.subjectName = newName;
      subject.updatedAt = DateTime.now();
      await _isarService.isar.subjectDbs.put(subject);
    });
  }

  /// 모의고사 설정 수정
  Future<void> updateMockSettings({
    required int id,
    required int timeSeconds,
    required int questionCount,
  }) async {
    final subject = await _isarService.isar.subjectDbs.get(id);
    if (subject == null || !subject.isMock) return;

    await _isarService.isar.writeTxn(() async {
      subject.mockTimeSeconds = timeSeconds;
      subject.mockQuestionCount = questionCount;
      subject.updatedAt = DateTime.now();
      await _isarService.isar.subjectDbs.put(subject);
    });
  }

  Future<void> deleteSubject(int id) async {
    await _isarService.isar.writeTxn(() async {
      // 과목 삭제
      await _isarService.isar.subjectDbs.delete(id);
      // 관련 시험 기록도 삭제 (연관 관계가 명시적이지 않으므로 쿼리로 삭제)
      await _isarService.isar.examDbs.filter().subjectIdEqualTo(id).deleteAll();
    });
  }
}
