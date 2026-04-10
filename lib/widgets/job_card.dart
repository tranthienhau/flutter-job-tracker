import 'package:flutter/material.dart';
import '../models/job.dart';
import 'status_badge.dart';

const _priorityColors = {
  JobPriority.low: Color(0xFF6C757D),
  JobPriority.medium: Color(0xFFFFC107),
  JobPriority.high: Color(0xFFFD7E14),
  JobPriority.urgent: Color(0xFFDC3545),
};

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _priorityColors[job.priority],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: job.status, small: true),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Footer - client & address
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: Color(0xFF6C757D)),
                  const SizedBox(width: 6),
                  Text(
                    job.clientName,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6C757D)),
                  ),
                ],
              ),
              if (job.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF6C757D)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF6C757D)),
                      ),
                    ),
                  ],
                ),
              ],

              // Meta (notes/photos count)
              if (job.notes.isNotEmpty || job.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFF0F0F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (job.notes.isNotEmpty) ...[
                        const Icon(Icons.description_outlined,
                            size: 12, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(
                          '${job.notes.length}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (job.photos.isNotEmpty) ...[
                        const Icon(Icons.camera_alt_outlined,
                            size: 12, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text(
                          '${job.photos.length}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF888888)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
