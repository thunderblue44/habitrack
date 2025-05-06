import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_track.dart';
import '../services/habit_service.dart';

class HabitProvider with ChangeNotifier {
  final HabitService _habitService;
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  HabitProvider({required HabitService habitService})
    : _habitService = habitService;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Habit> get activeHabits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();

  Future<void> loadHabits({bool includeArchived = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _habitService.getAllHabits(
        includeArchived: includeArchived,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Habit?> getHabit(int habitId) async {
    try {
      return await _habitService.getHabit(habitId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createHabit(Habit habit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newHabit = await _habitService.createHabit(habit);
      _habits.add(newHabit);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHabit(Habit habit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedHabit = await _habitService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(int habitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _habitService.deleteHabit(habitId);
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits.removeAt(index);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> trackHabit(HabitTrackRecord record) async {
    _error = null;

    try {
      await _habitService.trackHabit(record);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<HabitTrackRecord>?> getTracking(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _error = null;

    try {
      return await _habitService.getTracking(
        habitId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<HabitStat?> getStats(int habitId, {String period = 'weekly'}) async {
    _error = null;

    try {
      return await _habitService.getStats(habitId, period: period);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
