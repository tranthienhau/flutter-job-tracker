import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

const _priorityOrder = {
  JobPriority.urgent: 0,
  JobPriority.high: 1,
  JobPriority.medium: 2,
  JobPriority.low: 3,
};

class _FilterOption {
  final String label;
  final String value;
  const _FilterOption(this.label, this.value);
}

const _filters = [
  _FilterOption('All', 'all'),
  _FilterOption('Active', 'inProgress'),
  _FilterOption('Pending', 'pending'),
  _FilterOption('Done', 'completed'),
  _FilterOption('Cancelled', 'cancelled'),
];

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobProvider);
    final jobs = _filter == 'all'
        ? jobState.jobs
        : jobState.jobs
            .where((j) => j.status.name == _filter)
            .toList();

    final sortedJobs = List<Job>.from(jobs)
      ..sort((a, b) =>
          (_priorityOrder[a.priority] ?? 3)
              .compareTo(_priorityOrder[b.priority] ?? 3));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Jobs'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: _filters.map((f) {
                final active = _filter == f.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Job list
          Expanded(
            child: sortedJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.work_outline,
                            size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'No jobs found',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: sortedJobs.length,
                    itemBuilder: (context, index) {
                      final job = sortedJobs[index];
                      return JobCard(
                        job: job,
                        onTap: () => context.push('/job/${job.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create'),
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
