import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addFavorite({
    required String userId,
    required Map<String, String> recipe,
  }) async {
    final recipeId = recipe['id'] ?? '';

    if (recipeId.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId)
        .set({
      'recipeId': recipeId,
      'name': recipe['name'] ?? '',
      'category': recipe['category'] ?? '',
      'time': recipe['time'] ?? '',
      'icon': recipe['icon'] ?? '🍽️',
      'ingredients': recipe['ingredients'] ?? '',
      'instructions': recipe['instructions'] ?? '',
      'recipeUserId': recipe['userId'] ?? '',
      'imageUrl': recipe['imageUrl'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    if (recipeId.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(recipeId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserFavorites(
      String userId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots();
  }
}