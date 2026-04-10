import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(jobProvider);
    final stats = jobState.stats;
    final activeJobs =
        jobState.jobs.where((j) => j.status == JobStatus.inProgress).toList();
    final urgentJobs = jobState.jobs
        .where(
            (j) => j.priority == JobPriority.urgent && j.status != JobStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Stats Row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: Row(
              children: [
                _StatCard(
                  count: stats.activeJobs,
                  label: 'Active',
                  bg: const Color(0xFFD1ECF1),
                  fg: const Color(0xFF0C5460),
                ),
                _StatCard(
                  count: stats.pendingJobs,
                  label: 'Pending',
                  bg: const Color(0xFFFFF3CD),
                  fg: const Color(0xFF856404),
                ),
                _StatCard(
                  count: stats.completedJobs,
                  label: 'Done',
                  bg: const Color(0xFFD4EDDA),
                  fg: const Color(0xFF155724),
                ),
                _StatCard(
                  count: stats.totalJobs,
                  label: 'Total',
                  bg: const Color(0xFFE8EAF6),
                  fg: const Color(0xFF1E3A5F),
                ),
              ],
            ),
          ),

          // New Job button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/create'),
              icon: const Icon(Icons.add_circle, size: 24),
              label: const Text(
                'New Job',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Urgent section
          if (urgentJobs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.warning, size: 18, color: Color(0xFFDC3545)),
                  SizedBox(width: 6),
                  Text(
                    'Urgent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC3545),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...urgentJobs.map((job) => JobCard(
                  job: job,
                  onTap: () => context.push('/job/${job.id}'),
                )),
          ],

          // Active jobs section
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Active Jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (activeJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No active jobs right now',
                  style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                ),
              ),
            )
          else
            ...activeJobs.map((job) => JobCard(
                  job: job,
                  onTap: () => context.push('/job/${job.id}'),
                )),

          // Offline banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4EDDA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.cloud_done_outlined,
                    size: 16, color: Color(0xFF155724)),
                SizedBox(width: 6),
                Text(
                  'All data saved locally - works offline',
                  style: TextStyle(fontSize: 13, color: Color(0xFF155724)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color bg;
  final Color fg;

  const _StatCard({
    required this.count,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
