import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import 'quests_view.dart';
import 'achievements_view.dart';
import 'skill_tree_view.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final skillPoints = user?.skillPoints ?? 0;
    final l10n = ref.watch(l10nProvider);

    final tabs = [
      (l10n.get('rpg_tab_quests'), Icons.assignment),
      (l10n.get('rpg_tab_badges'), Icons.emoji_events),
      (l10n.get('rpg_tab_skills'), Icons.account_tree),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.get('nav_rpg'),
        ),
        actions: [
          Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.goldYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldYellow, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.goldYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$skillPoints SP',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.goldYellow,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2.seconds, color: Colors.white30),
        ],
      ),
      body: Column(
        children: [
          // ── Custom RPG Tab Bar ─────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isSelected = _tab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[i].$2,
                            size: 20,
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey[500],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].$1.toUpperCase(),
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                QuestsView(),
                AchievementsView(),
                SkillTreeView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
