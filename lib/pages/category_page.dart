import 'package:flutter/material.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/widgets/food_tile.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final String categoryTitle;

  const CategoryPage({
    Key? key,
    required this.category,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Food> foods = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategoryFoods();
  }

  Future<void> _loadCategoryFoods() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      print('Fetching foods for category: ${widget.category}');
      final fetchedFoods = await ApiService.getFoodsByCategory(widget.category);
      print('Received ${fetchedFoods.length} foods');

      if (mounted) {
        setState(() {
          foods = fetchedFoods;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading category foods: $e');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: Color(0xFF3a3a3b),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFfb3132)),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: Color(0xFF6e6e71), fontSize: 14),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Failed to load foods',
              style: TextStyle(
                color: Color(0xFF3a3a3b),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage.contains('Network') ||
                      errorMessage.contains('network')
                  ? 'Please check your internet connection'
                  : 'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6e6e71), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategoryFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfb3132),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (foods.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, color: Color(0xFFfae3e2), size: 70),
            SizedBox(height: 16),
            Text(
              'No items available',
              style: TextStyle(
                  color: Color(0xFF6e6e71),
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new items',
              style: TextStyle(color: Color(0xFF9b9b9c), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with item count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${foods.length} Items',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3a3a3b),
            ),
          ),
        ),

        // Grid with FIXED card width and height
        Expanded(
          child: GridView.builder(
            clipBehavior: Clip.none, // Prevents any clipping overflow
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170.0, // Fixed width like popular
              mainAxisExtent: 250, // Slightly increased to prevent 4px overflow
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    ScaleRoute(page: FoodDetailsPage(food: food)),
                  );
                },
                child: FoodTile(food: food),
              );
            },
          ),
        ),
      ],
    );
  }
}
