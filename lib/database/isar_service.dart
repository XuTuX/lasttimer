import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/database/exam_db.dart';

class IsarService extends GetxService {
  late Isar isar;

  static const String _sampleCreatedKey = 'sample_subjects_created';

  Future<IsarService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      SubjectDbSchema,
      ExamDbSchema,
    ], directory: dir.path);

    // 샘플 과목 생성 (최초 1회)
    await _createSampleSubjectsIfNeeded();

    return this;
  }

  /// 앱 최초 실행 시 샘플 과목 자동 생성
  Future<void> _createSampleSubjectsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyCreated = prefs.getBool(_sampleCreatedKey) ?? false;

    if (alreadyCreated) return;

    // SubjectDb가 비어있을 때만 생성
    final count = await isar.subjectDbs.count();
    if (count > 0) {
      await prefs.setBool(_sampleCreatedKey, true);
      return;
    }

    // 샘플 과목 3개 생성: 국어, 수학, 영어 (모의고사 타입)
    final now = DateTime.now();
    final sampleSubjects = [
      SubjectDb()
        ..subjectName = '국어'
        ..type = SubjectType.mock
        ..mockTimeSeconds =
            80 *
            60 // 80분
        ..mockQuestionCount = 45
        ..createdAt = now
        ..updatedAt = now,
      SubjectDb()
        ..subjectName = '수학'
        ..type = SubjectType.mock
        ..mockTimeSeconds =
            100 *
            60 // 100분
        ..mockQuestionCount = 30
        ..createdAt = now
        ..updatedAt = now,
      SubjectDb()
        ..subjectName = '영어'
        ..type = SubjectType.mock
        ..mockTimeSeconds =
            70 *
            60 // 70분
        ..mockQuestionCount = 45
        ..createdAt = now
        ..updatedAt = now,
    ];

    await isar.writeTxn(() async {
      for (final subject in sampleSubjects) {
        await isar.subjectDbs.put(subject);
      }
    });

    await prefs.setBool(_sampleCreatedKey, true);
  }

  void close() {
    isar.close();
  }
}
