import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../utils/habit_utils.dart';
import '../models/habit_track.dart';
import '../widgets/habit_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import 'habit_detail_screen.dart';
import 'create_habit_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = ['Daily Habits', 'All Habits', 'Stats'];

  @override
  void initState() {
    super.initState();
    // Load habits when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateHabitScreen()),
          ).then((_) {
            // Refresh habits list when returning from create screen
            Provider.of<HabitProvider>(context, listen: false).loadHabits();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDailyHabitsTab();
      case 1:
        return _buildAllHabitsTab();
      case 2:
        return _buildStatsTab();
      default:
        return _buildDailyHabitsTab();
    }
  }

  Widget _buildDailyHabitsTab() {
    final habitProvider = Provider.of<HabitProvider>(context);

    if (habitProvider.isLoading) {
      return const LoadingIndicator();
    }

    if (habitProvider.error != null) {
      return ErrorMessageWidget.simple(
        message: habitProvider.error!,
        onRetry: () {
          habitProvider.loadHabits();
        },
      );
    }

    final dailyHabits =
        habitProvider.activeHabits
            .where((habit) => habit.frequencyUnit.toString().contains('daily'))
            .toList();

    if (dailyHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No daily habits yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first daily habit',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateHabitScreen(),
                  ),
                ).then((_) {
                  habitProvider.loadHabits();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyHabits.length,
      itemBuilder: (context, index) {
        final habit = dailyHabits[index];
        return HabitCard(
          habit: habit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habitId: habit.id!),
              ),
            ).then((_) {
              habitProvider.loadHabits();
            });
          },
          onTrackTap: () {
            // Show a modal bottom sheet to track the habit
            _showTrackHabitBottomSheet(context, habit.id!);
          },
        );
      },
    );
  }

  Widget _buildAllHabitsTab() {
    final habitProvider = Provider.of<HabitProvider>(context);

    if (habitProvider.isLoading) {
      return const LoadingIndicator();
    }

    if (habitProvider.error != null) {
      return ErrorMessageWidget.simple(
        message: habitProvider.error!,
        onRetry: () {
          habitProvider.loadHabits();
        },
      );
    }

    if (habitProvider.activeHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first habit',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateHabitScreen(),
                  ),
                ).then((_) {
                  habitProvider.loadHabits();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habitProvider.activeHabits.length,
      itemBuilder: (context, index) {
        final habit = habitProvider.activeHabits[index];
        return HabitCard(
          habit: habit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habitId: habit.id!),
              ),
            ).then((_) {
              habitProvider.loadHabits();
            });
          },
          onTrackTap: () {
            // Show a modal bottom sheet to track the habit
            _showTrackHabitBottomSheet(context, habit.id!);
          },
        );
      },
    );
  }

  Widget _buildStatsTab() {
    final habitProvider = Provider.of<HabitProvider>(context);

    if (habitProvider.isLoading) {
      return const LoadingIndicator();
    }

    if (habitProvider.error != null) {
      return ErrorMessageWidget.simple(
        message: habitProvider.error!,
        onRetry: () {
          habitProvider.loadHabits();
        },
      );
    }

    if (habitProvider.activeHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No habits to analyze',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add habits to see your statistics',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateHabitScreen(),
                  ),
                ).then((_) {
                  habitProvider.loadHabits();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<HabitStat?>>(
      future: _fetchStatsForAllHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator(message: 'Loading statistics...');
        }

        if (snapshot.hasError) {
          return ErrorMessageWidget.simple(
            message: 'Error loading statistics: ${snapshot.error}',
            onRetry: () {
              setState(() {}); // Reload the future
            },
          );
        }

        final stats = snapshot.data;

        if (stats == null || stats.isEmpty) {
          return const Center(child: Text('No statistics available'));
        }

        // Filter out null statistics
        final validStats = stats.where((stat) => stat != null).toList();

        if (validStats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Not enough data yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your habits for a few days to see statistics',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStats(validStats.cast<HabitStat>()),
              const SizedBox(height: 24),
              _buildTopHabits(validStats.cast<HabitStat>()),
              const SizedBox(height: 24),
              _buildCurrentStreaks(validStats.cast<HabitStat>()),
            ],
          ),
        );
      },
    );
  }

  Future<List<HabitStat?>> _fetchStatsForAllHabits() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habits = habitProvider.activeHabits;

    final futures = <Future<HabitStat?>>[];

    for (final habit in habits) {
      if (habit.id != null) {
        futures.add(habitProvider.getStats(habit.id!));
      }
    }

    return await Future.wait(futures);
  }

  Widget _buildOverallStats(List<HabitStat> stats) {
    final totalHabits = stats.length;
    final completedCount = stats.where((stat) => stat.successRate >= 80).length;
    final streakCount = stats.fold<int>(0, (sum, stat) => sum + stat.streak);
    final averageSuccessRate =
        stats.fold<double>(0, (sum, stat) => sum + stat.successRate) /
        totalHabits;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.task_alt,
                  value: '$completedCount/$totalHabits',
                  label: 'On Track',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  value: '$streakCount',
                  label: 'Total Streak Days',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.insights,
                  value: '${averageSuccessRate.toStringAsFixed(1)}%',
                  label: 'Success Rate',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopHabits(List<HabitStat> stats) {
    final habitProvider = Provider.of<HabitProvider>(context);

    // Sort by success rate, descending
    final sortedStats = [...stats]
      ..sort((a, b) => b.successRate.compareTo(a.successRate));
    final topStats = sortedStats.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Habits',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topStats.map((stat) {
              final habit = habitProvider.activeHabits.firstWhere(
                (h) => h.id == stat.habitId,
                orElse: () => habitProvider.activeHabits.first,
              );

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HabitColors.getColor(habit.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    HabitIcons.getIcon(habit.icon),
                    color: HabitColors.getColor(habit.color),
                  ),
                ),
                title: Text(habit.name),
                subtitle: Text(
                  '${stat.successRate.toStringAsFixed(1)}% success rate',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForSuccessRate(stat.successRate),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stat.streak} day streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HabitDetailScreen(habitId: habit.id!),
                    ),
                  ).then((_) {
                    habitProvider.loadHabits();
                  });
                },
              );
            }),

            if (topStats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Track your habits to see your top performers'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStreaks(List<HabitStat> stats) {
    final habitProvider = Provider.of<HabitProvider>(context);

    // Sort by streak, descending
    final sortedStats = [...stats]
      ..sort((a, b) => b.streak.compareTo(a.streak));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Streaks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedStats.map((stat) {
              final habit = habitProvider.activeHabits.firstWhere(
                (h) => h.id == stat.habitId,
                orElse: () => habitProvider.activeHabits.first,
              );

              final streakColor = _getStreakColor(stat.streak);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: streakColor.withOpacity(0.2),
                  child: Text(
                    '${stat.streak}',
                    style: TextStyle(
                      color: streakColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(habit.name),
                subtitle: Text(
                  stat.streak > 0
                      ? 'Keep going! Your streak is building.'
                      : 'Start your streak today!',
                ),
                trailing: Icon(
                  Icons.local_fire_department,
                  color: streakColor,
                  size: 28,
                ),
              );
            }),

            if (sortedStats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No active streaks yet'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSuccessRate(double rate) {
    if (rate >= 80) {
      return Colors.green;
    } else if (rate >= 60) {
      return Colors.lightGreen;
    } else if (rate >= 40) {
      return Colors.amber;
    } else if (rate >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) {
      return Colors.purple;
    } else if (streak >= 14) {
      return Colors.indigo;
    } else if (streak >= 7) {
      return Colors.blue;
    } else if (streak >= 3) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  void _showTrackHabitBottomSheet(BuildContext context, int habitId) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habit = habitProvider.activeHabits.firstWhere((h) => h.id == habitId);

    bool isCompleted = true;
    int value = habit.goal;
    String? notes;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: HabitColors.getColor(
                              habit.color,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            HabitIcons.getIcon(habit.icon),
                            color: HabitColors.getColor(habit.color),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Date
                    Text(
                      'Track for today, ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Completed switch
                    SwitchListTile(
                      title: const Text('Mark as completed'),
                      subtitle: Text(
                        isCompleted
                            ? 'This habit is completed for today'
                            : 'This habit is not completed for today',
                      ),
                      value: isCompleted,
                      onChanged: (newValue) {
                        setState(() {
                          isCompleted = newValue;
                        });
                      },
                    ),

                    // Value counter
                    Row(
                      children: [
                        Text(
                          'How many times?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Goal: ${habit.goal})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed:
                              value > 0
                                  ? () {
                                    setState(() {
                                      value--;
                                      if (value < habit.goal) {
                                        isCompleted = false;
                                      }
                                    });
                                  }
                                  : null,
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          ),
                          child: Text(
                            value.toString(),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              value++;
                              if (value >= habit.goal) {
                                isCompleted = true;
                              }
                            });
                          },
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add notes about your progress today',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (text) {
                        notes = text;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting
                                ? null
                                : () async {
                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  final record = HabitTrackRecord(
                                    habitId: habit.id!,
                                    date: DateTime.now(),
                                    completed: isCompleted,
                                    value: value,
                                    notes: notes,
                                  );

                                  try {
                                    final success = await habitProvider
                                        .trackHabit(record);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${habit.name} tracked successfully!',
                                          ),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Failed to track habit',
                                          ),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      );
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      );
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            isSubmitting
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
