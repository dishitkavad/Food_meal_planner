import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Add a shopping item
  Future<void> addItem({
    required String userId,
    required String itemName,
  }) async {
    await _firestore.collection('shoppingItems').add({
      'userId': userId,
      'itemName': itemName.trim(),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get shopping items of the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserItems(
      String userId,
      ) {
    return _firestore
        .collection('shoppingItems')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  // Mark item as completed / not completed
  Future<void> updateItemStatus({
    required String itemId,
    required bool isCompleted,
  }) async {
    await _firestore
        .collection('shoppingItems')
        .doc(itemId)
        .update({
      'isCompleted': isCompleted,
    });
  }

  // Delete shopping item
  Future<void> deleteItem({
    required String itemId,
  }) async {
    await _firestore
        .collection('shoppingItems')
        .doc(itemId)
        .delete();
  }
}