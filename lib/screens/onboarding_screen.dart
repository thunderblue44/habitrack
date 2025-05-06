import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to HabiTrack',
      'description':
          'Your personal habit tracking companion to help you build better habits and achieve your goals.',
      'image': 'assets/images/onboarding_welcome.png',
      'color': Colors.blue,
      'icon': Icons.track_changes,
    },
    {
      'title': 'Track Daily Progress',
      'description':
          'Create habits, set goals, and track your daily progress. See your streaks grow as you stay consistent.',
      'image': 'assets/images/onboarding_track.png',
      'color': Colors.green,
      'icon': Icons.check_circle_outline,
    },
    {
      'title': 'Analyze Your Trends',
      'description':
          'View detailed statistics and visualizations to understand your behavior patterns over time.',
      'image': 'assets/images/onboarding_stats.png',
      'color': Colors.purple,
      'icon': Icons.insert_chart,
    },
    {
      'title': 'Stay Motivated',
      'description':
          'Set reminders, earn streaks, and celebrate your wins to stay motivated on your journey.',
      'image': 'assets/images/onboarding_motivation.png',
      'color': Colors.orange,
      'icon': Icons.emoji_events,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _numPages - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return _buildOnboardingPage(
                    title: data['title'],
                    description: data['description'],
                    imagePath: data['image'],
                    color: data['color'],
                    icon: data['icon'],
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _numPages,
                (index) => _buildDotIndicator(index == _currentPage),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _numPages - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: AppConstants.mediumAnimationDuration,
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String imagePath,
    required Color color,
    required IconData icon,
  }) {
    // Check if image exists, if not use a fallback
    bool imageExists = true;
    // In a real app, we would check if the image exists

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or icon
          imageExists
              ? Image.asset(
                imagePath,
                height: 240,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 100, color: color),
                  );
                },
              )
              : Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 100, color: color),
              ),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color:
            isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
