import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/signinpage.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/services/favorite_service.dart';
import 'package:flutter_app/widgets/bestfoodwidget.dart';
import 'package:flutter_app/widgets/bottomnavbarwidget.dart';
import 'package:flutter_app/widgets/popularfoodswidget.dart';
import 'package:flutter_app/widgets/searchwidget.dart';
import 'package:flutter_app/widgets/topmenus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Food> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  String? _searchQuery;
  final FocusNode _homePageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _homePageFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _homePageFocusNode.removeListener(_onFocusChanged);
    _homePageFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_homePageFocusNode.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
      _searchQuery = query;
    });

    try {
      final results = await ApiService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  void _handleClearSearch() {
    setState(() {
      _searchResults.clear();
      _showSearchResults = false;
      _searchQuery = null;
      _isSearching = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFfb3132)),
              const SizedBox(height: 16),
              Text(
                'Searching for "$_searchQuery"...',
                style: const TextStyle(color: Color(0xFF3a3737), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchQuery != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, color: const Color(0xFFfae3e2), size: 80),
              const SizedBox(height: 16),
              Text(
                'No results found for "$_searchQuery"',
                style: const TextStyle(
                  color: Color(0xFF3a3737),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching for something else',
                style: TextStyle(color: Color(0xFF6e6e71), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results (${_searchResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3a3a3b),
                ),
              ),
              if (_searchQuery != null)
                Chip(
                  label: Text(
                    _searchQuery!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFFfb3132),
                ),
            ],
          ),
        ),

        // Search results grid - same layout as PopularFoodsWidget
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170.0, // Fixed card width like popular
              mainAxisExtent: 250, // Height to avoid overflow
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    ScaleRoute(page: FoodDetailsPage(food: food)),
                  );
                },
                child: _buildSearchFoodCard(food),
              );
            },
          ),
        ),
      ],
    );
  }

  // New card widget - matches PopularFoodsWidget style with favorite heart
  Widget _buildSearchFoodCard(Food food) {
    return Container(
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFfae3e2),
              child: food.image.isNotEmpty
                  ? (food.image.startsWith('http')
                      ? Image.network(
                          food.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFfb3132)));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.fastfood,
                                  color: Color(0xFFfb3132), size: 40),
                            );
                          },
                        )
                      : Image.asset(
                          food.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.fastfood,
                                  color: Color(0xFFfb3132), size: 40),
                            );
                          },
                        ))
                  : const Center(
                      child: Icon(Icons.fastfood,
                          color: Color(0xFFfb3132), size: 40),
                    ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Color(0xFFfb3132)),
                        const SizedBox(width: 3),
                        Text(
                          food.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333)),
                        ),
                        Text(
                          ' (${food.totalReviews})',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$${food.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFfb3132),
                      ),
                    ),
                    // Favorite Heart Icon (same as PopularFoodsWidget)
                    Consumer<FavoriteService>(
                      builder: (context, favoriteService, child) {
                        final isFavorite = favoriteService.isFavorite(food.id);
                        return GestureDetector(
                          onTap: () async {
                            await favoriteService.toggleFavorite(food,
                                context: context);
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFfb3132)
                                : Colors.grey,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: const Text(
          "What would you like to eat?",
          style: TextStyle(
            color: Color(0xFF3a3737),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: Color(0xFF3a3737)),
            onPressed: () {
              Navigator.push(
                context,
                ScaleRoute(page: SignInPage()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SearchWidget(
                onSearchChanged: _handleSearch,
                onClearSearch: _handleClearSearch,
              ),
              if (_showSearchResults)
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      200, // Give full screen height for search results
                  child: _buildSearchResults(),
                )
              else
                Column(
                  children: [
                    TopMenus(),
                    PopularFoodsWidget(),
                    BestFoodWidget(),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarWidget(),
    );
  }
}
