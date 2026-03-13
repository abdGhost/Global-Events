import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether user has completed onboarding (persist with shared_preferences in production).
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
