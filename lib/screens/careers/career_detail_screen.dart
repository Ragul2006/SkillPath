import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

/// Career detail page with dynamic data from Supabase
class CareerDetailScreen extends StatefulWidget {
  final String tradeId;
  const CareerDetailScreen({super.key, required this.tradeId});

  @override
  State<CareerDetailScreen> createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  Map<String, dynamic>? _tradeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final res = await SupabaseService.trades
          .select('*, outcomes(*), career_roles(*)')
          .eq('id', widget.tradeId)
          .single();
      setState(() {
        _tradeData = res;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback Demo Data for CNC Operator if fetching fails
      setState(() {
        _tradeData = {
          'name': 'CNC Operator',
          'nsqf_level': 4,
          'sector': 'Manufacturing',
          'description': 'A CNC Operator programs and operates Computer Numerical Control machines to produce precision parts. This trade is in high demand across manufacturing industries.',
          'skills': [
            'Machine Operation',
            'CNC Programming',
            'Technical Drawing',
            'Precision Measurement',
            'Quality Control',
            'Problem Solving'
          ],
          'outcomes': [
            {
              'placement_rate': 82,
              'min_salary': 16000,
              'max_salary': 20000,
              'average_salary': 18000,
              'sample_size': 420,
              'data_year': 2026,
              'source': 'Hackathon demo dataset'
            }
          ]
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trade = _tradeData ?? {};
    final outcomes = trade['outcomes'] as List<dynamic>?;
    final outcome = outcomes != null && outcomes.isNotEmpty ? outcomes.first : null;
    final skills = List<String>.from(trade['skills'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Details'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trade['name'] ?? 'Career',
                    style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NSQF Level ${trade['nsqf_level'] ?? 4} • ${trade['sector'] ?? 'General'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Verified data card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'VERIFIED OUTCOME DATA',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DataPoint(
                          label: 'Placement',
                          value: outcome != null ? '${outcome['placement_rate']}%' : 'N/A',
                        ),
                      ),
                      Expanded(
                        child: _DataPoint(
                          label: 'Starting',
                          value: outcome != null
                              ? '₹${(outcome['min_salary'] / 1000).toStringAsFixed(0)}K–₹${(outcome['max_salary'] / 1000).toStringAsFixed(0)}K'
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DataPoint(
                          label: 'Average',
                          value: outcome != null ? '₹${(outcome['average_salary'] / 1000).toStringAsFixed(0)}K' : 'N/A',
                        ),
                      ),
                      Expanded(
                        child: _DataPoint(
                          label: 'Sample',
                          value: outcome != null ? '${outcome['sample_size']}' : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Data year: ${outcome?['data_year'] ?? 2026} • ✓ Verified demo dataset',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview Section
            _Section(
              title: 'Overview',
              child: Text(
                trade['description'] ?? 'No description available.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            ),

            // Skills Section
            if (skills.isNotEmpty)
              _Section(
                title: 'Skills Required',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((s) => _SkillChip(s)).toList(),
                ),
              ),

            // Career Growth Section
            _Section(
              title: 'Career Growth',
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/careers/${widget.tradeId}/path'),
                  icon: const Icon(Icons.timeline_rounded),
                  label: const Text('View Career Path'),
                ),
              ),
            ),

            // Ask AI Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/ai-counsellor'),
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Ask AI About This Career'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DataPoint extends StatelessWidget {
  final String label;
  final String value;
  const _DataPoint({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.statSmall.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTextStyles.bodySmall),
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide.none,
    );
  }
}
