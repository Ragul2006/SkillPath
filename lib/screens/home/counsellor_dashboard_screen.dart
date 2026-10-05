import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Counsellor dashboard with bottom navigation
class CounsellorDashboardScreen extends ConsumerStatefulWidget {
  const CounsellorDashboardScreen({super.key});

  @override
  ConsumerState<CounsellorDashboardScreen> createState() =>
      _CounsellorDashboardScreenState();
}

class _CounsellorDashboardScreenState
    extends ConsumerState<CounsellorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(name: authState.name ?? 'Counsellor'),
          const _RequestsTab(),
          const _ClientsTab(),
          _CounsellorProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final String name;
  const _DashboardTab({required this.name});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Hello, $name', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Counsellor Dashboard',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Stat cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: '3',
                    color: AppColors.warning,
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'In Progress',
                    value: '2',
                    color: AppColors.info,
                    icon: Icons.hourglass_top_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Resolved',
                    value: '8',
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Recent Requests', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),

            _EscalationTile(
              name: 'Ravi Kumar',
              concern: 'Job Security — CNC Operator',
              district: 'Salem',
              priority: 'High',
              status: 'Pending',
            ),
            _EscalationTile(
              name: 'Lakshmi Devi',
              concern: 'Salary — Electrician',
              district: 'Coimbatore',
              priority: 'Medium',
              status: 'In Progress',
            ),
            _EscalationTile(
              name: 'Anitha M',
              concern: 'Career Growth — Solar Tech',
              district: 'Madurai',
              priority: 'Low',
              status: 'Pending',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EscalationTile extends StatelessWidget {
  final String name;
  final String concern;
  final String district;
  final String priority;
  final String status;

  const _EscalationTile({
    required this.name,
    required this.concern,
    required this.district,
    required this.priority,
    required this.status,
  });

  Color get _priorityColor {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.titleSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: AppTextStyles.labelSmall.copyWith(color: _priorityColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(concern, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text(
            '$district • $status',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escalation Requests', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage assigned counselling requests',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Requests will appear here from Supabase',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientsTab extends StatelessWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clients', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'View assigned learner and family profiles',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounsellorProfileTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primarySurface,
              child: Text(
                (authState.name ?? 'C')[0].toUpperCase(),
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(authState.name ?? 'Counsellor', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text('Sign Out', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
