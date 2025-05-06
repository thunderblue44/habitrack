package middleware

import (
	"net/http"
	"strings"

	"gitlab.com/KARSTERRR/habitrack/config"
	"gitlab.com/KARSTERRR/habitrack/utils"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware is a middleware for authenticating JWT tokens
func AuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			c.Abort()
			return
		}

		// Check if the header has the correct format
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header format must be Bearer {token}"})
			c.Abort()
			return
		}

		// Get the token from the header
		tokenString := parts[1]

		// Validate the token
		claims, err := utils.ValidateJWT(tokenString, cfg.JWTSecret)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			c.Abort()
			return
		}

		// Set user ID in context for handlers to use
		c.Set("userID", claims.UserID)
		c.Next()
	}
}