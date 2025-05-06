import 'package:flutter/material.dart';

/// A class containing app-wide constants for consistent styling and behavior
class AppConstants {
  // App Information
  static const String appName = 'HabiTrack';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Build Better Habits';
  static const String appDescription =
      'Track your habits and build a better you. HabiTrack helps you create new habits and break bad ones.';

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Layout constants
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 60.0;
  static const double buttonHeight = 56.0;

  // Text sizes
  static const double textSizeSmall = 12.0;
  static const double textSizeDefault = 14.0;
  static const double textSizeLarge = 16.0;
  static const double textSizeHeading = 20.0;
  static const double textSizeTitle = 24.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeDefault = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Streak messages based on streak count
  static final Map<int, String> streakMessages = {
    1: 'Great start! Keep it up!',
    3: 'Three days in a row! Nice progress!',
    7: 'A whole week! You\'re building momentum!',
    14: 'Two weeks strong! You\'re developing a real habit!',
    21: 'Three weeks! Science says you\'re forming a habit!',
    30: 'A full month! You\'re amazing!',
    60: 'Two months! This habit is becoming part of who you are!',
    90: 'Three months! Incredible consistency!',
    180: 'Six months! You\'re an inspiration!',
    365: 'A FULL YEAR! You\'re unstoppable!',
  };

  // Helper to get the appropriate streak message
  static String getStreakMessage(int streakCount) {
    // Find the highest threshold that's less than or equal to the streak count
    final thresholds = streakMessages.keys.toList()..sort();
    String message = 'Keep it up!';

    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (streakCount >= thresholds[i]) {
        message = streakMessages[thresholds[i]]!;
        break;
      }
    }

    return message;
  }

  // Form validation patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
  );

  // Date formats
  static const String dateFormatFull = 'MMMM d, yyyy';
  static const String dateFormatShort = 'MMM d, yyyy';
  static const String dateFormatCompact = 'MM/dd/yy';
  static const String timeFormat = 'h:mm a';

  // Navigation routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String habitDetailRoute = '/habit/detail';
  static const String createHabitRoute = '/habit/create';
  static const String editHabitRoute = '/habit/edit';

  // Shared Preference Keys
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefDailyReminderTime = 'daily_reminder_time';
}
