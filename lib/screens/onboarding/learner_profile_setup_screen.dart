import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';

/// Learner profile setup during onboarding
class LearnerProfileSetupScreen extends ConsumerStatefulWidget {
  const LearnerProfileSetupScreen({super.key});

  @override
  ConsumerState<LearnerProfileSetupScreen> createState() =>
      _LearnerProfileSetupScreenState();
}

class _LearnerProfileSetupScreenState
    extends ConsumerState<LearnerProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSaving = false;

  // Form data
  String? _educationLevel;
  String? _district;
  final List<String> _selectedInterests = [];
  final List<String> _selectedSkills = [];
  String? _preferredIndustry;
  String? _salaryExpectation;
  bool _willingToRelocate = false;

  final List<String> _interestOptions = [
    'Mechanical Work',
    'Electrical Work',
    'Computer & IT',
    'Automotive',
    'Construction',
    'Beauty & Wellness',
    'Solar & Renewable Energy',
    'HVAC & Cooling',
    'Plumbing',
    'Welding & Fabrication',
  ];

  final List<String> _skillOptions = [
    'Hands-on / Practical',
    'Problem Solving',
    'Communication',
    'Technical Drawing',
    'Computer Skills',
    'Teamwork',
    'Attention to Detail',
    'Physical Fitness',
  ];

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) return;

      await AuthService.createLearnerProfile(
        userId: userId,
        educationLevel: _educationLevel,
        interests: _selectedInterests,
        skills: _selectedSkills,
        preferredIndustries:
            _preferredIndustry != null ? [_preferredIndustry!] : null,
        salaryExpectation: _salaryExpectation,
        willingToRelocate: _willingToRelocate,
      );

      // Update profile with district
      if (_district != null) {
        await AuthService.createProfile(
          userId: userId,
          name: AuthService.userName ?? '',
          email: AuthService.currentUser?.email ?? '',
          role: AppConstants.roleLearner,
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEducationStep(),
                _buildInterestsStep(),
                _buildSkillsStep(),
                _buildPreferencesStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education & Location', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Tell us about your education background',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          Text('Education Level', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.educationLevels.map((level) {
              final selected = _educationLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: selected,
                onSelected: (v) => setState(() => _educationLevel = level),
                selectedColor: AppColors.primarySurface,
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Text('District', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _district,
            decoration: const InputDecoration(
              hintText: 'Select your district',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: AppConstants.districts.map((d) {
              return DropdownMenuItem(value: d, child: Text(d));
            }).toList(),
            onChanged: (v) => setState(() => _district = v),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Interests', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Select areas that interest you (choose multiple)',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...List.generate(_interestOptions.length, (i) {
            final interest = _interestOptions[i];
            final selected = _selectedInterests.contains(interest);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.primarySurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        interest,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedInterests.isNotEmpty ? _nextStep : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Skills', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'What skills do you already have?',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillOptions.map((skill) {
              final selected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: AppColors.secondarySurface,
                checkmarkColor: AppColors.secondary,
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Help us find the best career matches for you',
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          Text('Preferred Industry', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _preferredIndustry,
            decoration: const InputDecoration(
              hintText: 'Select an industry',
              prefixIcon: Icon(Icons.factory_outlined),
            ),
            items: AppConstants.industries.map((ind) {
              return DropdownMenuItem(value: ind, child: Text(ind));
            }).toList(),
            onChanged: (v) => setState(() => _preferredIndustry = v),
          ),
          const SizedBox(height: 24),

          Text('Salary Expectation', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _salaryExpectation,
            decoration: const InputDecoration(
              hintText: 'Expected salary range',
              prefixIcon: Icon(Icons.currency_rupee_rounded),
            ),
            items: AppConstants.salaryRanges.map((range) {
              return DropdownMenuItem(value: range, child: Text(range));
            }).toList(),
            onChanged: (v) => setState(() => _salaryExpectation = v),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            value: _willingToRelocate,
            onChanged: (v) => setState(() => _willingToRelocate = v),
            title: Text('Willing to relocate?', style: AppTextStyles.titleSmall),
            subtitle: Text(
              'Would you move to another city for a job?',
              style: AppTextStyles.bodySmall,
            ),
            activeThumbColor: AppColors.secondary,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 40),

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
        ],
      ),
    );
  }
}
