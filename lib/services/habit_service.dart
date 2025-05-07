import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_track.dart';
import 'auth_service.dart';

class HabitService {
  final String baseUrl;
  final AuthService authService;
  final http.Client _client = http.Client();

  HabitService({required this.baseUrl, required this.authService});

  // Get all habits for the current user
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse(
      '$baseUrl/api/v1/habits${includeArchived ? '?include_archived=true' : ''}',
    );

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habits');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Habit.fromJson(json)).toList();
  }

  // Get a single habit by ID
  Future<Habit> getHabit(int habitId) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/api/v1/habits/$habitId');

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habit');
    }

    final data = json.decode(response.body);
    return Habit.fromJson(data);
  }

  // Create a new habit
  Future<Habit> createHabit(Habit habit) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/api/v1/habits');

    final response = await _client.post(
      url,
      headers: headers,
      body: json.encode(habit.toJson()),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create habit');
    }

    final data = json.decode(response.body);
    return Habit.fromJson(data);
  }

  // Update an existing habit
  Future<Habit> updateHabit(Habit habit) async {
    if (habit.id == null) {
      throw Exception('Cannot update habit without an ID');
    }

    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/api/v1/habits/${habit.id}');

    final response = await _client.put(
      url,
      headers: headers,
      body: json.encode(habit.toJson()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update habit');
    }

    final data = json.decode(response.body);
    return Habit.fromJson(data);
  }

  // Delete (archive) a habit
  Future<void> deleteHabit(int habitId) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/api/v1/habits/$habitId');

    final response = await _client.delete(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete habit');
    }
  }

  // Track a habit for a specific date
  Future<HabitTrackRecord> trackHabit(HabitTrackRecord record) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse('$baseUrl/api/v1/habits/${record.habitId}/track');

    final response = await _client.post(
      url,
      headers: headers,
      body: json.encode(record.toJson()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to track habit');
    }

    final data = json.decode(response.body);
    return HabitTrackRecord.fromJson(data);
  }

  // Get tracking records for a habit
  Future<List<HabitTrackRecord>> getTracking(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final headers = await authService.getAuthHeaders();

    var queryParams = '';
    if (startDate != null) {
      queryParams += '?start_date=${startDate.toIso8601String().split('T')[0]}';
    }
    if (endDate != null) {
      queryParams += queryParams.isEmpty ? '?' : '&';
      queryParams += 'end_date=${endDate.toIso8601String().split('T')[0]}';
    }

    final url = Uri.parse(
      '$baseUrl/api/v1/habits/$habitId/tracking$queryParams',
    );

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get tracking data');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => HabitTrackRecord.fromJson(json)).toList();
  }

  // Get statistics for a habit
  Future<HabitStat> getStats(int habitId, {String period = 'weekly'}) async {
    final headers = await authService.getAuthHeaders();
    final url = Uri.parse(
      '$baseUrl/api/v1/habits/$habitId/stats?period=$period',
    );

    final response = await _client.get(url, headers: headers);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to get habit stats');
    }

    final data = json.decode(response.body);
    return HabitStat.fromJson(data);
  }
}
