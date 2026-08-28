import 'package:flutter/material.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/user_profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/support/help_support_screen.dart';

/// Central route definitions for the app.
/// All named routes are defined here for maintainability.
class AppRoutes {
  AppRoutes._();

  // ── Route Names ────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String userProfile = '/user-profile';
  static const String editProfile = '/edit-profile';
  static const String helpSupport = '/help-support';

  // ── Route Generator ────────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case registration:
        return _slideRoute(const RegistrationScreen(), settings);

      case forgotPassword:
        return _slideRoute(const ForgotPasswordScreen(), settings);

      case home:
        return _fadeRoute(const HomeScreen(), settings);

      case userProfile:
        return _slideRoute(const UserProfileScreen(), settings);

      case editProfile:
        return _slideRoute(const EditProfileScreen(), settings);

      case helpSupport:
        return _slideRoute(const HelpSupportScreen(), settings);

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text(
                'Route "${settings.name}" not found',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          settings,
        );
    }
  }

  // ── Transition Helpers ─────────────────────────────────────────

  /// Fade transition route
  static PageRouteBuilder<T> _fadeRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide-up transition route
  static PageRouteBuilder<T> _slideRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
