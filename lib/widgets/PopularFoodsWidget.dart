import 'package:flutter/material.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/widgets/food_tile.dart';
import 'package:flutter_app/animation/ScaleRoute.dart'; // Import for smooth transition
import 'package:flutter_app/pages/FoodDetailsPage.dart'; // Import your details page

class PopularFoodsWidget extends StatefulWidget {
  @override
  _PopularFoodsWidgetState createState() => _PopularFoodsWidgetState();
}

class _PopularFoodsWidgetState extends State<PopularFoodsWidget> {
  List<Food> popularFoods = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPopularFoods();
  }

  Future<void> _loadPopularFoods() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      print('Fetching popular foods from API...');
      final foods = await ApiService.getPopularFoods();
      print('Received ${foods.length} popular foods from API');

      if (mounted) {
        setState(() {
          popularFoods = foods;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading popular foods: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 265,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          PopularFoodTitle(),
          Expanded(
            child: _buildContent(),
          )
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
            CircularProgressIndicator(color: Color(0xFFfb3132)),
            SizedBox(height: 10),
            Text(
              'Loading popular foods...',
              style: TextStyle(
                color: Color(0xFF6e6e71),
                fontSize: 12,
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
              'Failed to load popular foods',
              style: TextStyle(
                color: Color(0xFF3a3a3b),
                fontSize: 14,
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
              onPressed: _loadPopularFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfb3132),
                minimumSize: Size(100, 30),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (popularFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood,
              color: Color(0xFFfae3e2),
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'No popular foods',
              style: TextStyle(
                color: Color(0xFF6e6e71),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Check back later',
              style: TextStyle(
                color: Color(0xFF9b9b9c),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: popularFoods.length,
      itemBuilder: (context, index) {
        final food = popularFoods[index];
        return Container(
          width: 170,
          padding: EdgeInsets.only(left: 10, right: 5),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                ScaleRoute(page: FoodDetailsPage(food: food)),
              );
            },
            child: FoodTile(food: food),
          ),
        );
      },
    );
  }
}

class PopularFoodTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Popular Foods",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF3a3a3b),
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Optional: Navigate to a "See All Popular Foods" page
              // Navigator.push(context, MaterialPageRoute(builder: (_) => AllPopularFoodsPage()));
            },
            child: Text(
              "", //seeall is here
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }
}
