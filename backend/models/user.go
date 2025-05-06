package models

import (
	"database/sql"
	"errors"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// User model for user authentication
type User struct {
	ID             int64     `json:"id"`
	Username       string    `json:"username" validate:"required,min=3,max=50"`
	Email          string    `json:"email" validate:"required,email"`
	Password       string    `json:"password,omitempty" validate:"required,min=6"`
	HashedPassword string    `json:"-"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	LastLogin      time.Time `json:"last_login"`
	PasswordResetToken string `json:"-"`
	PasswordResetExpires time.Time `json:"-"`
}

// HashPassword creates a hashed password from user's password
func (u *User) HashPassword() error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.HashedPassword = string(hashedPassword)
	u.Password = "" // Clear password field for security
	return nil
}

// CheckPassword verifies if provided password matches with saved hash
func (u *User) CheckPassword(password string) error {
	return bcrypt.CompareHashAndPassword([]byte(u.HashedPassword), []byte(password))
}

// UserRepository handles database operations for users
type UserRepository struct {
	DB *sql.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{DB: db}
}

// Create inserts a new user in the database
func (r *UserRepository) Create(user *User) error {
	// Hash the password before storing
	if err := user.HashPassword(); err != nil {
		return err
	}

	now := time.Now()
	user.CreatedAt = now
	user.UpdatedAt = now

	query := `
        INSERT INTO users (username, email, hashed_password, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id`
	
	err := r.DB.QueryRow(
		query,
		user.Username,
		user.Email,
		user.HashedPassword,
		user.CreatedAt,
		user.UpdatedAt,
	).Scan(&user.ID)
	
	return err
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(id int64) (*User, error) {
	user := &User{}
	query := `
        SELECT id, username, email, hashed_password, created_at, updated_at, last_login
        FROM users
        WHERE id = $1`
	
	err := r.DB.QueryRow(query, id).Scan(
		&user.ID,
		&user.Username,
		&user.Email,
		&user.HashedPassword,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.LastLogin,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	
	return user, nil
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(email string) (*User, error) {
	user := &User{}
	query := `
        SELECT id, username, email, hashed_password, created_at, updated_at, last_login
        FROM users
        WHERE email = $1`
	
	err := r.DB.QueryRow(query, email).Scan(
		&user.ID,
		&user.Username,
		&user.Email,
		&user.HashedPassword,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.LastLogin,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	
	return user, nil
}

// UpdatePassword updates a user's password
func (r *UserRepository) UpdatePassword(userID int64, hashedPassword string) error {
	query := `
        UPDATE users
        SET hashed_password = $1, updated_at = $2
        WHERE id = $3`
	
	_, err := r.DB.Exec(query, hashedPassword, time.Now(), userID)
	return err
}

// UpdateLastLogin updates a user's last login timestamp
func (r *UserRepository) UpdateLastLogin(userID int64) error {
	now := time.Now()
	query := `
        UPDATE users
        SET last_login = $1
        WHERE id = $2`
	
	_, err := r.DB.Exec(query, now, userID)
	return err
}

// UpdatePasswordResetToken sets a password reset token for a user
func (r *UserRepository) UpdatePasswordResetToken(email string, token string, expires time.Time) error {
	query := `
        UPDATE users
        SET password_reset_token = $1, password_reset_expires = $2
        WHERE email = $3`
	
	_, err := r.DB.Exec(query, token, expires, email)
	return err
}

// GetByResetToken retrieves a user by password reset token
func (r *UserRepository) GetByResetToken(token string) (*User, error) {
	user := &User{}
	query := `
        SELECT id, username, email, hashed_password, password_reset_token, password_reset_expires
        FROM users
        WHERE password_reset_token = $1 AND password_reset_expires > $2`
	
	err := r.DB.QueryRow(query, token, time.Now()).Scan(
		&user.ID,
		&user.Username,
		&user.Email,
		&user.HashedPassword,
		&user.PasswordResetToken,
		&user.PasswordResetExpires,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("invalid or expired reset token")
		}
		return nil, err
	}
	
	return user, nil
}