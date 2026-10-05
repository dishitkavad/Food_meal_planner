import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Add or update a meal for a specific day.
  Future<void> addMeal({
    required String userId,
    required String day,
    required String recipeId,
    required String recipeName,
  }) async {
    await _firestore.collection('mealPlans').add({
      'userId': userId,
      'day': day,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all meal plan items for the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserMealPlan(
      String userId,
      ) {
    return _firestore
        .collection('mealPlans')
        .where(
      'userId',
      isEqualTo: userId,
    )
        .snapshots();
  }

  /// Delete a meal from the meal plan.
  Future<void> deleteMeal({
    required String mealPlanId,
  }) async {
    await _firestore
        .collection('mealPlans')
        .doc(mealPlanId)
        .delete();
  }
}