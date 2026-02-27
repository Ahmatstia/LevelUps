import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/gamification/gamification_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/habits/habits_screen.dart';
import 'core/models/user_model.dart';
import 'core/models/task_model.dart';
import 'core/models/note_model.dart';
import 'core/models/tag_model.dart';
import 'core/models/subtask_model.dart';
import 'core/models/achievement_model.dart';
import 'core/models/quest_model.dart';
import 'core/models/skill_node_model.dart';
import 'core/models/habit_model.dart';
import 'core/theme/game_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/task_provider.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/level_up_overlay.dart';
import 'core/widgets/daily_reward_dialog.dart';
import 'features/splash/splash_screen.dart';

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
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(QuestModelAdapter());
  Hive.registerAdapter(SkillNodeModelAdapter());
  Hive.registerAdapter(AchievementCategoryAdapter());
  Hive.registerAdapter(AchievementRarityAdapter());
  Hive.registerAdapter(QuestTypeAdapter());
  Hive.registerAdapter(QuestDifficultyAdapter());
  Hive.registerAdapter(SkillTypeAdapter());
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<UserModel>('user_data');
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<TagModel>('tags');
  await Hive.openBox<AchievementModel>('achievements');
  await Hive.openBox<QuestModel>('quests');
  await Hive.openBox<SkillNodeModel>('skills');
  await Hive.openBox<HabitModel>('habits');

  // Init notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: LevelUpApp()));
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelUp',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.darkTheme,
      home: const SplashScreen(),
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

  @override
  void initState() {
    super.initState();
    // Show daily reward & schedule notifications after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Daily reward dialog
      if (mounted) {
        await DailyRewardDialog.show(context, ref);
      }
      // Schedule notifications
      final taskCount = ref.read(todayTasksProvider).length;
      await NotificationService().scheduleMorningBriefing(taskCount: taskCount);
      await NotificationService().scheduleEveningRecap();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to level changes for level-up overlay
    ref.listen(userProvider, (previous, current) {
      if (previous != null &&
          current != null &&
          current.level > previous.level) {
        LevelUpOverlay.show(context, newLevel: current.level);
      }
    });

    final l10n = ref.watch(l10nProvider);

    final screens = [
      const DashboardScreen(),
      const TasksScreen(),
      const HabitsScreen(),
      const StatsScreen(),
      const GamificationScreen(),
      const NotesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: GameTheme.surface,
          border: const Border(
            top: BorderSide(color: GameTheme.neonCyan, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: GameTheme.neonCyan.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: GameTheme.neonCyan,
          unselectedItemColor: Colors.grey[700],
          selectedLabelStyle: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 7,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 7,
            letterSpacing: 0.5,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard, size: 20),
              label: l10n.get('nav_dashboard').toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.task, size: 20),
              label: l10n.get('nav_tasks').toUpperCase(),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.repeat, size: 20),
              label: 'HABITS',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart, size: 20),
              label: l10n.get('nav_stats').toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: l10n.get('nav_rpg').toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.note, size: 20),
              label: l10n.get('nav_notes').toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings, size: 20),
              label: l10n.get('settings_title').toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }
}
