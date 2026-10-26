import 'package:flutter/material.dart';

/// Findora Logo Widget — stylized "F" with a magnifying glass teal accent.
/// Used across splash, login, onboarding, and nav elements.
class FindoraLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBackground;

  const FindoraLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoIcon(size: size),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'Findora',
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              color: darkBackground
                  ? Colors.white
                  : const Color(0xFF0A2540),
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          Text(
            'Campus Lost & Found',
            style: TextStyle(
              fontSize: size * 0.16,
              fontWeight: FontWeight.w400,
              color: darkBackground
                  ? Colors.white60
                  : const Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoIcon extends StatelessWidget {
  final double size;
  const _LogoIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2540), Color(0xFF1B3A5C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withOpacity(0.25),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "F" letter
          Positioned(
            left: size * 0.18,
            top: size * 0.18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top horizontal bar of F
                Container(
                  width: size * 0.42,
                  height: size * 0.095,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.05),
                  ),
                ),
                SizedBox(height: size * 0.07),
                // Middle horizontal bar
                Container(
                  width: size * 0.30,
                  height: size * 0.085,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.05),
                  ),
                ),
                SizedBox(height: size * 0.07),
                // Bottom vertical bar only
                Container(
                  width: size * 0.095,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.05),
                  ),
                ),
              ],
            ),
          ),
          // Teal magnifying glass circle in bottom-right
          Positioned(
            right: size * 0.10,
            bottom: size * 0.10,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4D8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4D8).withOpacity(0.5),
                    blurRadius: size * 0.15,
                    spreadRadius: size * 0.02,
                  ),
                ],
              ),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: size * 0.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

