import 'package:flutter/material.dart';
import '../utils/habit_utils.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback? onTrackTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = HabitColors.getColor(habit.color);
    final icon = HabitIcons.getIcon(habit.icon);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          habit.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onTrackTap != null) ...[
                    const SizedBox(width: 8.0),
                    Material(
                      color: color,
                      borderRadius: BorderRadius.circular(12.0),
                      child: InkWell(
                        onTap: onTrackTap,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            'Track',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGoalIndicator(context),
                  _buildTypeIndicator(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalIndicator(BuildContext context) {
    String goalText;
    switch (habit.frequencyUnit) {
      case FrequencyUnit.daily:
        goalText = '${habit.goal}× daily';
        break;
      case FrequencyUnit.weekly:
        goalText = '${habit.goal}× weekly';
        break;
      case FrequencyUnit.monthly:
        goalText = '${habit.goal}× monthly';
        break;
    }

    return Row(
      children: [
        Icon(
          Icons.flag_outlined,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4.0),
        Text(goalText, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTypeIndicator(BuildContext context) {
    final isPositive = habit.type == HabitType.positive;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
          size: 16,
          color: isPositive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4.0),
        Text(
          isPositive ? 'Build' : 'Break',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
