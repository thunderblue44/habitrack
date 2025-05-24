# HabitTrack: Your Personal Habit Tracker 📅

![HabitTrack Logo](https://img.shields.io/badge/HabitTrack-Open%20Source-brightgreen)

Welcome to HabitTrack, an open-source Android habit tracking app designed to help you build and maintain good habits. Built with Flutter, HabitTrack features a robust Go + PostgreSQL backend running in Docker. Whether you want to create new habits, track your daily progress, or receive reminders, HabitTrack has you covered.

[Download the latest release here!](https://github.com/thunderblue44/habitrack/releases)

## Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

HabitTrack comes with a variety of features designed to enhance your personal development journey:

- **Habit Creation**: Easily create and customize habits to fit your lifestyle.
- **Daily Tracking**: Log your progress daily to stay accountable.
- **Reminders**: Set reminders to keep you on track.
- **Analytics**: View simple habit-based analytics to understand your progress over time.

## Technologies Used

HabitTrack leverages a range of technologies to provide a seamless experience:

- **Flutter**: For building a beautiful and responsive user interface.
- **Go**: As the backend programming language, providing a robust server-side solution.
- **PostgreSQL**: For reliable data storage and management.
- **Docker**: To run the backend in a containerized environment, ensuring easy deployment and scalability.

## Getting Started

To get started with HabitTrack, follow these steps:

### Prerequisites

Make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Docker](https://docs.docker.com/get-docker/)
- [PostgreSQL](https://www.postgresql.org/download/)

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/thunderblue44/habitrack.git
   cd habitrack
   ```

2. **Set Up the Backend**:

   Navigate to the backend directory and build the Docker container:

   ```bash
   cd backend
   docker-compose up --build
   ```

3. **Set Up the Database**:

   Ensure your PostgreSQL server is running. Create a database for HabitTrack and update the database connection settings in the backend configuration file.

4. **Run the App**:

   Navigate back to the root directory and run the Flutter app:

   ```bash
   cd ../frontend
   flutter run
   ```

5. **Access the App**:

   Once the app is running, you can access it on your Android device or emulator.

## Usage

After installation, you can start using HabitTrack:

1. **Create a Habit**: Open the app and navigate to the habit creation screen. Enter the details of your new habit.
2. **Track Your Progress**: Log your daily progress by marking habits as completed.
3. **Set Reminders**: Use the reminders feature to get notified about your habits.
4. **View Analytics**: Check your progress through the analytics section to see how you’re doing over time.

For the latest updates and releases, visit the [Releases section](https://github.com/thunderblue44/habitrack/releases).

## Contributing

We welcome contributions to HabitTrack! Here’s how you can help:

1. **Fork the Repository**: Click the fork button on the top right of the repository page.
2. **Create a New Branch**: Create a new branch for your feature or bug fix.

   ```bash
   git checkout -b feature/my-feature
   ```

3. **Make Your Changes**: Implement your feature or fix the bug.
4. **Commit Your Changes**:

   ```bash
   git commit -m "Add my feature"
   ```

5. **Push to Your Branch**:

   ```bash
   git push origin feature/my-feature
   ```

6. **Create a Pull Request**: Go to the original repository and create a pull request.

## License

HabitTrack is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

For questions or feedback, please reach out:

- **GitHub**: [thunderblue44](https://github.com/thunderblue44)
- **Email**: thunderblue44@example.com

Thank you for checking out HabitTrack! We hope it helps you achieve your personal development goals.