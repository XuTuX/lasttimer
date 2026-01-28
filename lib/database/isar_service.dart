import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:last_timer/database/subject_db.dart';
import 'package:last_timer/database/exam_db.dart';

class IsarService extends GetxService {
  late Isar isar;

  Future<IsarService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      SubjectDbSchema,
      ExamDbSchema,
    ], directory: dir.path);
    return this;
  }

  void close() {
    isar.close();
  }
}
