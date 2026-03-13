import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.splashGradient),
          ),
          // Soft blur circles for depth
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo + headline
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.champagneGlasses,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOut),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 80.ms).slideY(begin: -0.15, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to discover events worldwide',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 120.ms).slideY(begin: -0.1, end: 0),
                    const SizedBox(height: 32),
                    // Card
                    AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              prefixIcon: Icon(FontAwesomeIcons.envelope, size: 20, color: primary.withValues(alpha: 0.8)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: primary, width: 1),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.06, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 18),
                          TextFormField(
                            style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              prefixIcon: Icon(FontAwesomeIcons.lock, size: 20, color: primary.withValues(alpha: 0.8)),
                              suffixIcon: IconButton(
                                icon: FaIcon(
                                  _obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: primary, width: 1),
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ).animate().fadeIn(delay: 260.ms).slideX(begin: 0.06, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('Forgot password?'),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => context.go('/'),
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text('Sign In'),
                          ).animate().fadeIn(delay: 340.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'or continue with',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            ],
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.go('/'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    foregroundColor: Colors.grey.shade800,
                                  ),
                                  icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF4285F4)),
                                  label: const Text('Google'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.go('/'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    foregroundColor: Colors.grey.shade800,
                                  ),
                                  icon: const FaIcon(FontAwesomeIcons.apple, size: 20, color: Color(0xFF000000)),
                                  label: const Text('Apple'),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 440.ms).slideY(begin: 0.04, end: 0),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                              ),
                              TextButton(
                                onPressed: () => context.push('/register'),
                                style: TextButton.styleFrom(
                                  foregroundColor: primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ),
                                child: const Text('Sign up'),
                              ),
                            ],
                          ).animate().fadeIn(delay: 520.ms),
                        ],
                      ),
                    ).animate().fadeIn(delay: 160.ms).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
