import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../config/app_constants.dart';
import '../models/user_model.dart';
import '../../models/item_model.dart';
import '../../models/claim_model.dart';

/// Handles all Firestore and Firebase Storage operations.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  factory FirestoreService() => instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Firestore References ───────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get _supportRef =>
      _firestore.collection(AppConstants.supportCollection);

  CollectionReference<Map<String, dynamic>> get _itemsRef =>
      _firestore.collection(AppConstants.itemsCollection);

  CollectionReference<Map<String, dynamic>> get _claimsRef =>
      _firestore.collection(AppConstants.claimsCollection);

  // ── User CRUD ──────────────────────────────────────────────────

  /// Creates a new user document in Firestore.
  Future<void> createUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to create user profile: ${e.message}');
    }
  }

  /// Retrieves a [UserModel] by [uid].
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreException('Failed to fetch user profile: ${e.message}');
    }
  }

  /// Retrieves raw user profile map by [uid].
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return doc.data();
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

  /// Upload a profile image as raw bytes (Works seamlessly across Web and Mobile).
  Future<String> uploadProfileImageBytes({
    required String uid,
    required Uint8List bytes,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$uid.jpg');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirestoreException('Failed to upload profile photo: $e');
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

  // ── Lost & Found Items Methods ──────────────────────────────────────────

  /// Generates a new unique Firestore ID for an item.
  String generateItemId() => _itemsRef.doc().id;

  /// Add a new lost or found item report.
  Future<void> createItem(ItemModel item) async {
    try {
      await _itemsRef.doc(item.id).set(item.toMap());
    } catch (e) {
      throw FirestoreException('Failed to create item report: $e');
    }
  }

  /// Fetch a single item by its ID.
  Future<ItemModel?> getItem(String itemId) async {
    try {
      final doc = await _itemsRef.doc(itemId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ItemModel.fromMap(doc.data()!);
    } catch (e) {
      throw FirestoreException('Failed to fetch item: $e');
    }
  }

  /// Update an existing item report.
  Future<void> updateItem(String itemId, Map<String, dynamic> data) async {
    try {
      await _itemsRef.doc(itemId).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update item: $e');
    }
  }

  /// Delete an item report and its image if any.
  Future<void> deleteItem(String itemId, {String? imageUrl}) async {
    try {
      await _itemsRef.doc(itemId).delete();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (_) {
          // Image deletion optional/fail-safe
        }
      }
    } catch (e) {
      throw FirestoreException('Failed to delete item: $e');
    }
  }

  /// Upload an item image as raw bytes (Works seamlessly across Web and Mobile).
  Future<String> uploadItemImageBytes({
    required String itemId,
    required Uint8List bytes,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.itemImagesPath)
          .child('$itemId.jpg');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirestoreException('Failed to upload item photo: $e');
    }
  }

  /// Fetch all active items (Realtime stream).
  Stream<List<ItemModel>> getActiveItems() {
    try {
      return _itemsRef
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Fetch all items regardless of status (Realtime stream).
  Stream<List<ItemModel>> getAllItems() {
    try {
      return _itemsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Fetch items reported by a specific user.
  Stream<List<ItemModel>> getUserItems(String userId) {
    try {
      return _itemsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ItemModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Real-time stream of campus statistics (Lost, Found, Reunited).
  Stream<Map<String, int>> getStatsStream() {
    return _itemsRef.snapshots().map((snapshot) {
      int lost = 0;
      int found = 0;
      int reunited = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = (data['type'] as String? ?? '').toLowerCase();
        final status = (data['status'] as String? ?? '').toLowerCase();

        if (status == 'returned' || status == 'resolved') {
          reunited++;
        } else if (type == 'lost') {
          lost++;
        } else if (type == 'found') {
          found++;
        }
      }

      return {'lost': lost, 'found': found, 'reunited': reunited};
    });
  }

  // ── Claim Requests Methods ──────────────────────────────────────────────

  /// Generate unique Claim ID.
  String generateClaimId() => _claimsRef.doc().id;

  /// Submit a new claim request for a found item.
  Future<void> submitClaim(ClaimModel claim) async {
    try {
      await _claimsRef.doc(claim.id).set(claim.toMap());
    } catch (e) {
      throw FirestoreException('Failed to submit claim request: $e');
    }
  }

  /// Stream of claim requests submitted by a specific user.
  Stream<List<ClaimModel>> getUserClaims(String claimantId) {
    try {
      return _claimsRef
          .where('claimantId', isEqualTo: claimantId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ClaimModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Stream of claim requests for a specific item.
  Stream<List<ClaimModel>> getItemClaims(String itemId) {
    try {
      return _claimsRef
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ClaimModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Delete or cancel a claim request.
  Future<void> cancelClaim(String claimId) async {
    try {
      await _claimsRef.doc(claimId).delete();
    } catch (e) {
      throw FirestoreException('Failed to cancel claim request: $e');
    }
  }

    /// Stream of claims made on items reported by a specific user.
  Stream<List<ClaimModel>> getClaimsOnMyItems(String ownerId) {
    return _claimsRef
        .where('itemOwnerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClaimModel.fromMap(doc.data()))
            .toList());
  }

  /// Stream of all claims in the system (for admin).
  Stream<List<Map<String, dynamic>>> getAllClaims() {
    try {
      return _claimsRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] = doc.id;
                return data;
              }).toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Stream of all registered users (for admin).
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    try {
      return _usersRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = Map<String, dynamic>.from(doc.data());
                data['uid'] = doc.id;
                return data;
              }).toList());
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Updates specific fields of a claim.
  Future<void> updateClaim(String claimId, Map<String, dynamic> data) async {
    try {
      await _claimsRef.doc(claimId).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update claim: $e');
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