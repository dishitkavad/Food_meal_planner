
import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final String recipeName;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String preparationTime;
  final int servings;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeName,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.servings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Recipe Details'),
        backgroundColor: const Color(0xFFE85D04),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipeName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292524),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFFE85D04),
                ),
                const SizedBox(width: 8),
                Text(
                  preparationTime,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.people,
                  color: Color(0xFFE85D04),
                ),
                const SizedBox(width: 8),
                Text(
                  '$servings servings',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F),
              ),
            ),

            const SizedBox(height: 12),

            ...ingredients.map(
                  (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF2D6A4F),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Cooking Instructions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F),
              ),
            ),

            const SizedBox(height: 12),

            ...instructions.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFE85D04),
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
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