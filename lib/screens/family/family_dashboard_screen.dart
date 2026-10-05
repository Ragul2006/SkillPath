import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Family dashboard showing learner/parent decision progress
class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Decision')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family Decision Support', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Work through career decisions together',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Learner preference
            _SectionCard(
              icon: Icons.school_rounded,
              iconColor: AppColors.primary,
              title: 'Learner Preference',
              content: 'Interested in CNC Operator\n12th Standard • Salem',
            ),

            // Parent concerns
            _SectionCard(
              icon: Icons.family_restroom_rounded,
              iconColor: AppColors.secondary,
              title: 'Parent Concerns',
              content: '🔒 Job Security — High concern\n💰 Salary — Moderate concern',
            ),

            // Verified evidence
            _SectionCard(
              icon: Icons.verified_rounded,
              iconColor: AppColors.success,
              title: 'Verified Evidence',
              content: 'CNC Operator\n82% placement rate\n₹16K–₹20K starting salary\n420 sample size • 2026 data',
            ),

            // Decision progress
            Text('Decision Progress', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.4,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2 of 5 steps completed',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            _ProgressStep(label: 'Career explored', done: true),
            _ProgressStep(label: 'Salary discussed', done: true),
            _ProgressStep(label: 'Job security discussed', done: false),
            _ProgressStep(label: 'Training provider selected', done: false),
            _ProgressStep(label: 'Final decision', done: false),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Discuss with AI Counsellor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 6),
                Text(content, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool done;
  const _ProgressStep({required this.label, required this.done});

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
            ),
          ),
        ],
      ),
    );
  }
}
