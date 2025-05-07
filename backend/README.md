# HabiTrack - Habit Tracking Application

HabiTrack is a comprehensive habit tracking application built with Flutter that helps users build and maintain positive habits through daily tracking, reminders, and insightful statistics.

## Features

- **Habit Management**: Create, edit, and delete personal habits
- **Daily Tracking**: Mark habits as complete and track your progress over time
- **Custom Reminders**: Set custom notifications to remind you of your habits
- **Detailed Statistics**: View success rates, streaks, and progress visualizations
- **User Authentication**: Secure login and registration system
- **Dark/Light Mode**: Customize your app appearance

## Technology Stack

- **Frontend**: Flutter/Dart
- **State Management**: Provider
- **Local Storage**: Flutter Secure Storage, Shared Preferences
- **Notifications**: Flutter Local Notifications
- **Backend API Integration**: REST API support

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK or iOS development tools

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/KARSTERRR/habitrack.git
   cd habitrack
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration

The app uses a configuration file for environment-specific settings. Update the values in config.dart to match your development or production environment:

```dart
// Example configuration
static const String host = "192.168.1.120";  // Your backend server IP
static const int port = 8080;                // Your backend server port
```

## Project Structure

```
lib/
├── models/            # Data models
├── providers/         # State management
├── screens/           # UI screens
├── services/          # API services
├── themes/            # App themes
├── utils/             # Utilities and helpers
└── widgets/           # Reusable UI components
```

## Development

### Testing

To run tests:

```bash
flutter test
```

### Build for Production

To generate a release build:

```bash
flutter build apk --release
```

or for iOS:

```bash
flutter build ios --release
```

## Developer Notes

- The app includes a development mode in the AuthService class to facilitate testing. Set `devMode = true` to bypass actual authentication.
- When testing, any email/password combination will work in dev mode.
- Model classes use consistent ID types - be careful when modifying models as type mismatches between String and int IDs can occur.

## Future Enhancements

- Social sharing capabilities
- Community challenges
- Habit categories and tags
- Advanced statistics and analytics
- Cross-platform synchronization

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

_HabiTrack - Build better habits, one day at a time._

Similar code found with 2 license types
