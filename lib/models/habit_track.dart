class HabitTrackRecord {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool completed;
  final int value;
  final String? notes;

  HabitTrackRecord({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.value = 0,
    this.notes,
  });

  factory HabitTrackRecord.fromJson(Map<String, dynamic> json) {
    return HabitTrackRecord(
      id: json['id'],
      habitId: json['habit_id'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      value: json['value'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T')[0],
      'completed': completed,
      'value': value,
      'notes': notes,
    };
  }

  HabitTrackRecord copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
    int? value,
    String? notes,
  }) {
    return HabitTrackRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      value: value ?? this.value,
      notes: notes ?? this.notes,
    );
  }
}

class HabitStat {
  final int? id;
  final int userId;
  final int habitId;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int completedDays;
  final double successRate;
  final int streak;
  final int longestStreak;
  final DateTime calculatedAt;

  HabitStat({
    this.id,
    required this.userId,
    required this.habitId,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.completedDays,
    required this.successRate,
    required this.streak,
    required this.longestStreak,
    required this.calculatedAt,
  });

  factory HabitStat.fromJson(Map<String, dynamic> json) {
    return HabitStat(
      id: json['id'],
      userId: json['user_id'],
      habitId: json['habit_id'],
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'],
      completedDays: json['completed_days'],
      successRate:
          (json['success_rate'] is int)
              ? json['success_rate'].toDouble()
              : json['success_rate'],
      streak: json['streak'],
      longestStreak: json['longest_streak'],
      calculatedAt: DateTime.parse(json['calculated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'completed_days': completedDays,
      'success_rate': successRate,
      'streak': streak,
      'longest_streak': longestStreak,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}
