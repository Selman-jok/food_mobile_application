import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  // Use your server's base URL (same as cart service)
  static const String _baseUrl = 'http://10.161.161.40:5000/api';
  // static const String _baseUrl = 'http://10.151.209.124:5000/api';

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  AuthService() {
    _loadAuthData();
  }

  String? get token => _token;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated && _token != null;
// Add this method to your AuthService class
// Add to AuthService class
  // Future<Map<String, dynamic>> resetPassword({
  //   required String token,
  //   required String password,
  //   required String confirmPassword,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     print('🔄 Resetting password with token');
  //     print('🌐 URL: ${_baseUrl}/users/reset-password/$token');

  //     final requestBody = {
  //       'password': password,
  //       'confirmPassword': confirmPassword,
  //     };

  //     final response = await http.patch(
  //       Uri.parse('${_baseUrl}/users/reset-password/$token'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: json.encode(requestBody),
  //     );

  //     print('📥 Reset password response: ${response.statusCode}');
  //     print('📥 Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       if (data['status'] == 'success') {
  //         // Save new token
  //         _token = data['token'];
  //         _userId = data['data']['user']['_id'];
  //         _userEmail = data['data']['user']['email'];
  //         _userName = data['data']['user']['name'];
  //         _isAuthenticated = true;

  //         await _saveAuthData();

  //         return {
  //           'success': true,
  //           'message': 'Password reset successful!',
  //           'user': data['data']['user'],
  //           'token': _token,
  //         };
  //       } else {
  //         return {
  //           'success': false,
  //           'message': data['message'] ?? 'Password reset failed',
  //         };
  //       }
  //     } else if (response.statusCode == 400) {
  //       return {
  //         'success': false,
  //         'message': 'Token is invalid or has expired',
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'success': false,
  //         'message': errorData['message'] ?? 'Server error',
  //       };
  //     }
  //   } catch (error) {
  //     print('💥 Reset password error: $error');
  //     return {
  //       'success': false,
  //       'message': 'Network error: $error',
  //     };
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

// Add to your AuthService class
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      print('🔄 Resetting password with token: $token');
      print('🌐 URL: $_baseUrl/users/reset-password/$token');

      final response = await http.patch(
        Uri.parse('$_baseUrl/users/reset-password/$token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      print('📥 Reset password response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset successful!',
          'token': responseData['token'],
          'user': responseData['data']?['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
        };
      }
    } catch (error) {
      print('💥 Reset password error: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('📧 Sending password reset request for email: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': responseData['message'] ?? 'Reset email sent successfully',
          'token': responseData['token'], // For development/testing
          'resetURL': responseData['resetURL'], // For development/testing
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Failed to send reset email',
        };
      }
    } catch (error) {
      print('💥 Forgot password error: $error');
      return {
        'status': 'error',
        'message': 'Network error: $error',
      };
    }
  }

  // Load authentication data from SharedPreferences
  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      _userId = prefs.getString(_userIdKey);
      _userEmail = prefs.getString(_userEmailKey);
      _userName = prefs.getString(_userNameKey);

      _isAuthenticated = _token != null && _token!.isNotEmpty;

      if (_isAuthenticated) {
        print('✅ Loaded saved auth data');
        print('👤 User: $_userName ($_userEmail)');
      } else {
        print('ℹ️ No saved auth data found');
      }

      notifyListeners();
    } catch (error) {
      print('❌ Error loading auth data: $error');
    }
  }

  // Save authentication data to SharedPreferences
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_userId != null) {
        await prefs.setString(_userIdKey, _userId!);
      }
      if (_userEmail != null) {
        await prefs.setString(_userEmailKey, _userEmail!);
      }
      if (_userName != null) {
        await prefs.setString(_userNameKey, _userName!);
      }
    } catch (error) {
      print('❌ Error saving auth data: $error');
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
    } catch (error) {
      print('❌ Error clearing auth data: $error');
    }
  }

  // Sign Up
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Signing up user: $email');
      print('📞 Phone: $phoneNumber');
      print('🌐 URL: $_baseUrl/users/signup');

      final requestBody = {
        'name': name,
        'email': email.toLowerCase(),
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
        'role': 'user',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/users/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📥 Signup response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Save token and user data
          _token = data['token'];
          _userId = data['data']['user']['_id'];
          _userEmail = data['data']['user']['email'];
          _userName = data['data']['user']['name'];
          _isAuthenticated = true;

          await _saveAuthData();

          print('✅ Signup successful for user: $_userName');

          return {
            'success': true,
            'message': 'Registration successful!',
            'user': data['data']['user'],
            'token': _token,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed',
          };
        }
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Bad request',
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'Email or phone number already exists',
        };
      } else if (response.statusCode == 500) {
        // Handle MongoDB duplicate errors
        final errorBody = response.body;

        if (errorBody.contains('duplicate key error')) {
          if (errorBody.contains('email_1')) {
            return {
              'success': false,
              'message':
                  'Email already registered. Please use a different email or sign in.',
            };
          } else if (errorBody.contains('phoneNumber_1')) {
            return {
              'success': false,
              'message': 'Phone number already registered.',
            };
          } else {
            return {
              'success': false,
              'message': 'Account with these details already exists.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Server error during registration',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (error) {
      print('💥 Signup error: $error');
      String errorMessage = 'Network error';
      if (error.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Server is not responding.';
      } else if (error.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Check your network.';
      }
      return {
        'success': false,
        'message': '$errorMessage',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 Signing in user: $email');
      print('🌐 URL: $_baseUrl/users/login');

      final requestBody = {
        'email': email.toLowerCase(),
        'password': password,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📥 Signin response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Save token and user data
          _token = data['token'];
          _userId = data['data']['user']['_id'];
          _userEmail = data['data']['user']['email'];
          _userName = data['data']['user']['name'];
          _isAuthenticated = true;

          await _saveAuthData();

          print('✅ Signin successful for user: $_userName');

          return {
            'success': true,
            'message': 'Login successful!',
            'user': data['data']['user'],
            'token': _token,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Bad request',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (error) {
      print('💥 Signin error: $error');
      String errorMessage = 'Network error';
      if (error.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Server is not responding.';
      } else if (error.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Check your network.';
      }
      return {
        'success': false,
        'message': '$errorMessage',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot Password
  // Future<Map<String, dynamic>> forgotPassword(String email) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     print('🔄 Requesting password reset for: $email');
  //     print('🌐 URL: $_baseUrl/users/forgot-password');

  //     final requestBody = {'email': email.toLowerCase()};

  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/users/forgot-password'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //       body: json.encode(requestBody),
  //     );

  //     print('📥 Forgot password response: ${response.statusCode}');
  //     print('📥 Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       // For development/testing
  //       if (data['token'] != null) {
  //         print('🔑 Reset token: ${data['token']}');
  //         print('🔗 Reset URL: ${data['resetURL']}');
  //       }

  //       return {
  //         'success': true,
  //         'message':
  //             data['message'] ?? 'Password reset instructions sent to email',
  //         'token': data['token'],
  //         'resetURL': data['resetURL'],
  //       };
  //     } else {
  //       final errorData = json.decode(response.body);
  //       return {
  //         'success': false,
  //         'message':
  //             errorData['message'] ?? 'Failed to send reset instructions',
  //       };
  //     }
  //   } catch (error) {
  //     print('💥 Forgot password error: $error');
  //     return {
  //       'success': false,
  //       'message': 'Network error: $error',
  //     };
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Sign Out (Simplified - remove context parameter)
  Future<void> signOut() async {
    try {
      print('🔄 Signing out user: $_userName');

      // Clear auth data
      _token = null;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _isAuthenticated = false;

      await _clearAuthData();

      notifyListeners();
      print('✅ User signed out successfully');
    } catch (error) {
      print('💥 Logout error: $error');
      // Still clear local data even if something fails
      _token = null;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _isAuthenticated = false;
      await _clearAuthData();
      notifyListeners();
    }
  }

  // Get authentication headers for API calls
  Map<String, String> getAuthHeaders() {
    if (_token != null) {
      return {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Validate token (optional - for checking if token is still valid)
  Future<bool> validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }
}
