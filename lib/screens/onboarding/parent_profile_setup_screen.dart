import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';

/// Parent profile setup — captures concerns and expectations
class ParentProfileSetupScreen extends ConsumerStatefulWidget {
  const ParentProfileSetupScreen({super.key});

  @override
  ConsumerState<ParentProfileSetupScreen> createState() =>
      _ParentProfileSetupScreenState();
}

class _ParentProfileSetupScreenState
    extends ConsumerState<ParentProfileSetupScreen> {
  bool _isSaving = false;
  String? _district;

  // Concern sliders (0–10 scale)
  final Map<String, double> _concerns = {
    'salary': 5.0,
    'job_security': 5.0,
    'social_status': 5.0,
    'safety': 5.0,
    'distance': 5.0,
    'course_quality': 5.0,
    'career_growth': 5.0,
    'higher_education': 5.0,
  };

  final Map<String, String> _concernLabels = {
    'salary': '💰 Salary & Income',
    'job_security': '🔒 Job Security',
    'social_status': '🏆 Social Status',
    'safety': '🛡️ Workplace Safety',
    'distance': '📍 Distance from Home',
    'course_quality': '📚 Course Quality',
    'career_growth': '📈 Career Growth',
    'higher_education': '🎓 Higher Education Options',
  };

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) return;

      // Filter concerns rated > 5 as active concerns
      final activeConcerns = _concerns.entries
          .where((e) => e.value >= 6)
          .map((e) => e.key)
          .toList();

      await AuthService.createParentProfile(
        userId: userId,
        concerns: activeConcerns,
        expectations: _concerns,
      );

      if (_district != null) {
        await AuthService.createProfile(
          userId: userId,
          name: AuthService.userName ?? '',
          email: AuthService.currentUser?.email ?? '',
          role: AppConstants.roleParent,
          district: _district,
        );
      }

      ref.read(authProvider.notifier).completeOnboarding();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What matters most to you?',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Rate how important each factor is for your child\'s career decision.',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // District
            DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: const InputDecoration(
                labelText: 'Your District',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: AppConstants.districts.map((d) {
                return DropdownMenuItem(value: d, child: Text(d));
              }).toList(),
              onChanged: (v) => setState(() => _district = v),
            ),
            const SizedBox(height: 32),

            // Concern sliders
            ..._concerns.entries.map((entry) {
              return _ConcernSlider(
                label: _concernLabels[entry.key] ?? entry.key,
                value: entry.value,
                onChanged: (v) {
                  setState(() => _concerns[entry.key] = v);
                },
              );
            }),

            const SizedBox(height: 16),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SkillPath will use these preferences to provide relevant career information that addresses your concerns.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Complete Setup'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ConcernSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _ConcernSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  String get _levelLabel {
    if (value <= 3) return 'Low concern';
    if (value <= 6) return 'Moderate';
    return 'High concern';
  }

  Color get _levelColor {
    if (value <= 3) return AppColors.success;
    if (value <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.titleSmall),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _levelLabel,
                  style: AppTextStyles.labelSmall.copyWith(color: _levelColor),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: _levelColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
