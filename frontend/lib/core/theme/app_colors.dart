import 'package:flutter/material.dart';

/// Single primary color (teal) used across the app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00BFA5); // Teal
  static const Color primaryDark = Color(0xFF00897B); // Dark teal/green
  static const Color surfaceOverlay = Color(0x12FFFFFF);
  static const Color cardElevated = Color(0xFF1E1E2E);

  /// Gradient using primary with a slightly darker shade for depth.
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Full-screen gradient (splash, auth, onboarding).
  static final LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary,
      primary.withValues(alpha: 0.9),
    ],
  );
}
