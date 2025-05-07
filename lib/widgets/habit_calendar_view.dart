import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/habit_track.dart';

class HabitCalendarView extends StatefulWidget {
  final List<HabitTrackRecord> tracks;
  final Color habitColor;
  final DateTime firstDate;

  const HabitCalendarView({
    super.key,
    required this.tracks,
    required this.habitColor,
    required this.firstDate,
  });

  @override
  State<HabitCalendarView> createState() => _HabitCalendarViewState();
}

class _HabitCalendarViewState extends State<HabitCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<HabitTrackRecord>> _eventsByDay;
  late int _currentStreak;
  late int _longestStreak;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _processEvents();
    _calculateStreaks();
  }

  @override
  void didUpdateWidget(HabitCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tracks != widget.tracks) {
      _processEvents();
      _calculateStreaks();
    }
  }

  void _processEvents() {
    _eventsByDay = {};
    for (final track in widget.tracks) {
      final day = DateTime(track.date.year, track.date.month, track.date.day);
      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }
      _eventsByDay[day]!.add(track);
    }
  }

  void _calculateStreaks() {
    if (widget.tracks.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    // Sort tracks by date in descending order
    final sortedTracks = List<HabitTrackRecord>.from(widget.tracks)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate current streak
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    bool isContinuous = false;
    int streak = 0;
    DateTime lastDate = todayDate;

    for (final track in sortedTracks) {
      final trackDay = DateTime(
        track.date.year,
        track.date.month,
        track.date.day,
      );

      // Check if this is first iteration
      if (!isContinuous) {
        // If first tracked date is today, streak starts
        if (trackDay.isAtSameMomentAs(todayDate)) {
          streak = 1;
          lastDate = todayDate;
          isContinuous = true;
        }
        // If first tracked date is yesterday, streak starts
        else if (trackDay.isAtSameMomentAs(
          todayDate.subtract(const Duration(days: 1)),
        )) {
          streak = 1;
          lastDate = trackDay;
          isContinuous = true;
        } else {
          // If first tracked date is older than yesterday, no current streak
          break;
        }
      } else {
        // Check if the track date is one day before the last date we saw
        if (trackDay.isAtSameMomentAs(
          lastDate.subtract(const Duration(days: 1)),
        )) {
          streak++;
          lastDate = trackDay;
        } else if (trackDay.isAtSameMomentAs(lastDate)) {
          // Same day, ignore
          continue;
        } else {
          // Gap in streak
          break;
        }
      }
    }

    _currentStreak = streak;

    // Calculate longest streak
    int longestStreak = 0;
    int currentLongest = 0;
    DateTime? prevDate;

    // Sort tracks by date in ascending order
    sortedTracks.sort((a, b) => a.date.compareTo(b.date));

    for (final track in sortedTracks) {
      final trackDay = DateTime(
        track.date.year,
        track.date.month,
        track.date.day,
      );

      if (prevDate == null) {
        // First event
        currentLongest = 1;
        prevDate = trackDay;
      } else {
        // Calculate difference in days
        final difference = trackDay.difference(prevDate).inDays;

        if (difference == 1) {
          // Consecutive day
          currentLongest++;
        } else if (difference > 1) {
          // Break in streak - reset
          longestStreak =
              longestStreak < currentLongest ? currentLongest : longestStreak;
          currentLongest = 1;
        }
        // If same day, ignore (difference == 0)

        prevDate = trackDay;
      }
    }

    // Check final streak
    longestStreak =
        longestStreak < currentLongest ? currentLongest : longestStreak;

    _longestStreak = longestStreak;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStreakInfo(),
        const SizedBox(height: 16),
        _buildCalendar(),
        const SizedBox(height: 16),
        _buildSelectedDayInfo(),
      ],
    );
  }

  Widget _buildStreakInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStreakItem(
          title: 'Current Streak',
          value: _currentStreak,
          icon: Icons.local_fire_department,
          color: _currentStreak > 0 ? Colors.orange : Colors.grey,
        ),
        _buildStreakItem(
          title: 'Longest Streak',
          value: _longestStreak,
          icon: Icons.emoji_events,
          color: _longestStreak > 0 ? Colors.amber : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStreakItem({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
              .animate(
                onPlay:
                    (controller) => controller.repeat(
                      reverse: true,
                      period: const Duration(seconds: 2),
                    ),
              )
              .scaleXY(end: value > 0 ? 1.1 : 1.0, begin: 1.0),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: widget.firstDate,
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return _eventsByDay[normalizedDay] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: widget.habitColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: widget.habitColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: widget.habitColor,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final tracks = _getTracksForDay(_selectedDay);

    if (tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No tracking data for ${DateFormat.yMMMMd().format(_selectedDay)}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd().format(_selectedDay),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Completed ${tracks.length} ${tracks.length == 1 ? 'time' : 'times'}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.habitColor.withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: widget.habitColor),
                  ),
                ),
                title: Text(DateFormat.jm().format(track.date)),
                subtitle:
                    track.notes?.isNotEmpty == true ? Text(track.notes!) : null,
              );
            },
          ),
        ],
      ),
    );
  }

  List<HabitTrackRecord> _getTracksForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final tracks = _eventsByDay[normalizedDay] ?? [];
    return tracks..sort((a, b) => a.date.compareTo(b.date));
  }
}
