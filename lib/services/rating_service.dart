
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// Add or update a user's rating for a recipe.
Future<void> addOrUpdateRating({
required String recipeId,
required String userId,
required double rating,
}) async {
await _firestore
    .collection('recipes')
    .doc(recipeId)
    .collection('ratings')
    .doc(userId)
    .set({
'userId': userId,
'rating': rating,
'updatedAt': FieldValue.serverTimestamp(),
});
}

// Get all ratings for a recipe.
Stream<QuerySnapshot<Map<String, dynamic>>>
getRecipeRatings(String recipeId) {
return _firestore
    .collection('recipes')
    .doc(recipeId)
    .collection('ratings')
    .snapshots();
}

// Get the current user's rating for a recipe.
Future<DocumentSnapshot<Map<String, dynamic>>>
getUserRating({
required String recipeId,
required String userId,
}) async {
return await _firestore
    .collection('recipes')
    .doc(recipeId)
    .collection('ratings')
    .doc(userId)
    .get();
}

// Delete the current user's rating.
Future<void> deleteRating({
required String recipeId,
required String userId,
}) async {
await _firestore
    .collection('recipes')
    .doc(recipeId)
    .collection('ratings')
    .doc(userId)
    .delete();
}

// Get the average rating and rating count.
Future<Map<String, dynamic>> getRatingSummary(
String recipeId) async {
final snapshot = await _firestore
    .collection('recipes')
    .doc(recipeId)
    .collection('ratings')
    .get();

if (snapshot.docs.isEmpty) {
return {
'average': 0.0,
'count': 0,
};
}

double total = 0;

for (final document in snapshot.docs) {
final data = document.data();

total +=
(data['rating'] as num?)?.toDouble() ?? 0;
}

final count = snapshot.docs.length;

return {
'average': total / count,
'count': count,
};
}
}
