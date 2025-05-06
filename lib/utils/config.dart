class Config {
  // API configuration
  static const String apiUrl = 'http://localhost:8080/api/v1';

  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // Habit endpoints
  static const String habitsEndpoint = '/habits';
  static const String habitTrackingEndpoint = '/habits/tracking';
  static const String habitStatsEndpoint = '/habits/stats';

  // User endpoints
  static const String userEndpoint = '/users';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themePreferenceKey = 'theme_preference';

  // App settings
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 30);
  static const Duration apiTimeout = Duration(seconds: 30);
}
