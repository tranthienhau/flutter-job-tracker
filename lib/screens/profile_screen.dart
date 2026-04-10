import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final jobState = ref.watch(jobProvider);
    final stats = jobState.stats;

    final displayName = authState.user?.name ?? 'Tradesperson';
    final displayTrade = authState.user?.trade ?? 'General Maintenance';
    final email = authState.user?.email;
    final completionRate = stats.totalJobs > 0
        ? (stats.completedJobs / stats.totalJobs * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Avatar section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayTrade,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF666666)),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF999999)),
                  ),
                ],
              ],
            ),
          ),

          // Stats summary
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
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                      value: '${stats.totalJobs}', label: 'Total Jobs'),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE8E8E8)),
                Expanded(
                  child: _StatItem(
                      value: '${stats.completedJobs}', label: 'Completed'),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFE8E8E8)),
                Expanded(
                  child: _StatItem(
                    value: '$completionRate%',
                    label: 'Rate',
                    valueColor: const Color(0xFF28A745),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
              children: const [
                _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications'),
                _MenuItem(
                  icon: Icons.cloud_off_outlined,
                  label: 'Offline Mode',
                  subtitle: 'Data syncs when online',
                ),
                _MenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Data & Privacy'),
                _MenuItem(
                    icon: Icons.help_outline, label: 'Help & Support'),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'About',
                  subtitle: 'Version 1.0.0',
                  showBorder: false,
                ),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout,
                  size: 20, color: Color(0xFFDC3545)),
              label: const Text(
                'Log Out',
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF1E3A5F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style:
              const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool showBorder;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0)),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1E3A5F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 18, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }
}
