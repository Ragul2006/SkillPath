import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

/// Settings screen with language selection, low-literacy mode, and account actions
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Language & Regional', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: const Text('Primary Language'),
                  subtitle: Text(
                    localeState.isTamil ? 'தமிழ் (Tamil)' : 'English',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'ta', label: Text('தமிழ்')),
                    ],
                    selected: {localeState.languageCode},
                    onSelectionChanged: (Set<String> newSelection) {
                      localeNotifier.setLanguage(newSelection.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: localeState.isLowLiteracyMode,
                  onChanged: (val) => localeNotifier.toggleLowLiteracyMode(val),
                  title: const Text('Audio-Visual Mode (Low Literacy)'),
                  subtitle: const Text('Enlarged touch targets, icons, and simplified voice guidance'),
                  secondary: const Icon(Icons.accessibility_new_rounded, color: AppColors.secondary),
                  activeThumbColor: AppColors.secondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Hackathon & Safety Notice', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_outlined, color: AppColors.secondary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo dataset provided for hackathon evaluation. Placement and salary data are compiled from pilot sample sizes in Tamil Nadu.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Account', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out of SkillPath?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(authProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
