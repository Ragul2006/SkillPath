import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

/// Create human counsellor escalation
class CreateEscalationScreen extends StatefulWidget {
  const CreateEscalationScreen({super.key});

  @override
  State<CreateEscalationScreen> createState() => _CreateEscalationScreenState();
}

class _CreateEscalationScreenState extends State<CreateEscalationScreen> {
  String? _selectedReason;
  String _selectedPriority = 'Medium';
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Career selection guidance',
    'Salary & income questions',
    'Training provider recommendation',
    'Family concern resolution',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        await SupabaseService.escalations.insert({
          'user_id': userId,
          'reason': _selectedReason,
          'priority': _selectedPriority,
          'status': 'Pending',
        });
      } else {
        // Fallback simulation delay
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escalation request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Counsellor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Talk to a SkillPath Counsellor',
                          style: AppTextStyles.titleSmall.copyWith(color: AppColors.info),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A qualified counsellor will be assigned to help you.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reason
            Text('Reason for request', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(_reasons.length, (i) {
              final reason = _reasons[i];
              final selected = _selectedReason == reason;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedReason = reason),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primarySurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: selected ? AppColors.primary : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          reason,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: selected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Priority
            Text('Priority', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: _priorities.map((p) {
                final selected = _selectedPriority == p;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: p != 'High' ? 8 : 0),
                    child: ChoiceChip(
                      label: Text(p),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedPriority = p),
                      selectedColor: AppColors.primarySurface,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Details
            Text('Additional details (optional)', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your concern...',
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null && !_isSubmitting ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
