import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:last_timer/database/exam_db.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/database/subject_db.dart';

class SubjectController extends GetxController {
  final IsarService _isarService = Get.find<IsarService>();

  final subjects = <SubjectDb>[].obs;
  final selectedSubjectId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _loadSubjects();
    _watchSubjects();
  }

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

  Future<void> addSubject(String name) async {
    if (name.trim().isEmpty) return;

    final existing = await _isarService.isar.subjectDbs
        .where()
        .filter()
        .subjectNameEqualTo(name, caseSensitive: false)
        .findFirst();

    if (existing != null) {
      Get.snackbar('Error', 'Subject already exists');
      return;
    }

    final newSubject = SubjectDb()
      ..subjectName = name
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.subjectDbs.put(newSubject);
    });
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
        Get.snackbar('Error', 'Subject name already taken');
        return;
      }

      subject.subjectName = newName;
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
}
