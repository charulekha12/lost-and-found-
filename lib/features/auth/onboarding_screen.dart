
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';

/// Onboarding screen — illustrated intro with Get Started + Sign In.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.search_rounded,
      iconColor: Color(0xFF00B4D8),
      title: 'Lost & Found\nMade Simple',
      subtitle:
          'Report lost items, find forgotten belongings and get them back — all in one place.',
    ),
    _OnboardPage(
      icon: Icons.location_on_rounded,
      iconColor: Color(0xFF0A2540),
      title: 'Campus-Wide\nCoverage',
      subtitle:
          'Search across the entire campus with location-based filtering and real-time updates.',
    ),
    _OnboardPage(
      icon: Icons.verified_rounded,
      iconColor: Color(0xFF22C55E),
      title: 'Verified\nClaims',
      subtitle:
          'Submit claim requests securely. Get notified when your item is found or claimed.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.login,
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Onboarding pages — logo removed
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: _pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryTeal
                        : AppTheme.borderMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Next / Get Started
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.registration,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Sign In appears only on the last page
                  if (_currentPage == _pages.length - 1) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(
                            color: AppTheme.borderMedium,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardPage page;

  const _OnboardingPage({
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.iconColor.withOpacity(0.08),
              border: Border.all(
                color: page.iconColor.withOpacity(0.15),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.iconColor.withOpacity(0.1),
                  ),
                ),
                Icon(
                  page.icon,
                  size: 72,
                  color: page.iconColor,
                ),
              ],
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Page title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(
                delay: 200.ms,
                duration: 500.ms,
              )
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 200.ms,
                duration: 500.ms,
              ),

          const SizedBox(height: 16),

          // Page description
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(
                delay: 300.ms,
                duration: 500.ms,
              )
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 300.ms,
                duration: 500.ms,
              ),
        ],
      ),
    );
  }
}
