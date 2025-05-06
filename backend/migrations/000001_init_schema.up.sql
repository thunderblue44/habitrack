-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    last_login TIMESTAMP,
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMP
);

-- Create habits table
CREATE TABLE IF NOT EXISTS habits (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(20) NOT NULL CHECK (type IN ('positive', 'negative')),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    goal INTEGER NOT NULL DEFAULT 1,
    frequency_unit VARCHAR(20) NOT NULL CHECK (frequency_unit IN ('daily', 'weekly', 'monthly')) DEFAULT 'daily',
    reminder_enabled BOOLEAN NOT NULL DEFAULT false,
    reminder_time VARCHAR(5),
    reminder_days VARCHAR(20),
    color VARCHAR(7),
    icon VARCHAR(50),
    is_archived BOOLEAN NOT NULL DEFAULT false
);

-- Create habit tracking records table
CREATE TABLE IF NOT EXISTS habit_tracks (
    id SERIAL PRIMARY KEY,
    habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT false,
    value INTEGER DEFAULT 0,
    notes TEXT,
    UNIQUE(habit_id, date)
);

-- Create habit stats table
CREATE TABLE IF NOT EXISTS habit_stats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    period VARCHAR(20) NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    completed_days INTEGER NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    calculated_at TIMESTAMP NOT NULL,
    UNIQUE(habit_id, period, start_date, end_date)
);
