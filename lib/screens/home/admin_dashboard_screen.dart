import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

/// Admin dashboard with complete analytics overview per Section 23
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _OverviewTab(),
          const _InsightsTab(),
          const _UsersTab(),
          const _EscalationsTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline_rounded),
            selectedIcon: Icon(Icons.lightbulb_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent_rounded),
            label: 'Escalations',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Admin Analytics', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'SkillPath Career Counselling Platform Insights',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            // Demo Data Disclaimer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.info),
                  const SizedBox(width: 6),
                  Text(
                    AppConstants.demoDataLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 23: Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.forum_rounded,
                    label: 'Total Sessions',
                    value: '1,480',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.psychology_rounded,
                    label: 'Avg AI Match',
                    value: '84%',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'Parent Sessions',
                    value: '890 (60%)',
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.school_rounded,
                    label: 'Learner Sessions',
                    value: '590 (40%)',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.translate_rounded,
                    label: 'Tamil Sessions',
                    value: '1,120 (76%)',
                    color: const Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.language_rounded,
                    label: 'English Sessions',
                    value: '360 (24%)',
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Active Escalations',
                    value: '12',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AdminStatCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Resolved Escalations',
                    value: '48',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Section 23: Top Parent Concerns Chart
            Text('Top Parent Concerns', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Distribution of primary parental hesitation categories',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            _ConcernBar(label: 'Income / Salary', percentage: 42, color: AppColors.error),
            _ConcernBar(label: 'Job Security', percentage: 28, color: AppColors.warning),
            _ConcernBar(label: 'Career Growth', percentage: 16, color: AppColors.info),
            _ConcernBar(label: 'Social Perception', percentage: 9, color: AppColors.secondary),
            _ConcernBar(label: 'Safety & Working Conditions', percentage: 5, color: const Color(0xFF8B5CF6)),

            const SizedBox(height: 28),

            // Section 23: Sentiment Before vs After Counselling
            Text('Sentiment Evolution', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Impact of evidence-based counselling on family confidence',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_toggle_off_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text('Before Counselling', style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SentimentBar(label: 'Anxious / Concerned', percentage: 62, color: AppColors.error),
                  _SentimentBar(label: 'Uncertain / Confused', percentage: 24, color: AppColors.warning),
                  _SentimentBar(label: 'Positive / Open', percentage: 14, color: AppColors.success),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('After Counselling', style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SentimentBar(label: 'Hopeful / Informed', percentage: 68, color: AppColors.success),
                  _SentimentBar(label: 'Positive / Confident', percentage: 22, color: AppColors.secondary),
                  _SentimentBar(label: 'Still Uncertain (Escalated)', percentage: 10, color: AppColors.info),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 23: Most Requested Trades
            Text('Most Requested Trades', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Top vocations explored by Tamil Nadu families',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            _TradeRankCard(rank: 1, name: 'CNC Operator', queries: '492 requests (34%)', sector: 'Manufacturing'),
            _TradeRankCard(rank: 2, name: 'Electrician', queries: '406 requests (28%)', sector: 'Construction / Power'),
            _TradeRankCard(rank: 3, name: 'Solar Technician', queries: '290 requests (20%)', sector: 'Renewable Energy'),
            _TradeRankCard(rank: 4, name: 'Automotive Mechanic', queries: '160 requests (11%)', sector: 'Automotive'),
            _TradeRankCard(rank: 5, name: 'Welder', queries: '102 requests (7%)', sector: 'Fabrication'),
          ],
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AdminStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ConcernBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _ConcernBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodyMedium),
              Text('$percentage%', style: AppTextStyles.labelLarge.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const _SentimentBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final String queries;
  final String sector;

  const _TradeRankCard({
    required this.rank,
    required this.name,
    required this.queries,
    required this.sector,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: rank <= 3 ? AppColors.primary : AppColors.surfaceVariant,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall),
                Text(sector, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(
            queries,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Policy Insights', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Text('Key Policy Insight', style: AppTextStyles.titleSmall.copyWith(color: AppColors.info)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Salem and Coimbatore industrial districts show that when parents are presented with verified 3-year career progression (Technician -> Shift Supervisor earning ₹40k+), hesitation decreases by 54%.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.demoDataLabel,
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform Users', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage enrolled learners and linked parents',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscalationsTab extends StatelessWidget {
  const _EscalationsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escalations Queue', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Active and resolved 1-on-1 human counsellor cases',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
