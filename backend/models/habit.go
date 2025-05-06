package models

import (
	"database/sql"
	"errors"
	"time"
)

// HabitType represents the type of habit (positive or negative)
type HabitType string

const (
	PositiveHabit HabitType = "positive" // Habits to build
	NegativeHabit HabitType = "negative" // Habits to break
)

// Habit model for tracking habits
type Habit struct {
	ID          int64     `json:"id"`
	UserID      int64     `json:"user_id"`
	Name        string    `json:"name" validate:"required,min=1,max=100"`
	Description string    `json:"description" validate:"max=500"`
	Type        HabitType `json:"type" validate:"required,oneof=positive negative"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Goal        int       `json:"goal"` // Target frequency (e.g., 3 times per week)
	FrequencyUnit string  `json:"frequency_unit" validate:"required,oneof=daily weekly monthly"` // daily, weekly, monthly
	ReminderEnabled bool  `json:"reminder_enabled"`
	ReminderTime   string `json:"reminder_time"` // Format: "HH:MM"
	ReminderDays   string `json:"reminder_days"` // Comma-separated days: "1,2,3,4,5,6,7" (Monday=1, Sunday=7)
	Color         string  `json:"color" validate:"max=7"` // Color code for UI display
	Icon          string  `json:"icon" validate:"max=50"` // Icon name for UI display
	IsArchived    bool    `json:"is_archived"` // Whether habit is archived
}

// HabitTrackRecord model for tracking daily habit completion
type HabitTrackRecord struct {
	ID        int64     `json:"id"`
	HabitID   int64     `json:"habit_id"`
	Date      time.Time `json:"date"`
	Completed bool      `json:"completed"`
	Value     int       `json:"value"` // Optional value (e.g., 8 glasses of water)
	Notes     string    `json:"notes" validate:"max=500"`
}

// Stat model for storing calculated statistics
type Stat struct {
	ID           int64     `json:"id"`
	UserID       int64     `json:"user_id"`
	HabitID      int64     `json:"habit_id"`
	Period       string    `json:"period"` // "daily", "weekly", "monthly", "yearly"
	StartDate    time.Time `json:"start_date"`
	EndDate      time.Time `json:"end_date"`
	TotalDays    int       `json:"total_days"`
	CompletedDays int      `json:"completed_days"`
	SuccessRate  float64   `json:"success_rate"` // Percentage of completion
	Streak       int       `json:"streak"` // Current streak
	LongestStreak int      `json:"longest_streak"`
	CalculatedAt time.Time `json:"calculated_at"`
}

// HabitRepository handles database operations for habits
type HabitRepository struct {
	DB *sql.DB
}

// NewHabitRepository creates a new habit repository
func NewHabitRepository(db *sql.DB) *HabitRepository {
	return &HabitRepository{DB: db}
}

// Create inserts a new habit in the database
func (r *HabitRepository) Create(habit *Habit) error {
	now := time.Now()
	habit.CreatedAt = now
	habit.UpdatedAt = now

	query := `
        INSERT INTO habits (
            user_id, name, description, type, created_at, updated_at,
            goal, frequency_unit, reminder_enabled, reminder_time, reminder_days,
            color, icon, is_archived
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
        RETURNING id`

	err := r.DB.QueryRow(
		query,
		habit.UserID,
		habit.Name,
		habit.Description,
		habit.Type,
		habit.CreatedAt,
		habit.UpdatedAt,
		habit.Goal,
		habit.FrequencyUnit,
		habit.ReminderEnabled,
		habit.ReminderTime,
		habit.ReminderDays,
		habit.Color,
		habit.Icon,
		habit.IsArchived,
	).Scan(&habit.ID)

	return err
}

// GetByID retrieves a habit by ID and user ID (for security)
func (r *HabitRepository) GetByID(id int64, userID int64) (*Habit, error) {
	habit := &Habit{}
	query := `
        SELECT 
            id, user_id, name, description, type, created_at, updated_at,
            goal, frequency_unit, reminder_enabled, reminder_time, reminder_days,
            color, icon, is_archived
        FROM habits
        WHERE id = $1 AND user_id = $2`

	err := r.DB.QueryRow(query, id, userID).Scan(
		&habit.ID,
		&habit.UserID,
		&habit.Name,
		&habit.Description,
		&habit.Type,
		&habit.CreatedAt,
		&habit.UpdatedAt,
		&habit.Goal,
		&habit.FrequencyUnit,
		&habit.ReminderEnabled,
		&habit.ReminderTime,
		&habit.ReminderDays,
		&habit.Color,
		&habit.Icon,
		&habit.IsArchived,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("habit not found")
		}
		return nil, err
	}

	return habit, nil
}

// Update updates a habit
func (r *HabitRepository) Update(habit *Habit) error {
	habit.UpdatedAt = time.Now()

	query := `
        UPDATE habits
        SET 
            name = $1, 
            description = $2, 
            type = $3, 
            updated_at = $4,
            goal = $5, 
            frequency_unit = $6, 
            reminder_enabled = $7, 
            reminder_time = $8, 
            reminder_days = $9,
            color = $10, 
            icon = $11, 
            is_archived = $12
        WHERE id = $13 AND user_id = $14`

	_, err := r.DB.Exec(
		query,
		habit.Name,
		habit.Description,
		habit.Type,
		habit.UpdatedAt,
		habit.Goal,
		habit.FrequencyUnit,
		habit.ReminderEnabled,
		habit.ReminderTime,
		habit.ReminderDays,
		habit.Color,
		habit.Icon,
		habit.IsArchived,
		habit.ID,
		habit.UserID,
	)

	return err
}

// Delete deletes a habit (soft delete by archiving)
func (r *HabitRepository) Delete(id int64, userID int64) error {
	query := `
        UPDATE habits
        SET is_archived = true, updated_at = $1
        WHERE id = $2 AND user_id = $3`

	result, err := r.DB.Exec(query, time.Now(), id, userID)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return errors.New("habit not found or already deleted")
	}

	return nil
}

// GetAllByUser retrieves all habits for a user
func (r *HabitRepository) GetAllByUser(userID int64, includeArchived bool) ([]*Habit, error) {
	query := `
        SELECT 
            id, user_id, name, description, type, created_at, updated_at,
            goal, frequency_unit, reminder_enabled, reminder_time, reminder_days,
            color, icon, is_archived
        FROM habits
        WHERE user_id = $1`

	if !includeArchived {
		query += " AND is_archived = false"
	}

	query += " ORDER BY created_at DESC"

	rows, err := r.DB.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	habits := make([]*Habit, 0)
	for rows.Next() {
		habit := &Habit{}
		err := rows.Scan(
			&habit.ID,
			&habit.UserID,
			&habit.Name,
			&habit.Description,
			&habit.Type,
			&habit.CreatedAt,
			&habit.UpdatedAt,
			&habit.Goal,
			&habit.FrequencyUnit,
			&habit.ReminderEnabled,
			&habit.ReminderTime,
			&habit.ReminderDays,
			&habit.Color,
			&habit.Icon,
			&habit.IsArchived,
		)
		if err != nil {
			return nil, err
		}
		habits = append(habits, habit)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return habits, nil
}

// TrackRepository handles database operations for habit tracking records
type TrackRepository struct {
	DB *sql.DB
}

// NewTrackRepository creates a new track repository
func NewTrackRepository(db *sql.DB) *TrackRepository {
	return &TrackRepository{DB: db}
}

// TrackHabit records a habit tracking event
func (r *TrackRepository) TrackHabit(record *HabitTrackRecord) error {
	query := `
        INSERT INTO habit_tracks (habit_id, date, completed, value, notes)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (habit_id, date)
        DO UPDATE SET completed = $3, value = $4, notes = $5
        RETURNING id`

	err := r.DB.QueryRow(
		query,
		record.HabitID,
		record.Date,
		record.Completed,
		record.Value,
		record.Notes,
	).Scan(&record.ID)

	return err
}

// GetTracking retrieves habit tracking records for a date range
func (r *TrackRepository) GetTracking(habitID int64, startDate, endDate time.Time) ([]*HabitTrackRecord, error) {
	query := `
        SELECT id, habit_id, date, completed, value, notes
        FROM habit_tracks
        WHERE habit_id = $1 AND date >= $2 AND date <= $3
        ORDER BY date ASC`

	rows, err := r.DB.Query(query, habitID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	records := make([]*HabitTrackRecord, 0)
	for rows.Next() {
		record := &HabitTrackRecord{}
		err := rows.Scan(
			&record.ID,
			&record.HabitID,
			&record.Date,
			&record.Completed,
			&record.Value,
			&record.Notes,
		)
		if err != nil {
			return nil, err
		}
		records = append(records, record)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return records, nil
}

// StatRepository handles database operations for statistics
type StatRepository struct {
	DB *sql.DB
}

// NewStatRepository creates a new stat repository
func NewStatRepository(db *sql.DB) *StatRepository {
	return &StatRepository{DB: db}
}

// UpdateStats calculates and stores statistics for a habit
func (r *StatRepository) UpdateStats(habitID int64, userID int64) (*Stat, error) {
	// This is a simplified version - in a real app, this would be more sophisticated
	// and would likely use database functions or a background worker
	
	// Get current time
	now := time.Now()
	
	// Calculate start and end dates for weekly stats (last 7 days)
	endDate := now.Truncate(24 * time.Hour)
	startDate := endDate.AddDate(0, 0, -6) // Last 7 days
	
	// Get habit tracking records for the date range
	trackRepo := NewTrackRepository(r.DB)
	records, err := trackRepo.GetTracking(habitID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	
	// Calculate statistics
	totalDays := 7
	completedDays := 0
	streak := 0
	longestStreak := 0
	currentStreak := 0
	
	for _, record := range records {
		if record.Completed {
			completedDays++
			currentStreak++
			if currentStreak > longestStreak {
				longestStreak = currentStreak
			}
		} else {
			if currentStreak > streak {
				streak = currentStreak
			}
			currentStreak = 0
		}
	}
	
	// Set final streak
	if currentStreak > streak {
		streak = currentStreak
	}
	
	// Calculate success rate
	successRate := float64(completedDays) / float64(totalDays) * 100.0
	
	// Create or update stat record
	stat := &Stat{
		UserID:       userID,
		HabitID:      habitID,
		Period:       "weekly",
		StartDate:    startDate,
		EndDate:      endDate,
		TotalDays:    totalDays,
		CompletedDays: completedDays,
		SuccessRate:  successRate,
		Streak:       streak,
		LongestStreak: longestStreak,
		CalculatedAt: now,
	}
	
	// Store in database
	query := `
        INSERT INTO habit_stats (
            user_id, habit_id, period, start_date, end_date,
            total_days, completed_days, success_rate, streak, longest_streak, calculated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        ON CONFLICT (habit_id, period, start_date, end_date)
        DO UPDATE SET 
            total_days = $6, 
            completed_days = $7, 
            success_rate = $8, 
            streak = $9, 
            longest_streak = $10,
            calculated_at = $11
        RETURNING id`
	
	err = r.DB.QueryRow(
		query,
		stat.UserID,
		stat.HabitID,
		stat.Period,
		stat.StartDate,
		stat.EndDate,
		stat.TotalDays,
		stat.CompletedDays,
		stat.SuccessRate,
		stat.Streak,
		stat.LongestStreak,
		stat.CalculatedAt,
	).Scan(&stat.ID)
	
	if err != nil {
		return nil, err
	}
	
	return stat, nil
}

// GetStats retrieves statistics for a habit
func (r *StatRepository) GetStats(habitID int64, userID int64, period string) (*Stat, error) {
	stat := &Stat{}
	query := `
        SELECT 
            id, user_id, habit_id, period, start_date, end_date,
            total_days, completed_days, success_rate, streak, longest_streak, calculated_at
        FROM habit_stats
        WHERE habit_id = $1 AND user_id = $2 AND period = $3
        ORDER BY calculated_at DESC
        LIMIT 1`
	
	err := r.DB.QueryRow(query, habitID, userID, period).Scan(
		&stat.ID,
		&stat.UserID,
		&stat.HabitID,
		&stat.Period,
		&stat.StartDate,
		&stat.EndDate,
		&stat.TotalDays,
		&stat.CompletedDays,
		&stat.SuccessRate,
		&stat.Streak,
		&stat.LongestStreak,
		&stat.CalculatedAt,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("stats not found")
		}
		return nil, err
	}
	
	return stat, nil
}