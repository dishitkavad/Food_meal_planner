import 'package:flutter/material.dart';

import 'package:food_meal_planner/services/recipe_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final String initialName;
  final String initialCategory;
  final int initialCookingTime;
  final String initialIngredients;
  final String initialInstructions;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
    required this.initialName,
    required this.initialCategory,
    required this.initialCookingTime,
    required this.initialIngredients,
    required this.initialInstructions,
  });

  @override
  State<EditRecipeScreen> createState() =>
      _EditRecipeScreenState();
}

class _EditRecipeScreenState
    extends State<EditRecipeScreen> {
  final RecipeService _recipeService =
  RecipeService();

  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;

  late String _selectedCategory;

  final List<String> _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );

    _timeController = TextEditingController(
      text: widget.initialCookingTime.toString(),
    );

    _ingredientsController =
        TextEditingController(
          text: widget.initialIngredients,
        );

    _instructionsController =
        TextEditingController(
          text: widget.initialInstructions,
        );

    _selectedCategory =
    _categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'Breakfast';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();

    super.dispose();
  }

  Future<void> _updateRecipe() async {
    final name = _nameController.text.trim();
    final timeText = _timeController.text.trim();
    final ingredients =
    _ingredientsController.text.trim();
    final instructions =
    _instructionsController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter recipe name.');
      return;
    }

    if (timeText.isEmpty) {
      _showMessage('Please enter cooking time.');
      return;
    }

    final cookingTime = int.tryParse(timeText);

    if (cookingTime == null || cookingTime <= 0) {
      _showMessage(
        'Cooking time must be a valid number.',
      );
      return;
    }

    if (ingredients.isEmpty) {
      _showMessage(
        'Please enter ingredients.',
      );
      return;
    }

    if (instructions.isEmpty) {
      _showMessage(
        'Please enter cooking instructions.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _recipeService.updateRecipe(
        recipeId: widget.recipeId,
        name: name,
        category: _selectedCategory,
        cookingTime: cookingTime,
        ingredients: ingredients,
        instructions: instructions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe updated successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to update recipe: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter recipe name',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              items: _categories.map(
                    (category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Cooking Time (minutes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Example: 30',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _ingredientsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                'Example: Paneer, Onion, Tomato, Salt',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Cooking Instructions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _instructionsController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                'Enter cooking instructions...',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                _isSaving ? null : _updateRecipe,
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(),
                )
                    : const Text(
                  'Update Recipe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
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