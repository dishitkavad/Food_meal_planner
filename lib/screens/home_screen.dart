
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_meal_planner/screens/add_recipe_screen.dart';
import 'package:food_meal_planner/screens/edit_recipe_screen.dart';
import 'package:food_meal_planner/screens/profile_screen.dart';
import 'package:food_meal_planner/screens/recipe_details_screen.dart';
import 'package:food_meal_planner/services/recipe_service.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final RecipeService _recipeService = RecipeService();

int _selectedIndex = 0;

String _selectedCategory = 'All';

final List<Map<String, String>> _favoriteRecipes = [];

final Map<String, Map<String, String>?> _mealPlan = {
'Monday': null,
'Tuesday': null,
'Wednesday': null,
'Thursday': null,
'Friday': null,
'Saturday': null,
'Sunday': null,
};

List<Map<String, String>> _currentRecipes = [];

final List<String> _shoppingItems = [];

final List<bool> _shoppingItemChecked = [];

final List<String> _categories = [
'All',
'Breakfast',
'Lunch',
'Dinner',
'Dessert',
'Snack',
];

final List<String> _days = [
'Monday',
'Tuesday',
'Wednesday',
'Thursday',
'Friday',
'Saturday',
'Sunday',
];

final List<Map<String, String>> _sampleRecipes = [
{
'name': 'Vegetable Sandwich',
'category': 'Breakfast',
'time': '15 min',
'icon': '🥪',
'ingredients':
'Bread, Tomato, Onion, Cucumber, Cheese, Salt',
'instructions':
'Prepare the vegetables. Place cheese and vegetables between the bread slices. Toast the sandwich until golden brown. Serve hot.',
},
{
'name': 'Paneer Curry',
'category': 'Lunch',
'time': '30 min',
'icon': '🍛',
'ingredients':
'Paneer, Onion, Tomato, Ginger, Garlic, Spices',
'instructions':
'Cut the paneer into cubes. Prepare onion and tomato gravy. Add spices and paneer. Cook for 10 minutes and serve hot.',
},
{
'name': 'Vegetable Pasta',
'category': 'Dinner',
'time': '25 min',
'icon': '🍝',
'ingredients':
'Pasta, Onion, Tomato, Capsicum, Garlic, Cheese',
'instructions':
'Boil the pasta. Sauté vegetables with garlic. Add pasta and seasoning. Mix well and serve hot.',
},
{
'name': 'Chocolate Cake',
'category': 'Dessert',
'time': '45 min',
'icon': '🍰',
'ingredients':
'Flour, Cocoa Powder, Sugar, Milk, Butter, Baking Powder',
'instructions':
'Mix all ingredients into a smooth batter. Pour into a cake tin. Bake until fully cooked. Allow it to cool before serving.',
},
];

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFFFF8F0),
appBar: AppBar(
title: const Text(
'Food & Meal Planner',
style: TextStyle(fontWeight: FontWeight.bold),
),
backgroundColor: const Color(0xFFE85D04),
foregroundColor: Colors.white,
actions: [
IconButton(
icon: const Icon(Icons.person),
tooltip: 'Profile',
onPressed: _openProfile,
),
],
),
body: _buildCurrentScreen(),
floatingActionButton: _selectedIndex == 0
? FloatingActionButton(
backgroundColor: const Color(0xFFE85D04),
foregroundColor: Colors.white,
onPressed: _openAddRecipe,
child: const Icon(Icons.add),
)
    : _selectedIndex == 3
? FloatingActionButton(
backgroundColor: const Color(0xFFE85D04),
foregroundColor: Colors.white,
onPressed: _addShoppingItem,
child: const Icon(Icons.add),
)
    : null,
bottomNavigationBar: BottomNavigationBar(
currentIndex: _selectedIndex,
type: BottomNavigationBarType.fixed,
selectedItemColor: const Color(0xFFE85D04),
unselectedItemColor: Colors.grey,
onTap: (index) {
setState(() {
_selectedIndex = index;
});
},
items: const [
BottomNavigationBarItem(
icon: Icon(Icons.home_outlined),
activeIcon: Icon(Icons.home),
label: 'Home',
),
BottomNavigationBarItem(
icon: Icon(Icons.favorite_border),
activeIcon: Icon(Icons.favorite),
label: 'Favorites',
),
BottomNavigationBarItem(
icon: Icon(Icons.calendar_month_outlined),
activeIcon: Icon(Icons.calendar_month),
label: 'Meal Plan',
),
BottomNavigationBarItem(
icon: Icon(Icons.shopping_cart_outlined),
activeIcon: Icon(Icons.shopping_cart),
label: 'Shopping',
),
],
),
);
}

Widget _buildCurrentScreen() {
switch (_selectedIndex) {
case 1:
return _buildFavoritesScreen();
case 2:
return _buildMealPlanScreen();
case 3:
return _buildShoppingScreen();
default:
return _buildHomeScreen();
}
}

Widget _buildHomeScreen() {
return StreamBuilder(
stream: _recipeService.getAllRecipes(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(20),
child: Text(
'Something went wrong:\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final firestoreRecipes = snapshot.data?.docs ?? [];

final List<Map<String, String>> recipes = [
..._sampleRecipes,
...firestoreRecipes.map((doc) {
final data = doc.data();

return {
'id': doc.id,
'name': data['name']?.toString() ?? '',
'category': data['category']?.toString() ?? '',
'time':
'${data['cookingTime']?.toString() ?? '0'} min',
'icon': '🍽️',
'ingredients':
data['ingredients']?.toString() ?? '',
'instructions':
data['instructions']?.toString() ?? '',
'userId':
data['userId']?.toString() ?? '',
'imageUrl':
data['imageUrl']?.toString() ?? '',
};
}),
];

_currentRecipes = recipes;

final filteredRecipes = _selectedCategory == 'All'
? recipes
    : recipes
    .where(
(recipe) =>
recipe['category'] ==
_selectedCategory,
)
    .toList();

return SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Welcome! 👋',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: Color(0xFF292524),
),
),
const SizedBox(height: 8),
const Text(
'What would you like to cook today?',
style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),
const SizedBox(height: 20),
_buildSearchBox(),
const SizedBox(height: 20),
const Text(
'Categories',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
SizedBox(
height: 45,
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: _categories.length,
itemBuilder: (context, index) {
final category =
_categories[index];

final isSelected =
_selectedCategory == category;

return Padding(
padding:
const EdgeInsets.only(right: 10),
child: ChoiceChip(
label: Text(category),
selected: isSelected,
selectedColor:
const Color(0xFFE85D04),
labelStyle: TextStyle(
color: isSelected
? Colors.white
    : Colors.black87,
fontWeight: FontWeight.w500,
),
onSelected: (_) {
setState(() {
_selectedCategory =
category;
});
},
),
);
},
),
),
const SizedBox(height: 24),
Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
const Text(
'Recipes',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
Text(
'${filteredRecipes.length} recipes',
style:
const TextStyle(color: Colors.grey),
),
],
),
const SizedBox(height: 12),
if (filteredRecipes.isEmpty)
const Center(
child: Padding(
padding: EdgeInsets.all(30),
child: Text(
'No recipes found.',
style: TextStyle(
fontSize: 16,
color: Colors.black54,
),
),
),
),
...filteredRecipes.map(
(recipe) => _buildRecipeCard(recipe),
),
],
),
);
},
);
}

Widget _buildSearchBox() {
return TextField(
decoration: InputDecoration(
hintText: 'Search recipes...',
prefixIcon: const Icon(Icons.search),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
borderSide: BorderSide.none,
),
),
);
}

Widget _buildRecipeCard(
Map<String, String> recipe) {
final recipeId = recipe['id'];

final isFirestoreRecipe =
recipeId != null && recipeId.isNotEmpty;

final currentUser =
FirebaseAuth.instance.currentUser;

final isRecipeOwner =
isFirestoreRecipe &&
recipe['userId'] == currentUser?.uid;

final isFavorite = _isFavorite(recipe);

return Card(
margin: const EdgeInsets.only(bottom: 14),
elevation: 2,
color: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: Padding(
padding: const EdgeInsets.all(14),
child: Row(
children: [
Container(
width: 65,
height: 65,
decoration: BoxDecoration(
color: const Color(0xFFFFE8D6),
borderRadius:
BorderRadius.circular(14),
),
alignment: Alignment.center,
child: Text(
recipe['icon'] ?? '🍽️',
style:
const TextStyle(fontSize: 32),
),
),
const SizedBox(width: 14),
Expanded(
child: InkWell(
onTap: () {
_openRecipeDetails(recipe);
},
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
recipe['name'] ?? '',
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 5),
Text(
recipe['category'] ?? '',
style: const TextStyle(
color: Color(0xFF2D6A4F),
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 5),
Row(
children: [
const Icon(
Icons.access_time,
size: 16,
color: Colors.grey,
),
const SizedBox(width: 4),
Text(
recipe['time'] ?? '',
style: const TextStyle(
color: Colors.grey,
),
),
],
),
],
),
),
),
IconButton(
tooltip: isFavorite
? 'Remove from Favorites'
    : 'Add to Favorites',
icon: Icon(
isFavorite
? Icons.favorite
    : Icons.favorite_border,
color: isFavorite
? Colors.red
    : Colors.grey,
),
onPressed: () {
_toggleFavorite(recipe);
},
),
if (isRecipeOwner) ...[
IconButton(
icon: const Icon(
Icons.edit,
color: Color(0xFF2D6A4F),
),
tooltip: 'Edit Recipe',
onPressed: () {
_openEditRecipe(recipe);
},
),
IconButton(
icon: const Icon(
Icons.delete,
color: Colors.red,
),
tooltip: 'Delete Recipe',
onPressed: () {
_showDeleteDialog(recipe);
},
),
],
],
),
),
);
}

bool _isFavorite(
Map<String, String> recipe) {
return _favoriteRecipes.any(
(favorite) =>
_recipeKey(favorite) ==
_recipeKey(recipe),
);
}

String _recipeKey(
Map<String, String> recipe) {
if (recipe['id'] != null &&
recipe['id']!.isNotEmpty) {
return recipe['id']!;
}

return '${recipe['name']}_${recipe['category']}';
}

void _toggleFavorite(
Map<String, String> recipe) {
setState(() {
if (_isFavorite(recipe)) {
_favoriteRecipes.removeWhere(
(favorite) =>
_recipeKey(favorite) ==
_recipeKey(recipe),
);
} else {
_favoriteRecipes.add(
Map<String, String>.from(recipe),
);
}
});

final added = _isFavorite(recipe);

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
duration: const Duration(seconds: 1),
content: Text(
added
? '${recipe['name']} added to Favorites ❤️'
    : '${recipe['name']} removed from Favorites',
),
),
);
}

Widget _buildFavoritesScreen() {
if (_favoriteRecipes.isEmpty) {
return const Center(
child: Padding(
padding: EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.favorite_border,
size: 90,
color: Colors.grey,
),
SizedBox(height: 20),
Text(
'No Favorites Yet',
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 10),
Text(
'Tap the ❤️ button on a recipe to add it here.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),
],
),
),
);
}

return SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'My Favorites ❤️',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
'${_favoriteRecipes.length} favorite recipe(s)',
style:
const TextStyle(color: Colors.grey),
),
const SizedBox(height: 20),
..._favoriteRecipes.map(
(recipe) =>
_buildFavoriteCard(recipe),
),
],
),
);
}

Widget _buildFavoriteCard(
Map<String, String> recipe) {
return Card(
margin: const EdgeInsets.only(bottom: 14),
color: Colors.white,
child: ListTile(
contentPadding:
const EdgeInsets.all(12),
leading: Container(
width: 55,
height: 55,
decoration: BoxDecoration(
color: const Color(0xFFFFE8D6),
borderRadius:
BorderRadius.circular(12),
),
alignment: Alignment.center,
child: Text(
recipe['icon'] ?? '🍽️',
style:
const TextStyle(fontSize: 28),
),
),
title: Text(
recipe['name'] ?? '',
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 17,
),
),
subtitle: Text(
'${recipe['category'] ?? ''} • ${recipe['time'] ?? ''}',
),
trailing: IconButton(
icon: const Icon(
Icons.favorite,
color: Colors.red,
),
onPressed: () {
_toggleFavorite(recipe);
},
),
onTap: () {
_openRecipeDetails(recipe);
},
),
);
}

Widget _buildMealPlanScreen() {
return SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Weekly Meal Plan 📅',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
const Text(
'Plan your meals for each day.',
style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),
const SizedBox(height: 20),
..._days.map(
(day) => _buildMealDayCard(day),
),
],
),
);
}

Widget _buildMealDayCard(String day) {
final meal = _mealPlan[day];

return Card(
margin: const EdgeInsets.only(bottom: 12),
color: Colors.white,
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
child: Padding(
padding: const EdgeInsets.all(14),
child: Row(
children: [
Container(
width: 52,
height: 52,
decoration: BoxDecoration(
color: const Color(0xFFFFE8D6),
borderRadius:
BorderRadius.circular(12),
),
alignment: Alignment.center,
child: const Icon(
Icons.restaurant,
color: Color(0xFFE85D04),
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
day,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 5),
if (meal == null)
const Text(
'No meal planned',
style:
TextStyle(color: Colors.grey),
)
else
Text(
'${meal['icon'] ?? '🍽️'} ${meal['name'] ?? ''}',
style: const TextStyle(
fontSize: 16,
color: Color(0xFF2D6A4F),
fontWeight: FontWeight.w500,
),
),
],
),
),
if (meal != null)
IconButton(
tooltip: 'Remove meal',
icon: const Icon(
Icons.delete_outline,
color: Colors.red,
),
onPressed: () {
setState(() {
_mealPlan[day] = null;
});

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content:
Text('Meal removed from $day.'),
),
);
},
),
IconButton(
tooltip: 'Choose meal',
icon: const Icon(
Icons.add_circle,
color: Color(0xFFE85D04),
),
onPressed: () {
_showMealSelectionDialog(day);
},
),
],
),
),
);
}

void _showMealSelectionDialog(
String day) {
if (_currentRecipes.isEmpty) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content:
Text('No recipes available yet.'),
),
);
return;
}

showModalBottomSheet(
context: context,
isScrollControlled: true,
shape:
const RoundedRectangleBorder(
borderRadius:
BorderRadius.vertical(
top: Radius.circular(20),
),
),
builder: (context) {
return SafeArea(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
mainAxisSize:
MainAxisSize.min,
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Choose Meal for $day',
style: const TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),
const SizedBox(height: 15),
SizedBox(
height: 400,
child: ListView.builder(
itemCount:
_currentRecipes.length,
itemBuilder:
(context, index) {
final recipe =
_currentRecipes[index];

return Card(
color: Colors.white,
child: ListTile(
leading: Text(
recipe['icon'] ??
'🍽️',
style:
const TextStyle(
fontSize: 28,
),
),
title: Text(
recipe['name'] ?? '',
style:
const TextStyle(
fontWeight:
FontWeight.bold,
),
),
subtitle: Text(
'${recipe['category'] ?? ''} • ${recipe['time'] ?? ''}',
),
trailing:
const Icon(
Icons.add_circle,
color:
Color(0xFFE85D04),
),
onTap: () {
setState(() {
_mealPlan[day] =
Map<String, String>.from(
recipe,
);
});

Navigator.pop(context);

ScaffoldMessenger.of(
context)
    .showSnackBar(
SnackBar(
content: Text(
'${recipe['name']} added to $day.',
),
),
);
},
),
);
},
),
),
],
),
),
);
},
);
}

void _openRecipeDetails(
Map<String, String> recipe) {
final ingredients =
(recipe['ingredients'] ?? '')
    .split(',')
    .map((item) => item.trim())
    .where(
(item) => item.isNotEmpty,
)
    .toList();

final instructions =
(recipe['instructions'] ?? '')
    .split('.')
    .map((item) => item.trim())
    .where(
(item) => item.isNotEmpty,
)
    .toList();

Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
RecipeDetailsScreen(
recipeName:
recipe['name'] ?? '',
description:
'A delicious ${recipe['category'] ?? ''} recipe.',
ingredients:
ingredients,
instructions:
instructions,
preparationTime:
recipe['time'] ?? '0 min',
servings: 2,
imageUrl:
recipe['imageUrl'] ?? '',
),
),
);
}

void _openEditRecipe(
Map<String, String> recipe) {
final recipeId = recipe['id'];

if (recipeId == null ||
recipeId.isEmpty) {
return;
}

final cookingTime =
int.tryParse(
(recipe['time'] ?? '0')
    .replaceAll(' min', ''),
) ??
0;

Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
EditRecipeScreen(
recipeId: recipeId,
initialName:
recipe['name'] ?? '',
initialCategory:
recipe['category'] ??
'Breakfast',
initialCookingTime:
cookingTime,
initialIngredients:
recipe['ingredients'] ?? '',
initialInstructions:
recipe['instructions'] ?? '',
),
),
);
}

Future<void> _showDeleteDialog(
Map<String, String> recipe) async {
final recipeId = recipe['id'];

if (recipeId == null ||
recipeId.isEmpty) {
return;
}

final recipeName =
recipe['name'] ?? 'this recipe';

final shouldDelete =
await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title:
const Text('Delete Recipe?'),
content: Text(
'Are you sure you want to delete "$recipeName"?\n\nThis action cannot be undone.',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
context,
false,
);
},
child:
const Text('Cancel'),
),
ElevatedButton(
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.red,
foregroundColor:
Colors.white,
),
onPressed: () {
Navigator.pop(
context,
true,
);
},
child:
const Text('Delete'),
),
],
);
},
);

if (shouldDelete != true) {
return;
}

try {
await _recipeService.deleteRecipe(
recipeId: recipeId,
);

if (!mounted) return;

setState(() {
_favoriteRecipes.removeWhere(
(favorite) =>
_recipeKey(favorite) ==
recipeId,
);

for (final day in _days) {
if (_mealPlan[day] != null &&
_recipeKey(
_mealPlan[day]!,
) ==
recipeId) {
_mealPlan[day] = null;
}
}
});

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content:
Text('Recipe deleted successfully!'),
),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content:
Text('Failed to delete recipe: $e'),
),
);
}
}

void _openProfile() {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const ProfileScreen(),
),
);
}

Future<void> _openAddRecipe() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const AddRecipeScreen(),
),
);

if (mounted) {
setState(() {});
}
}

Widget _buildShoppingScreen() {
return Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Shopping List 🛒',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
const Text(
'Add ingredients you need to buy.',
style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),
const SizedBox(height: 20),
if (_shoppingItems.isEmpty)
const Expanded(
child: Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.shopping_cart_outlined,
size: 80,
color: Colors.grey,
),
SizedBox(height: 16),
Text(
'Shopping list is empty',
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
SizedBox(height: 8),
Text(
'Tap + to add an item.',
style: TextStyle(
color: Colors.grey,
),
),
],
),
),
)
else
Expanded(
child: ListView.builder(
itemCount:
_shoppingItems.length,
itemBuilder:
(context, index) {
final isChecked =
_shoppingItemChecked[
index];

return Card(
color: Colors.white,
margin:
const EdgeInsets.only(
bottom: 10,
),
child: ListTile(
leading: Checkbox(
value: isChecked,
activeColor:
const Color(
0xFFE85D04,
),
onChanged: (value) {
setState(() {
_shoppingItemChecked[
index] =
value ?? false;
});
},
),
title: Text(
_shoppingItems[index],
style: TextStyle(
fontSize: 16,
decoration: isChecked
? TextDecoration
    .lineThrough
    : TextDecoration
    .none,
color: isChecked
? Colors.grey
    : Colors.black87,
),
),
trailing:
IconButton(
icon: const Icon(
Icons.delete,
color: Colors.red,
),
onPressed: () {
setState(() {
_shoppingItems
    .removeAt(
index,
);

_shoppingItemChecked
    .removeAt(
index,
);
});
},
),
),
);
},
),
),
],
),
);
}

void _addShoppingItem() {
final controller =
TextEditingController();

showDialog(
context: context,
builder: (context) {
return AlertDialog(
title:
const Text('Add Shopping Item'),
content: TextField(
controller: controller,
autofocus: true,
decoration:
const InputDecoration(
hintText:
'Example: Tomatoes',
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child:
const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
final item =
controller.text.trim();

if (item.isNotEmpty) {
setState(() {
_shoppingItems.add(item);

_shoppingItemChecked
    .add(false);
});
}

Navigator.pop(context);
},
child:
const Text('Add'),
),
],
);
},
);
}
}
