package handlers

import (
	"database/sql"
	"net/http"
	"strconv"
	"time"

	"gitlab.com/KARSTERRR/habitrack/models"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

// HabitHandler handles habit-related requests
type HabitHandler struct {
	DB *sql.DB
}

// NewHabitHandler creates a new habit handler
func NewHabitHandler(db *sql.DB) *HabitHandler {
	return &HabitHandler{DB: db}
}

// CreateHabit creates a new habit
func (h *HabitHandler) CreateHabit(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var habit models.Habit
	if err := c.ShouldBindJSON(&habit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	validate := validator.New()
	if err := validate.Struct(habit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set user ID
	habit.UserID = userID.(int64)

	// Create habit in database
	habitRepo := models.NewHabitRepository(h.DB)
	if err := habitRepo.Create(&habit); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create habit"})
		return
	}

	c.JSON(http.StatusCreated, habit)
}

// GetHabit retrieves a habit by ID
func (h *HabitHandler) GetHabit(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Get habit from database
	habitRepo := models.NewHabitRepository(h.DB)
	habit, err := habitRepo.GetByID(habitID, userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		return
	}

	c.JSON(http.StatusOK, habit)
}

// UpdateHabit updates a habit
func (h *HabitHandler) UpdateHabit(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Get current habit
	habitRepo := models.NewHabitRepository(h.DB)
	habit, err := habitRepo.GetByID(habitID, userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		return
	}

	// Parse updated habit from request
	var updatedHabit models.Habit
	if err := c.ShouldBindJSON(&updatedHabit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	// Verify that the habit belongs to the user
	if habit.UserID != userID.(int64) {
		c.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to update this habit"})
		return
	}

	// Update fields
	updatedHabit.ID = habitID
	updatedHabit.UserID = userID.(int64)
	updatedHabit.CreatedAt = habit.CreatedAt

	validate := validator.New()
	if err := validate.Struct(updatedHabit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update in database
	if err := habitRepo.Update(&updatedHabit); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update habit"})
		return
	}

	c.JSON(http.StatusOK, updatedHabit)
}

// DeleteHabit deletes a habit
func (h *HabitHandler) DeleteHabit(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Delete from database
	habitRepo := models.NewHabitRepository(h.DB)
	if err := habitRepo.Delete(habitID, userID.(int64)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete habit"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Habit deleted successfully"})
}

// ListHabits lists all habits for a user
func (h *HabitHandler) ListHabits(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse query parameters
	includeArchived := false
	if c.Query("include_archived") == "true" {
		includeArchived = true
	}

	// Get habits from database
	habitRepo := models.NewHabitRepository(h.DB)
	habits, err := habitRepo.GetAllByUser(userID.(int64), includeArchived)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve habits"})
		return
	}

	c.JSON(http.StatusOK, habits)
}

// TrackHabit tracks a habit for a specific date
func (h *HabitHandler) TrackHabit(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Check if habit belongs to user
	habitRepo := models.NewHabitRepository(h.DB)
	_, err = habitRepo.GetByID(habitID, userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		return
	}

	// Parse track record from request
	var record models.HabitTrackRecord
	if err := c.ShouldBindJSON(&record); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	// Set habit ID
	record.HabitID = habitID

	// If date is not provided, use current date
	if record.Date.IsZero() {
		record.Date = time.Now().Truncate(24 * time.Hour)
	}

	// Save tracking record
	trackRepo := models.NewTrackRepository(h.DB)
	if err := trackRepo.TrackHabit(&record); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to track habit"})
		return
	}

	// Update stats
	statRepo := models.NewStatRepository(h.DB)
	_, err = statRepo.UpdateStats(habitID, userID.(int64))
	if err != nil {
		// Non-critical error, just log it
		// log.Printf("Failed to update stats: %v", err)
	}

	c.JSON(http.StatusOK, record)
}

// GetHabitTracking retrieves habit tracking records for a date range
func (h *HabitHandler) GetHabitTracking(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Check if habit belongs to user
	habitRepo := models.NewHabitRepository(h.DB)
	_, err = habitRepo.GetByID(habitID, userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		return
	}

	// Parse date range from query parameters
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	var startDate, endDate time.Time
	if startDateStr == "" {
		// Default to 30 days ago
		startDate = time.Now().AddDate(0, 0, -30).Truncate(24 * time.Hour)
	} else {
		var err error
		startDate, err = time.Parse("2006-01-02", startDateStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start date format (use YYYY-MM-DD)"})
			return
		}
	}

	if endDateStr == "" {
		// Default to today
		endDate = time.Now().Truncate(24 * time.Hour)
	} else {
		var err error
		endDate, err = time.Parse("2006-01-02", endDateStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid end date format (use YYYY-MM-DD)"})
			return
		}
	}

	// Get tracking records
	trackRepo := models.NewTrackRepository(h.DB)
	records, err := trackRepo.GetTracking(habitID, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve tracking records"})
		return
	}

	c.JSON(http.StatusOK, records)
}

// GetHabitStats retrieves statistics for a habit
func (h *HabitHandler) GetHabitStats(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Parse habit ID from URL
	habitID, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid habit ID"})
		return
	}

	// Check if habit belongs to user
	habitRepo := models.NewHabitRepository(h.DB)
	_, err = habitRepo.GetByID(habitID, userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Habit not found"})
		return
	}

	// Parse period from query parameter
	period := c.DefaultQuery("period", "weekly")
	if period != "daily" && period != "weekly" && period != "monthly" && period != "yearly" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid period (use daily, weekly, monthly, or yearly)"})
		return
	}

	// Get stats from database
	statRepo := models.NewStatRepository(h.DB)
	
	// First try to get existing stats
	stats, err := statRepo.GetStats(habitID, userID.(int64), period)
	if err != nil {
		// If stats don't exist, calculate them
		stats, err = statRepo.UpdateStats(habitID, userID.(int64))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve statistics"})
			return
		}
	}

	c.JSON(http.StatusOK, stats)
}
