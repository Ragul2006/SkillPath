import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Career comparison screen — compare 2-4 careers side by side
class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Careers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Career Comparison',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Compare vocational careers side by side',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Comparison table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.primarySurface),
                columns: const [
                  DataColumn(label: Text('Factor')),
                  DataColumn(label: Text('CNC Operator')),
                  DataColumn(label: Text('Electrician')),
                  DataColumn(label: Text('Solar Tech')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('Placement')),
                    DataCell(Text('82%')),
                    DataCell(Text('78%')),
                    DataCell(Text('75%')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Starting Salary')),
                    DataCell(Text('₹16K–₹20K')),
                    DataCell(Text('₹14K–₹18K')),
                    DataCell(Text('₹15K–₹22K')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Career Growth')),
                    DataCell(Text('High')),
                    DataCell(Text('High')),
                    DataCell(Text('Very High')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('NSQF Level')),
                    DataCell(Text('4')),
                    DataCell(Text('4')),
                    DataCell(Text('4')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Relocation')),
                    DataCell(Text('Sometimes')),
                    DataCell(Text('Rarely')),
                    DataCell(Text('Sometimes')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Further Study')),
                    DataCell(Text('B.Tech possible')),
                    DataCell(Text('B.Tech possible')),
                    DataCell(Text('B.Tech possible')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Best match
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Best match for your stated preferences',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CNC Operator — 92% match score\nStrong placement rate and salary alignment with your preferences.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Demo dataset provided for hackathon evaluation.',
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
