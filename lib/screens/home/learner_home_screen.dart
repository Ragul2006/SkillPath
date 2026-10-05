import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Learner home with bottom navigation
class LearnerHomeScreen extends ConsumerStatefulWidget {
  const LearnerHomeScreen({super.key});

  @override
  ConsumerState<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends ConsumerState<LearnerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(),
          _ExploreTab(),
          _CounsellorTab(),
          _FamilyTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic_rounded),
            label: 'Counsellor',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom_rounded),
            label: 'Family',
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

// ── Home Tab ──
class _HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final greeting = _getGreeting();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Greeting
            Text(
              '$greeting, ${authState.name ?? 'Learner'} 👋',
              style: AppTextStyles.headlineLarge,
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 4),
            Text(
              "Let's find the right career path.",
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // ── Quick Action Cards ──
            _ActionCard(
              gradient: AppColors.heroGradient,
              icon: Icons.mic_rounded,
              title: 'Talk to AI Counsellor',
              subtitle: 'Get personalized career advice in Tamil or English',
              onTap: () => context.go('/ai-counsellor'),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SmallCard(
                    icon: Icons.search_rounded,
                    title: 'Explore\nCareers',
                    color: AppColors.secondary,
                    onTap: () => context.go('/careers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallCard(
                    icon: Icons.compare_arrows_rounded,
                    title: 'Compare\nCareers',
                    color: AppColors.tertiary,
                    onTap: () => context.go('/compare'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SmallCard(
                    icon: Icons.family_restroom_rounded,
                    title: 'Family\nDecision',
                    color: AppColors.info,
                    onTap: () => context.go('/family'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallCard(
                    icon: Icons.support_agent_rounded,
                    title: 'Human\nCounsellor',
                    color: AppColors.primary,
                    onTap: () => context.go('/escalation/create'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // ── Recommended Careers ──
            Text('Recommended For You', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),

            _RecommendationCard(
              trade: 'CNC Operator',
              matchScore: 92,
              placement: '82%',
              salary: '₹16K–₹20K',
              onTap: () {},
            ).animate().fadeIn(delay: 500.ms),

            _RecommendationCard(
              trade: 'Electrician',
              matchScore: 84,
              placement: '78%',
              salary: '₹14K–₹18K',
              onTap: () {},
            ).animate().fadeIn(delay: 600.ms),

            _RecommendationCard(
              trade: 'Solar Technician',
              matchScore: 79,
              placement: '75%',
              salary: '₹15K–₹22K',
              onTap: () {},
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Explore Tab (placeholder — full screen in Phase 3) ──
class _ExploreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Explore Careers', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Discover vocational careers with verified data',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/careers'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Browse All Careers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Counsellor Tab ──
class _CounsellorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppColors.elevatedShadow,
                ),
                child: const Icon(Icons.mic_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'AI Career Counsellor',
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Get real-time career advice using voice.\nSpeak in Tamil or English.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/ai-counsellor'),
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text('Start Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Family Tab ──
class _FamilyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Family Decision', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Work together with your family to make career decisions',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/family'),
                icon: const Icon(Icons.family_restroom_rounded),
                label: const Text('View Family Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Tab ──
class _ProfileTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primarySurface,
              child: Text(
                (authState.name ?? 'U')[0].toUpperCase(),
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(authState.name ?? 'User', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (authState.role ?? 'learner').toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 32),

            _ProfileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => context.go('/profile'),
            ),
            _ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.go('/settings'),
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About SkillPath',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _ProfileMenuItem(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              isDestructive: true,
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──

class _ActionCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SmallCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String trade;
  final int matchScore;
  final String placement;
  final String salary;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.trade,
    required this.matchScore,
    required this.placement,
    required this.salary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Match score circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySurface,
              ),
              child: Center(
                child: Text(
                  '$matchScore%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trade, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    '$placement placement  •  $salary',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
