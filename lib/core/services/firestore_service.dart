import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../config/app_constants.dart';
import '../models/user_model.dart';

/// Handles all Firestore and Firebase Storage operations for user data.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Firestore References ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get _supportRef =>
      _firestore.collection(AppConstants.supportCollection);

  // ── User CRUD ──────────────────────────────────────────────────

  /// Creates a new user document in Firestore.
  /// Uses the user's [uid] as the document ID.
  Future<void> createUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Failed to create user profile: ${e.message}',
      );
    }
  }

  /// Retrieves a [UserModel] by [uid].
  /// Returns null if no document exists for the given uid.
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to fetch user profile: ${e.message}');
    }
  }

  /// Updates specific fields of a user document.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _usersRef.doc(uid).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to update profile: ${e.message}');
    }
  }

  /// Returns a real-time stream of [UserModel] for the given [uid].
  Stream<UserModel?> userStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  /// Deletes a user document from Firestore.
  Future<void> deleteUser(String uid) async {
    try {
      await _usersRef.doc(uid).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to delete user: ${e.message}');
    }
  }

  // ── Profile Image ──────────────────────────────────────────────

  /// Uploads a profile image [file] for the user with [uid].
  /// Returns the download URL of the uploaded image.
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$uid.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to upload image: ${e.message}');
    }
  }

  /// Deletes the profile image for the user with [uid].
  Future<void> deleteProfileImage(String uid) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$uid.jpg');
      await ref.delete();
    } catch (_) {
      // Silently fail — image may not exist
    }
  }

  // ── Support Requests ───────────────────────────────────────────

  /// Submits a support request to Firestore.
  Future<void> submitSupportRequest({
    required String userId,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await _supportRef.add({
        'userId': userId,
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to submit request: ${e.message}');
    }
  }
}

/// Custom exception for Firestore/Storage errors.
class FirestoreException implements Exception {
  final String message;
  const FirestoreException(this.message);

  @override
  String toString() => message;
}
