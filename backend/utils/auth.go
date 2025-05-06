package utils

import (
	"errors"
	"time"

	"gitlab.com/KARSTERRR/habitrack/models"

	"github.com/dgrijalva/jwt-go"
)

// Claims is a struct that will be encoded to a JWT.
type Claims struct {
	UserID int64 `json:"user_id"`
	jwt.StandardClaims
}

// GenerateJWT generates a JWT token for a user
func GenerateJWT(user *models.User, secret string, expiration time.Duration) (string, error) {
	claims := &Claims{
		UserID: user.ID,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(expiration).Unix(),
			IssuedAt:  time.Now().Unix(),
			Issuer:    "habitrack",
			Subject:   user.Email,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

// ValidateJWT validates a JWT token
func ValidateJWT(tokenString string, secret string) (*Claims, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}

// GenerateRefreshToken generates a refresh token for a user
func GenerateRefreshToken(user *models.User, secret string, expiration time.Duration) (string, error) {
	claims := &Claims{
		UserID: user.ID,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(expiration).Unix(),
			IssuedAt:  time.Now().Unix(),
			Issuer:    "habitrack",
			Subject:   "refresh",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
