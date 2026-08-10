/// Form validation utilities for the Campus Lost & Found app.
/// All methods return null for valid input, or a user-friendly error string.
class Validators {
  Validators._();

  // ── Email ──────────────────────────────────────────────────────

  /// Validates an email address using RFC 5322 simplified regex.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────

  /// Validates a password for minimum length and complexity.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates a strong password (min 8 chars, mixed case + digit).
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    return null;
  }

  /// Validates that [value] matches [original] (confirm password).
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != original) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // ── Name ───────────────────────────────────────────────────────

  /// Validates a full name (letters and spaces only, 2–50 chars).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be under 50 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s'\-]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  // ── Phone ──────────────────────────────────────────────────────

  /// Validates an Indian mobile number (10 digits, starts with 6–9).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.length == 13 && cleaned.startsWith('91')) {
      // Handle +91 prefix
      final withoutCode = cleaned.substring(2);
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(withoutCode)) {
        return 'Please enter a valid 10-digit phone number';
      }
      return null;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  // ── Roll Number ────────────────────────────────────────────────

  /// Validates a student roll number (alphanumeric, 3–20 chars).
  static String? rollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    if (value.trim().length < 3) {
      return 'Roll number must be at least 3 characters';
    }
    if (value.trim().length > 20) {
      return 'Roll number must be under 20 characters';
    }
    return null;
  }

  // ── Generic ────────────────────────────────────────────────────

  /// Validates that a field is not empty.
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  /// Validates a text field with a minimum length requirement.
  static String? Function(String?) minLength(String fieldName, int min) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      if (value.trim().length < min) {
        return '$fieldName must be at least $min characters';
      }
      return null;
    };
  }

  /// Validates a text field with a maximum length requirement.
  static String? Function(String?) maxLength(String fieldName, int max) {
    return (String? value) {
      if (value != null && value.length > max) {
        return '$fieldName must be under $max characters';
      }
      return null;
    };
  }

  /// Validates a message (required, min 10 chars, max 500 chars).
  static String? message(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    if (value.trim().length > 500) {
      return 'Message must be under 500 characters';
    }
    return null;
  }
}
