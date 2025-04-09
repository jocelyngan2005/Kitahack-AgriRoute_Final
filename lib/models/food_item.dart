// food_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String? id;
  final String name;
  final DateTime expiryDate;
  final String userId;
  final DateTime createdAt;

  FoodItem({
    this.id,
    required this.name,
    required this.expiryDate,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a FoodItem from Firestore data
  factory FoodItem.fromMap(Map<String, dynamic> map, String id) {
    return FoodItem(
      id: id,
      name: map['name'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Calculate days until expiry or since expiry
  int get daysUntilExpiry {
    final today = DateTime.now();
    return expiryDate.difference(today).inDays;
  }

  // Get status of food item
  String getStatus() {
    final days = daysUntilExpiry;
    if (days < -1) return 'ROTTEN';
    if (days <= 0) return 'EXPIRED';
    if (days <= 2) return 'EXPIRING_SOON';
    return 'FRESH';
  }

  // Get human-readable status line
  String getStatusLine() {
    final days = daysUntilExpiry;
    if (days < 0) {
      return 'Expired ${days.abs()} days ago';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else {
      return 'Expires in $days days';
    }
  }
}