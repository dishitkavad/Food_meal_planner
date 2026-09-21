
import 'package:flutter/material.dart';
import 'package:food_meal_planner/screens/recipe_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  String selectedCategory = 'All';
  String searchQuery = '';
  String selectedDay = 'Monday';
  String newShoppingItem = '';

  final Set<String> favoriteRecipes = {};
  final Map<String, String> mealPlan = {};
  final Map<String, bool> shoppingList = {};

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
  ];

  final List<Map<String, String>> recipes = [
    {
      'name': 'Vegetable Sandwich',
      'category': 'Breakfast',
      'time': '15 min',
      'icon': '🥪',
    },
    {
      'name': 'Paneer Curry',
      'category': 'Lunch',
      'time': '30 min',
      'icon': '🍛',
    },
    {
      'name': 'Vegetable Pasta',
      'category': 'Dinner',
      'time': '25 min',
      'icon': '🍝',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Dessert',
      'time': '45 min',
      'icon': '🍰',
    },
  ];

  // FILTER RECIPES
  List<Map<String, String>> getFilteredRecipes() {
    return recipes.where((recipe) {
      final matchesCategory = selectedCategory == 'All' ||
          recipe['category'] == selectedCategory;

      final matchesSearch = recipe['name']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // GET FAVORITE RECIPES
  List<Map<String, String>> getFavoriteRecipes() {
    return recipes.where((recipe) {
      return favoriteRecipes.contains(recipe['name']);
    }).toList();
  }

  // FIND A RECIPE BY NAME
  Map<String, String>? findRecipe(String recipeName) {
    for (final recipe in recipes) {
      if (recipe['name'] == recipeName) {
        return recipe;
      }
    }
    return null;
  }

  // ADD OR REMOVE FAVORITES
  void toggleFavorite(String recipeName) {
    setState(() {
      if (favoriteRecipes.contains(recipeName)) {
        favoriteRecipes.remove(recipeName);
      } else {
        favoriteRecipes.add(recipeName);
      }
    });
  }

  // OPEN RECIPE DETAILS
  void openRecipeDetails(Map<String, String> recipe) {
    final recipeName = recipe['name']!;

    String description;
    List<String> ingredients;
    List<String> instructions;
    String preparationTime;
    int servings = 2;

    switch (recipeName) {
      case 'Vegetable Sandwich':
        description =
        'A quick and tasty sandwich filled with fresh vegetables.';
        ingredients = [
          '4 slices of bread',
          '1 small onion, chopped',
          '1 small tomato, chopped',
          '1/2 cup chopped vegetables',
          'Butter or chutney',
          'Salt and pepper to taste',
        ];
        instructions = [
          'Chop the vegetables into small pieces.',
          'Mix the vegetables with salt and pepper.',
          'Spread butter or chutney on the bread slices.',
          'Add the vegetable mixture and cover with another slice.',
          'Toast the sandwich if you like, then serve.',
        ];
        preparationTime = '15 min';
        break;

      case 'Paneer Curry':
        description =
        'A flavorful Indian curry made with paneer and spices.';
        ingredients = [
          '200 g paneer, cubed',
          '2 tomatoes, chopped',
          '1 onion, chopped',
          '1 tablespoon oil',
          '1/2 teaspoon turmeric',
          '1 teaspoon curry masala',
          'Salt to taste',
          'Water as needed',
        ];
        instructions = [
          'Heat oil in a pan and sauté the chopped onion.',
          'Add tomatoes and cook until soft.',
          'Add turmeric, curry masala, and salt.',
          'Add a little water and mix well.',
          'Add paneer cubes and simmer for a few minutes.',
          'Serve hot with roti or rice.',
        ];
        preparationTime = '30 min';
        break;

      case 'Vegetable Pasta':
        description =
        'A delicious pasta dish prepared with vegetables and sauce.';
        ingredients = [
          '1 cup pasta',
          '1/2 cup chopped vegetables',
          '2 tablespoons tomato sauce',
          '1 tablespoon oil',
          'Salt to taste',
          'Black pepper to taste',
        ];
        instructions = [
          'Boil the pasta according to the packet instructions.',
          'Heat oil in a pan and cook the chopped vegetables.',
          'Add tomato sauce, salt, and pepper.',
          'Add the boiled pasta and mix everything together.',
          'Cook for another two minutes and serve.',
        ];
        preparationTime = '25 min';
        break;

      case 'Chocolate Cake':
        description = 'A sweet chocolate cake that is perfect for dessert.';
        ingredients = [
          '1 cup flour',
          '1/2 cup sugar',
          '2 tablespoons cocoa powder',
          '1/2 cup milk',
          '1/4 cup oil',
          '1 teaspoon baking powder',
        ];
        instructions = [
          'Mix the flour, sugar, cocoa powder, and baking powder.',
          'Add milk and oil, then mix into a smooth batter.',
          'Pour the batter into a greased baking tin.',
          'Bake in a preheated oven until a toothpick comes out clean.',
          'Allow the cake to cool before serving.',
        ];
        preparationTime = '45 min';
        break;

      default:
        description = 'A delicious recipe to try at home.';
        ingredients = ['Ingredients will be added soon.'];
        instructions = ['Cooking instructions will be added soon.'];
        preparationTime = recipe['time'] ?? 'Not specified';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(
          recipeName: recipeName,
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          preparationTime: preparationTime,
          servings: servings,
        ),
      ),
    );
  }

  // RECIPE CARD
  Widget buildRecipeCard(Map<String, String> recipe) {
    final recipeName = recipe['name']!;
    final isFavorite = favoriteRecipes.contains(recipeName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          child: Text(
            recipe['icon']!,
            style: const TextStyle(fontSize: 25),
          ),
        ),
        title: Text(
          recipeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${recipe['category']} • ${recipe['time']}',
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () => toggleFavorite(recipeName),
        ),
        onTap: () => openRecipeDetails(recipe),
      ),
    );
  }

  // HOME SCREEN
  Widget buildHomeContent() {
    final filteredRecipes = getFilteredRecipes();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Hello, Food Lover! 👋',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'What would you like to cook today?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
            const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];

              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'All Recipes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (filteredRecipes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No recipes found. Try another search or category.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...filteredRecipes.map(buildRecipeCard),
      ],
    );
  }

  // FAVORITES SCREEN
  Widget buildFavoritesContent() {
    final favorites = getFavoriteRecipes();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'My Favorites ❤️',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Your saved recipes are all in one place.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 24),

        if (favorites.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No favorite recipes yet.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Go to Home and tap the heart on a recipe '
                      'to save it here.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...favorites.map(buildRecipeCard),
      ],
    );
  }

  // MEAL PLAN SCREEN
  Widget buildMealPlanContent() {
    final plannedRecipeName = mealPlan[selectedDay];
    final plannedRecipe = plannedRecipeName == null
        ? null
        : findRecipe(plannedRecipeName);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Weekly Meal Plan 📅',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Choose a day and plan what you want to eat.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Select a day',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((day) {
            return ChoiceChip(
              label: Text(day),
              selected: selectedDay == day,
              onSelected: (selected) {
                setState(() {
                  selectedDay = day;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        Text(
          '$selectedDay\'s Meal',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (plannedRecipe != null)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                child: Text(
                  plannedRecipe['icon']!,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
              title: Text(
                plannedRecipe['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${plannedRecipe['category']} • '
                    '${plannedRecipe['time']}',
              ),
              onTap: () => openRecipeDetails(plannedRecipe),
              trailing: IconButton(
                tooltip: 'Remove from plan',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    mealPlan.remove(selectedDay);
                  });
                },
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No meal planned for this day yet.'),
              ),
            ),
          ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(
            plannedRecipe == null ? 'Add a Meal' : 'Change Meal',
          ),
          onPressed: showRecipePicker,
        ),

        const SizedBox(height: 24),

        const Text(
          'Your Weekly Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...days.map((day) {
          final recipeName = mealPlan[day];

          return Card(
            child: ListTile(
              title: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(recipeName ?? 'No meal planned'),
              leading: const Icon(Icons.calendar_today_outlined),
              onTap: () {
                setState(() {
                  selectedDay = day;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  // PICK A RECIPE FOR THE SELECTED DAY
  void showRecipePicker() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Choose a meal for $selectedDay'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: recipes.map((recipe) {
                return ListTile(
                  leading: Text(
                    recipe['icon']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(recipe['name']!),
                  subtitle: Text(
                    '${recipe['category']} • ${recipe['time']}',
                  ),
                  onTap: () {
                    setState(() {
                      mealPlan[selectedDay] = recipe['name']!;
                    });

                    Navigator.pop(dialogContext);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // SHOPPING LIST SCREEN
  Widget buildShoppingContent() {
    final remainingItems =
        shoppingList.values.where((purchased) => !purchased).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Shopping List 🛒',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '$remainingItems item(s) left to buy',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter an ingredient...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  newShoppingItem = value;
                },
                onSubmitted: (value) {
                  addShoppingItem();
                },
              ),
            ),

            const SizedBox(width: 8),

            IconButton.filled(
              icon: const Icon(Icons.add),
              tooltip: 'Add item',
              onPressed: addShoppingItem,
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (shoppingList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'Your shopping list is empty.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add ingredients using the field above.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...shoppingList.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: entry.value,
                title: Text(
                  entry.key,
                  style: TextStyle(
                    decoration: entry.value
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                onChanged: (checked) {
                  setState(() {
                    shoppingList[entry.key] = checked ?? false;
                  });
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove item',
                  onPressed: () {
                    setState(() {
                      shoppingList.remove(entry.key);
                    });
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  // ADD AN ITEM TO THE SHOPPING LIST
  void addShoppingItem() {
    final item = newShoppingItem.trim();

    if (item.isEmpty) {
      return;
    }

    setState(() {
      final alreadyExists = shoppingList.keys.any(
            (key) => key.toLowerCase() == item.toLowerCase(),
      );

      if (!alreadyExists) {
        shoppingList[item] = false;
      }

      newShoppingItem = '';
    });
  }

  // SELECT WHICH SCREEN TO DISPLAY
  Widget getSelectedScreen() {
    switch (selectedIndex) {
      case 0:
        return buildHomeContent();
      case 1:
        return buildFavoritesContent();
      case 2:
        return buildMealPlanContent();
      case 3:
        return buildShoppingContent();
      default:
        return buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Meal Planner'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile screen will be added later.'),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),

      body: SafeArea(
        child: getSelectedScreen(),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Meal Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Shopping',
          ),
        ],
      ),
    );
  }
}