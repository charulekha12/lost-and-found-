
import 'package:flutter/material.dart';

import '../features/admin/admin_claims_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_reports_screen.dart';
import '../features/admin/admin_users_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/claims/claims_on_my_items_screen.dart';
import '../features/claims/my_claims_screen.dart';
import '../features/items/browse_items_screen.dart';
import '../features/items/my_reports_screen.dart';
import '../features/main_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/user_profile_screen.dart';
import '../features/report_item_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/support/help_support_screen.dart';

/// Central route definitions for Findora — Campus Lost & Found.
class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String userProfile = '/user-profile';
  static const String editProfile = '/edit-profile';
  static const String helpSupport = '/help-support';
  static const String browseItems = '/browse-items';
  static const String reportItem = '/report-item';
  static const String myReports = '/my-reports';
  static const String myClaims = '/my-claims';
  static const String claimsOnMyItems = '/claims-on-my-items';
  static const String notifications = '/notifications';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminClaims = '/admin-claims';
  static const String adminReports = '/admin-reports';
  static const String adminUsers = '/admin-users';

  // Route Generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case registration:
        return _slideRoute(const RegistrationScreen(), settings);

      case forgotPassword:
        return _slideRoute(const ForgotPasswordScreen(), settings);

      case home:
        return _fadeRoute(const MainScreen(), settings);

      case userProfile:
        return _slideRoute(const UserProfileScreen(), settings);

      case editProfile:
        return _slideRoute(const EditProfileScreen(), settings);

      case helpSupport:
        return _slideRoute(const HelpSupportScreen(), settings);

      case browseItems:
        return _slideRoute(const BrowseItemsScreen(), settings);

      case reportItem:
        return _slideRoute(const ReportItemScreen(), settings);

      case myReports:
        return _slideRoute(const MyReportsScreen(), settings);

      case myClaims:
        return _slideRoute(const MyClaimsScreen(), settings);

      case claimsOnMyItems:
        return _slideRoute(
          const ClaimsOnMyItemsScreen(),
          settings,
        );

      case notifications:
        return _slideRoute(const NotificationsScreen(), settings);

      case adminDashboard:
        return _slideRoute(const AdminDashboardScreen(), settings);

      case adminClaims:
        return _slideRoute(const AdminClaimsScreen(), settings);

      case adminReports:
        return _slideRoute(const AdminReportsScreen(), settings);

      case adminUsers:
        return _slideRoute(const AdminUsersScreen(), settings);

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text(
                'Route "${settings.name}" not found',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          settings,
        );
    }
  }

  // Transition Helpers
  static PageRouteBuilder<T> _fadeRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
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

  static PageRouteBuilder<T> _slideRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
