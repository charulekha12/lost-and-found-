import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's profile in the Campus Lost & Found app.
/// Maps directly to the `users` Firestore collection document.
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String rollNumber;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.rollNumber,
    this.profileImageUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Factory Constructors ───────────────────────────────────────

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      department: map['department'] as String? ?? '',
      rollNumber: map['rollNumber'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Creates an empty placeholder [UserModel].
  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      uid: '',
      fullName: '',
      email: '',
      phone: '',
      department: '',
      rollNumber: '',
      profileImageUrl: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ── Serialization ──────────────────────────────────────────────

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'rollNumber': rollNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns only the fields needed for a profile update operation.
  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'department': department,
      'rollNumber': rollNumber,
      'profileImageUrl': profileImageUrl,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // ── CopyWith ───────────────────────────────────────────────────

  /// Returns a copy of this model with updated fields.
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? department,
    String? rollNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      rollNumber: rollNumber ?? this.rollNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Computed Properties ────────────────────────────────────────

  /// Returns true if this model has valid data (not empty).
  bool get isValid => uid.isNotEmpty && email.isNotEmpty;

  /// Returns user's initials for avatar placeholder.
  String get initials {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Returns true if user has a profile image.
  bool get hasProfileImage => profileImageUrl.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
