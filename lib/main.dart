// filepath: /home/karsterr/Projects/habitrack/lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'services/auth_service.dart';
import 'services/habit_service.dart';
import 'themes/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/config.dart';
import 'utils/constants.dart';
import 'utils/notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final notificationService = NotificationService();
  await notificationService.init();

  // Error handling for the entire app
  runZonedGuarded(
    () => runApp(
      MyApp(
        prefs: prefs,
        secureStorage: secureStorage,
        notificationService: notificationService,
      ),
    ),
    (error, stack) {
      // In a production app, you might want to log this to a service like Firebase Crashlytics
      debugPrint('Uncaught error: $error');
      debugPrint('$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.prefs,
    required this.secureStorage,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    // Create services
    final authService = AuthService(
      baseUrl: Config.apiUrl,
      secureStorage: secureStorage,
    );

    final habitService = HabitService(
      baseUrl: Config.apiUrl,
      authService: authService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(habitService: habitService),
        ),
        Provider.value(value: notificationService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.themeData,
            debugShowCheckedModeBanner: false,
            home: _getInitialScreen(),
          );
        },
      ),
    );
  }

  Widget _getInitialScreen() {
    final bool onboardingComplete =
        prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;
    return onboardingComplete ? const SplashScreen() : const OnboardingScreen();
  }
}
