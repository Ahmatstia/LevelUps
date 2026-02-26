import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/locale_provider.dart';
import 'quests_view.dart';
import 'achievements_view.dart';
import 'skill_tree_view.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final skillPoints = user?.skillPoints ?? 0;
    final l10n = ref.watch(l10nProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.get('nav_rpg')),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$skillPoints SP',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.assignment),
                text: l10n.get('rpg_tab_quests'),
              ),
              Tab(
                icon: const Icon(Icons.emoji_events),
                text: l10n.get('rpg_tab_badges'),
              ),
              Tab(
                icon: const Icon(Icons.account_tree),
                text: l10n.get('rpg_tab_skills'),
              ),
            ],
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [QuestsView(), AchievementsView(), SkillTreeView()],
        ),
      ),
    );
  }
}
