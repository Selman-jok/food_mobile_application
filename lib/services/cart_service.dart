// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../models/cart_item.dart';

// class CartService extends ChangeNotifier {
//   List<CartItem> _items = [];
//   bool _isLoading = false;
//   String? _userId;
//   String? _authToken; // Store auth token directly

//   // Use the SAME baseUrl as your ApiService
//   static const String _baseUrl = 'http://10.161.161.40:5000/api';

//   // SharedPreferences key prefix
//   static const String _cartItemsKey = 'cart_items_';

//   CartService() {
//     // Don't auto-initialize, will be initialized after login
//   }

//   List<CartItem> get items => List.from(_items);
//   bool get isLoading => _isLoading;

//   int get totalItems {
//     return _items.fold(0, (total, item) => total + item.quantity);
//   }

//   double get subtotal {
//     return _items.fold(0.0, (total, item) => total + item.totalPrice);
//   }

//   double get deliveryFee => 50.0;
//   double get totalAmount => subtotal + deliveryFee;

//   // Set user data (call after login)
//   void setUserData(String userId, String? authToken) {
//     _userId = userId;
//     _authToken = authToken;
//     print('🛒 CartService set user data: userId=$_userId');
//     fetchCart();
//   }

//   // Clear user data (call on logout)
//   void clearUserData() {
//     _userId = null;
//     _authToken = null;
//     _items.clear();
//     print('🛒 CartService cleared user data');
//     notifyListeners();
//   }

//   // Fetch cart from server
//   Future<void> fetchCart() async {
//     if (_authToken == null || _userId == null) {
//       print('⚠️ Cannot fetch cart: No auth token or user ID');
//       await _loadCartFromStorage();
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🔄 Fetching cart for user: $_userId');
//       print('🌐 URL: $_baseUrl/cart');

//       final response = await http.get(
//         Uri.parse('$_baseUrl/cart'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       print('📥 Fetch cart response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           final cartData = data['data'];

//           if (cartData['items'] != null) {
//             _items = (cartData['items'] as List)
//                 .map((item) => CartItem.fromJson(item))
//                 .toList();
//             print(
//                 '✅ Loaded ${_items.length} items from server for user $_userId');
//           } else {
//             _items = [];
//             print('ℹ️ No items in cart for user $_userId');
//           }

//           await _saveCartToStorage();
//         } else {
//           print('❌ Server returned success: false - ${data['message']}');
//           await _loadCartFromStorage();
//         }
//       } else if (response.statusCode == 401) {
//         print('❌ Unauthorized - User not logged in');
//         _items = [];
//         notifyListeners();
//       } else {
//         print('❌ Failed to fetch cart: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         await _loadCartFromStorage();
//       }
//     } catch (error) {
//       print('💥 Error fetching cart from server: $error');
//       await _loadCartFromStorage();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Add item to cart
//   Future<void> addToCart({
//     required String foodId,
//     required String name,
//     required double price,
//     required String image,
//     int quantity = 1,
//     BuildContext? context,
//   }) async {
//     if (_authToken == null) {
//       print('❌ Cannot add to cart: User not logged in');
//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Please login to add items to cart'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🛒 === ADD TO CART ===');
//       print('🍔 foodId: $foodId');
//       print('🔢 quantity: $quantity');
//       print('🌐 URL: $_baseUrl/cart/add');

//       final requestBody = {
//         'foodId': foodId,
//         'quantity': quantity,
//       };

//       final response = await http.post(
//         Uri.parse('$_baseUrl/cart/add'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//         body: json.encode(requestBody),
//       );

//       print('📥 Response Status: ${response.statusCode}');
//       print('📥 Response Body: ${response.body}');

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('✅ Successfully added to cart on server');

//           // Refresh cart from server
//           await fetchCart();

//           // Show success message
//           if (context != null && context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('✅ $name added to cart!'),
//                 backgroundColor: Colors.green,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }
//           return;
//         } else {
//           print('❌ Server error: ${data['message']}');
//           throw Exception('Server error: ${data['message']}');
//         }
//       } else if (response.statusCode == 401) {
//         print('❌ Unauthorized - User not logged in');
//         throw Exception('Please login to add items to cart');
//       } else {
//         print('❌ Server error: ${response.statusCode}');
//         throw Exception('Server error: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('💥 Error adding to cart: $error');

//       if (context != null && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${error.toString()}'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Update item quantity
//   Future<void> updateQuantity(String itemId, int newQuantity) async {
//     if (newQuantity < 1) newQuantity = 1;

//     if (_authToken == null) {
//       print('❌ Cannot update quantity: User not logged in');
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🔄 Updating quantity - itemId: $itemId, quantity: $newQuantity');

//       final response = await http.put(
//         Uri.parse('$_baseUrl/cart/update/$itemId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//         body: json.encode({'quantity': newQuantity}),
//       );

//       print('📥 Update response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         await fetchCart(); // Refresh from server
//       }
//     } catch (error) {
//       print('💥 Error updating quantity: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Remove item from cart
//   Future<void> removeFromCart(String itemId, {BuildContext? context}) async {
//     // Show confirmation dialog if context is provided
//     if (context != null) {
//       final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Remove Item'),
//           content:
//               Text('Are you sure you want to remove this item from your cart?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFFfb3132),
//               ),
//               child: Text('Remove'),
//             ),
//           ],
//         ),
//       );

//       if (confirmed != true) {
//         return; // User cancelled
//       }
//     }

//     if (_authToken == null) {
//       print('❌ Cannot remove item: User not logged in');
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🗑️ Removing from cart - itemId: $itemId');

//       final response = await http.delete(
//         Uri.parse('$_baseUrl/cart/remove/$itemId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       print('📥 Remove response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         await fetchCart(); // Refresh from server
//       }
//     } catch (error) {
//       print('💥 Error removing from cart: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Clear entire cart
//   Future<void> clearCart() async {
//     if (_authToken == null) {
//       print('❌ Cannot clear cart: User not logged in');
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🧹 Clearing entire cart');

//       final response = await http.delete(
//         Uri.parse('$_baseUrl/cart/clear'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_authToken',
//         },
//       );

//       print('📥 Clear cart response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         await fetchCart();
//       }
//     } catch (error) {
//       print('💥 Error clearing cart: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Check if item is in cart
//   bool isInCart(String foodId) {
//     return _items.any((item) => item.foodId == foodId);
//   }

//   // Get quantity of specific item
//   int getItemQuantity(String foodId) {
//     try {
//       return _items.firstWhere((item) => item.foodId == foodId).quantity;
//     } catch (e) {
//       return 0;
//     }
//   }

//   // Save cart to local storage (user-specific)
//   Future<void> _saveCartToStorage() async {
//     try {
//       if (_userId == null) return;

//       final prefs = await SharedPreferences.getInstance();
//       final cartJson =
//           json.encode(_items.map((item) => item.toJson()).toList());
//       await prefs.setString('${_cartItemsKey}$_userId', cartJson);
//       print(
//           '💾 Cart saved to local storage for user $_userId (${_items.length} items)');
//     } catch (error) {
//       print('❌ Error saving cart to storage: $error');
//     }
//   }

//   // Load cart from local storage (user-specific)
//   Future<void> _loadCartFromStorage() async {
//     try {
//       if (_userId == null) return;

//       final prefs = await SharedPreferences.getInstance();
//       final cartJson = prefs.getString('${_cartItemsKey}$_userId');

//       if (cartJson != null) {
//         final List<dynamic> jsonList = json.decode(cartJson);
//         _items = jsonList.map((json) => CartItem.fromJson(json)).toList();
//         print(
//             '📂 Loaded ${_items.length} items from local storage for user $_userId');
//         notifyListeners();
//       }
//     } catch (error) {
//       print('❌ Error loading cart from storage: $error');
//     }
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _userId;
  String? _authToken;

  // Use the SAME baseUrl as your ApiService
  static const String _baseUrl = 'http://10.161.161.40:5000/api';

  // SharedPreferences key prefix
  static const String _cartItemsKey = 'cart_items_';

  CartService() {
    // Don't auto-initialize, will be initialized after login
  }

  List<CartItem> get items => List.from(_items);
  bool get isLoading => _isLoading;

  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  double get deliveryFee => 50.0;
  double get totalAmount => subtotal + deliveryFee;

  // Set user data (call after login)
  void setUserData(String userId, String? authToken) {
    _userId = userId;
    _authToken = authToken;
    print('🛒 CartService set user data: userId=$_userId');
    fetchCart();
  }

  // Clear user data (call on logout)
  void clearUserData() {
    _userId = null;
    _authToken = null;
    _items.clear();
    print('🛒 CartService cleared user data');
    notifyListeners();
  }

  // Fetch cart from server
  Future<void> fetchCart() async {
    if (_authToken == null || _userId == null) {
      print('⚠️ Cannot fetch cart: No auth token or user ID');
      await _loadCartFromStorage();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Fetching cart for user: $_userId');
      print('🌐 URL: $_baseUrl/cart');

      final response = await http.get(
        Uri.parse('$_baseUrl/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Fetch cart response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final cartData = data['data'];

          if (cartData['items'] != null) {
            _items = (cartData['items'] as List)
                .map((item) => CartItem.fromJson(item))
                .toList();
            print(
                '✅ Loaded ${_items.length} items from server for user $_userId');
          } else {
            _items = [];
            print('ℹ️ No items in cart for user $_userId');
          }

          await _saveCartToStorage();
        } else {
          print('❌ Server returned success: false - ${data['message']}');
          await _loadCartFromStorage();
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - User not logged in');
        _items = [];
        notifyListeners();
      } else {
        print('❌ Failed to fetch cart: ${response.statusCode}');
        print('Response body: ${response.body}');
        await _loadCartFromStorage();
      }
    } catch (error) {
      print('💥 Error fetching cart from server: $error');
      await _loadCartFromStorage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addToCart({
    required String foodId,
    required String name,
    required double price,
    required String image,
    int quantity = 1,
    BuildContext? context,
  }) async {
    if (_authToken == null) {
      print('❌ Cannot add to cart: User not logged in');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login to add items to cart'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🛒 === ADD TO CART ===');
      print('🍔 foodId: $foodId');
      print('🔢 quantity: $quantity');
      print('🌐 URL: $_baseUrl/cart/add');

      final requestBody = {
        'foodId': foodId,
        'quantity': quantity,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Successfully added to cart on server');

          // Refresh cart from server
          await fetchCart();

          // Show success message
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ $name added to cart!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        } else {
          print('❌ Server error: ${data['message']}');
          throw Exception('Server error: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - User not logged in');
        throw Exception('Please login to add items to cart');
      } else {
        print('❌ Server error: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('💥 Error adding to cart: $error');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) newQuantity = 1;

    if (_authToken == null) {
      print('❌ Cannot update quantity: User not logged in');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Updating quantity - itemId: $itemId, quantity: $newQuantity');

      final response = await http.put(
        Uri.parse('$_baseUrl/cart/update/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({'quantity': newQuantity}),
      );

      print('📥 Update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh from server
      } else {
        print('❌ Failed to update quantity: ${response.body}');
      }
    } catch (error) {
      print('💥 Error updating quantity: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId, {BuildContext? context}) async {
    // Show confirmation dialog if context is provided
    if (context != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Remove Item'),
          content:
              Text('Are you sure you want to remove this item from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfb3132),
              ),
              child: Text('Remove'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return; // User cancelled
      }
    }

    if (_authToken == null) {
      print('❌ Cannot remove item: User not logged in');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🗑️ Removing from cart - itemId: $itemId');

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/remove/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Remove response: ${response.statusCode}');

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh from server
      } else {
        print('❌ Failed to remove item: ${response.body}');
      }
    } catch (error) {
      print('💥 Error removing from cart: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (_authToken == null) {
      print('❌ Cannot clear cart: User not logged in');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🧹 Clearing entire cart');

      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/clear'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      print('📥 Clear cart response: ${response.statusCode}');

      if (response.statusCode == 200) {
        await fetchCart();
      } else {
        print('❌ Failed to clear cart: ${response.body}');
      }
    } catch (error) {
      print('💥 Error clearing cart: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if item is in cart
  bool isInCart(String foodId) {
    return _items.any((item) => item.foodId == foodId);
  }

  // Get quantity of specific item
  int getItemQuantity(String foodId) {
    try {
      return _items.firstWhere((item) => item.foodId == foodId).quantity;
    } catch (e) {
      return 0;
    }
  }

  // Save cart to local storage (user-specific)
  Future<void> _saveCartToStorage() async {
    try {
      if (_userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final cartJson =
          json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('${_cartItemsKey}$_userId', cartJson);
      print(
          '💾 Cart saved to local storage for user $_userId (${_items.length} items)');
    } catch (error) {
      print('❌ Error saving cart to storage: $error');
    }
  }

  // Load cart from local storage (user-specific)
  Future<void> _loadCartFromStorage() async {
    try {
      if (_userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('${_cartItemsKey}$_userId');

      if (cartJson != null) {
        final List<dynamic> jsonList = json.decode(cartJson);
        _items = jsonList.map((json) => CartItem.fromJson(json)).toList();
        print(
            '📂 Loaded ${_items.length} items from local storage for user $_userId');
        notifyListeners();
      }
    } catch (error) {
      print('❌ Error loading cart from storage: $error');
    }
  }

  // Get cart summary
  Future<Map<String, dynamic>> getCartSummary() async {
    if (_authToken == null) {
      return {
        'success': false,
        'message': 'User not logged in',
        'data': {
          'totalQuantity': totalItems,
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'totalAmount': totalAmount,
        }
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Failed to get cart summary',
          'data': {
            'totalQuantity': totalItems,
            'subtotal': subtotal,
            'deliveryFee': deliveryFee,
            'totalAmount': totalAmount,
          }
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': error.toString(),
        'data': {
          'totalQuantity': totalItems,
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'totalAmount': totalAmount,
        }
      };
    }
  }
}
