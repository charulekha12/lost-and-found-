import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

/// Utility class for showing consistent, styled SnackBars across the app.
class SnackbarUtils {
  SnackbarUtils._();

  static const Duration _defaultDuration = Duration(seconds: 3);

  // ── Success ────────────────────────────────────────────────────

  /// Shows a green success SnackBar with [message].
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF1A3A2A),
      borderColor: AppTheme.successColor,
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.successColor,
    );
  }

  // ── Error ──────────────────────────────────────────────────────

  /// Shows a red error SnackBar with [message].
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF3A1A1A),
      borderColor: AppTheme.errorColor,
      icon: Icons.error_rounded,
      iconColor: AppTheme.errorColor,
    );
  }

  // ── Info ───────────────────────────────────────────────────────

  /// Shows a teal info SnackBar with [message].
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF0F2A35),
      borderColor: AppTheme.primaryTeal,
      icon: Icons.info_rounded,
      iconColor: AppTheme.primaryTeal,
    );
  }

  // ── Warning ────────────────────────────────────────────────────

  /// Shows a yellow warning SnackBar with [message].
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF2C2500),
      borderColor: AppTheme.warningColor,
      icon: Icons.warning_rounded,
      iconColor: AppTheme.warningColor,
    );
  }

  // ── Internal ───────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    Duration duration = _defaultDuration,
  }) {
    // Remove any existing SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
