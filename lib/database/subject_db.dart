import 'package:isar/isar.dart';

part 'subject_db.g.dart';

@collection
class SubjectDb {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String subjectName;

  late DateTime createdAt;

  late DateTime updatedAt;
}
