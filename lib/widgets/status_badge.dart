import 'package:flutter/material.dart';
import '../models/job.dart';

class StatusBadge extends StatelessWidget {
  final JobStatus status;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status]!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: config.text,
        ),
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color bg;
  final Color text;

  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.text,
  });
}

const _statusConfig = {
  JobStatus.pending: _StatusStyle(
    label: 'Pending',
    bg: Color(0xFFFFF3CD),
    text: Color(0xFF856404),
  ),
  JobStatus.inProgress: _StatusStyle(
    label: 'In Progress',
    bg: Color(0xFFD1ECF1),
    text: Color(0xFF0C5460),
  ),
  JobStatus.completed: _StatusStyle(
    label: 'Completed',
    bg: Color(0xFFD4EDDA),
    text: Color(0xFF155724),
  ),
  JobStatus.cancelled: _StatusStyle(
    label: 'Cancelled',
    bg: Color(0xFFF8D7DA),
    text: Color(0xFF721C24),
  ),
};
