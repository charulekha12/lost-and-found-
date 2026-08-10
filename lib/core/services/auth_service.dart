import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication operations with clean error handling.
/// All methods throw [AuthException] on failure with user-friendly messages.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Auth State ─────────────────────────────────────────────────

  /// Stream of [User?] changes from Firebase Auth.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Returns true if a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  // ── Sign Up ────────────────────────────────────────────────────

  /// Creates a new Firebase Auth user with [email] and [password].
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [AuthException] with a user-friendly message on failure.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // ── Sign In ────────────────────────────────────────────────────

  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [AuthException] with a user-friendly message on failure.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out. Please try again.');
    }
  }

  // ── Password Reset ─────────────────────────────────────────────

  /// Sends a password reset email to the given [email] address.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('Failed to send reset email. Please try again.');
    }
  }

  // ── Email Verification ─────────────────────────────────────────

  /// Sends a verification email to the current user.
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw AuthException('Failed to send verification email.');
    }
  }

  // ── Update Profile ─────────────────────────────────────────────

  /// Updates the Firebase Auth display name for the current user.
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
    } catch (e) {
      throw AuthException('Failed to update display name.');
    }
  }

  // ── Error Mapping ──────────────────────────────────────────────

  /// Maps Firebase error codes to user-friendly messages.
  String _mapFirebaseError(String code) {
    switch (code) {
      // Registration errors
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';

      // Sign-in errors
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';

      // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      // Token errors
      case 'id-token-expired':
        return 'Session expired. Please log in again.';

      default:
        return 'Authentication error: $code. Please try again.';
    }
  }
}

/// Custom exception for authentication errors with user-friendly messages.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
