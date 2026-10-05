import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

/// Career explorer with search and filters — dynamically loaded from Supabase
class CareerExplorerScreen extends StatefulWidget {
  const CareerExplorerScreen({super.key});

  @override
  State<CareerExplorerScreen> createState() => _CareerExplorerScreenState();
}

class _CareerExplorerScreenState extends State<CareerExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSector = 'All';
  List<Map<String, dynamic>> _trades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrades();
  }

  Future<void> _fetchTrades() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.trades.select('*, outcomes(*)');
      setState(() {
        _trades = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      // Fallback demo dataset if backend unreachable
      setState(() {
        _trades = [
          {
            'id': 'b305221c-43db-4cc9-b7b5-0c58e727dbf8',
            'name': 'CNC Operator',
            'sector': 'Manufacturing',
            'nsqf_level': 4,
            'outcomes': [
              {'placement_rate': 82, 'min_salary': 16000, 'max_salary': 20000}
            ]
          },
          {
            'id': '5de5837d-1db9-4089-a2e6-7313bd855cca',
            'name': 'Electrician',
            'sector': 'Construction',
            'nsqf_level': 4,
            'outcomes': [
              {'placement_rate': 78, 'min_salary': 14000, 'max_salary': 18000}
            ]
          },
          {
            'id': '0eec711a-0e9e-4eec-893c-2374e5088eb4',
            'name': 'Solar Technician',
            'sector': 'Renewable Energy',
            'nsqf_level': 4,
            'outcomes': [
              {'placement_rate': 75, 'min_salary': 15000, 'max_salary': 22000}
            ]
          },
          {
            'id': '6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde',
            'name': 'Fitter',
            'sector': 'Manufacturing',
            'nsqf_level': 4,
            'outcomes': [
              {'placement_rate': 74, 'min_salary': 13000, 'max_salary': 17000}
            ]
          },
        ];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTrades {
    return _trades.filter((trade) {
      final matchesSector = _selectedSector == 'All' || trade['sector'] == _selectedSector;
      final matchesSearch = trade['name']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      return matchesSector && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Careers'),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search careers...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Manufacturing',
                      'Construction',
                      'Renewable Energy',
                      'Automotive',
                      'Electronics'
                    ].map((sector) {
                      final isSelected = _selectedSector == sector;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(sector),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSector = sector);
                          },
                          selectedColor: AppColors.primarySurface,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Career Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTrades.isEmpty
                    ? const Center(child: Text('No careers found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTrades.length,
                        itemBuilder: (context, index) {
                          final trade = _filteredTrades[index];
                          final outcomes = trade['outcomes'] as List<dynamic>?;
                          final outcome = outcomes != null && outcomes.isNotEmpty ? outcomes.first : null;

                          final placement = outcome != null ? '${outcome['placement_rate']}%' : 'N/A';
                          final salary = outcome != null
                              ? '₹${(outcome['min_salary'] / 1000).toStringAsFixed(0)}K–₹${(outcome['max_salary'] / 1000).toStringAsFixed(0)}K'
                              : 'N/A';

                          return GestureDetector(
                            onTap: () => context.go('/careers/${trade['id']}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(trade['name'] ?? '', style: AppTextStyles.titleMedium),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          trade['sector'] ?? 'General',
                                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('NSQF Level ${trade['nsqf_level'] ?? 4}', style: AppTextStyles.bodySmall),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _InfoBadge(icon: Icons.work_outline_rounded, text: '$placement placement'),
                                      const SizedBox(width: 16),
                                      _InfoBadge(icon: Icons.currency_rupee_rounded, text: salary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T element) test) sync* {
    for (T element in this) {
      if (test(element)) yield element;
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
