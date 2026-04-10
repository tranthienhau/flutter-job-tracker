import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';

class _PriorityOption {
  final String label;
  final JobPriority value;
  final Color color;
  const _PriorityOption(this.label, this.value, this.color);
}

const _priorities = [
  _PriorityOption('Low', JobPriority.low, Color(0xFF6C757D)),
  _PriorityOption('Medium', JobPriority.medium, Color(0xFFFFC107)),
  _PriorityOption('High', JobPriority.high, Color(0xFFFD7E14)),
  _PriorityOption('Urgent', JobPriority.urgent, Color(0xFFDC3545)),
];

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientController = TextEditingController();
  final _addressController = TextEditingController();
  JobPriority _priority = JobPriority.medium;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final client = _clientController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job title is required')),
      );
      return;
    }
    if (client.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client name is required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(jobProvider.notifier).addJob(
            title: title,
            description: _descriptionController.text.trim(),
            clientName: client,
            address: _addressController.text.trim(),
            priority: _priority,
          );
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save job')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('New Job'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _FieldLabel('Job Title *'),
            _buildTextField(
              controller: _titleController,
              placeholder: 'e.g. Kitchen cabinet repair',
            ),
            const SizedBox(height: 18),

            // Description
            _FieldLabel('Description'),
            _buildTextField(
              controller: _descriptionController,
              placeholder: 'Describe the work needed...',
              maxLines: 4,
              height: 100,
            ),
            const SizedBox(height: 18),

            // Client
            _FieldLabel('Client Name *'),
            _buildTextField(
              controller: _clientController,
              placeholder: "Client's full name",
            ),
            const SizedBox(height: 18),

            // Address
            _FieldLabel('Address'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.location_on_outlined,
                        size: 20, color: Color(0xFF888888)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Job site address',
                        hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Priority
            _FieldLabel('Priority'),
            Row(
              children: _priorities.map((p) {
                final selected = _priority == p.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? p.color
                              : const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _handleSave,
                icon:
                    const Icon(Icons.check_circle, size: 22, color: Colors.white),
                label: Text(
                  _saving ? 'Saving...' : 'Create Job',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor:
                      const Color(0xFF1E3A5F).withAlpha(153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    double? height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF333333),
        ),
      ),
    );
  }
}
