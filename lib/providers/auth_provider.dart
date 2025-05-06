import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthProvider({required AuthService authService})
    : _authService = authService {
    // Check if the user is already logged in
    checkAuthStatus();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      _user = await _authService.getCurrentUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> requestPasswordReset(String email) async {
    _error = null;
    notifyListeners();

    try {
      await _authService.requestPasswordReset(email);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String token, String password) async {
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(token: token, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
