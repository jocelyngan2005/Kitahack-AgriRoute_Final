// food_inventory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';

class FoodInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the collection reference
  CollectionReference get _foodCollection => _firestore.collection('foodItems');
  
  // Get current user ID or throw if not logged in
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }
  
  // Stream of food items for the current user
  Stream<List<FoodItem>> getFoodItems() {
    try {
      return _foodCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('expiryDate')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return FoodItem.fromMap(
                doc.data() as Map<String, dynamic>, 
                doc.id
              );
            }).toList();
          });
    } catch (e) {
      throw Exception('Failed to load food items: $e');
    }
  }
  
  // Add a new food item
  Future<DocumentReference> addFoodItem(FoodItem item) async {
    try {
      return await _foodCollection.add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add food item: $e');
    }
  }
  
  // Update an existing food item
  Future<void> updateFoodItem(FoodItem item) async {
    try {
      if (item.id == null) throw Exception('Item ID cannot be null');
      await _foodCollection.doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update food item: $e');
    }
  }
  
  // Delete a food item
  Future<void> deleteFoodItem(String itemId) async {
    try {
      await _foodCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }
  
  // Get expiring soon items (within next 3 days)
  Stream<List<FoodItem>> getExpiringSoonItems() {
    final thresholdDate = DateTime.now().add(Duration(days: 3));
    
    return _foodCollection
        .where('userId', isEqualTo: _userId)
        .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(thresholdDate))
        .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return FoodItem.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id
            );
          }).toList();
        });
  }
  
  // Get expired items
  Stream<List<FoodItem>> getExpiredItems() {
    final today = DateTime.now();
    
    return _foodCollection
        .where('userId', isEqualTo: _userId)
        .where('expiryDate', isLessThan: Timestamp.fromDate(today))
        .orderBy('expiryDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return FoodItem.fromMap(
              doc.data() as Map<String, dynamic>, 
              doc.id
            );
          }).toList();
        });
  }
}