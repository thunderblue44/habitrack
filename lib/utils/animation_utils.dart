import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'constants.dart';

class AnimationUtils {
  // Staggered list item animations
  static List<Widget> staggeredList(List<Widget> children, {Duration? delay}) {
    return List.generate(
      children.length,
      (index) => children[index]
          .animate(delay: (delay ?? Duration.zero) + (50 * index).ms)
          .fadeIn(duration: AppConstants.shortAnimationDuration)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: AppConstants.shortAnimationDuration,
          ),
    );
  }

  // Card entrance animation
  static Widget cardEntrance(Widget child, {int? index}) {
    return child
        .animate(delay: index != null ? (50 * index).ms : 0.ms)
        .fadeIn(duration: AppConstants.mediumAnimationDuration)
        .scale(begin: const Offset(0.95, 0.95), alignment: Alignment.center)
        .slideY(begin: 0.1, end: 0);
  }

  // Button press animation
  static Widget buttonPress(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1,
          end: 0.95,
          duration: AppConstants.shortAnimationDuration,
        )
        .then()
        .scaleXY(
          begin: 0.95,
          end: 1,
          duration: AppConstants.shortAnimationDuration,
        );
  }

  // Success animation
  static Widget successAnimation(Widget child) {
    return child
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: AppConstants.shortAnimationDuration,
          curve: Curves.elasticOut,
        )
        .fadeIn();
  }

  // Error shake animation
  static Widget errorShake(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.forward(from: 0))
        .shakeX(hz: 4, amount: 4);
  }

  // Page transition animations
  static Widget pageTransition(Widget child, {bool reverse = false}) {
    return child
        .animate()
        .fadeIn(duration: AppConstants.mediumAnimationDuration)
        .slideX(
          begin: reverse ? -0.1 : 0.1,
          end: 0,
          duration: AppConstants.mediumAnimationDuration,
          curve: Curves.easeOutQuad,
        );
  }

  // Shimmer loading effect
  static Widget shimmerLoading(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          blendMode: BlendMode.srcATop,
          color: Colors.white54,
        );
  }

  // Pulse attention animation
  static Widget pulseAttention(Widget child) {
    return child
        .animate(
          onPlay:
              (controller) =>
                  controller.repeat(reverse: true, min: 0.0, max: 1.0),
        )
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
  }
}
