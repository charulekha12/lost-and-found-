import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Button variant types.
enum ButtonVariant { primary, outline, ghost }

/// A reusable, animated button with loading state, gradient background,
/// and support for primary, outline, and ghost variants.
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? prefixIcon;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.prefixIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: _buildButton(),
        ),
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _PrimaryButton(
          label: widget.label,
          onPressed: widget.isLoading ? null : widget.onPressed,
          isLoading: widget.isLoading,
          prefixIcon: widget.prefixIcon,
          borderRadius: widget.borderRadius,
        );
      case ButtonVariant.outline:
        return _OutlineButton(
          label: widget.label,
          onPressed: widget.isLoading ? null : widget.onPressed,
          isLoading: widget.isLoading,
          prefixIcon: widget.prefixIcon,
          borderRadius: widget.borderRadius,
        );
      case ButtonVariant.ghost:
        return _GhostButton(
          label: widget.label,
          onPressed: widget.isLoading ? null : widget.onPressed,
          isLoading: widget.isLoading,
          prefixIcon: widget.prefixIcon,
        );
    }
  }
}

// ── Primary Button ─────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? prefixIcon;
  final double borderRadius;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.prefixIcon,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? AppTheme.primaryGradient
            : const LinearGradient(
                colors: [Color(0xFF2A3A3A), Color(0xFF1A2A2A)],
              ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          prefixIcon: prefixIcon,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Outline Button ─────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? prefixIcon;
  final double borderRadius;

  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.prefixIcon,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: onPressed != null
              ? AppTheme.primaryTeal
              : AppTheme.darkBorder,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        prefixIcon: prefixIcon,
        color: AppTheme.primaryTeal,
      ),
    );
  }
}

// ── Ghost Button ───────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? prefixIcon;

  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        prefixIcon: prefixIcon,
        color: AppTheme.primaryTeal,
      ),
    );
  }
}

// ── Shared Content ─────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final IconData? prefixIcon;
  final Color color;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.color,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(prefixIcon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      );
    }
    return Text(label, style: TextStyle(color: color));
  }
}
