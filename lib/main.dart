import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:last_timer/database/isar_service.dart';
import 'package:last_timer/layouts/adaptive_scaffold.dart';
import 'package:last_timer/layouts/ipad/ipad_main_layout.dart';
import 'package:last_timer/layouts/ipad/ipad_timer_layout.dart';
import 'package:last_timer/pages/record_detail/record_detail_page.dart';
import 'package:last_timer/pages/subject_detail/memos_page.dart';
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
        // Main (Subject List) - iPad uses 2-column layout
        GetPage(
          name: Routes.subjectList,
          page: () => AdaptiveLayoutBuilder(
            phoneBuilder: (_) => const SubjectListPage(),
            tabletBuilder: (_) => const IPadMainLayout(),
          ),
        ),
        // Subject Detail - iPad embeds in main layout, phone uses separate page
        GetPage(
          name: Routes.subjectDetail,
          page: () => const SubjectDetailPage(),
        ),
        // Timer - iPad uses larger layout with lap panel
        GetPage(
          name: Routes.timer,
          page: () => AdaptiveLayoutBuilder(
            phoneBuilder: (_) => const TimerPage(),
            tabletBuilder: (_) => const IPadTimerLayout(),
          ),
        ),
        // Record Detail - same for both (modal-like detail view)
        GetPage(
          name: Routes.recordDetail,
          page: () => const RecordDetailPage(),
        ),
        // Memos
        GetPage(name: Routes.memos, page: () => const MemosPage()),
      ],
    );
  }
}
