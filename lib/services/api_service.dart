// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/food.dart';

// class ApiService {
//   // For Physical Device - Use your computer's IP address
//   // static const String baseUrl = 'http://192.168.1.100:5000/api';

//   // For Android Emulator
//   static const String baseUrl = 'http://10.161.161.40:5000/api';
//   // For iOS Simulator
//   // static const String baseUrl = 'http://localhost:5000/api';

//   // SEARCH FOODS - NEW METHOD
//   static Future<List<Food>> searchFoods(String query) async {
//     try {
//       print('🔍 API Search Request: GET $baseUrl/foods?search=$query');

//       final response = await http.get(
//         Uri.parse('$baseUrl/foods?search=$query'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('🔍 Search Response Status Code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         print('🔍 Search API Response Success: ${jsonData['success']}');
//         print('🔍 Search Found: ${jsonData['count']} items');

//         if (jsonData['success'] == true) {
//           List<Food> foods = (jsonData['data'] as List)
//               .map((item) => Food.fromJson(item))
//               .toList();
//           print('🔍 Parsed ${foods.length} foods from search');
//           return foods;
//         } else {
//           print('🔍 Search failed: ${jsonData['message']}');
//           return [];
//         }
//       } else {
//         print('🔍 Search Response Body: ${response.body}');
//         return [];
//       }
//     } catch (e) {
//       print('🔍 Network Error in searchFoods: $e');
//       return [];
//     }
//   }

//   // GET ALL FOODS (for when clearing search) - NEW METHOD
//   static Future<List<Food>> getAllFoods() async {
//     try {
//       print('API Request: GET $baseUrl/foods');

//       final response = await http.get(
//         Uri.parse('$baseUrl/foods'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('All Foods Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           return (jsonData['data'] as List)
//               .map((item) => Food.fromJson(item))
//               .toList();
//         } else {
//           print('Failed to load all foods: ${jsonData['message']}');
//           return [];
//         }
//       } else {
//         print('Failed to load all foods. Status: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Network Error in getAllFoods: $e');
//       return [];
//     }
//   }

//   // Get foods by category (burger, pizza, cake, etc.)
//   static Future<List<Food>> getFoodsByCategory(String category) async {
//     try {
//       print('API Request: GET $baseUrl/foods/category/$category');

//       final response = await http.get(
//         Uri.parse('$baseUrl/foods/category/$category'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('Response Status Code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         print('API Response Success: ${jsonData['success']}');
//         print('API Response Count: ${jsonData['count']}');

//         if (jsonData['success'] == true) {
//           List<Food> foods = (jsonData['data'] as List)
//               .map((item) => Food.fromJson(item))
//               .toList();
//           print('Parsed ${foods.length} foods');
//           return foods;
//         } else {
//           throw Exception('Failed to load foods: ${jsonData['message']}');
//         }
//       } else {
//         print('Response Body: ${response.body}');
//         throw Exception('Failed to load foods. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Network Error in getFoodsByCategory: $e');
//       rethrow;
//     }
//   }

//   // Get popular foods
//   static Future<List<Food>> getPopularFoods() async {
//     try {
//       print('API Request: GET $baseUrl/foods/popular');

//       final response = await http.get(
//         Uri.parse('$baseUrl/foods/popular'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('Popular Foods Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           return (jsonData['data'] as List)
//               .map((item) => Food.fromJson(item))
//               .toList();
//         } else {
//           throw Exception(
//               'Failed to load popular foods: ${jsonData['message']}');
//         }
//       } else {
//         throw Exception(
//             'Failed to load popular foods. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Network Error in getPopularFoods: $e');
//       rethrow;
//     }
//   }

//   // Get special offers
//   static Future<List<Food>> getSpecialOffers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/foods/special-offers'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           return (jsonData['data'] as List)
//               .map((item) => Food.fromJson(item))
//               .toList();
//         } else {
//           throw Exception('Failed to load special offers');
//         }
//       } else {
//         throw Exception('Failed to load special offers');
//       }
//     } catch (e) {
//       print('Error fetching special offers: $e');
//       rethrow;
//     }
//   }

//   // Get food by ID
//   static Future<Food> getFoodById(String id) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/foods/$id'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           return Food.fromJson(jsonData['data']);
//         } else {
//           throw Exception('Failed to load food details');
//         }
//       } else {
//         throw Exception('Failed to load food details');
//       }
//     } catch (e) {
//       print('Error fetching food details: $e');
//       rethrow;
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class ApiService {
  // For Android Emulator
  static const String baseUrl = 'http://10.161.161.40:5000/api';

  // SEARCH FOODS - NEW METHOD
  static Future<List<Food>> searchFoods(String query) async {
    try {
      print('🔍 API Search Request: GET $baseUrl/foods?search=$query');

      final response = await http.get(
        Uri.parse('$baseUrl/foods?search=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Search Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🔍 Search API Response Success: ${jsonData['success']}');
        print('🔍 Search Found: ${jsonData['count']} items');

        if (jsonData['success'] == true) {
          List<Food> foods = (jsonData['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
          print('🔍 Parsed ${foods.length} foods from search');
          return foods;
        } else {
          print('🔍 Search failed: ${jsonData['message']}');
          return [];
        }
      } else {
        print('🔍 Search Response Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('🔍 Network Error in searchFoods: $e');
      return [];
    }
  }

  // GET ALL FOODS (for when clearing search) - NEW METHOD
  static Future<List<Food>> getAllFoods() async {
    try {
      print('API Request: GET $baseUrl/foods');

      final response = await http.get(
        Uri.parse('$baseUrl/foods'),
        headers: {'Content-Type': 'application/json'},
      );

      print('All Foods Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return (jsonData['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
        } else {
          print('Failed to load all foods: ${jsonData['message']}');
          return [];
        }
      } else {
        print('Failed to load all foods. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network Error in getAllFoods: $e');
      return [];
    }
  }

  // Get foods by category
  static Future<List<Food>> getFoodsByCategory(String category) async {
    try {
      print('API Request: GET $baseUrl/foods/category/$category');

      final response = await http.get(
        Uri.parse('$baseUrl/foods/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response Success: ${jsonData['success']}');
        print('API Response Count: ${jsonData['count']}');

        if (jsonData['success'] == true) {
          List<Food> foods = (jsonData['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
          print('Parsed ${foods.length} foods');
          return foods;
        } else {
          throw Exception('Failed to load foods: ${jsonData['message']}');
        }
      } else {
        print('Response Body: ${response.body}');
        throw Exception('Failed to load foods. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error in getFoodsByCategory: $e');
      rethrow;
    }
  }

  // Get popular foods
  static Future<List<Food>> getPopularFoods() async {
    try {
      print('API Request: GET $baseUrl/foods/popular');

      final response = await http.get(
        Uri.parse('$baseUrl/foods/popular'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Popular Foods Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return (jsonData['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
        } else {
          throw Exception(
              'Failed to load popular foods: ${jsonData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load popular foods. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error in getPopularFoods: $e');
      rethrow;
    }
  }

  // Get special offers
  static Future<List<Food>> getSpecialOffers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/special-offers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return (jsonData['data'] as List)
              .map((item) => Food.fromJson(item))
              .toList();
        } else {
          throw Exception('Failed to load special offers');
        }
      } else {
        throw Exception('Failed to load special offers');
      }
    } catch (e) {
      print('Error fetching special offers: $e');
      rethrow;
    }
  }

  // Get food by ID
  static Future<Food> getFoodById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return Food.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to load food details');
        }
      } else {
        throw Exception('Failed to load food details');
      }
    } catch (e) {
      print('Error fetching food details: $e');
      rethrow;
    }
  }

  // Add review to food
  static Future<Map<String, dynamic>> addReview({
    required String foodId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'foodId': foodId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get reviews for food
  static Future<List<dynamic>> getFoodReviews(String foodId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/food/$foodId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}
