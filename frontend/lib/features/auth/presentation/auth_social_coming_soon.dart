import 'package:flutter/material.dart';

/// Google / Apple OAuth are not wired yet — show a consistent “coming soon” message.
void showAuthProviderComingSoon(BuildContext context, {required String providerLabel}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$providerLabel sign-in is coming soon. Please use email and password for now.',
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}
