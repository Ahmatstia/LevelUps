import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import 'task_provider.dart';

class AnalyticsData {
  final Map<DateTime, int> heatmapData;
  final String mostProductiveTime;
  final String mostProductiveDay;
  final Duration averageCompletionTime;
  final bool isBurnoutRisk;
  final Map<QuadrantType, int> quadrantDistribution;
  final List<double> weeklyXpGrowth;
  final List<int> weeklyTaskCompletions;

  AnalyticsData({
    required this.heatmapData,
    required this.mostProductiveTime,
    required this.mostProductiveDay,
    required this.averageCompletionTime,
    required this.isBurnoutRisk,
    required this.quadrantDistribution,
    required this.weeklyXpGrowth,
    required this.weeklyTaskCompletions,
  });

  factory AnalyticsData.empty() {
    return AnalyticsData(
      heatmapData: {},
      mostProductiveTime: 'Not enough data',
      mostProductiveDay: 'Not enough data',
      averageCompletionTime: Duration.zero,
      isBurnoutRisk: false,
      quadrantDistribution: {
        QuadrantType.doFirst: 0,
        QuadrantType.schedule: 0,
        QuadrantType.delegate: 0,
        QuadrantType.eliminate: 0,
      },
      weeklyXpGrowth: List.filled(7, 0.0),
      weeklyTaskCompletions: List.filled(7, 0),
    );
  }
}

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final completedTasks = ref.watch(completedTasksProvider);

  if (completedTasks.isEmpty) {
    return AnalyticsData.empty();
  }

  // 1. Heatmap Data (Last 90 days)
  final Map<DateTime, int> heatmap = {};
  final now = DateTime.now();
  final ninetyDaysAgo = now.subtract(const Duration(days: 90));

  for (var task in completedTasks) {
    if (task.completedAt != null && task.completedAt!.isAfter(ninetyDaysAgo)) {
      final date = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      heatmap[date] = (heatmap[date] ?? 0) + 1;
    }
  }

  // 2. Time of Day Productivity
  int morning = 0; // 5 AM - 12 PM
  int afternoon = 0; // 12 PM - 6 PM
  int night = 0; // 6 PM - 5 AM

  for (var task in completedTasks) {
    if (task.completedAt != null) {
      final hour = task.completedAt!.hour;
      if (hour >= 5 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 18) {
        afternoon++;
      } else {
        night++;
      }
    }
  }

  String bestTime = 'Not enough data';
  if (morning > afternoon && morning > night) {
    bestTime = 'Morning (5AM - 12PM)';
  } else if (afternoon > morning && afternoon > night) {
    bestTime = 'Afternoon (12PM - 6PM)';
  } else if (night > morning && night > afternoon) {
    bestTime = 'Night Time (6PM - 5AM)';
  }

  // 3. Day of Week Productivity
  final Map<int, int> dayCounts = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
  }; // 1 = Monday, 7 = Sunday

  for (var task in completedTasks) {
    if (task.completedAt != null) {
      dayCounts[task.completedAt!.weekday] =
          dayCounts[task.completedAt!.weekday]! + 1;
    }
  }

  int maxDayCount = 0;
  int bestDayInt = 0;
  dayCounts.forEach((day, count) {
    if (count > maxDayCount) {
      maxDayCount = count;
      bestDayInt = day;
    }
  });

  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final bestDay = bestDayInt > 0 ? dayNames[bestDayInt - 1] : 'Unknown';

  // 4. Average Completion Time
  List<Duration> completionTimes = [];
  for (var task in completedTasks) {
    if (task.completedAt != null) {
      completionTimes.add(task.completedAt!.difference(task.createdAt));
    }
  }

  Duration avgTime = Duration.zero;
  if (completionTimes.isNotEmpty) {
    int totalSeconds = completionTimes.fold(
      0,
      (sum, duration) => sum + duration.inSeconds,
    );
    avgTime = Duration(seconds: totalSeconds ~/ completionTimes.length);
  }

  // 5. Burnout Detection (Last 7 days logic)
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final recentTasks = completedTasks
      .where(
        (task) =>
            task.completedAt != null && task.completedAt!.isAfter(sevenDaysAgo),
      )
      .toList();

  int hardTaskCount = 0;
  for (var task in recentTasks) {
    if (task.difficulty == TaskDifficulty.hard ||
        task.energyLevel == EnergyLevel.high) {
      hardTaskCount++;
    }
  }

  // Alert if > 25 tasks in 7 days, and > 40% are Hard/High Energy
  bool burnoutRisk = false;
  if (recentTasks.length > 25 && (hardTaskCount / recentTasks.length) > 0.4) {
    burnoutRisk = true;
  }

  // 6. Quadrant Distribution
  final Map<QuadrantType, int> quadrants = {
    QuadrantType.doFirst: 0,
    QuadrantType.schedule: 0,
    QuadrantType.delegate: 0,
    QuadrantType.eliminate: 0,
  };

  for (var task in completedTasks) {
    quadrants[task.quadrant] = (quadrants[task.quadrant] ?? 0) + 1;
  }

  // 7. Weekly Charts Data (Last 7 days, 0 is today, 6 is 6 days ago. Reversing for chart UI where 0 is start of week)
  final List<double> xpGrowth = List.filled(7, 0.0);
  final List<int> taskComps = List.filled(7, 0);

  for (var task in completedTasks) {
    if (task.completedAt != null && task.completedAt!.isAfter(sevenDaysAgo)) {
      // Difference in days from today (0 = today, 1 = yesterday, etc.)
      // Normalizing date to compare days accurately
      final taskDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      final today = DateTime(now.year, now.month, now.day);

      final diffDays = today.difference(taskDate).inDays;

      if (diffDays >= 0 && diffDays < 7) {
        // Because charts render left-to-right (past-to-present), index 6 is today, 0 is 6 days ago
        int chartIndex = 6 - diffDays;

        taskComps[chartIndex] += 1;
        xpGrowth[chartIndex] += task.difficulty.xpValue.toDouble();
      }
    }
  }

  return AnalyticsData(
    heatmapData: heatmap,
    mostProductiveTime: bestTime,
    mostProductiveDay: bestDay,
    averageCompletionTime: avgTime,
    isBurnoutRisk: burnoutRisk,
    quadrantDistribution: quadrants,
    weeklyXpGrowth: xpGrowth,
    weeklyTaskCompletions: taskComps,
  );
});
