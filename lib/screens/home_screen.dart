import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_meal_planner/screens/add_recipe_screen.dart';
import 'package:food_meal_planner/screens/edit_recipe_screen.dart';
import 'package:food_meal_planner/screens/profile_screen.dart';
import 'package:food_meal_planner/screens/recipe_details_screen.dart';
import 'package:food_meal_planner/services/recipe_service.dart';
import 'package:food_meal_planner/services/rating_service.dart';
import 'package:food_meal_planner/services/shopping_service.dart';
import 'package:food_meal_planner/services/meal_plan_service.dart';
import 'package:food_meal_planner/services/favorite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  final RatingService _ratingService = RatingService();
  final ShoppingService _shoppingService = ShoppingService();
  final MealPlanService _mealPlanService = MealPlanService();
  final FavoriteService _favoriteService = FavoriteService();

  StreamSubscription? _favoriteSubscription;

  StreamSubscription? _mealPlanSubscription;

  int _selectedIndex = 0;

  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  final ValueNotifier<String> _searchQueryNotifier =
  ValueNotifier<String>('');

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

  final Map<String, String?> _mealPlanDocumentIds = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  List<Map<String, String>> _currentRecipes = [];

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



  @override
  void initState() {
    super.initState();
    _listenToMealPlan();
    _listenToFavorites();
  }

  void _listenToFavorites() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    _favoriteSubscription = _favoriteService
        .getUserFavorites(user.uid)
        .listen((snapshot) {
      final updatedFavorites = <Map<String, String>>[];

      for (final document in snapshot.docs) {
        final data = document.data();

        updatedFavorites.add({
          'id': data['recipeId']?.toString() ?? document.id,
          'name': data['name']?.toString() ?? '',
          'category': data['category']?.toString() ?? '',
          'time': data['time']?.toString() ?? '',
          'icon': data['icon']?.toString() ?? '🍽️',
          'ingredients': data['ingredients']?.toString() ?? '',
          'instructions': data['instructions']?.toString() ?? '',
          'userId': data['recipeUserId']?.toString() ?? '',
          'imageUrl': data['imageUrl']?.toString() ?? '',
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _favoriteRecipes
          ..clear()
          ..addAll(updatedFavorites);
      });
    });
  }

  void _listenToMealPlan() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    _mealPlanSubscription = _mealPlanService
        .getUserMealPlan(user.uid)
        .listen((snapshot) {
      final updatedMealPlan = <String, Map<String, String>?>{
        'Monday': null,
        'Tuesday': null,
        'Wednesday': null,
        'Thursday': null,
        'Friday': null,
        'Saturday': null,
        'Sunday': null,
      };

      final updatedDocumentIds = <String, String?>{
        'Monday': null,
        'Tuesday': null,
        'Wednesday': null,
        'Thursday': null,
        'Friday': null,
        'Saturday': null,
        'Sunday': null,
      };

      for (final document in snapshot.docs) {
        final data = document.data();
        final day = data['day']?.toString();

        if (day == null || !updatedMealPlan.containsKey(day)) {
          continue;
        }

        updatedMealPlan[day] = {
          'id': data['recipeId']?.toString() ?? '',
          'name': data['recipeName']?.toString() ?? '',
          'category': data['category']?.toString() ?? '',
          'time': data['time']?.toString() ?? '',
          'icon': data['icon']?.toString() ?? '🍽️',
          'ingredients': data['ingredients']?.toString() ?? '',
          'instructions': data['instructions']?.toString() ?? '',
          'userId': data['recipeUserId']?.toString() ?? '',
          'imageUrl': data['imageUrl']?.toString() ?? '',
        };

        updatedDocumentIds[day] = document.id;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _mealPlan
          ..clear()
          ..addAll(updatedMealPlan);

        _mealPlanDocumentIds
          ..clear()
          ..addAll(updatedDocumentIds);
      });
    });
  }

  @override
  void dispose() {
    _mealPlanSubscription?.cancel();
    _favoriteSubscription?.cancel();
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final firestoreRecipes = snapshot.data?.docs ?? [];

        final List<Map<String, String>> recipes = [
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

        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchText, child) {
            final filteredRecipes = recipes.where((recipe) {
              final matchesCategory =
                  _selectedCategory == 'All' ||
                      recipe['category'] == _selectedCategory;

              final matchesSearch =
                  searchText.isEmpty ||
                      (recipe['name'] ?? '')
                          .toLowerCase()
                          .contains(searchText) ||
                      (recipe['category'] ?? '')
                          .toLowerCase()
                          .contains(searchText) ||
                      (recipe['ingredients'] ?? '')
                          .toLowerCase()
                          .contains(searchText);

              return matchesCategory && matchesSearch;
            }).toList();

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
                            _selectedCategory ==
                                category;

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            right: 10,
                          ),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor:
                            const Color(0xFFE85D04),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight:
                              FontWeight.w500,
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
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
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
                        (recipe) =>
                        _buildRecipeCard(recipe),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchText, child) {
            if (searchText.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchQueryNotifier.value = '';
                _searchFocusNode.requestFocus();
              },
            );
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        _searchQueryNotifier.value = value.toLowerCase();
      },
    );
  }

  Widget _buildRecipeCard(
      Map<String, String> recipe) {
    final recipeId = recipe['id'];

    final isFirestoreRecipe =
        recipeId != null &&
            recipeId.isNotEmpty;

    final currentUser =
        FirebaseAuth.instance.currentUser;

    final isRecipeOwner =
        isFirestoreRecipe &&
            recipe['userId'] ==
                currentUser?.uid;

    final isFavorite =
    _isFavorite(recipe);

    return Card(
      margin:
      const EdgeInsets.only(bottom: 14),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: SizedBox(
                width: 65,
                height: 65,
                child: recipe['imageUrl'] !=
                    null &&
                    recipe['imageUrl']!
                        .isNotEmpty
                    ? Image.network(
                  recipe['imageUrl']!,
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
                      color: const Color(
                        0xFFFFE8D6,
                      ),
                      alignment:
                      Alignment.center,
                      child:
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(
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
                      color: const Color(
                        0xFFFFE8D6,
                      ),
                      alignment:
                      Alignment.center,
                      child: Text(
                        recipe['icon'] ??
                            '🍽️',
                        style:
                        const TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: const Color(
                    0xFFFFE8D6,
                  ),
                  alignment:
                  Alignment.center,
                  child: Text(
                    recipe['icon'] ??
                        '🍽️',
                    style:
                    const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () {
                  _openRecipeDetails(
                      recipe);
                },
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? '',
                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe['category'] ?? '',
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF2D6A4F),
                        fontWeight:
                        FontWeight.w500,
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
                          style:
                          const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        if (isFirestoreRecipe) ...[
                          const SizedBox(width: 10),

                          Flexible(
                            child: FutureBuilder<
                                Map<String, dynamic>>(
                              future: _ratingService
                                  .getRatingSummary(
                                recipeId,
                              ),
                              builder:
                                  (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                }

                                final average =
                                    (snapshot.data![
                                    'average']
                                    as num?)
                                        ?.toDouble() ??
                                        0.0;

                                final count =
                                    (snapshot.data![
                                    'count']
                                    as num?)
                                        ?.toInt() ??
                                        0;

                                if (count == 0) {
                                  return const Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          'No ratings',
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        '${average.toStringAsFixed(1)} ($count)',
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
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
                  color:
                  Color(0xFF2D6A4F),
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
                  _showDeleteDialog(
                      recipe);
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

  Future<void> _toggleFavorite(
      Map<String, String> recipe,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final alreadyFavorite = _isFavorite(recipe);
    final recipeId = recipe['id'] ?? '';

    // Sample recipes do not have a Firestore ID, so they cannot
    // be stored permanently in the Favorites collection.
    if (recipeId.isEmpty) {
      setState(() {
        if (alreadyFavorite) {
          _favoriteRecipes.removeWhere(
                (favorite) =>
            _recipeKey(favorite) == _recipeKey(recipe),
          );
        } else {
          _favoriteRecipes.add(
            Map<String, String>.from(recipe),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(
            alreadyFavorite
                ? '${recipe['name']} removed from Favorites'
                : '${recipe['name']} added to Favorites ❤️',
          ),
        ),
      );

      return;
    }

    try {
      if (alreadyFavorite) {
        await _favoriteService.removeFavorite(
          userId: user.uid,
          recipeId: recipeId,
        );
      } else {
        await _favoriteService.addFavorite(
          userId: user.uid,
          recipe: recipe,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(
            alreadyFavorite
                ? '${recipe['name']} removed from Favorites'
                : '${recipe['name']} added to Favorites ❤️',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update Favorites: $e',
          ),
        ),
      );
    }
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
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tap the ❤️ button on a recipe to add it here.',
                textAlign:
                TextAlign.center,
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
      padding:
      const EdgeInsets.all(16),
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
            const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ..._favoriteRecipes.map(
                (recipe) =>
                _buildFavoriteCard(
                    recipe),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
      Map<String, String> recipe) {
    final recipeId = recipe['id'];

    final isFirestoreRecipe =
        recipeId != null &&
            recipeId.isNotEmpty;

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding:
        const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius:
          BorderRadius.circular(12),
          child: SizedBox(
            width: 55,
            height: 55,
            child: recipe['imageUrl'] !=
                null &&
                recipe['imageUrl']!
                    .isNotEmpty
                ? Image.network(
              recipe['imageUrl']!,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  color: const Color(
                    0xFFFFE8D6,
                  ),
                  alignment:
                  Alignment.center,
                  child: Text(
                    recipe['icon'] ??
                        '🍽️',
                    style:
                    const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                );
              },
            )
                : Container(
              color: const Color(
                0xFFFFE8D6,
              ),
              alignment:
              Alignment.center,
              child: Text(
                recipe['icon'] ??
                    '🍽️',
                style:
                const TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          recipe['name'] ?? '',
          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              '${recipe['category'] ?? ''} • ${recipe['time'] ?? ''}',
            ),

            if (isFirestoreRecipe)
              FutureBuilder<
                  Map<String, dynamic>>(
                future: _ratingService
                    .getRatingSummary(
                  recipeId,
                ),
                builder:
                    (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final average =
                      (snapshot.data![
                      'average']
                      as num?)
                          ?.toDouble() ??
                          0.0;

                  final count =
                      (snapshot.data![
                      'count']
                      as num?)
                          ?.toInt() ??
                          0;

                  if (count == 0) {
                    return const Text(
                      '⭐ No ratings',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }

                  return Text(
                    '⭐ ${average.toStringAsFixed(1)} ($count ratings)',
                    style:
                    const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
          ],
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
      padding:
      const EdgeInsets.all(16),
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
                (day) =>
                _buildMealDayCard(day),
          ),
        ],
      ),
    );
  }

  Widget _buildMealDayCard(
      String day) {
    final meal = _mealPlan[day];

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      color: Colors.white,
      elevation: 2,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration:
              BoxDecoration(
                color: const Color(
                  0xFFFFE8D6,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              alignment:
              Alignment.center,
              child: const Icon(
                Icons.restaurant,
                color:
                Color(0xFFE85D04),
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
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (meal == null)
                    const Text(
                      'No meal planned',
                      style:
                      TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  else
                    Text(
                      '${meal['icon'] ?? '🍽️'} ${meal['name'] ?? ''}',
                      style:
                      const TextStyle(
                        fontSize: 16,
                        color:
                        Color(0xFF2D6A4F),
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (meal != null)
              IconButton(
                tooltip:
                'Remove meal',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () {
                  _removeMealFromDay(day);
                },
              ),
            IconButton(
              tooltip:
              'Choose meal',
              icon: const Icon(
                Icons.add_circle,
                color:
                Color(0xFFE85D04),
              ),
              onPressed: () {
                _showMealSelectionDialog(
                    day);
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
          content: Text(
            'No recipes available yet.',
          ),
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
            padding:
            const EdgeInsets.all(16),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Meal for $day',
                  style:
                  const TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height: 15),
                SizedBox(
                  height: 400,
                  child:
                  ListView.builder(
                    itemCount:
                    _currentRecipes
                        .length,
                    itemBuilder:
                        (context, index) {
                      final recipe =
                      _currentRecipes[
                      index];

                      return Card(
                        color:
                        Colors.white,
                        child:
                        ListTile(
                          leading: Text(
                            recipe['icon'] ??
                                '🍽️',
                            style:
                            const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          title: Text(
                            recipe['name'] ??
                                '',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                          subtitle:
                          Text(
                            '${recipe['category'] ?? ''} • ${recipe['time'] ?? ''}',
                          ),
                          trailing:
                          const Icon(
                            Icons
                                .add_circle,
                            color:
                            Color(
                              0xFFE85D04,
                            ),
                          ),
                          onTap: () {
                            _saveMealForDay(
                              day,
                              recipe,
                            );

                            Navigator.pop(
                              context,
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

  Future<void> _saveMealForDay(
      String day,
      Map<String, String> recipe,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final existingDocumentId =
      _mealPlanDocumentIds[day];

      if (existingDocumentId != null &&
          existingDocumentId.isNotEmpty) {
        await _mealPlanService.deleteMeal(
          mealPlanId: existingDocumentId,
        );
      }

      await _mealPlanService.addMeal(
        userId: user.uid,
        day: day,
        recipeId: recipe['id'] ?? '',
        recipeName: recipe['name'] ?? '',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${recipe['name']} added to $day.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save meal plan: $e',
          ),
        ),
      );
    }
  }

  Future<void> _removeMealFromDay(
      String day,
      ) async {
    final documentId =
    _mealPlanDocumentIds[day];

    if (documentId == null ||
        documentId.isEmpty) {
      return;
    }

    try {
      await _mealPlanService.deleteMeal(
        mealPlanId: documentId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Meal removed from $day.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove meal: $e',
          ),
        ),
      );
    }
  }

  void _openRecipeDetails(
      Map<String, String> recipe) {
    // Ingredients can be entered using commas or separate lines.
    final ingredients =
    (recipe['ingredients'] ?? '')
        .split(RegExp(r'[,\r\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    // Instructions can be entered one step per line or as sentences.
    final instructions =
    (recipe['instructions'] ?? '')
        .split(RegExp(r'(?:\r?\n)+|(?<=[.!?])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
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
              recipeId:
              recipe['id'] ?? '',
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
              .replaceAll(
            ' min',
            '',
          ),
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
              recipe['ingredients'] ??
                  '',
              initialInstructions:
              recipe['instructions'] ??
                  '',
              initialImageUrl:
              recipe['imageUrl'] ?? '',
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
        recipe['name'] ??
            'this recipe';

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
      await _recipeService
          .deleteRecipe(
        recipeId: recipeId,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          await _favoriteService.removeFavorite(
            userId: user.uid,
            recipeId: recipeId,
          );
        } catch (_) {
          // The recipe deletion itself has already succeeded.
        }
      }

      if (!mounted) return;

      setState(() {
        _favoriteRecipes
            .removeWhere(
              (favorite) =>
          _recipeKey(
            favorite,
          ) ==
              recipeId,
        );

        for (final day in _days) {
          if (_mealPlan[day] != null &&
              _recipeKey(
                _mealPlan[day]!,
              ) ==
                  recipeId) {
            final mealPlanId =
            _mealPlanDocumentIds[day];

            if (mealPlanId != null &&
                mealPlanId.isNotEmpty) {
              _mealPlanService.deleteMeal(
                mealPlanId: mealPlanId,
              );
            }
          }
        }
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe deleted successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete recipe: $e',
          ),
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please login to use the shopping list.'),
      );
    }

    return StreamBuilder(
      stream: _shoppingService.getUserItems(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Something went wrong:\\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data?.docs ?? [];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              if (items.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            fontWeight: FontWeight.bold,
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
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final document = items[index];
                      final data = document.data();

                      final itemName =
                          data['itemName']?.toString() ?? '';

                      final isChecked =
                          data['isCompleted'] == true;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Checkbox(
                            value: isChecked,
                            activeColor:
                            const Color(0xFFE85D04),
                            onChanged: (value) async {
                              try {
                                await _shoppingService.updateItemStatus(
                                  itemId: document.id,
                                  isCompleted: value ?? false,
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update item: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          title: Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isChecked
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              try {
                                await _shoppingService.deleteItem(
                                  itemId: document.id,
                                );
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to delete item: $e',
                                    ),
                                  ),
                                );
                              }
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
      },
    );
  }

  Future<void> _addShoppingItem() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    String itemText = '';

    final item = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Shopping Item',
          ),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Example: Tomatoes',
            ),
            onChanged: (value) {
              itemText = value;
            },
            onSubmitted: (value) {
              Navigator.pop(
                dialogContext,
                value.trim(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  itemText.trim(),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (item == null || item.isEmpty) {
      return;
    }

    try {
      await _shoppingService.addItem(
        userId: user.uid,
        itemName: item,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item added to shopping list!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add item: $e',
          ),
        ),
      );
    }
  }
}
