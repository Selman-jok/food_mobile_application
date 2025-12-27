import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService extends ChangeNotifier {
  static const String _baseUrl = 'http://10.161.161.40:5000/api';
  // static const String _baseUrl = 'http://10.151.209.124:5000/api';

  String? _authToken;
  String? _userName; // Add this
  String? _userId; // Add this
  List<Review> _reviews = [];
  bool _isLoading = false;

  ReviewService() {
    _loadUserData(); // Change from _loadToken to _loadUserData
  }

  List<Review> get reviews => List.from(_reviews);
  bool get isLoading => _isLoading;
  int get reviewCount => _reviews.length;
  String? get currentUserName => _userName; // Add this getter

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userName = prefs.getString('user_name'); // Load user name
    _userId = prefs.getString('user_id'); // Load user ID
    print('📝 ReviewService loaded user: $_userName');

    // Debug logs
    print('📝 ReviewService loaded:');
    print('   Token: ${_authToken != null ? "Yes" : "No"}');
    print('   User ID: $_userId');
    print('   User Name: $_userName');
  }

  Future<void> _saveUserData(
      String token, String userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
    _authToken = token;
    _userId = userId;
    _userName = userName;
  }

  // Update setUserData to accept all user info
  void setUserData(String? authToken, String? userId, String? userName) {
    _authToken = authToken;
    _userId = userId;
    _userName = userName;

    if (authToken != null && userId != null && userName != null) {
      _saveUserData(authToken, userId, userName);
    }

    print('📝 ReviewService set user data: $_userName');
    notifyListeners();
  }

  // Clear user data (call on logout)
  void clearUserData() {
    _authToken = null;
    _userId = null;
    _userName = null;
    _reviews.clear();
    print('📝 ReviewService cleared user data');
    notifyListeners();
  }

  // Add a review
  Future<Map<String, dynamic>> addReview({
    required String foodId,
    required int rating,
    required String comment,
    BuildContext? context,
  }) async {
    if (_authToken == null) {
      return {'success': false, 'message': 'Please login to add a review'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('📝 Adding review for food: $foodId');
      print('👤 Current user: $_userName ($_userId)');

      final response = await http.post(
        Uri.parse('$_baseUrl/reviews/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'foodId': foodId,
          'rating': rating,
          'comment': comment,
          // You can also send userName for testing if backend needs it
        }),
      );

      print('📥 Add review response status: ${response.statusCode}');
      print(
          '📥 Add review response body: ${response.body}'); // ADD THIS LINE FOR DEBUGGING

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Show success message
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Review added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Parse and add the new review
        if (data['data'] != null) {
          try {
            final newReview = Review.fromJson(data['data']);

            // If the backend doesn't return userName, use the local one
            if (newReview.userName == null ||
                newReview.userName == 'Anonymous') {
              // Create a modified review with the correct user name
              final modifiedReview = Review(
                id: newReview.id,
                foodId: newReview.foodId,
                userId: newReview.userId,
                userName: _userName ?? 'User', // Use local user name
                userEmail: newReview.userEmail,
                rating: newReview.rating,
                comment: newReview.comment,
                createdAt: newReview.createdAt,
              );
              _reviews.insert(0, modifiedReview);
            } else {
              _reviews.insert(0, newReview);
            }

            print('✅ Review added: ${newReview.comment} by ${_userName}');
          } catch (e) {
            print('⚠️ Error parsing review: $e');
            print('⚠️ Raw data: ${data['data']}');
          }
        }

        _isLoading = false;
        notifyListeners();

        return {
          'success': true,
          'message': 'Review added successfully',
          'data': data['data'],
        };
      } else {
        final data = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add review',
        };
      }
    } catch (error) {
      print('💥 Error adding review: $error');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // Get reviews for a food item
  Future<List<Review>> getFoodReviews(String foodId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📝 Fetching reviews for food: $foodId');

      final response = await http.get(
        Uri.parse('$_baseUrl/reviews/food/$foodId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 Get reviews response: ${response.statusCode}');
      print('📥 Get reviews body: ${response.body}'); // ADD THIS FOR DEBUGGING

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> reviewsJson = data['data'] ?? [];
          _reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();

          // Log the first review to check user names
          if (_reviews.isNotEmpty) {
            print('✅ First review user: ${_reviews.first.userName}');
          }

          print('✅ Loaded ${_reviews.length} reviews');

          _isLoading = false;
          notifyListeners();
          return _reviews;
        }
      }

      _isLoading = false;
      notifyListeners();
      return [];
    } catch (error) {
      print('💥 Error fetching reviews: $error');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Delete a review
  Future<Map<String, dynamic>> deleteReview(
      String reviewId, BuildContext? context) async {
    if (_authToken == null) {
      return {'success': false, 'message': 'Please login to delete review'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🗑️ Deleting review: $reviewId');

      final response = await http.delete(
        Uri.parse('$_baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Delete review response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Remove from local list
        _reviews.removeWhere((review) => review.id == reviewId);

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Review deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': 'Review deleted successfully',
        };
      } else {
        final data = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete review',
        };
      }
    } catch (error) {
      print('💥 Error deleting review: $error');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
}
