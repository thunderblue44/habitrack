import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;

  AuthService({required this.baseUrl, required this.secureStorage});

  bool devMode = true;

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to register');
    }

    final data = json.decode(response.body);
    await _saveTokens(data['token'], data['refresh_token']);
  }

  Future<User> login({required String email, required String password}) async {
    if (devMode) {
      // Convert the integer to a string
      return User(
        id: '9999', // Convert to String since User expects a String id
        username: 'dev-user',
        email: email,
        createdAt: DateTime.now(),
      );
    }

    final url = Uri.parse('$baseUrl/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to login');
    }

    final data = json.decode(response.body);
    await _saveTokens(data['token'], data['refresh_token']);

    return User(
      id: data['user_id'],
      username: data['username'],
      email: data['email'],
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<User> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/api/v1/user/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user info');
    }

    final data = json.decode(response.body);
    return User.fromJson(data);
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return false;
      }

      final url = Uri.parse('$baseUrl/api/v1/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 200) {
        // If refresh token is invalid, logout the user
        await logout();
        return false;
      }

      final data = json.decode(response.body);
      await _saveTokens(data['token'], data['refresh_token']);
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to request password reset');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token, 'password': password}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to reset password');
    }
  }

  Future<void> _saveTokens(String token, String refreshToken) async {
    await secureStorage.write(key: 'auth_token', value: token);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
