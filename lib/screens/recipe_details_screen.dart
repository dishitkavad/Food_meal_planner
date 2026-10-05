
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_meal_planner/services/rating_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
final String recipeName;
final String description;
final List<String> ingredients;
final List<String> instructions;
final String preparationTime;
final int servings;
final String imageUrl;
final String recipeId;

const RecipeDetailsScreen({
super.key,
required this.recipeName,
required this.description,
required this.ingredients,
required this.instructions,
required this.preparationTime,
required this.servings,
this.imageUrl = '',
this.recipeId = '',
});

@override
State<RecipeDetailsScreen> createState() =>
_RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState
extends State<RecipeDetailsScreen> {
final RatingService _ratingService =
RatingService();

double _selectedRating = 0;

double _averageRating = 0;

int _ratingCount = 0;

bool _isLoadingRating = true;

@override
void initState() {
super.initState();
_loadRating();
}

Future<void> _loadRating() async {
if (widget.recipeId.isEmpty) {
setState(() {
_isLoadingRating = false;
});
return;
}

try {
final snapshot =
await _ratingService
    .getRecipeRatings(widget.recipeId)
    .first;

double totalRating = 0;

double? currentUserRating;

final currentUser =
FirebaseAuth.instance.currentUser;

for (final document in snapshot.docs) {
final data = document.data();

final ratingValue =
(data['rating'] as num?)?.toDouble() ?? 0;

totalRating += ratingValue;

if (currentUser != null &&
data['userId'] ==
currentUser.uid) {
currentUserRating = ratingValue;
}
}

final count = snapshot.docs.length;

if (!mounted) return;

setState(() {
_ratingCount = count;

_averageRating =
count > 0 ? totalRating / count : 0;

_selectedRating =
currentUserRating ?? 0;

_isLoadingRating = false;
});
} catch (e) {
if (!mounted) return;

setState(() {
_isLoadingRating = false;
});
}
}

Future<void> _submitRating() async {
if (widget.recipeId.isEmpty) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Rating is available only for saved recipes.',
),
),
);
return;
}

if (_selectedRating == 0) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Please select a star rating first.',
),
),
);
return;
}

final currentUser =
FirebaseAuth.instance.currentUser;

if (currentUser == null) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Please login to rate this recipe.',
),
),
);
return;
}

try {
await _ratingService.addOrUpdateRating(
recipeId: widget.recipeId,
userId: currentUser.uid,
rating: _selectedRating,
);

await _loadRating();

if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
'Rating submitted successfully! ⭐',
),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
'Failed to submit rating: $e',
),
),
);
}
}

Widget _buildRatingSection() {
if (widget.recipeId.isEmpty) {
return const SizedBox.shrink();
}

return Card(
color: Colors.white,
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Recipe Rating ⭐',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Color(0xFF2D6A4F),
),
),

const SizedBox(height: 16),

if (_isLoadingRating)
const Center(
child: CircularProgressIndicator(
color: Color(0xFFE85D04),
),
)
else ...[
Row(
children: [
Text(
_averageRating
    .toStringAsFixed(1),
style: const TextStyle(
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(width: 10),

Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: List.generate(
5,
(index) {
final starNumber =
index + 1;

return Icon(
starNumber <=
_averageRating
? Icons.star
    : Icons
    .star_border,
color:
const Color(
0xFFFFB703,
),
size: 24,
);
},
),
),

Text(
'$_ratingCount rating(s)',
style:
const TextStyle(
color: Colors.grey,
),
),
],
),
],
),

const SizedBox(height: 20),

const Text(
'Rate this recipe',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 10),

Row(
children: List.generate(
5,
(index) {
final starNumber =
index + 1;

return IconButton(
onPressed: () {
setState(() {
_selectedRating =
starNumber
    .toDouble();
});
},
icon: Icon(
starNumber <=
_selectedRating
? Icons.star
    : Icons.star_border,
color:
const Color(
0xFFFFB703,
),
size: 34,
),
);
},
),
),

const SizedBox(height: 8),

SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: _submitRating,
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(
0xFFE85D04,
),
foregroundColor:
Colors.white,
padding:
const EdgeInsets
    .symmetric(
vertical: 14,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
icon: const Icon(
Icons.star,
),
label: Text(
_selectedRating > 0
? 'Submit ${_selectedRating.toInt()} Star Rating'
    : 'Submit Rating',
),
),
),
],
],
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFFFFF8F0),

appBar: AppBar(
title:
const Text('Recipe Details'),
backgroundColor:
const Color(0xFFE85D04),
foregroundColor:
Colors.white,
),

body: SingleChildScrollView(
padding:
const EdgeInsets.all(16),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
// RECIPE IMAGE
if (widget.imageUrl.isNotEmpty)
ClipRRect(
borderRadius:
BorderRadius.circular(16),
child: Image.network(
widget.imageUrl,
width:
double.infinity,
height: 240,
fit: BoxFit.cover,

loadingBuilder:
(
context,
child,
loadingProgress,
) {
if (loadingProgress ==
null) {
return child;
}

return Container(
width:
double.infinity,
height: 240,
color:
const Color(
0xFFFFE8D6,
),
child:
const Center(
child:
CircularProgressIndicator(
color:
Color(
0xFFE85D04,
),
),
),
);
},

errorBuilder:
(
context,
error,
stackTrace,
) {
return Container(
width:
double.infinity,
height: 240,
color:
const Color(
0xFFFFE8D6,
),
child:
const Center(
child: Icon(
Icons
    .broken_image,
size: 60,
color:
Colors.grey,
),
),
);
},
),
),

if (widget.imageUrl.isNotEmpty)
const SizedBox(height: 20),

// RECIPE NAME
Text(
widget.recipeName,
style: const TextStyle(
fontSize: 28,
fontWeight:
FontWeight.bold,
color:
Color(0xFF292524),
),
),

const SizedBox(height: 12),

// DESCRIPTION
Text(
widget.description,
style: const TextStyle(
fontSize: 16,
color: Colors.black87,
),
),

const SizedBox(height: 20),

// TIME AND SERVINGS
Row(
children: [
const Icon(
Icons.access_time,
color:
Color(0xFFE85D04),
),

const SizedBox(width: 8),

Text(
widget.preparationTime,
style:
const TextStyle(
fontSize: 16,
),
),

const SizedBox(width: 24),

const Icon(
Icons.people,
color:
Color(0xFFE85D04),
),

const SizedBox(width: 8),

Text(
'${widget.servings} servings',
style:
const TextStyle(
fontSize: 16,
),
),
],
),

const SizedBox(height: 28),

// RATING SECTION
_buildRatingSection(),

if (widget.recipeId.isNotEmpty)
const SizedBox(height: 28),

// INGREDIENTS
const Text(
'Ingredients',
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
color:
Color(0xFF2D6A4F),
),
),

const SizedBox(height: 12),

...widget.ingredients.map(
(ingredient) =>
Padding(
padding:
const EdgeInsets
    .symmetric(
vertical: 6,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
const Icon(
Icons
    .check_circle_outline,
color:
Color(0xFF2D6A4F),
),

const SizedBox(
width: 10),

Expanded(
child: Text(
ingredient,
style:
const TextStyle(
fontSize: 16,
),
),
),
],
),
),
),

const SizedBox(height: 28),

// COOKING INSTRUCTIONS
const Text(
'Cooking Instructions',
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
color:
Color(0xFF2D6A4F),
),
),

const SizedBox(height: 12),

...widget.instructions
    .asMap()
    .entries
    .map(
(entry) => Padding(
padding:
const EdgeInsets
    .only(
bottom: 16,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
CircleAvatar(
radius: 16,
backgroundColor:
const Color(
0xFFE85D04,
),
child: Text(
'${entry.key + 1}',
style:
const TextStyle(
color:
Colors.white,
fontWeight:
FontWeight
    .bold,
),
),
),

const SizedBox(
width: 12),

Expanded(
child: Text(
entry.value,
style:
const TextStyle(
fontSize: 16,
height: 1.5,
),
),
),
],
),
),
),

const SizedBox(height: 20),
],
),
),
);
}
}

