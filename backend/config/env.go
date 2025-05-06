package config

import (
	"log"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

// Config holds all environment configurations
type Config struct {
	Port            string
	JWTSecret       string
	JWTExpiration   time.Duration
	RefreshSecret   string
	RefreshDuration time.Duration
	DBHost          string
	DBPort          string
	DBUser          string
	DBPassword      string
	DBName          string
	DBSSLMode       string
}

// LoadConfig loads the environment variables into a Config struct
func LoadConfig() *Config {
	// Load environment file if present
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// JWT expiration in hours, default 24 hours
	jwtExp, err := strconv.Atoi(os.Getenv("JWT_EXPIRATION_HOURS"))
	if err != nil || jwtExp < 1 {
		jwtExp = 24
	}

	// Refresh token expiration in days, default 7 days
	refreshExp, err := strconv.Atoi(os.Getenv("REFRESH_EXPIRATION_DAYS"))
	if err != nil || refreshExp < 1 {
		refreshExp = 7
	}

	return &Config{
		Port:            getEnvWithDefault("PORT", "8080"),
		JWTSecret:       getEnvWithDefault("JWT_SECRET", "your-secret-key"),
		JWTExpiration:   time.Duration(jwtExp) * time.Hour,
		RefreshSecret:   getEnvWithDefault("REFRESH_SECRET", "your-refresh-secret-key"),
		RefreshDuration: time.Duration(refreshExp) * 24 * time.Hour,
		DBHost:          getEnvWithDefault("DB_HOST", "localhost"),
		DBPort:          getEnvWithDefault("DB_PORT", "5432"),
		DBUser:          getEnvWithDefault("DB_USER", "postgres"),
		DBPassword:      getEnvWithDefault("DB_PASSWORD", "postgres"),
		DBName:          getEnvWithDefault("DB_NAME", "habitrack"),
		DBSSLMode:       getEnvWithDefault("DB_SSL_MODE", "disable"),
	}
}

// Get environment variable or return default value
func getEnvWithDefault(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}