import 'package:flutter/material.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/services/favorite_service.dart';
import 'package:provider/provider.dart';

class FoodTile extends StatelessWidget {
  final Food food;

  const FoodTile({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // IMAGE
          Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFfae3e2),
            child: _buildFoodImage(),
          ),

          // CONTENT - Reduced padding
          Padding(
            padding: const EdgeInsets.fromLTRB(
                12, 10, 12, 10), // Reduced vertical padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2d2d2d),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4), // Reduced from 6

                // CATEGORY + RATING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, // Reduced
                        vertical: 3, // Reduced
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfb3132).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        food.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFfb3132),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Color(0xFFfb3132)), // Smaller
                        const SizedBox(width: 3), // Reduced
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11, // Smaller
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          ' (${food.totalReviews})',
                          style: TextStyle(
                            fontSize: 10, // Smaller
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8), // Reduced from 12

                // PRICE + TINY HEART - FIXED
                SizedBox(
                  height: 24, // Fixed small height
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PRICE
                      Text(
                        "\$${food.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16, // Slightly smaller
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFfb3132),
                        ),
                      ),

                      // TINY HEART
                      Consumer<FavoriteService>(
                        builder: (context, favoriteService, child) {
                          final isFavorite =
                              favoriteService.isFavorite(food.id);
                          return GestureDetector(
                            onTap: () async {
                              await favoriteService.toggleFavorite(food,
                                  context: context);
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? const Color(0xFFfb3132)
                                  : Colors.grey,
                              size: 16, // Very small
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    if (food.image.startsWith('http')) {
      return Image.network(
        food.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFfb3132),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.fastfood, color: Colors.grey, size: 40),
          );
        },
      );
    } else {
      return Image.asset(
        food.image,
        fit: BoxFit.cover,
      );
    }
  }
}
