import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final currentLocale = ref.watch(localeProvider);
    final user = ref.watch(userProvider);
    final isDark = true; // Theme provider can be added later

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          if (user != null)
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 36, color: Colors.blue),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text('Lv ${user.level} | ${user.totalXp} XP'),
              ),
            ),

          // Settings Options
          Text(
            l10n.get('settings_title'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.get('settings_language')),
                  trailing: DropdownButton<String>(
                    value: currentLocale,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'id',
                        child: Text('🇮🇩 Indonesia'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('🇬🇧 English'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(l10n.get('settings_dark_mode')),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.get('settings_theme_soon')),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Danger Zone
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.red.withValues(alpha: 0.1),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                l10n.get('settings_reset'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Reset logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.get('settings_reset_demo'))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
