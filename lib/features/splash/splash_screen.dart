import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';

/// Animated splash screen that auto-navigates based on auth state.
/// Shows app logo, name, and tagline with staggered entrance animations.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      // Pre-load user data before navigating home
      await userProvider.fetchUser(uid: authProvider.currentUser!.uid);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF0A1628),
              Color(0xFF0D1F2D),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Background Decorations ───────────────────────
              _BackgroundDecor(),

              // ── Main Content ─────────────────────────────────
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo / Icon
                    _buildLogo(),
                    const SizedBox(height: 32),

                    // App Name
                    _buildAppName(),
                    const SizedBox(height: 12),

                    // Tagline
                    _buildTagline(),
                  ],
                ),
              ),

              // ── Bottom Loader ────────────────────────────────
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: _buildLoader(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.search_rounded,
        color: Colors.white,
        size: 48,
      ),
    )
        .animate(controller: _controller)
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppName() {
    return Column(
      children: [
        Text(
          'Campus',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Lost & Found',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
      ],
    )
        .animate(controller: _controller)
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          delay: 400.ms,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildTagline() {
    return Text(
      AppConstants.appTagline,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    )
        .animate(controller: _controller)
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: 700.ms,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryTeal.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Loading...',
          style: TextStyle(
            color: AppTheme.textHint,
            fontSize: 12,
          ),
        ),
      ],
    )
        .animate(controller: _controller)
        .fadeIn(delay: 900.ms, duration: 600.ms);
  }
}

// ── Background Decorative Circles ──────────────────────────────────────────

class _BackgroundDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Stack(
        children: [
          // Top-left glow
          Positioned(
            top: -size.width * 0.3,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(0.05),
              ),
            ),
          ),
          // Bottom-right glow
          Positioned(
            bottom: -size.width * 0.3,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withOpacity(0.04),
              ),
            ),
          ),
          // Center radial dots grid
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
