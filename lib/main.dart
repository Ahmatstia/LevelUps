import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/gamification/gamification_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/providers/locale_provider.dart';
import 'core/models/user_model.dart';
import 'core/models/task_model.dart';
import 'core/models/note_model.dart';
import 'core/models/tag_model.dart';
import 'core/models/subtask_model.dart';
import 'core/models/achievement_model.dart';
import 'core/models/quest_model.dart';
import 'core/models/skill_node_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(TaskDifficultyAdapter());
  Hive.registerAdapter(StatTypeAdapter());
  Hive.registerAdapter(RecurringTypeAdapter());
  Hive.registerAdapter(EnergyLevelAdapter());
  Hive.registerAdapter(QuadrantTypeAdapter());
  Hive.registerAdapter(TagModelAdapter());
  Hive.registerAdapter(SubtaskModelAdapter());

  // New RPG Gamification Adapters
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(QuestModelAdapter());
  Hive.registerAdapter(QuestTypeAdapter());
  Hive.registerAdapter(SkillNodeModelAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<UserModel>('user_data');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<TagModel>('tags');

  // New RPG Gamification Boxes
  await Hive.openBox<AchievementModel>('achievements');
  await Hive.openBox<QuestModel>('quests');
  await Hive.openBox<SkillNodeModel>('skills');

  runApp(const ProviderScope(child: LevelUpApp()));
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Convert to getter to avoid Hot Reload RangeError issues when adding new screens
  List<Widget> get _screens => [
    const DashboardScreen(),
    const TasksScreen(),
    const GamificationScreen(), // The Hub
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.get('nav_dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.task_outlined),
              activeIcon: const Icon(Icons.task),
              label: l10n.get('nav_tasks'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              activeIcon: const Icon(Icons.emoji_events),
              label: l10n.get('nav_rpg'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: l10n.get('nav_stats'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.get('settings_title'),
            ),
          ],
        ),
      ),
    );
  }
}
