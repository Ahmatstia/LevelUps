import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/game_theme.dart';
import '../../core/widgets/rpg_status_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Box _settings;

  @override
  void initState() {
    super.initState();
    _settings = Hive.box('settings');
  }

  bool _getBool(String key, {bool defaultVal = true}) =>
      _settings.get(key, defaultValue: defaultVal) as bool;

  Future<void> _setNotifBool(String key, bool val) async {
    await _settings.put(key, val);
    setState(() {});
    final svc = NotificationService();
    if (key == 'notif_morning') {
      if (val) {
        await svc.scheduleMorningBriefing();
      } else {
        await svc.cancelMorning();
      }
    } else if (key == 'notif_evening') {
      if (val) {
        await svc.scheduleEveningRecap();
      } else {
        await svc.cancelEvening();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final currentLocale = ref.watch(localeProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          l10n.get('settings_title'),
          style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Player Profile Card ─────────────────────────────────
          if (user != null)
            _gamePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: GameTheme.neonCyan.withValues(alpha: 0.1),
                          border: Border.all(
                            color: GameTheme.neonCyan,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GameTheme.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: GameTheme.neonCyan,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.toUpperCase(),
                              style: GameTheme.neonTextStyle(
                                GameTheme.neonPink,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'LEVEL ${user.level}  •  ${user.totalXp} XP',
                              style: GameTheme.textTheme.bodySmall?.copyWith(
                                color: GameTheme.goldYellow,
                                fontSize: 9,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RpgStatusBar(
                    value:
                        (user.totalXp - 100 * (user.level - 1)) /
                        (100 * user.level - 100 * (user.level - 1)),
                    barColor: GameTheme.neonCyan,
                    label: 'XP TO NEXT LEVEL',
                    segments: 10,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),

          const SizedBox(height: 20),

          // ── Settings Header ─────────────────────────────────────
          _sectionLabel('SYSTEM CONFIG'),
          const SizedBox(height: 8),

          // ── Language ──────────────────────────────────────────
          _gamePanel(
            child: Column(
              children: [
                _settingRow(
                  icon: Icons.language,
                  iconColor: GameTheme.manaBlue,
                  title: l10n.get('settings_language'),
                  trailing: DropdownButton<String>(
                    value: currentLocale,
                    underline: const SizedBox(),
                    dropdownColor: GameTheme.surface,
                    style: GameTheme.textTheme.bodySmall?.copyWith(
                      color: GameTheme.neonCyan,
                      fontSize: 10,
                    ),
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
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(localeProvider.notifier).setLocale(val);
                      }
                    },
                  ),
                ),
                _divider(),
                _settingRow(
                  icon: Icons.dark_mode,
                  iconColor: GameTheme.neonPink,
                  title: l10n.get('settings_dark_mode'),
                  trailing: Switch(
                    value: true,
                    activeTrackColor: GameTheme.neonCyan.withValues(alpha: 0.5),
                    activeThumbColor: GameTheme.neonCyan,
                    onChanged: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: GameTheme.surface,
                          content: Text(
                            l10n.get('settings_theme_soon'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _divider(),
                _settingRow(
                  icon: Icons.volume_up,
                  iconColor: GameTheme.goldYellow,
                  title: 'SOUND EFFECTS',
                  trailing: Switch(
                    value: true,
                    activeTrackColor: GameTheme.neonCyan.withValues(alpha: 0.5),
                    activeThumbColor: GameTheme.neonCyan,
                    onChanged: (val) {
                      // SfxService.instance.setEnabled(val);
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

          const SizedBox(height: 20),

          // ── Notification Settings ────────────────────────────────
          _sectionLabel('NOTIFICATIONS'),
          const SizedBox(height: 8),

          _gamePanel(
            child: Column(
              children: [
                _settingRow(
                  icon: Icons.wb_sunny,
                  iconColor: GameTheme.goldYellow,
                  title: 'MORNING BRIEFING (07:00)',
                  trailing: Switch(
                    value: _getBool('notif_morning'),
                    activeTrackColor: GameTheme.goldYellow.withValues(
                      alpha: 0.4,
                    ),
                    activeThumbColor: GameTheme.goldYellow,
                    onChanged: (val) => _setNotifBool('notif_morning', val),
                  ),
                ),
                _divider(),
                _settingRow(
                  icon: Icons.nights_stay,
                  iconColor: GameTheme.manaBlue,
                  title: 'EVENING RECAP (21:00)',
                  trailing: Switch(
                    value: _getBool('notif_evening'),
                    activeTrackColor: GameTheme.manaBlue.withValues(alpha: 0.4),
                    activeThumbColor: GameTheme.manaBlue,
                    onChanged: (val) => _setNotifBool('notif_evening', val),
                  ),
                ),
                _divider(),
                _settingRow(
                  icon: Icons.warning_amber,
                  iconColor: GameTheme.hpRed,
                  title: 'OVERDUE ALERTS',
                  trailing: Switch(
                    value: _getBool('notif_overdue'),
                    activeTrackColor: GameTheme.hpRed.withValues(alpha: 0.4),
                    activeThumbColor: GameTheme.hpRed,
                    onChanged: (val) => _setNotifBool('notif_overdue', val),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 280.ms).slideX(begin: 0.1),

          const SizedBox(height: 20),

          // ── Danger Zone ─────────────────────────────────────────
          _sectionLabel('DANGER ZONE', color: GameTheme.hpRed),
          const SizedBox(height: 8),

          _gamePanel(
            borderColor: GameTheme.hpRed.withValues(alpha: 0.4),
            child: _settingRow(
              icon: Icons.delete_forever,
              iconColor: GameTheme.hpRed,
              title: l10n.get('settings_reset'),
              titleColor: GameTheme.hpRed,
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: GameTheme.surface,
                    content: Text(
                      l10n.get('settings_reset_demo'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'LEVELUP APP  v1.0\nPHASE 8 RELEASE',
              textAlign: TextAlign.center,
              style: GameTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[800],
                fontSize: 7,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gamePanel({required Widget child, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(color: borderColor ?? Colors.white12, width: 1.5),
        boxShadow: borderColor != null
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String label, {Color? color}) {
    return Text(
      label,
      style: GameTheme.textTheme.bodySmall?.copyWith(
        color: color ?? GameTheme.neonCyan.withValues(alpha: 0.7),
        fontSize: 8,
        letterSpacing: 3,
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.white10, thickness: 1);
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GameTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: titleColor ?? Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
