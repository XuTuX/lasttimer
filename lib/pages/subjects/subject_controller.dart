import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/database/subject_db.dart';

class SubjectController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  final subjects = <SubjectDb>[].obs;
  final selectedSubjectId = RxnInt();

  /// 현재 선택된 탭 (0: 모의고사, 1: 일반공부)
  final selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSubjects();
    _watchSubjects();
  }

  /// 모의고사 과목 목록
  List<SubjectDb> get mockSubjects => subjects.where((s) => s.isMock).toList();

  /// 일반공부 과목 목록
  List<SubjectDb> get practiceSubjects =>
      subjects.where((s) => s.isPractice).toList();

  /// 현재 선택된 탭의 과목 목록
  List<SubjectDb> get currentSubjects =>
      selectedTabIndex.value == 0 ? mockSubjects : practiceSubjects;

  void _loadSubjects() async {
    subjects.value = await _isarService.isar.subjectDbs.where().findAll();
  }

  void _watchSubjects() {
    final stream = _isarService.isar.subjectDbs.where().watch(
      fireImmediately: true,
    );
    stream.listen((event) {
      subjects.value = event;
    });
  }

  /// 일반공부 과목 추가
  Future<void> addPracticeSubject(String name) async {
    if (name.trim().isEmpty) return;

    final existing = await _isarService.isar.subjectDbs
        .where()
        .filter()
        .subjectNameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (existing != null) {
      Get.snackbar('오류', '이미 존재하는 과목입니다');
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

  /// 모의고사 과목 추가
  Future<void> addMockSubject({
    required String name,
    required int timeSeconds,
    required int questionCount,
  }) async {
    if (name.trim().isEmpty) return;

    final existing = await _isarService.isar.subjectDbs
        .where()
        .filter()
        .subjectNameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (existing != null) {
      Get.snackbar('오류', '이미 존재하는 과목입니다');
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

  /// 기존 addSubject 호환용 (일반공부로 추가)
  Future<void> addSubject(String name) async {
    return addPracticeSubject(name);
  }

  Future<void> renameSubject(int id, String newName) async {
    if (newName.trim().isEmpty) return;

    final subject = await _isarService.isar.subjectDbs.get(id);
    if (subject != null) {
      final existing = await _isarService.isar.subjectDbs
          .where()
          .filter()
          .subjectNameEqualTo(newName, caseSensitive: false)
          .findFirst();

      if (existing != null && existing.id != id) {
        Get.snackbar('오류', '이미 존재하는 과목명입니다');
        return;
      }

      subject.subjectName = newName;
      subject.updatedAt = DateTime.now();
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.subjectDbs.put(subject);
      });
    }
  }

  /// 모의고사 설정 수정
  Future<void> updateMockSettings({
    required int id,
    int? timeSeconds,
    int? questionCount,
  }) async {
    final subject = await _isarService.isar.subjectDbs.get(id);
    if (subject != null && subject.isMock) {
      if (timeSeconds != null) subject.mockTimeSeconds = timeSeconds;
      if (questionCount != null) subject.mockQuestionCount = questionCount;
      subject.updatedAt = DateTime.now();

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.subjectDbs.put(subject);
      });
    }
  }

  Future<void> deleteSubject(int id, {bool deleteExams = true}) async {
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.subjectDbs.delete(id);
      if (deleteExams) {
        await _isarService.isar.examDbs
            .filter()
            .subjectIdEqualTo(id)
            .deleteAll();
      }
    });
  }

  void selectSubject(int? id) {
    selectedSubjectId.value = id;
  }

  /// 특정 과목 가져오기
  SubjectDb? getSubject(int id) {
    return subjects.firstWhereOrNull((s) => s.id == id);
  }

  /// 현재 선택된 과목 가져오기
  SubjectDb? get selectedSubject {
    final id = selectedSubjectId.value;
    if (id == null) return null;
    return getSubject(id);
  }
}
