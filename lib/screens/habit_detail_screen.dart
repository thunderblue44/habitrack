import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_track.dart';
import '../providers/habit_provider.dart';
import '../utils/habit_utils.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final int habitId;

  const HabitDetailScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Habit? _habit;
  List<HabitTrackRecord>? _trackingRecords;
  HabitStat? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      // Load habit details
      _habit = await habitProvider.getHabit(widget.habitId);

      if (_habit != null) {
        // Load tracking data for the last 30 days
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 30));

        _trackingRecords = await habitProvider.getTracking(
          widget.habitId,
          startDate: startDate,
          endDate: now,
        );

        // Load stats
        _stats = await habitProvider.getStats(widget.habitId);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: const LoadingIndicator(),
      );
    }

    if (_error != null || _habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: ErrorMessageWidget.simple(
          message: _error ?? 'Failed to load habit details',
          onRetry: _loadData,
        ),
      );
    }

    final habit = _habit!;
    final color = HabitColors.getColor(habit.color);
    final icon = HabitIcons.getIcon(habit.icon);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: habit),
                ),
              ).then((_) {
                _loadData(); // Reload data when returning from edit screen
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(habit),
          _buildHistoryTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTrackHabitDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewTab(Habit habit) {
    final isPositive = habit.type == HabitType.positive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: HabitColors.getColor(habit.color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      HabitIcons.getIcon(habit.icon),
                      color: HabitColors.getColor(habit.color),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${habit.goal}× ${habit.frequencyUnit.toString().split('.').last}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              size: 16,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPositive ? 'Habit to build' : 'Habit to break',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (habit.description.isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(habit.description),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Current streak
          if (_stats != null) ...[
            Text(
              'Current Streak',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_stats!.streak} days',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reminders
          Text(
            'Reminders',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                habit.reminderEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color:
                    habit.reminderEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
              ),
              title: Text(
                habit.reminderEnabled
                    ? 'Reminder at ${habit.reminderTime}'
                    : 'No reminder set',
              ),
              subtitle:
                  habit.reminderEnabled && habit.reminderDays != null
                      ? Text(
                        'On days: ${_formatReminderDays(habit.reminderDays!)}',
                      )
                      : null,
              trailing: TextButton(
                child: const Text('Edit'),
                onPressed: () {
                  // Will implement reminder editing later
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon')));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReminderDays(String reminderDays) {
    final days = reminderDays.split(',');
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((day) => dayNames[int.parse(day) - 1]).join(', ');
  }

  Widget _buildHistoryTab() {
    if (_trackingRecords == null) {
      return const LoadingIndicator();
    }

    if (_trackingRecords!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tracking data yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your habit',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Sort by date (most recent first)
    final sortedRecords = [..._trackingRecords!]
      ..sort((a, b) => b.date.compareTo(a.date));

    final dateFormat = DateFormat('MMM d, yyyy');

    return ListView.builder(
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Icon(
              record.completed ? Icons.check_circle : Icons.circle_outlined,
              color:
                  record.completed
                      ? Colors.green
                      : Theme.of(context).disabledColor,
              size: 28,
            ),
            title: Text(dateFormat.format(record.date)),
            subtitle:
                record.notes != null && record.notes!.isNotEmpty
                    ? Text(record.notes!)
                    : null,
            trailing:
                record.value > 0
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${record.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const LoadingIndicator();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Success Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: _stats!.successRate / 100,
                          strokeWidth: 12,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForSuccessRate(_stats!.successRate),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_stats!.successRate.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'success rate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_stats!.completedDays}/${_stats!.totalDays} days completed',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Current Streak',
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_stats!.streak}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Longest Streak',
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${_stats!.longestStreak}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Add more statistics widgets as needed
        ],
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

  Future<void> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: const Text(
            'Are you sure you want to delete this habit? '
            'All tracking data will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deleteHabit();
    }
  }

  Future<void> _deleteHabit() async {
    if (_habit?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final success = await habitProvider.deleteHabit(_habit!.id!);

      if (success && mounted) {
        Navigator.of(context).pop(); // Return to previous screen
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete habit')));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showTrackHabitDialog() async {
    if (_habit?.id == null) return;

    bool isCompleted = true;
    int value = _habit!.goal;
    String? notes;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
                    ),
                    const SizedBox(height: 16),

                    // Completed switch
                    SwitchListTile(
                      title: const Text('Completed'),
                      value: isCompleted,
                      onChanged: (newValue) {
                        setState(() {
                          isCompleted = newValue;
                        });
                      },
                    ),

                    // Value counter
                    ListTile(
                      title: const Text('Value'),
                      subtitle: Text('Goal: ${_habit!.goal}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                value > 0
                                    ? () {
                                      setState(() {
                                        value--;
                                      });
                                    }
                                    : null,
                          ),
                          Text(
                            value.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                value++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Notes field
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add notes about your progress',
                      ),
                      maxLines: 3,
                      onChanged: (text) {
                        notes = text;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _trackHabit(isCompleted, value, notes);
    }
  }

  Future<void> _trackHabit(bool completed, int value, String? notes) async {
    if (_habit?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      final record = HabitTrackRecord(
        habitId: _habit!.id!,
        date: DateTime.now(),
        completed: completed,
        value: value,
        notes: notes,
      );

      final success = await habitProvider.trackHabit(record);

      if (success) {
        // Reload data to show updated tracking information
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to track habit')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
