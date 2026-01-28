import 'package:isar/isar.dart';

part 'subject_db.g.dart';

/// 과목 타입
enum SubjectType {
  practice, // 일반공부 (스톱워치)
  mock, // 모의고사 (카운트다운)
}

@collection
class SubjectDb {
  Id id = Isar.autoIncrement;

  /// 과목명 - 단독 unique 제거, 복합 인덱스로 변경
  late String subjectName;

  /// 과목 타입: 0 = practice (일반공부), 1 = mock (모의고사)
  @enumerated
  SubjectType type = SubjectType.practice;

  /// 복합 인덱스: type + subjectName 조합으로 unique
  @Index(unique: true, composite: [CompositeIndex('subjectName')])
  int get typeIndex => type.index;

  /// 모의고사 전용: 총 시간 (초)
  int? mockTimeSeconds;

  /// 모의고사 전용: 문항 수
  int? mockQuestionCount;

  late DateTime createdAt;

  late DateTime updatedAt;

  /// 모의고사 타입인지 확인
  bool get isMock => type == SubjectType.mock;

  /// 일반공부 타입인지 확인
  bool get isPractice => type == SubjectType.practice;
}
