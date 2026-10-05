import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 3-screen onboarding: Welcome → Role → Language → Login/Signup
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _FeaturesPage(onNext: _nextPage),
                  _GetStartedPage(
                    onLogin: () => context.go('/login'),
                    onSignup: () => context.go('/signup'),
                  ),
                ],
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo / icon area
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: const Icon(
              Icons.route_rounded,
              size: 56,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),
          const SizedBox(height: 40),

          Text(
            'SkillPath',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.primary,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

          const SizedBox(height: 12),

          Text(
            'Your Skills.',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.secondary,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

          Text(
            'Your Career.',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.secondary,
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

          Text(
            'Your Path.',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.secondary,
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

          const SizedBox(height: 24),

          Text(
            'AI-powered career counselling for\nvocational education',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get Started'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 1000.ms, duration: 500.ms).slideY(
                begin: 0.2,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  final VoidCallback onNext;
  const _FeaturesPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What SkillPath Does',
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 32),

          _FeatureItem(
            icon: Icons.mic_rounded,
            title: 'AI Voice Counsellor',
            subtitle: 'Talk in Tamil or English about career options',
            color: AppColors.primary,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          _FeatureItem(
            icon: Icons.verified_rounded,
            title: 'Verified Career Data',
            subtitle: 'Real placement rates, salaries & providers',
            color: AppColors.secondary,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          _FeatureItem(
            icon: Icons.family_restroom_rounded,
            title: 'Family Decision Support',
            subtitle: 'Address parent concerns with evidence',
            color: AppColors.tertiary,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

          _FeatureItem(
            icon: Icons.support_agent_rounded,
            title: 'Human Counsellor',
            subtitle: 'Connect with experts when you need them',
            color: AppColors.info,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStartedPage extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _GetStartedPage({
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 48,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 500.ms,
              ),
          const SizedBox(height: 32),

          Text(
            'Ready to find\nyour career path?',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          Text(
            'Join thousands of learners and parents\nmaking informed career decisions.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSignup,
              child: const Text('Create Account'),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onLogin,
              child: const Text('Sign In'),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
