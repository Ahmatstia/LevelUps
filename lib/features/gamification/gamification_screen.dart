import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/game_theme.dart';
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
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          l10n.get('nav_rpg'),
          style: GameTheme.neonTextStyle(GameTheme.neonPink, fontSize: 16),
        ),
        actions: [
          Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: GameTheme.goldYellow.withValues(alpha: 0.15),
                  border: Border.all(color: GameTheme.goldYellow, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.goldYellow.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: GameTheme.goldYellow,
                      size: 14,
                      shadows: [
                        Shadow(color: GameTheme.goldYellow, blurRadius: 10),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$skillPoints SP',
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        color: GameTheme.goldYellow,
                        fontSize: 9,
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
              color: GameTheme.surface,
              border: Border.all(color: Colors.white12, width: 1),
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
                              color: GameTheme.neonPink.withValues(alpha: 0.15),
                              border: Border.all(
                                color: GameTheme.neonPink,
                                width: 1.5,
                              ),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[i].$2,
                            size: 16,
                            color: isSelected
                                ? GameTheme.neonPink
                                : Colors.grey[700],
                            shadows: isSelected
                                ? [
                                    const Shadow(
                                      color: GameTheme.neonPink,
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].$1.toUpperCase(),
                            style: GameTheme.textTheme.bodySmall?.copyWith(
                              fontSize: 7,
                              color: isSelected
                                  ? GameTheme.neonPink
                                  : Colors.grey[700],
                              letterSpacing: 0.5,
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
