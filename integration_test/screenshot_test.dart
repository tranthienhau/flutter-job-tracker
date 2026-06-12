import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_job_tracker/screens/dashboard_screen.dart';
import 'package:flutter_job_tracker/screens/jobs_screen.dart';
import 'package:flutter_job_tracker/screens/job_detail_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Widget wrap(Widget screen) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1E3A5F),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        ),
        home: screen,
      ),
    );
  }

  setUpAll(() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen('auth')) await Hive.openBox('auth');
    if (!Hive.isBoxOpen('jobs')) {
      final box = await Hive.openBox('jobs');
      // Ensure sample data is seeded fresh for clean screenshots.
      await box.delete('jobs_data');
    }
  });

  testWidgets('capture job tracker flow', (tester) async {
    // Dashboard with stats + active/urgent jobs (provider auto-seeds samples).
    await tester.pumpWidget(wrap(const DashboardScreen()));
    await tester.pumpAndSettle();
    await shoot(tester, '01-dashboard');

    // Jobs list with priority sorting + filter chips.
    await tester.pumpWidget(wrap(const JobsScreen()));
    await tester.pumpAndSettle();
    await shoot(tester, '02-jobs-list');

    // Job detail with client info, notes, status actions.
    await tester.pumpWidget(wrap(const JobDetailScreen(jobId: '1')));
    await tester.pumpAndSettle();
    await shoot(tester, '03-job-detail');
  });
}
