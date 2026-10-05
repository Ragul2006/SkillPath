import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Parent home — similar to learner but with parent-specific content
class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _ParentHomeTab(name: authState.name ?? 'Parent'),
          _ExploreTab(),
          _CounsellorTab(),
          _FamilyTab(),
          _ParentProfileTab(),
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

class _ParentHomeTab extends StatelessWidget {
  final String name;
  const _ParentHomeTab({required this.name});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('$greeting, $name 👋', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text(
              "Let's make the best career decision for your child.",
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // AI counsellor card
            GestureDetector(
              onTap: () => context.go('/ai-counsellor'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
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
                            'Ask AI About Your Concerns',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get verified career data to address your concerns',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Family decision progress
            Text('Family Decision Progress', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            _ProgressItem(label: 'Career explored', done: true),
            _ProgressItem(label: 'Salary discussed', done: true),
            _ProgressItem(label: 'Job security discussed', done: false),
            _ProgressItem(label: 'Training provider selected', done: false),
            _ProgressItem(label: 'Final decision', done: false),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final bool done;
  const _ProgressItem({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: done ? AppColors.success : AppColors.textTertiary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: done ? AppColors.textPrimary : AppColors.textTertiary,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Careers', style: AppTextStyles.headlineLarge),
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
                ),
                child: const Icon(Icons.mic_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text('AI Career Counsellor', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Ask questions about your child\'s career in Tamil or English.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
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

class _FamilyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family Decision', style: AppTextStyles.headlineLarge),
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

class _ParentProfileTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primarySurface,
              child: Text(
                (authState.name ?? 'P')[0].toUpperCase(),
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(authState.name ?? 'Parent', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PARENT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/settings'),
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Sign Out',
                  style: TextStyle(color: AppColors.error)),
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
