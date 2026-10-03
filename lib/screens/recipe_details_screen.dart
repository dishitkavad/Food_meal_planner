import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final String recipeName;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String preparationTime;
  final int servings;
  final String imageUrl;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeName,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.preparationTime,
    required this.servings,
    this.imageUrl = '',
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
            // RECIPE IMAGE
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 240,
                      color: const Color(0xFFFFE8D6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE85D04),
                        ),
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 240,
                      color: const Color(0xFFFFE8D6),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (imageUrl.isNotEmpty)
              const SizedBox(height: 20),

            // RECIPE NAME
            Text(
              recipeName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292524),
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            Text(
              description,
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
                  color: Color(0xFFE85D04),
                ),
                const SizedBox(width: 8),
                Text(
                  preparationTime,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.people,
                  color: Color(0xFFE85D04),
                ),
                const SizedBox(width: 8),
                Text(
                  '$servings servings',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // INGREDIENTS
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
                padding:
                const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF2D6A4F),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(
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
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F),
              ),
            ),

            const SizedBox(height: 12),

            ...instructions.asMap().entries.map(
                  (entry) => Padding(
                padding:
                const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      const Color(0xFFE85D04),
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