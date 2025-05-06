# Habitrack

**Habitrack** is an open-source habit tracking mobile application designed for Android. The app helps users build better routines and break bad habits through consistent daily tracking, reminders, and simple insights. It is developed using Flutter for the frontend and Go with PostgreSQL for the backend, containerized via Docker.

---

## ✨ Features

- ✅ User authentication (sign in, sign out, password reset)
- ➕ Add, edit, and delete habits (positive or negative)
- 📅 Daily habit tracking interface
- ⏰ Custom reminders for each habit
- 📊 Basic analytics and progress statistics
- ⚠️ Repeated alerts for bad habits the user wants to reduce

---

## 🛠 Tech Stack

### Mobile App (Flutter)
- Dart & Flutter SDK
- Platform: Android only
- State Management: (add here, e.g., Provider, Riverpod, etc.)
- Local storage: (add if used, e.g., Hive, SharedPreferences)

### Backend (Go + PostgreSQL)
- REST API with Go
- PostgreSQL for data persistence
- Dockerized service for deployment
- Handles:
  - User authentication (JWT)
  - Habit data storage
  - Periodic statistics generation
  - Sync between devices (planned)

---

## 📦 Installation

### Backend
```bash
cd backend
docker compose up --build
