import 'package:flutter/material.dart';

enum ErrorType { network, auth, notFound, server, validation, unknown }

class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final String? actionText;
  final VoidCallback? onAction;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.actionText,
    this.onAction,
  });

  factory AppError.network({
    String message = 'No internet connection',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.network,
    originalError: originalError,
    actionText: actionText ?? 'Retry',
    onAction: onAction,
  );

  factory AppError.auth({
    String message = 'Authentication error',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.auth,
    originalError: originalError,
    actionText: actionText,
    onAction: onAction,
  );

  factory AppError.notFound({
    String message = 'Resource not found',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.notFound,
    originalError: originalError,
    actionText: actionText,
    onAction: onAction,
  );

  factory AppError.server({
    String message = 'Server error occurred',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.server,
    originalError: originalError,
    actionText: actionText ?? 'Retry',
    onAction: onAction,
  );

  factory AppError.validation({
    String message = 'Validation error',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.validation,
    originalError: originalError,
    actionText: actionText,
    onAction: onAction,
  );

  factory AppError.unknown({
    String message = 'An unexpected error occurred',
    dynamic originalError,
    String? actionText,
    VoidCallback? onAction,
  }) => AppError(
    message: message,
    type: ErrorType.unknown,
    originalError: originalError,
    actionText: actionText ?? 'Retry',
    onAction: onAction,
  );

  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.signal_wifi_off;
      case ErrorType.auth:
        return Icons.lock;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.unknown:
        return Icons.warning_amber;
    }
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.auth:
        return Colors.red;
      case ErrorType.notFound:
        return Colors.grey;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.unknown:
        return Colors.red;
    }
  }
}

// Helper function to map status codes to error types
ErrorType errorTypeFromStatusCode(int statusCode) {
  if (statusCode == 0) {
    return ErrorType.network;
  } else if (statusCode == 401 || statusCode == 403) {
    return ErrorType.auth;
  } else if (statusCode == 404) {
    return ErrorType.notFound;
  } else if (statusCode >= 400 && statusCode < 500) {
    return ErrorType.validation;
  } else if (statusCode >= 500) {
    return ErrorType.server;
  }
  return ErrorType.unknown;
}
