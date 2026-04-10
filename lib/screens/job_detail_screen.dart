import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/status_badge.dart';

const _priorityColors = {
  JobPriority.low: Color(0xFF6C757D),
  JobPriority.medium: Color(0xFFFFC107),
  JobPriority.high: Color(0xFFFD7E14),
  JobPriority.urgent: Color(0xFFDC3545),
};

class _StatusAction {
  final String label;
  final JobStatus value;
  final IconData icon;
  const _StatusAction(this.label, this.value, this.icon);
}

const _statusActions = [
  _StatusAction('Start Work', JobStatus.inProgress, Icons.play_circle_outline),
  _StatusAction('Complete', JobStatus.completed, Icons.check_circle_outline),
  _StatusAction('Set Pending', JobStatus.pending, Icons.access_time),
  _StatusAction('Cancel', JobStatus.cancelled, Icons.cancel_outlined),
];

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final _noteController = TextEditingController();
  bool _showStatusMenu = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleAddNote(String jobId) async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await ref.read(jobProvider.notifier).addNote(jobId, text);
    _noteController.clear();
  }

  Future<void> _handleAddPhoto(String jobId) async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result != null) {
      await ref.read(jobProvider.notifier).addPhoto(jobId, result.path);
    }
  }

  Future<void> _handleTakePhoto(String jobId) async {
    final result = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (result != null) {
      await ref.read(jobProvider.notifier).addPhoto(jobId, result.path);
    }
  }

  void _handleDeleteJob(String jobId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(jobProvider.notifier).deleteJob(jobId);
              if (mounted) context.pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFDC3545))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobProvider);
    final job = jobState.jobs
        .cast<Job?>()
        .firstWhere((j) => j?.id == widget.jobId, orElse: () => null);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Job Details'),
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 48, color: Color(0xFFCCCCCC)),
              SizedBox(height: 12),
              Text('Job not found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _priorityColors[job.priority],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: job.status),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description
          if (job.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                job.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ),

          // Client info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  text: job.clientName,
                  color: const Color(0xFF1E3A5F),
                ),
                if (job.address.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: job.address,
                    color: const Color(0xFF1E3A5F),
                  ),
                ],
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.flag_outlined,
                  text:
                      '${job.priority.name[0].toUpperCase()}${job.priority.name.substring(1)} Priority',
                  color: _priorityColors[job.priority]!,
                ),
              ],
            ),
          ),

          // Status actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _showStatusMenu = !_showStatusMenu),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      Icon(
                        _showStatusMenu
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ],
                  ),
                ),
                if (_showStatusMenu) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _statusActions
                        .where((a) => a.value != job.status)
                        .map((action) => GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(jobProvider.notifier)
                                    .updateStatus(job.id, action.value);
                                setState(() => _showStatusMenu = false);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFE0E0E0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(action.icon,
                                        size: 20,
                                        color: const Color(0xFF1E3A5F)),
                                    const SizedBox(width: 6),
                                    Text(
                                      action.label,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // Notes section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes (${job.notes.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 12),
                // Note input
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 80),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: TextField(
                          controller: _noteController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Add a note...',
                            hintStyle:
                                TextStyle(color: Color(0xFFAAAAAA)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF333333)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _handleAddNote(job.id),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.send,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...job.notes.map((note) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                              color: Color(0xFF1E3A5F), width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormat.format(note.createdAt),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999)),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(jobProvider.notifier)
                                    .deleteNote(job.id, note.id),
                                child: const Icon(Icons.delete_outline,
                                    size: 16,
                                    color: Color(0xFFDC3545)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Photos section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photos (${job.photos.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PhotoButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Take Photo',
                      onTap: () => _handleTakePhoto(job.id),
                    ),
                    const SizedBox(width: 12),
                    _PhotoButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => _handleAddPhoto(job.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (job.photos.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.photos
                        .map((photo) => _PhotoTile(
                              photo: photo,
                              onDelete: () => ref
                                  .read(jobProvider.notifier)
                                  .deletePhoto(job.id, photo.id),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),

          // Delete button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => _handleDeleteJob(job.id),
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Color(0xFFDC3545)),
              label: const Text(
                'Delete Job',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC3545),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFF8D7DA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: color),
          ),
        ),
      ],
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final JobPhoto photo;
  final VoidCallback onDelete;

  const _PhotoTile({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileSize = (screenWidth - 32 - 16) / 3;

    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(photo.uri),
              width: tileSize,
              height: tileSize,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8E8E8),
                child: const Icon(Icons.broken_image,
                    color: Color(0xFF999999)),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.cancel,
                  size: 22, color: Color(0xFFDC3545)),
            ),
          ),
        ],
      ),
    );
  }
}
