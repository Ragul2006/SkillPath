import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

/// Visual career progression timeline loaded from Supabase
class CareerPathScreen extends StatefulWidget {
  final String tradeId;
  const CareerPathScreen({super.key, required this.tradeId});

  @override
  State<CareerPathScreen> createState() => _CareerPathScreenState();
}

class _CareerPathScreenState extends State<CareerPathScreen> {
  List<Map<String, dynamic>> _steps = [];
  String _tradeName = 'Career';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCareerPath();
  }

  Future<void> _fetchCareerPath() async {
    setState(() => _isLoading = true);
    try {
      final tradeRes = await SupabaseService.trades.select('name').eq('id', widget.tradeId).single();
      final pathsRes = await SupabaseService.careerPaths
          .select('*')
          .eq('trade_id', widget.tradeId)
          .order('step_number', ascending: true);

      setState(() {
        _tradeName = tradeRes['name'] ?? 'Career';
        _steps = List<Map<String, dynamic>>.from(pathsRes);
        _isLoading = false;
      });
    } catch (e) {
      // Fallback Demo Steps
      setState(() {
        _tradeName = 'CNC Operator';
        _steps = [
          {
            'step_number': 1,
            'title': '10th / 12th Standard',
            'description': 'Basic education foundation'
          },
          {
            'step_number': 2,
            'title': 'Vocational Training (ITI/ITC)',
            'description': '1-2 years • CNC Programming basics'
          },
          {
            'step_number': 3,
            'title': 'CNC Operator',
            'description': '₹16K–₹20K • Entry level'
          },
          {
            'step_number': 4,
            'title': 'Senior CNC Operator',
            'description': '₹20K–₹28K • 2-3 years experience'
          },
          {
            'step_number': 5,
            'title': 'Production Technician',
            'description': '₹28K–₹35K • 4-5 years experience'
          },
          {
            'step_number': 6,
            'title': 'Supervisor / Shop Floor Manager',
            'description': '₹35K–₹50K • 6+ years experience'
          },
          {
            'step_number': 7,
            'title': 'Advanced Certification / B.Tech',
            'description': 'Further education opportunities'
          },
        ];
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

    return Scaffold(
      appBar: AppBar(title: const Text('Career Path')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_tradeName, style: AppTextStyles.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Career Progression Path',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            ..._steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isFirst = idx == 0;
              final isLast = idx == _steps.length - 1;
              final isHighlighted = idx == 2; // highlight entry level role

              return _PathStep(
                step: step['step_number'] ?? (idx + 1),
                title: step['title'] ?? '',
                subtitle: step['description'] ?? '',
                icon: _getStepIcon(idx),
                color: _getStepColor(idx),
                isFirst: isFirst,
                isLast: isLast,
                isHighlighted: isHighlighted,
              );
            }),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo dataset provided for hackathon evaluation.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.school_rounded;
      case 1:
        return Icons.build_rounded;
      case 2:
        return Icons.precision_manufacturing_rounded;
      case 3:
        return Icons.star_rounded;
      case 4:
        return Icons.engineering_rounded;
      case 5:
        return Icons.manage_accounts_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  Color _getStepColor(int index) {
    switch (index) {
      case 0:
        return AppColors.textTertiary;
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.tertiary;
      case 4:
        return AppColors.primary;
      case 5:
        return AppColors.primaryLight;
      default:
        return AppColors.success;
    }
  }
}

class _PathStep extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final bool isHighlighted;

  const _PathStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + circle
          SizedBox(
            width: 48,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 3,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isHighlighted ? color : color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: isHighlighted
                        ? null
                        : Border.all(color: color.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(
                    icon,
                    color: isHighlighted ? Colors.white : color,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 3,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? color.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHighlighted
                      ? color.withValues(alpha: 0.3)
                      : AppColors.border.withValues(alpha: 0.5),
                  width: isHighlighted ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
