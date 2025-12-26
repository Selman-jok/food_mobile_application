import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/pages/foodorderpage.dart';
import 'package:flutter_app/services/review_service.dart';
import 'package:flutter_app/models/review.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class FoodDetailsPage extends StatefulWidget {
  final Food food;

  const FoodDetailsPage({super.key, required this.food});

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  bool _showAddReviewForm = false;
  int _newReviewRating = 5;
  final TextEditingController _reviewCommentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    final reviews = await _reviewService.getFoodReviews(widget.food.id);

    setState(() {
      _reviews = reviews;
      _isLoadingReviews = false;
    });
  }

  Future<void> _submitReview() async {
    if (_reviewCommentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final reviewService = Provider.of<ReviewService>(context, listen: false);

    setState(() {
      _isLoadingReviews = true;
    });

    final result = await reviewService.addReview(
      foodId: widget.food.id,
      rating: _newReviewRating,
      comment: _reviewCommentController.text.trim(),
      context: context,
    );

    setState(() {
      _isLoadingReviews = false;
    });

    if (result['success'] == true) {
      // Clear form
      _reviewCommentController.clear();
      _newReviewRating = 5;
      _showAddReviewForm = false;

      // Reload reviews
      await _loadReviews();

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit review'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Future<void> _submitReview() async {
  //   if (_reviewCommentController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Please enter a comment'),
  //           backgroundColor: Colors.orange),
  //     );
  //     return;
  //   }

  //   final result = await _reviewService.addReview(
  //     foodId: widget.food.id,
  //     rating: _newReviewRating,
  //     comment: _reviewCommentController.text.trim(),
  //     context: context,
  //   );

  //   if (result['success'] == true) {
  //     _reviewCommentController.clear();
  //     _newReviewRating = 5;
  //     _showAddReviewForm = false;
  //     await _loadReviews();

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Review submitted successfully!'),
  //           backgroundColor: Colors.green),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text(result['message'] ?? 'Failed to submit review'),
  //           backgroundColor: Colors.red),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF3a3737)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.business_center, color: Color(0xFF3a3737)),
              onPressed: () {
                Navigator.push(context, ScaleRoute(page: FoodOrderPage()));
              },
            )
          ],
        ),
        body: Column(
          children: [
            // Food Image
            Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.all(15),
              child: Container(
                height: 180,
                width: double.infinity,
                child: _buildFoodImage(),
              ),
            ),

            // Title & Price
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: FoodTitleWidget(
                productName: widget.food.name,
                productPrice: "\$${widget.food.price.toStringAsFixed(2)}",
                productHost: widget.food.category.toUpperCase(),
              ),
            ),

            SizedBox(height: 10),

            // Rating
            _buildRatingWidget(),

            // Special Offer
            if (widget.food.isSpecialOffer &&
                widget.food.discountPercent != null)
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: _buildSpecialOfferBadge(),
              ),

            SizedBox(height: 15),

            // Add to Cart
            AddToCartMenu(food: widget.food),

            SizedBox(height: 15),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: TabBar(
                labelColor: Color(0xFFfd3f40),
                indicatorColor: Color(0xFFfd3f40),
                unselectedLabelColor: Color(0xFFa4a1a1),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                unselectedLabelStyle: TextStyle(fontSize: 14),
                tabs: const [
                  Tab(text: "Details"),
                  Tab(text: "Ingredients"),
                  Tab(text: "Reviews"),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Details
                  SingleChildScrollView(
                    padding: EdgeInsets.all(15),
                    child: DetailContentMenu(food: widget.food),
                  ),

                  // Ingredients
                  _buildIngredientsTab(),

                  // Reviews - Fully scrollable
                  SingleChildScrollView(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add Review Button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(
                                () => _showAddReviewForm = !_showAddReviewForm);
                          },
                          icon: Icon(Icons.add_comment, size: 18),
                          label: Text(_showAddReviewForm
                              ? 'Cancel Review'
                              : 'Add Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFfb3132),
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Add Review Form
                        if (_showAddReviewForm)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Add Your Review',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text('Rating: ',
                                        style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 10),
                                    ...List.generate(5, (index) {
                                      return GestureDetector(
                                        onTap: () => setState(
                                            () => _newReviewRating = index + 1),
                                        child: Icon(
                                          Icons.star,
                                          size: 28,
                                          color: index < _newReviewRating
                                              ? Color(0xFFfb3132)
                                              : Colors.grey[300],
                                        ),
                                      );
                                    }),
                                    SizedBox(width: 10),
                                    Text('$_newReviewRating/5',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: _reviewCommentController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    labelText: 'Your Comment',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFfb3132))),
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submitReview,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFfb3132),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Text('Submit Review',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 24),

                        // Reviews List
                        if (_isLoadingReviews)
                          Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFfb3132)))
                        else if (_reviews.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.reviews,
                                    color: Color(0xFFfae3e2), size: 50),
                                SizedBox(height: 12),
                                Text('No reviews yet',
                                    style: TextStyle(
                                        color: Color(0xFFa4a1a1),
                                        fontSize: 16)),
                                SizedBox(height: 8),
                                Text('Be the first to review!',
                                    style: TextStyle(color: Color(0xFF9b9b9c))),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFFfae3e2),
                                      child: Text(
                                        review.userName
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            'U',
                                        style: TextStyle(
                                            color: Color(0xFFfb3132),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.userName ?? 'Anonymous',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF3a3a3b)),
                                              ),
                                              Row(
                                                children: List.generate(
                                                    5,
                                                    (i) => Icon(
                                                          Icons.star,
                                                          size: 14,
                                                          color: i <
                                                                  review.rating
                                                              ? Color(
                                                                  0xFFfb3132)
                                                              : Color(
                                                                  0xFFd6d6d6),
                                                        )),
                                              ),
                                            ],
                                          ),
                                          if (review.comment.isNotEmpty) ...[
                                            SizedBox(height: 6),
                                            Text(review.comment,
                                                style: TextStyle(
                                                    color: Color(0xFF6e6e71),
                                                    fontSize: 13)),
                                          ],
                                          SizedBox(height: 6),
                                          Text(_formatDate(review.createdAt),
                                              style: TextStyle(
                                                  color: Color(0xFF9b9b9c),
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

///////////////////////////////////////////////////////////////////////
  Widget _buildFoodImage() {
    if (widget.food.isLocalImage) {
      return Image.asset(
        widget.food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/bestfood/ic_best_food_8.jpeg',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.network(
        widget.food.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/bestfood/ic_best_food_8.jpeg',
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFfb3132),
            ),
          );
        },
      );
    }
  }

  Widget _buildRatingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, color: Color(0xFFfb3132), size: 18),
        SizedBox(width: 5),
        Text(
          widget.food.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3a3a3b),
          ),
        ),
        SizedBox(width: 5),
        Text(
          '(${widget.food.totalReviews} reviews)',
          style: TextStyle(
            color: Color(0xFF9b9b9c),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialOfferBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFFfb3132).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFfb3132).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            color: Color(0xFFfb3132),
            size: 14,
          ),
          SizedBox(width: 5),
          Text(
            '${widget.food.discountPercent!.toInt()}% OFF',
            style: TextStyle(
              color: Color(0xFFfb3132),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.food.originalPrice != null)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Was \$${widget.food.originalPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF9b9b9c),
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    if (widget.food.ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              color: Color(0xFFfae3e2),
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'No ingredients listed',
              style: TextStyle(
                color: Color(0xFFa4a1a1),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(15),
      itemCount: widget.food.ingredients.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xFFfb3132),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.food.ingredients[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3a3a3b),
                  ),
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Add Review Button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showAddReviewForm = !_showAddReviewForm;
              });
            },
            icon: Icon(Icons.add_comment, size: 18),
            label: Text(_showAddReviewForm ? 'Cancel Review' : 'Add Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Add Review Form
        if (_showAddReviewForm)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Your Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3a3a3b),
                  ),
                ),
                SizedBox(height: 10),

                // Star Rating
                Row(
                  children: [
                    Text(
                      'Rating: ',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 10),
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _newReviewRating = index + 1;
                          });
                        },
                        child: Icon(
                          Icons.star,
                          size: 28,
                          color: index < _newReviewRating
                              ? Color(0xFFfb3132)
                              : Colors.grey[300],
                        ),
                      );
                    }),
                    SizedBox(width: 10),
                    Text(
                      '$_newReviewRating/5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFfb3132),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Comment
                TextField(
                  controller: _reviewCommentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Your Comment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFfb3132)),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfb3132),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Reviews List
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: _isLoadingReviews
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFfb3132)),
                  )
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.reviews,
                              color: Color(0xFFfae3e2),
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No reviews yet',
                              style: TextStyle(
                                color: Color(0xFFa4a1a1),
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Be the first to review!',
                              style: TextStyle(
                                color: Color(0xFF9b9b9c),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 8, bottom: 20),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFfae3e2),
                                  child: Text(
                                    review.userName
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: TextStyle(
                                      color: Color(0xFFfb3132),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            review.userName ?? 'Anonymous',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF3a3a3b),
                                              fontSize: 14,
                                            ),
                                          ),
                                          Row(
                                            children:
                                                List.generate(5, (starIndex) {
                                              return Icon(
                                                Icons.star,
                                                size: 14,
                                                color: starIndex < review.rating
                                                    ? Color(0xFFfb3132)
                                                    : Color(0xFFd6d6d6),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      if (review.comment.isNotEmpty)
                                        Text(
                                          review.comment,
                                          style: TextStyle(
                                            color: Color(0xFF6e6e71),
                                            fontSize: 13,
                                          ),
                                        ),
                                      SizedBox(height: 6),
                                      Text(
                                        _formatDate(review.createdAt),
                                        style: TextStyle(
                                          color: Color(0xFF9b9b9c),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class FoodTitleWidget extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productHost;

  const FoodTitleWidget({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productHost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                productName,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              productPrice,
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFFfb3132),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "Category: ${productHost}",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6e6e71),
          ),
        ),
      ],
    );
  }
}

class AddToCartMenu extends StatelessWidget {
  final Food food;

  const AddToCartMenu({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: InkWell(
        onTap: () {
          final cart = Provider.of<CartService>(context, listen: false);
          cart.addToCart(
            foodId: food.id,
            name: food.name,
            price: food.price,
            image: food.image,
            quantity: 1,
            context: context,
          );
        },
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFfb3132),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFfb3132).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Add To Cart - \$${food.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailContentMenu extends StatelessWidget {
  final Food food;

  const DetailContentMenu({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),

        SizedBox(height: 25),

        // Availability Status
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: food.available ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                food.available ? Icons.check_circle : Icons.cancel,
                color: food.available ? Colors.green : Colors.orange,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  food.available
                      ? 'Available for delivery'
                      : 'Currently out of stock',
                  style: TextStyle(
                    color:
                        food.available ? Colors.green[800] : Colors.orange[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

        // Preparation Time
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFf8f8f8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: Color(0xFFfb3132),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Preparation time: 15-20 minutes',
                style: TextStyle(
                  color: Color(0xFF3a3a3b),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

        // Allergen Info
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFf0f7ff),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Contains: Gluten, Dairy',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
