import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/pages/record_detail/record_detail_page.dart';
import 'package:last_timer/pages/subject_detail/subject_detail_page.dart';
import 'package:last_timer/pages/subjects/subject_controller.dart';
import 'package:last_timer/pages/subjects/subject_list_page.dart';
import 'package:last_timer/pages/timer/timer_page.dart';
import 'package:last_timer/routes/app_routes.dart';
import 'package:last_timer/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Services
  await Get.putAsync(() => IsarService().init());

  // Logic Controllers that should be global or available early
  Get.put(SubjectController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Momentum',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.subjectList,
      getPages: [
        GetPage(name: Routes.subjectList, page: () => const SubjectListPage()),
        GetPage(
          name: Routes.subjectDetail,
          page: () => const SubjectDetailPage(),
        ),
        GetPage(name: Routes.timer, page: () => const TimerPage()),
        GetPage(
          name: Routes.recordDetail,
          page: () => const RecordDetailPage(),
        ),
      ],
    );
  }
}
