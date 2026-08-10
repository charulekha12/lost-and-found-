import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Auth state enum representing every possible authentication state.
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Manages authentication state using [ChangeNotifier] (Provider pattern).
/// Wraps [AuthService] and exposes reactive state to the UI layer.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  User? _currentUser;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // ── Getters ────────────────────────────────────────────────────

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasError => _status == AuthStatus.error;

  // ── Auth State Listener ────────────────────────────────────────

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    if (user != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Sign Up ────────────────────────────────────────────────────

  /// Registers a new user. Returns true on success, false on failure.
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.signUp(email: email, password: password);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Sign In ────────────────────────────────────────────────────

  /// Signs in an existing user. Returns true on success, false on failure.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _authService.signIn(email: email, password: password);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────

  /// Signs out the current user.
  Future<void> signOut() async {
    _setLoading();
    try {
      await _authService.signOut();
      _clearError();
    } on AuthException catch (e) {
      _setError(e.message);
    }
  }

  // ── Password Reset ─────────────────────────────────────────────

  /// Sends a password reset email. Returns true on success, false on failure.
  Future<bool> resetPassword(String email) async {
    _setLoading();
    try {
      await _authService.resetPassword(email);
      _status = AuthStatus.unauthenticated;
      _clearError();
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── State Helpers ──────────────────────────────────────────────

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status =
        _currentUser != null ? AuthStatus.authenticated : AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  /// Clears any existing error message.
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
