import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/findora_logo.dart';

/// Findora splash screen — navy gradient with animated logo.
/// Auto-navigates to onboarding (first launch) or home/login.
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
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      await userProvider.fetchUser(uid: authProvider.currentUser!.uid);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
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
              Color(0xFF0A2540),
              Color(0xFF0D2F4F),
              Color(0xFF0A2540),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _BackgroundDecor(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FindoraLogo(size: 96, darkBackground: true)
                        .animate(controller: _controller)
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 500.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Lost something?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                        .animate(controller: _controller)
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 800.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    Text(
                      'Find your way back to it.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryTeal.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate(controller: _controller)
                        .fadeIn(delay: 1000.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 1000.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TagBadge(icon: Icons.search_rounded, label: 'Simple'),
                        const SizedBox(width: 16),
                        _TagBadge(icon: Icons.shield_outlined, label: 'Secure'),
                        const SizedBox(width: 16),
                        _TagBadge(icon: Icons.people_outline_rounded, label: 'Together'),
                      ],
                    )
                        .animate(controller: _controller)
                        .fadeIn(delay: 1300.ms, duration: 700.ms),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryTeal.withOpacity(0.6),
                        ),
                      ),
                    )
                        .animate(controller: _controller)
                        .fadeIn(delay: 1500.ms, duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryTeal),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -size.width * 0.4,
            left: -size.width * 0.4,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryTeal.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
