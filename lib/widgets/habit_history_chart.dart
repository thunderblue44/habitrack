import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_track.dart';
import '../utils/constants.dart';

enum ChartPeriod { week, month, year, all }

class HabitHistoryChart extends StatefulWidget {
  final List<HabitTrackRecord> habitTracks;
  final Color color;

  const HabitHistoryChart({
    super.key,
    required this.habitTracks,
    required this.color,
  });

  @override
  State<HabitHistoryChart> createState() => _HabitHistoryChartState();
}

class _HabitHistoryChartState extends State<HabitHistoryChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    if (widget.habitTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No tracking data available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your habit to see progress here',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Period selector
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildChart(),
          ),
        ),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SegmentedButton<ChartPeriod>(
        segments: const [
          ButtonSegment(value: ChartPeriod.week, label: Text('Week')),
          ButtonSegment(value: ChartPeriod.month, label: Text('Month')),
          ButtonSegment(value: ChartPeriod.year, label: Text('Year')),
          ButtonSegment(value: ChartPeriod.all, label: Text('All')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<ChartPeriod> selection) {
          setState(() {
            _selectedPeriod = selection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return widget.color.withOpacity(0.8);
            }
            return Colors.transparent;
          }),
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Filter data based on selected period
    final filteredData = _filterDataByPeriod(
      widget.habitTracks,
      _selectedPeriod,
    );

    // Group data by day
    final groupedData = _groupDataByDay(filteredData);

    if (groupedData.isEmpty) {
      return Center(
        child: Text(
          'No data for selected period',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // Calculate max value for Y axis
    final maxValue =
        groupedData.values.reduce((a, b) => a > b ? a : b).toDouble();

    // Create bar chart data
    final barGroups =
        groupedData.entries.map((entry) {
          final index = groupedData.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: widget.color,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2, // Add some space at the top
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < groupedData.keys.length) {
                  final day = groupedData.keys.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDateForChart(day, _selectedPeriod),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Completed'),
          const SizedBox(width: 24),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Target'),
        ],
      ),
    );
  }

  List<HabitTrackRecord> _filterDataByPeriod(
    List<HabitTrackRecord> data,
    ChartPeriod period,
  ) {
    final now = DateTime.now();

    switch (period) {
      case ChartPeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );
        return data
            .where(
              (track) => track.date.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ),
            )
            .toList();

      case ChartPeriod.month:
        final monthStart = DateTime(now.year, now.month, 1);
        return data
            .where(
              (track) => track.date.isAfter(
                monthStart.subtract(const Duration(seconds: 1)),
              ),
            )
            .toList();

      case ChartPeriod.year:
        final yearStart = DateTime(now.year, 1, 1);
        return data
            .where(
              (track) => track.date.isAfter(
                yearStart.subtract(const Duration(seconds: 1)),
              ),
            )
            .toList();

      case ChartPeriod.all:
      default:
        return data;
    }
  }

  Map<DateTime, int> _groupDataByDay(List<HabitTrackRecord> data) {
    final Map<DateTime, int> result = {};

    for (final track in data) {
      final dateKey = DateTime(
        track.date.year,
        track.date.month,
        track.date.day,
      );
      if (result.containsKey(dateKey)) {
        result[dateKey] = result[dateKey]! + 1;
      } else {
        result[dateKey] = 1;
      }
    }

    // Sort by date
    final sortedKeys = result.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (var key in sortedKeys) key: result[key]!};
  }

  String _formatDateForChart(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.week:
        return DateFormat('E').format(date);
      case ChartPeriod.month:
        return DateFormat('d').format(date);
      case ChartPeriod.year:
        return DateFormat('MMM').format(date);
      case ChartPeriod.all:
        return DateFormat('MMM d').format(date);
    }
  }
}
