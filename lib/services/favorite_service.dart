// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../models/food.dart';

// class FavoriteService extends ChangeNotifier {
//   List<Food> _favorites = [];
//   bool _isLoading = false;
//   String? _userId;
//   String? _authToken;

//   // Use the SAME baseUrl as your other services
//   static const String _baseUrl = 'http://10.161.161.40:5000/api';
//   // static const String _baseUrl = 'http://10.151.209.124:5000/api';

//   // SharedPreferences key prefix
//   static const String _favoritesKey = 'favorites_';

//   FavoriteService() {
//     // Don't auto-initialize
//   }

//   List<Food> get favorites => List.from(_favorites);
//   bool get isLoading => _isLoading;
//   int get favoriteCount => _favorites.length;

//   // Set user data (call after login)
//   void setUserData(String userId, String? authToken) {
//     _userId = userId;
//     _authToken = authToken;
//     print('❤️ FavoriteService set user data: userId=$_userId');
//     fetchFavorites();
//   }

//   // Clear user data (call on logout)
//   void clearUserData() {
//     _userId = null;
//     _authToken = null;
//     _favorites.clear();
//     print('❤️ FavoriteService cleared user data');
//     notifyListeners();
//   }

//   // Fetch favorites from server
//   Future<void> fetchFavorites() async {
//     if (_authToken == null || _userId == null) {
//       print('⚠️ Cannot fetch favorites: No auth token or user ID');
//       await _loadFavoritesFromStorage();
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🔄 Fetching favorites for user: $_userId');
//       print('🌐 URL: $_baseUrl/favorites');

//       final response = await http.get(
//         Uri.parse('$_baseUrl/favorites'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       print('📥 Fetch favorites response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final favoritesData = data['data'];

//           if (favoritesData != null) {
//             _favorites = (favoritesData as List)
//                 .map((foodJson) => Food.fromJson(foodJson))
//                 .toList();
//             print('✅ Loaded ${_favorites.length} favorites from server');
//           } else {
//             _favorites = [];
//             print('ℹ️ No favorites found');
//           }

//           await _saveFavoritesToStorage();
//         } else {
//           print('❌ Server returned success: false - ${data['message']}');
//           await _loadFavoritesFromStorage();
//         }
//       } else if (response.statusCode == 401) {
//         print('❌ Unauthorized - User not logged in');
//         _favorites = [];
//         notifyListeners();
//       } else {
//         print('❌ Failed to fetch favorites: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         await _loadFavoritesFromStorage();
//       }
//     } catch (error) {
//       print('💥 Error fetching favorites: $error');
//       await _loadFavoritesFromStorage();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Add food to favorites
//   Future<bool> addToFavorites(Food food, {BuildContext? context}) async {
//     if (_authToken == null) {
//       print('❌ Cannot add to favorites: User not logged in');
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Please login to add favorites'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//       return false;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('❤️ Adding to favorites - foodId: ${food.id}');

//       final response = await http.post(
//         Uri.parse('$_baseUrl/favorites/add'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//         body: json.encode({'foodId': food.id}),
//       );

//       print('📥 Add to favorites response: ${response.statusCode}');
//       print('📥 Response body: ${response.body}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           // Add to local list if not already there
//           if (!_favorites.any((f) => f.id == food.id)) {
//             _favorites.add(food);
//           }

//           await _saveFavoritesToStorage();
//           notifyListeners();

//           // Show success message
//           if (context != null && context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('❤️ Added ${food.name} to favorites'),
//                 backgroundColor: Color(0xFFfb3132),
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }

//           return true;
//         } else {
//           print('❌ Server error: ${data['message']}');

//           if (context != null && context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Failed: ${data['message']}'),
//                 backgroundColor: Colors.red,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }
//           return false;
//         }
//       } else if (response.statusCode == 400) {
//         final data = json.decode(response.body);
//         print('❌ Already in favorites: ${data['message']}');

//         // If already in favorites, add to local list
//         if (!_favorites.any((f) => f.id == food.id)) {
//           _favorites.add(food);
//           notifyListeners();
//         }

//         return true;
//       } else {
//         print('❌ Server error: ${response.statusCode}');
//         return false;
//       }
//     } catch (error) {
//       print('💥 Error adding to favorites: $error');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Remove food from favorites
//   Future<bool> removeFromFavorites(String foodId,
//       {BuildContext? context}) async {
//     if (_authToken == null) {
//       print('❌ Cannot remove from favorites: User not logged in');
//       return false;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('❤️ Removing from favorites - foodId: $foodId');

//       final response = await http.delete(
//         Uri.parse('$_baseUrl/favorites/remove/$foodId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       print('📥 Remove from favorites response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           // Remove from local list
//           _favorites.removeWhere((food) => food.id == foodId);

//           await _saveFavoritesToStorage();
//           notifyListeners();

//           // Show success message
//           if (context != null && context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Removed from favorites'),
//                 backgroundColor: Colors.grey,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }

//           return true;
//         }
//       }
//       return false;
//     } catch (error) {
//       print('💥 Error removing from favorites: $error');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Toggle favorite status
//   Future<void> toggleFavorite(Food food, {BuildContext? context}) async {
//     if (isFavorite(food.id)) {
//       await removeFromFavorites(food.id, context: context);
//     } else {
//       await addToFavorites(food, context: context);
//     }
//   }

//   // Check if food is in favorites
//   bool isFavorite(String foodId) {
//     return _favorites.any((food) => food.id == foodId);
//   }

//   // Save favorites to local storage
//   Future<void> _saveFavoritesToStorage() async {
//     try {
//       if (_userId == null) return;

//       final prefs = await SharedPreferences.getInstance();
//       final favoritesJson = json.encode(_favorites.map((food) {
//         return {
//           '_id': food.id,
//           'name': food.name,
//           'category': food.category,
//           'description': food.description,
//           'price': food.price,
//           'image': food.image,
//           'rating': food.rating,
//           'totalReviews': food.totalReviews,
//           'ingredients': food.ingredients,
//           'isSpecialOffer': food.isSpecialOffer,
//           'discountPercent': food.discountPercent,
//           'originalPrice': food.originalPrice,
//           'available': food.available,
//         };
//       }).toList());
//       await prefs.setString('${_favoritesKey}$_userId', favoritesJson);
//       print(
//           '💾 Favorites saved to local storage for user $_userId (${_favorites.length} items)');
//     } catch (error) {
//       print('❌ Error saving favorites to storage: $error');
//     }
//   }

//   // Load favorites from local storage
//   Future<void> _loadFavoritesFromStorage() async {
//     try {
//       if (_userId == null) return;

//       final prefs = await SharedPreferences.getInstance();
//       final favoritesJson = prefs.getString('${_favoritesKey}$_userId');

//       if (favoritesJson != null) {
//         final List<dynamic> jsonList = json.decode(favoritesJson);
//         _favorites = jsonList.map((json) => Food.fromJson(json)).toList();
//         print(
//             '📂 Loaded ${_favorites.length} favorites from local storage for user $_userId');
//         notifyListeners();
//       }
//     } catch (error) {
//       print('❌ Error loading favorites from storage: $error');
//     }
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class FavoriteService extends ChangeNotifier {
  List<Food> _favorites = [];
  bool _isLoading = false;
  String? _userId;
  String? _authToken;

  // Use the SAME baseUrl as your other services
  static const String _baseUrl = 'http://10.161.161.40:5000/api';

  // SharedPreferences key prefix
  static const String _favoritesKey = 'favorites_';

  FavoriteService() {
    // Don't auto-initialize
  }

  List<Food> get favorites => List.from(_favorites);
  bool get isLoading => _isLoading;
  int get favoriteCount => _favorites.length;

  // Set user data (call after login)
  void setUserData(String userId, String? authToken) {
    _userId = userId;
    _authToken = authToken;
    print('❤️ FavoriteService set user data: userId=$_userId');
    fetchFavorites();
  }

  // Clear user data (call on logout)
  void clearUserData() {
    _userId = null;
    _authToken = null;
    _favorites.clear();
    print('❤️ FavoriteService cleared user data');
    notifyListeners();
  }

  // Fetch favorites from server
  Future<void> fetchFavorites() async {
    if (_authToken == null || _userId == null) {
      print('⚠️ Cannot fetch favorites: No auth token or user ID');
      await _loadFavoritesFromStorage();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Fetching favorites for user: $_userId');
      print('🌐 URL: $_baseUrl/favorites');

      final response = await http.get(
        Uri.parse('$_baseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Fetch favorites response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final favoritesData = data['data'];

          if (favoritesData != null) {
            _favorites = (favoritesData as List)
                .map((foodJson) => Food.fromJson(foodJson))
                .toList();
            print('✅ Loaded ${_favorites.length} favorites from server');
          } else {
            _favorites = [];
            print('ℹ️ No favorites found');
          }

          await _saveFavoritesToStorage();
        } else {
          print('❌ Server returned success: false - ${data['message']}');
          await _loadFavoritesFromStorage();
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - User not logged in');
        _favorites = [];
        notifyListeners();
      } else {
        print('❌ Failed to fetch favorites: ${response.statusCode}');
        print('Response body: ${response.body}');
        await _loadFavoritesFromStorage();
      }
    } catch (error) {
      print('💥 Error fetching favorites: $error');
      await _loadFavoritesFromStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add food to favorites
  Future<bool> addToFavorites(Food food, {BuildContext? context}) async {
    if (_authToken == null) {
      print('❌ Cannot add to favorites: User not logged in');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login to add favorites'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('❤️ Adding to favorites - foodId: ${food.id}');

      final response = await http.post(
        Uri.parse('$_baseUrl/favorites/add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({'foodId': food.id}),
      );

      print('📥 Add to favorites response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Add to local list if not already there
          if (!_favorites.any((f) => f.id == food.id)) {
            _favorites.add(food);
          }

          await _saveFavoritesToStorage();
          notifyListeners();

          // Show success message
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❤️ Added ${food.name} to favorites'),
                backgroundColor: Color(0xFFfb3132),
                duration: Duration(seconds: 2),
              ),
            );
          }

          return true;
        } else {
          print('❌ Server error: ${data['message']}');
          return false;
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        print('❌ Already in favorites: ${data['message']}');

        // If already in favorites, add to local list
        if (!_favorites.any((f) => f.id == food.id)) {
          _favorites.add(food);
          notifyListeners();
        }

        return true;
      } else {
        print('❌ Server error: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('💥 Error adding to favorites: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove food from favorites
  Future<bool> removeFromFavorites(String foodId,
      {BuildContext? context}) async {
    if (_authToken == null) {
      print('❌ Cannot remove from favorites: User not logged in');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('❤️ Removing from favorites - foodId: $foodId');

      final response = await http.delete(
        Uri.parse('$_baseUrl/favorites/remove/$foodId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Remove from favorites response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from local list
          _favorites.removeWhere((food) => food.id == foodId);

          await _saveFavoritesToStorage();
          notifyListeners();

          // Show success message
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed from favorites'),
                backgroundColor: Colors.grey,
                duration: Duration(seconds: 2),
              ),
            );
          }

          return true;
        }
      }
      return false;
    } catch (error) {
      print('💥 Error removing from favorites: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Food food, {BuildContext? context}) async {
    if (isFavorite(food.id)) {
      await removeFromFavorites(food.id, context: context);
    } else {
      await addToFavorites(food, context: context);
    }
  }

  // Check if food is in favorites
  bool isFavorite(String foodId) {
    return _favorites.any((food) => food.id == foodId);
  }

  // Check favorite status from server
  Future<bool> checkIsFavorite(String foodId) async {
    if (_authToken == null) {
      return isFavorite(foodId); // Return local status
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favorites/check/$foodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isFavorite'] == true;
      }
      return false;
    } catch (error) {
      print('💥 Error checking favorite status: $error');
      return isFavorite(foodId); // Fallback to local status
    }
  }

  // Save favorites to local storage
  Future<void> _saveFavoritesToStorage() async {
    try {
      if (_userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(_favorites.map((food) {
        return {
          'id': food.id,
          'name': food.name,
          'category': food.category,
          'description': food.description,
          'price': food.price,
          'image': food.image,
          'rating': food.rating,
          'totalReviews': food.totalReviews,
          'ingredients': food.ingredients,
          'isSpecialOffer': food.isSpecialOffer,
          'discountPercent': food.discountPercent,
          'originalPrice': food.originalPrice,
          'available': food.available,
        };
      }).toList());
      await prefs.setString('${_favoritesKey}$_userId', favoritesJson);
      print(
          '💾 Favorites saved to local storage for user $_userId (${_favorites.length} items)');
    } catch (error) {
      print('❌ Error saving favorites to storage: $error');
    }
  }

  // Load favorites from local storage
  Future<void> _loadFavoritesFromStorage() async {
    try {
      if (_userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('${_favoritesKey}$_userId');

      if (favoritesJson != null) {
        final List<dynamic> jsonList = json.decode(favoritesJson);
        _favorites = jsonList.map((json) => Food.fromJson(json)).toList();
        print(
            '📂 Loaded ${_favorites.length} favorites from local storage for user $_userId');
        notifyListeners();
      }
    } catch (error) {
      print('❌ Error loading favorites from storage: $error');
    }
  }
}
