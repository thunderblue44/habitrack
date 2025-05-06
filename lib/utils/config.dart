class Config {
  // Your development machine's WiFi IP address
  static const String host = "192.168.1.120";

  // The port your backend is running on
  static const int port = 8080;

  // Base URLs
  static String get apiUrl => "http://$host:$port/api/v1";
  static String get authUrl => "$apiUrl/auth";
  static String get habitsUrl => "$apiUrl/habits";

  // Add other endpoints as needed
  static String get usersUrl => "$apiUrl/users";
  static String get statsUrl => "$apiUrl/stats";

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
