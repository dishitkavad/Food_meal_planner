import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ADD RECIPE
  Future<void> addRecipe({
    required String userId,
    required String name,
    required String category,
    required int cookingTime,
    required String ingredients,
    required String instructions,
    String? imageUrl,
  }) async {
    await _firestore.collection('recipes').add({
      'userId': userId,
      'name': name.trim(),
      'category': category,
      'cookingTime': cookingTime,
      'ingredients': ingredients.trim(),
      'instructions': instructions.trim(),
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE RECIPE
  Future<void> updateRecipe({
    required String recipeId,
    required String name,
    required String category,
    required int cookingTime,
    required String ingredients,
    required String instructions,
    String? imageUrl,
  }) async {
    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .update({
      'name': name.trim(),
      'category': category,
      'cookingTime': cookingTime,
      'ingredients': ingredients.trim(),
      'instructions': instructions.trim(),
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // DELETE RECIPE
  Future<void> deleteRecipe({
    required String recipeId,
  }) async {
    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  // GET ALL FIRESTORE RECIPES
  Stream<QuerySnapshot<Map<String, dynamic>>>
  getAllRecipes() {
    return _firestore
        .collection('recipes')
        .snapshots();
  }

  // GET RECIPES CREATED BY CURRENT USER
  Stream<QuerySnapshot<Map<String, dynamic>>>
  getUserRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }
}