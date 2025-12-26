import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/services/favorite_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF3a3737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "My Favorites",
          style: TextStyle(
            color: Color(0xFF3a3737),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<FavoriteService>(
            builder: (context, favoriteService, child) {
              return Container(
                margin: EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundColor: Color(0xFFfb3132),
                  child: Text(
                    '${favoriteService.favoriteCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteService>(
        builder: (context, favoriteService, child) {
          final authService = Provider.of<AuthService>(context);

          // Check if user is logged in
          if (!authService.isAuthenticated) {
            return _buildLoginPrompt();
          }

          if (favoriteService.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb3132),
              ),
            );
          }

          if (favoriteService.favorites.isEmpty) {
            return _buildEmptyFavorites();
          }

          return _buildFavoritesList(favoriteService);
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Color(0xFFfae3e2),
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Login to Save Favorites',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Sign in to save your favorite food items',
            style: TextStyle(
              color: Color(0xFF6e6e71),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Color(0xFFfae3e2),
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Tap the heart icon to add food items',
            style: TextStyle(
              color: Color(0xFF6e6e71),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Browse Foods',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoriteService favoriteService) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: favoriteService.favorites.length,
      itemBuilder: (context, index) {
        final food = favoriteService.favorites[index];
        return _buildFavoriteItem(food, favoriteService);
      },
    );
  }

  Widget _buildFavoriteItem(Food food, FavoriteService favoriteService) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            ScaleRoute(page: FoodDetailsPage(food: food)),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFfae3e2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildFoodImage(food),
                    ),
                  ),
                  SizedBox(width: 15),

                  // Food Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3a3a3b),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          food.category.toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFFfb3132),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${food.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfb3132),
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFfb3132),
                            ),
                            SizedBox(width: 4),
                            Text(
                              food.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6e6e71),
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${food.totalReviews} reviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9b9b9c),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Remove button (top right)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Color(0xFFfb3132),
                  size: 24,
                ),
                onPressed: () async {
                  await favoriteService.removeFromFavorites(
                    food.id,
                    context: context,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage(Food food) {
    if (food.image.startsWith('http')) {
      return Image.network(
        food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
        },
      );
    } else {
      return Image.asset(
        food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 30);
        },
      );
    }
  }
}
