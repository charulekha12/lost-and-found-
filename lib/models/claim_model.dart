import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemCategory;
  final String itemImageUrl;
  final String itemOwnerId;
  final String claimantId;
  final String claimantName;
  final String claimantEmail;
  final String claimantPhone;
  final String proofDescription;
  final String status; // 'pending', 'approved', 'rejected'
  final String adminRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClaimModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    this.itemCategory = '',
    this.itemImageUrl = '',
    required this.itemOwnerId,
    required this.claimantId,
    required this.claimantName,
    required this.claimantEmail,
    required this.claimantPhone,
    required this.proofDescription,
    this.status = 'pending',
    this.adminRemarks = '',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  String get description => proofDescription;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemCategory': itemCategory,
      'itemImageUrl': itemImageUrl,
      'itemOwnerId': itemOwnerId,
      'claimantId': claimantId,
      'claimantName': claimantName,
      'claimantEmail': claimantEmail,
      'claimantPhone': claimantPhone,
      'proofDescription': proofDescription,
      'status': status,
      'adminRemarks': adminRemarks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ClaimModel.fromMap(Map<String, dynamic> map) {
    return ClaimModel(
      id: map['id'] ?? '',
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      itemCategory: map['itemCategory'] ?? '',
      itemImageUrl: map['itemImageUrl'] ?? '',
      itemOwnerId: map['itemOwnerId'] ?? '',
      claimantId: map['claimantId'] ?? '',
      claimantName: map['claimantName'] ?? '',
      claimantEmail: map['claimantEmail'] ?? '',
      claimantPhone: map['claimantPhone'] ?? '',
      proofDescription: map['proofDescription'] ?? '',
      status: map['status'] ?? 'pending',
      adminRemarks: map['adminRemarks'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ClaimModel copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? itemCategory,
    String? itemImageUrl,
    String? itemOwnerId,
    String? claimantId,
    String? claimantName,
    String? claimantEmail,
    String? claimantPhone,
    String? proofDescription,
    String? status,
    String? adminRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClaimModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemCategory: itemCategory ?? this.itemCategory,
      itemImageUrl: itemImageUrl ?? this.itemImageUrl,
      itemOwnerId: itemOwnerId ?? this.itemOwnerId,
      claimantId: claimantId ?? this.claimantId,
      claimantName: claimantName ?? this.claimantName,
      claimantEmail: claimantEmail ?? this.claimantEmail,
      claimantPhone: claimantPhone ?? this.claimantPhone,
      proofDescription: proofDescription ?? this.proofDescription,
      status: status ?? this.status,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

