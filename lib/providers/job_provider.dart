import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/job.dart';

const _storageKey = 'jobs_data';
const _uuid = Uuid();

class JobState {
  final List<Job> jobs;
  final bool isLoading;

  JobState({this.jobs = const [], this.isLoading = true});

  JobState copyWith({List<Job>? jobs, bool? isLoading}) {
    return JobState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  DashboardStats get stats => DashboardStats(
        totalJobs: jobs.length,
        activeJobs: jobs.where((j) => j.status == JobStatus.inProgress).length,
        completedJobs:
            jobs.where((j) => j.status == JobStatus.completed).length,
        pendingJobs: jobs.where((j) => j.status == JobStatus.pending).length,
      );

  List<Job> getJobsByStatus(JobStatus status) {
    return jobs.where((j) => j.status == status).toList();
  }
}

class JobNotifier extends StateNotifier<JobState> {
  JobNotifier() : super(JobState()) {
    loadJobs();
  }

  Future<void> _persistJobs(List<Job> jobs) async {
    final box = Hive.box('jobs');
    final data = jobs.map((j) => j.toJson()).toList();
    await box.put(_storageKey, jsonEncode(data));
  }

  Future<void> loadJobs() async {
    try {
      final box = Hive.box('jobs');
      final stored = box.get(_storageKey);
      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored as String);
        final jobs = decoded
            .map((j) => Job.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        state = JobState(jobs: jobs, isLoading: false);
      } else {
        final sampleJobs = _createSampleJobs();
        await _persistJobs(sampleJobs);
        state = JobState(jobs: sampleJobs, isLoading: false);
      }
    } catch (_) {
      state = JobState(isLoading: false);
    }
  }

  Future<void> addJob({
    required String title,
    required String description,
    required String clientName,
    required String address,
    required JobPriority priority,
    JobStatus status = JobStatus.pending,
  }) async {
    final now = DateTime.now();
    final newJob = Job(
      id: _uuid.v4(),
      title: title,
      description: description,
      status: status,
      priority: priority,
      clientName: clientName,
      address: address,
      notes: [],
      photos: [],
      createdAt: now,
      updatedAt: now,
    );
    final updated = [...state.jobs, newJob];
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> updateJob(String id, {
    String? title,
    String? description,
    String? clientName,
    String? address,
    JobPriority? priority,
    JobStatus? status,
  }) async {
    final updated = state.jobs.map((j) {
      if (j.id == id) {
        return j.copyWith(
          title: title,
          description: description,
          clientName: clientName,
          address: address,
          priority: priority,
          status: status,
          updatedAt: DateTime.now(),
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> deleteJob(String id) async {
    final updated = state.jobs.where((j) => j.id != id).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> updateStatus(String id, JobStatus status) async {
    final now = DateTime.now();
    final updated = state.jobs.map((j) {
      if (j.id == id) {
        return j.copyWith(
          status: status,
          updatedAt: now,
          completedAt: status == JobStatus.completed ? now : j.completedAt,
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> addNote(String jobId, String text) async {
    final note = JobNote(
      id: _uuid.v4(),
      text: text,
      createdAt: DateTime.now(),
    );
    final updated = state.jobs.map((j) {
      if (j.id == jobId) {
        return j.copyWith(
          notes: [...j.notes, note],
          updatedAt: DateTime.now(),
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> deleteNote(String jobId, String noteId) async {
    final updated = state.jobs.map((j) {
      if (j.id == jobId) {
        return j.copyWith(
          notes: j.notes.where((n) => n.id != noteId).toList(),
          updatedAt: DateTime.now(),
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> addPhoto(String jobId, String uri, {String? caption}) async {
    final photo = JobPhoto(
      id: _uuid.v4(),
      uri: uri,
      caption: caption,
      createdAt: DateTime.now(),
    );
    final updated = state.jobs.map((j) {
      if (j.id == jobId) {
        return j.copyWith(
          photos: [...j.photos, photo],
          updatedAt: DateTime.now(),
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }

  Future<void> deletePhoto(String jobId, String photoId) async {
    final updated = state.jobs.map((j) {
      if (j.id == jobId) {
        return j.copyWith(
          photos: j.photos.where((p) => p.id != photoId).toList(),
          updatedAt: DateTime.now(),
        );
      }
      return j;
    }).toList();
    await _persistJobs(updated);
    state = state.copyWith(jobs: updated);
  }
}

List<Job> _createSampleJobs() {
  final now = DateTime.now();
  return [
    Job(
      id: '1',
      title: 'Kitchen Cabinet Repair',
      description:
          'Fix loose hinges and replace damaged shelf in upper cabinets. Client reports doors not closing properly.',
      status: JobStatus.inProgress,
      priority: JobPriority.high,
      clientName: 'Sarah Mitchell',
      address: '42 Oak Street, Unit 3B',
      notes: [
        JobNote(
          id: 'n1',
          text: 'Need 4x soft-close hinges, 1x shelf board 24"x12"',
          createdAt: now,
        ),
        JobNote(id: 'n2', text: 'Access code: 4521', createdAt: now),
      ],
      photos: [],
      createdAt: now,
      updatedAt: now,
    ),
    Job(
      id: '2',
      title: 'Bathroom Tile Replacement',
      description:
          'Replace cracked floor tiles near shower. Approximately 6 tiles affected. Grout color: light grey.',
      status: JobStatus.pending,
      priority: JobPriority.medium,
      clientName: 'David Chen',
      address: '118 Elm Avenue',
      notes: [
        JobNote(
          id: 'n3',
          text: 'Tile model: Porcelain 12x12 Mist Grey',
          createdAt: now,
        ),
      ],
      photos: [],
      createdAt: now,
      updatedAt: now,
    ),
    Job(
      id: '3',
      title: 'Exterior Door Weather Stripping',
      description:
          'Install new weather stripping on front and back doors. Current stripping is worn, causing drafts.',
      status: JobStatus.completed,
      priority: JobPriority.low,
      clientName: 'Maria Lopez',
      address: '87 Pine Road',
      notes: [],
      photos: [],
      createdAt: now,
      updatedAt: now,
      completedAt: now,
    ),
    Job(
      id: '4',
      title: 'Emergency Pipe Leak Fix',
      description:
          'Leaking pipe under kitchen sink. Water damage to cabinet floor. Need to fix pipe and assess damage.',
      status: JobStatus.inProgress,
      priority: JobPriority.urgent,
      clientName: 'Tom Bradley',
      address: '205 Maple Drive, Apt 12',
      notes: [
        JobNote(
          id: 'n4',
          text: 'Shut off valve is under the sink on the left',
          createdAt: now,
        ),
        JobNote(
          id: 'n5',
          text: 'Tenant available 8am-5pm weekdays',
          createdAt: now,
        ),
      ],
      photos: [],
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  return JobNotifier();
});
