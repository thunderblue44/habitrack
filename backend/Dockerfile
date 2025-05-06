FROM golang:1.21-alpine AS build

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Copy go.mod and go.sum files to download dependencies
COPY go.mod ./
COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -a -o habitrack-server .

# Create final lightweight image
FROM alpine:latest

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata

# Copy binary from build stage
COPY --from=build /app/habitrack-server .
COPY --from=build /app/migrations ./migrations

# Set environment variables
ENV GIN_MODE=release

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./habitrack-server"]
