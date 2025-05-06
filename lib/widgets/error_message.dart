import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/error_handler.dart';

class ErrorMessageWidget extends StatelessWidget {
  final AppError error;
  final bool isCompact;

  const ErrorMessageWidget({
    Key? key,
    required this.error,
    this.isCompact = false,
  }) : super(key: key);

  // For backward compatibility
  factory ErrorMessageWidget.simple({
    Key? key,
    required String message,
    VoidCallback? onRetry,
  }) => ErrorMessageWidget(
    key: key,
    error: AppError.unknown(
      message: message,
      actionText: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 8.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error.icon,
              size: isCompact ? 40 : 64,
              color: error.getColor(context),
            ).animate().fadeIn().scale(),
            SizedBox(height: isCompact ? 8 : 16),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(delay: 200.ms),
            if (error.actionText != null && error.onAction != null) ...[
              SizedBox(height: isCompact ? 8 : 16),
              ElevatedButton(
                onPressed: error.onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: error.getColor(context),
                  foregroundColor: Colors.white,
                ),
                child: Text(error.actionText!),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.5, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
