import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/services/favorite_service.dart';

class BestFoodWidget extends StatefulWidget {
  @override
  _BestFoodWidgetState createState() => _BestFoodWidgetState();
}

class _BestFoodWidgetState extends State<BestFoodWidget> {
  List<Food> specialOfferFoods = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSpecialOffers();
  }

  Future<void> _loadSpecialOffers() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      print('Loading special offers...');
      final foods = await ApiService.getSpecialOffers();
      print('Loaded ${foods.length} special offers');
      setState(() {
        specialOfferFoods = foods;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading special offers: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          BestFoodTitle(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFfb3132),
            ),
            SizedBox(height: 10),
            Text(
              'Loading special offers...',
              style: TextStyle(
                color: Color(0xFF6e6e71),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'Failed to load special offers',
              style: TextStyle(
                color: Color(0xFF3a3a3b),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Check your connection',
              style: TextStyle(
                color: Color(0xFF6e6e71),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadSpecialOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfb3132),
                minimumSize: Size(100, 35),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (specialOfferFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              color: Color(0xFFfae3e2),
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'No special offers available',
              style: TextStyle(
                color: Color(0xFF6e6e71),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Check back later for discounts',
              style: TextStyle(
                color: Color(0xFF9b9b9c),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: specialOfferFoods.length,
      itemBuilder: (context, index) {
        return BestFoodTiles(food: specialOfferFoods[index]);
      },
    );
  }
}

class BestFoodTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Text(
            "Special Offers",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Limited time",
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BestFoodTiles extends StatelessWidget {
  final Food food;

  const BestFoodTiles({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double originalPrice = food.originalPrice ?? food.price;
    double discountPrice = food.price;
    if (food.discountPercent != null && food.originalPrice != null) {
      discountPrice = food.originalPrice! -
          (food.originalPrice! * food.discountPercent! / 100);
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          ScaleRoute(page: FoodDetailsPage(food: food)),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Container(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IMAGE SECTION - 70% width
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Color(0xFFfae3e2),
                        child: _buildFoodImage(),
                      ),
                    ),
                    if (food.isSpecialOffer && food.discountPercent != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFfb3132),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${food.discountPercent!.toInt()}% OFF',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // CONTENT SECTION - 30% width
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Name
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
                      SizedBox(height: 4),

                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Color(0xFFfb3132)),
                          SizedBox(width: 4),
                          Text(
                            food.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6e6e71),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),

                      // Save tag
                      if (food.originalPrice != null &&
                          food.discountPercent != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Save \$${(originalPrice - discountPrice).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      Spacer(), // Push price + heart to bottom

                      // Price and Heart (aligned vertically at bottom)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${discountPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFfb3132),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (food.originalPrice != null)
                                Text(
                                  "\$${originalPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          _buildHeartButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartButton(BuildContext context) {
    return Consumer<FavoriteService>(
      builder: (context, favoriteService, child) {
        final isFavorite = favoriteService.isFavorite(food.id);
        return GestureDetector(
          onTap: () async {
            await favoriteService.toggleFavorite(food, context: context);
          },
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Color(0xFFfb3132) : Colors.grey,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodImage() {
    if (food.image.startsWith('assets/')) {
      return Image.asset(
        food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Color(0xFFfae3e2),
            child: Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 50),
          );
        },
      );
    } else {
      return Image.network(
        food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Color(0xFFfae3e2),
            child: Icon(Icons.fastfood, color: Color(0xFFfb3132), size: 50),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(color: Color(0xFFfb3132)),
          );
        },
      );
    }
  }
}
