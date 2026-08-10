import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Manages user profile state using [ChangeNotifier] (Provider pattern).
/// Fetches, caches, and updates the user's Firestore profile.
class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;

  UserModel _user = UserModel.empty();
  bool _isLoading = false;
  String _errorMessage = '';

  // ── Getters ────────────────────────────────────────────────────

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get hasUser => _user.isValid;

  // ── Fetch User ─────────────────────────────────────────────────

  /// Fetches the current user's profile from Firestore.
  Future<void> fetchUser({String? uid}) async {
    final userId = uid ?? _authService.currentUser?.uid;
    if (userId == null) return;

    _setLoading(true);
    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        _user = user;
        _errorMessage = '';
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Loads user data immediately from cache or Firestore.
  Future<void> loadUser(String uid) => fetchUser(uid: uid);

  // ── Create User ────────────────────────────────────────────────

  /// Creates a new user document in Firestore after registration.
  Future<bool> createUser(UserModel user) async {
    _setLoading(true);
    try {
      await _firestoreService.createUser(user);
      _user = user;
      _errorMessage = '';
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Profile ─────────────────────────────────────────────

  /// Updates the user's profile in Firestore and refreshes local state.
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String department,
    required String rollNumber,
    String? profileImageUrl,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return false;

    _setLoading(true);
    try {
      final updateData = {
        'fullName': fullName,
        'phone': phone,
        'department': department,
        'rollNumber': rollNumber,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };

      await _firestoreService.updateUser(uid, updateData);

      // Update local cache
      _user = _user.copyWith(
        fullName: fullName,
        phone: phone,
        department: department,
        rollNumber: rollNumber,
        profileImageUrl: profileImageUrl ?? _user.profileImageUrl,
      );

      _errorMessage = '';
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Profile Image ──────────────────────────────────────────────

  /// Uploads a new profile image and updates Firestore with the URL.
  Future<String?> uploadProfileImage(File imageFile) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    _setLoading(true);
    try {
      final url = await _firestoreService.uploadProfileImage(
        uid: uid,
        file: imageFile,
      );
      await _firestoreService.updateUser(uid, {'profileImageUrl': url});
      _user = _user.copyWith(profileImageUrl: url);
      _errorMessage = '';
      notifyListeners();
      return url;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── Refresh ────────────────────────────────────────────────────

  /// Forces a refresh of the user profile from Firestore.
  Future<void> refreshProfile() => fetchUser();

  // ── Clear ──────────────────────────────────────────────────────

  /// Clears user data (called on logout).
  void clearUser() {
    _user = UserModel.empty();
    _errorMessage = '';
    notifyListeners();
  }

  // ── State Helpers ──────────────────────────────────────────────

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
