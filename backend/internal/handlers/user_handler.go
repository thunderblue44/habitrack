package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"gitlab.com/KARSTERRR/habitrack/config"
	"gitlab.com/KARSTERRR/habitrack/models"
	"gitlab.com/KARSTERRR/habitrack/utils"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"golang.org/x/crypto/bcrypt"
)

// UserHandler handles user-related requests
type UserHandler struct {
	DB     *sql.DB
	Config *config.Config
}

// NewUserHandler creates a new user handler
func NewUserHandler(db *sql.DB, cfg *config.Config) *UserHandler {
	return &UserHandler{DB: db, Config: cfg}
}

// RegisterRequest is the request body for user registration
type RegisterRequest struct {
	Username string `json:"username" validate:"required,min=3,max=50"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
}

// LoginRequest is the request body for user login
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// PasswordResetRequest is the request body for requesting a password reset
type PasswordResetRequest struct {
	Email string `json:"email" validate:"required,email"`
}

// PasswordResetConfirmRequest is the request body for confirming a password reset
type PasswordResetConfirmRequest struct {
	Token    string `json:"token" validate:"required"`
	Password string `json:"password" validate:"required,min=6"`
}

// AuthResponse is the response body for auth operations
type AuthResponse struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refresh_token"`
	UserID       int64  `json:"user_id"`
	Username     string `json:"username"`
	Email        string `json:"email"`
	ExpiresIn    int    `json:"expires_in"` // Token expiration time in seconds
}

// RegisterUser handles user registration
func (h *UserHandler) RegisterUser(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	validate := validator.New()
	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create user repository
	userRepo := models.NewUserRepository(h.DB)

	// Check if user already exists
	_, err := userRepo.GetByEmail(req.Email)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "User with this email already exists"})
		return
	}

	// Create new user
	user := &models.User{
		Username: req.Username,
		Email:    req.Email,
		Password: req.Password,
	}

	// Save user to database
	if err := userRepo.Create(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Generate tokens
	token, err := utils.GenerateJWT(user, h.Config.JWTSecret, h.Config.JWTExpiration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	refreshToken, err := utils.GenerateRefreshToken(user, h.Config.RefreshSecret, h.Config.RefreshDuration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate refresh token"})
		return
	}

	// Update last login timestamp
	if err := userRepo.UpdateLastLogin(user.ID); err != nil {
		// Non-critical error, just log it
		// log.Printf("Failed to update last login: %v", err)
	}

	// Send response
	c.JSON(http.StatusCreated, AuthResponse{
		Token:        token,
		RefreshToken: refreshToken,
		UserID:       user.ID,
		Username:     user.Username,
		Email:        user.Email,
		ExpiresIn:    int(h.Config.JWTExpiration.Seconds()),
	})
}

// LoginUser handles user login
func (h *UserHandler) LoginUser(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	validate := validator.New()
	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create user repository
	userRepo := models.NewUserRepository(h.DB)

	// Get user by email
	user, err := userRepo.GetByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Check password
	if err := user.CheckPassword(req.Password); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Generate tokens
	token, err := utils.GenerateJWT(user, h.Config.JWTSecret, h.Config.JWTExpiration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	refreshToken, err := utils.GenerateRefreshToken(user, h.Config.RefreshSecret, h.Config.RefreshDuration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate refresh token"})
		return
	}

	// Update last login timestamp
	if err := userRepo.UpdateLastLogin(user.ID); err != nil {
		// Non-critical error, just log it
		// log.Printf("Failed to update last login: %v", err)
	}

	// Send response
	c.JSON(http.StatusOK, AuthResponse{
		Token:        token,
		RefreshToken: refreshToken,
		UserID:       user.ID,
		Username:     user.Username,
		Email:        user.Email,
		ExpiresIn:    int(h.Config.JWTExpiration.Seconds()),
	})
}

// RefreshToken refreshes a user's auth token
func (h *UserHandler) RefreshToken(c *gin.Context) {
	var req struct {
		RefreshToken string `json:"refresh_token" validate:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	// Validate the refresh token
	claims, err := utils.ValidateJWT(req.RefreshToken, h.Config.RefreshSecret)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired refresh token"})
		return
	}

	// Get user by ID
	userRepo := models.NewUserRepository(h.DB)
	user, err := userRepo.GetByID(claims.UserID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	// Generate new tokens
	token, err := utils.GenerateJWT(user, h.Config.JWTSecret, h.Config.JWTExpiration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	refreshToken, err := utils.GenerateRefreshToken(user, h.Config.RefreshSecret, h.Config.RefreshDuration)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate refresh token"})
		return
	}

	// Send response
	c.JSON(http.StatusOK, AuthResponse{
		Token:        token,
		RefreshToken: refreshToken,
		UserID:       user.ID,
		Username:     user.Username,
		Email:        user.Email,
		ExpiresIn:    int(h.Config.JWTExpiration.Seconds()),
	})
}

// RequestPasswordReset handles password reset request
func (h *UserHandler) RequestPasswordReset(c *gin.Context) {
	var req PasswordResetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	// Create user repository
	userRepo := models.NewUserRepository(h.DB)

	// Get user by email
	user, err := userRepo.GetByEmail(req.Email)
	if err != nil {
		// Don't reveal if email exists for security reasons
		c.JSON(http.StatusOK, gin.H{"message": "If your email is registered, you will receive a password reset link"})
		return
	}

	// Generate a random token for password reset
	// In a real app, use a proper random token generation
	// This is just a placeholder
	resetToken := "reset-token-" + time.Now().Format("20060102150405")
	expires := time.Now().Add(24 * time.Hour)

	// Save the token to user record
	if err := userRepo.UpdatePasswordResetToken(user.Email, resetToken, expires); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process reset request"})
		return
	}

	// In a real app, send an email with the reset link
	// For this example, we'll just return the token in the response
	c.JSON(http.StatusOK, gin.H{
		"message": "Password reset link sent",
		"token":   resetToken, // Only for development, remove in production
	})
}

// ResetPassword handles password reset confirmation
func (h *UserHandler) ResetPassword(c *gin.Context) {
	var req PasswordResetConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	validate := validator.New()
	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create user repository
	userRepo := models.NewUserRepository(h.DB)

	// Get user by reset token
	user, err := userRepo.GetByResetToken(req.Token)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired reset token"})
		return
	}

	// Hash the new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Update user's password
	if err := userRepo.UpdatePassword(user.ID, string(hashedPassword)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	// Clear reset token
	if err := userRepo.UpdatePasswordResetToken(user.Email, "", time.Time{}); err != nil {
		// Non-critical error, just log it
		// log.Printf("Failed to clear reset token: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password has been reset successfully"})
}

// GetCurrentUser retrieves the current user's profile
func (h *UserHandler) GetCurrentUser(c *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Create user repository
	userRepo := models.NewUserRepository(h.DB)

	// Get user by ID
	user, err := userRepo.GetByID(userID.(int64))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Return user profile without sensitive information
	c.JSON(http.StatusOK, gin.H{
		"id":        user.ID,
		"username":  user.Username,
		"email":     user.Email,
		"created_at": user.CreatedAt,
		"last_login": user.LastLogin,
	})
}
