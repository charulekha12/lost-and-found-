import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final String type; // 'lost' or 'found'
  final String imageUrl;
  final String userId;
  final String userName;
  final String userPhone;
  final String userEmail;
  final String status; // 'active', 'claimed', 'returned', 'resolved'
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.type,
    required this.imageUrl,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userEmail = '',
    required this.status,
    required this.createdAt,
  });

  bool get isLost => type.toLowerCase() == 'lost';
  bool get isFound => type.toLowerCase() == 'found';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isResolved =>
      status.toLowerCase() == 'resolved' || status.toLowerCase() == 'returned';

  // Convert ItemModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': Timestamp.fromDate(date),
      'type': type,
      'imageUrl': imageUrl,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create ItemModel from Firestore Document
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? 'lost',
      imageUrl: map['imageUrl'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? date,
    String? type,
    String? imageUrl,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? status,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
