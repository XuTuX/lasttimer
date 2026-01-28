import 'package:isar/isar.dart';

part 'exam_db.g.dart';

@collection
class ExamDb {
  Id id = Isar.autoIncrement;

  @Index()
  late int subjectId;

  late String title;

  late int totalSeconds;

  List<int> questionSeconds = [];

  int get questionCount => questionSeconds.length;

  late DateTime startedAt;

  @Index()
  late DateTime finishedAt;

  late DateTime createdAt;

  /// 메모 필드 (선택)
  String? memo;
}
