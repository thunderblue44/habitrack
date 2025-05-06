# Habitrack Backend

This folder contains the backend API for the Habitrack habit tracking application. It's built with Go and uses PostgreSQL for data storage.

## Features

- User authentication (register, login, password reset)
- JWT-based authentication
- Habit management (create, read, update, delete)
- Daily habit tracking
- Statistics and analytics
- Custom reminders for habits

## Development Setup

### Prerequisites

- Go 1.21 or later
- PostgreSQL 15 or later
- Docker and Docker Compose (optional, for containerized setup)

### Local Development

1. Clone the repository
2. Copy the `.env.example` file to `.env` and update the values as needed:
   ```
   cp .env.example .env
   ```
3. Install dependencies:
   ```
   go mod download
   ```
4. Run the application:
   ```
   go run main.go
   ```

### Docker Setup

To run the backend with Docker:

```
docker compose up --build
```

This will start the PostgreSQL database and the backend API.

## API Endpoints

### Authentication

- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Log in with email and password
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password` - Reset password with token

### User

- `GET /api/v1/user/me` - Get current user profile

### Habits

- `GET /api/v1/habits` - List all habits
- `POST /api/v1/habits` - Create a new habit
- `GET /api/v1/habits/:id` - Get a habit by ID
- `PUT /api/v1/habits/:id` - Update a habit
- `DELETE /api/v1/habits/:id` - Delete a habit

### Habit Tracking

- `POST /api/v1/habits/:id/track` - Track a habit for a date
- `GET /api/v1/habits/:id/tracking` - Get tracking records for a habit
- `GET /api/v1/habits/:id/stats` - Get statistics for a habit

## Project Structure

- `cmd/` - Command-line entry points
- `config/` - Configuration handling
- `internal/` - Internal packages
  - `handlers/` - HTTP request handlers
  - `middleware/` - HTTP middleware components
- `migrations/` - Database migration files
- `models/` - Data models and database operations
- `routes/` - API route definitions
- `utils/` - Utility functions
