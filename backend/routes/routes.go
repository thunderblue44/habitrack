package routes

import (
	"database/sql"
	"net/http"

	"gitlab.com/KARSTERRR/habitrack/config"
	"gitlab.com/KARSTERRR/habitrack/internal/handlers"
	"gitlab.com/KARSTERRR/habitrack/internal/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine, db *sql.DB) {
	// Load configuration
	cfg := config.LoadConfig()

	// Create handlers
	userHandler := handlers.NewUserHandler(db, cfg)
	habitHandler := handlers.NewHabitHandler(db)

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "OK", "message": "API is running"})
	})

	// API version group
	v1 := router.Group("/api/v1")
	{
		// Authentication routes (no auth required)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", userHandler.RegisterUser)
			auth.POST("/login", userHandler.LoginUser)
			auth.POST("/refresh", userHandler.RefreshToken)
			auth.POST("/forgot-password", userHandler.RequestPasswordReset)
			auth.POST("/reset-password", userHandler.ResetPassword)
		}

		// Protected routes (auth required)
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware(cfg))
		{
			// User routes
			protected.GET("/user/me", userHandler.GetCurrentUser)

			// Habit routes
			habits := protected.Group("/habits")
			{
				habits.POST("", habitHandler.CreateHabit)
				habits.GET("", habitHandler.ListHabits)
				habits.GET("/:id", habitHandler.GetHabit)
				habits.PUT("/:id", habitHandler.UpdateHabit)
				habits.DELETE("/:id", habitHandler.DeleteHabit)
				
				// Habit tracking
				habits.POST("/:id/track", habitHandler.TrackHabit)
				habits.GET("/:id/tracking", habitHandler.GetHabitTracking)
				habits.GET("/:id/stats", habitHandler.GetHabitStats)
			}
		}
	}
}