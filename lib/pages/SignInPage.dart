// import 'package:flutter/material.dart';
// import 'package:flutter_app/animation/ScaleRoute.dart';
// import 'package:flutter_app/pages/SignUpPage.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import '../services/cart_service.dart'; // ADD THIS IMPORT
// import '../services/favorite_service.dart';
// import '../services/review_service.dart';

// class SignInPage extends StatefulWidget {
//   @override
//   _SignInPageState createState() => _SignInPageState();
// }

// class _SignInPageState extends State<SignInPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   String defaultFontFamily = 'Roboto-Light.ttf';
//   double defaultFontSize = 14;
//   double defaultIconSize = 17;

//   bool _obscurePassword = true;
//   bool _isLoading = false;
//   bool _rememberMe = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

// // In your _submitForm() method in SignInPage class
// // In SignInPage.dart - Update only the relevant part
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final authService = Provider.of<AuthService>(context, listen: false);

//         final result = await authService.signIn(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );

//         if (result['success'] == true) {
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(result['message'] ?? 'Login successful!'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 3),
//             ),
//           );

//           // Get updated auth data
//           final updatedAuthService =
//               Provider.of<AuthService>(context, listen: false);

//           // Check if we have valid user data
//           if (updatedAuthService.userId != null &&
//               updatedAuthService.token != null &&
//               updatedAuthService.userName != null) {
//             // ADD userName check

//             final String userId = updatedAuthService.userId!;
//             final String token = updatedAuthService.token!;
//             final String userName =
//                 updatedAuthService.userName!; // Get userName

//             // Initialize cart service
//             final cartService =
//                 Provider.of<CartService>(context, listen: false);
//             cartService.setUserData(userId, token);

//             // Initialize favorite service
//             try {
//               final favoriteService =
//                   Provider.of<FavoriteService>(context, listen: false);
//               favoriteService.setUserData(userId, token);
//               print('✅ FavoriteService initialized for user: $userId');
//             } catch (e) {
//               print('⚠️ Error initializing FavoriteService: $e');
//             }

//             // INITIALIZE REVIEW SERVICE - ADD THIS
//             try {
//               final reviewService =
//                   Provider.of<ReviewService>(context, listen: false);
//               reviewService.setUserData(
//                   token, userId, userName); // Pass all data
//               print('✅ ReviewService initialized for user: $userName');
//             } catch (e) {
//               print('⚠️ Error initializing ReviewService: $e');
//             }

//             // Navigate to home page
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               '/',
//               (route) => false,
//             );
//           } else {
//             // Log what's missing for debugging
//             print('❌ Missing user data after login:');
//             print('   userId: ${updatedAuthService.userId}');
//             print('   token: ${updatedAuthService.token}');
//             print('   userName: ${updatedAuthService.userName}');
//             throw Exception('User data is incomplete after login');
//           }
//         } else {
//           // Show error message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(result['message'] ?? 'Invalid email or password'),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       } catch (error) {
//         print('💥 Login error: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Login failed: $error'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   void _handleForgotPassword() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Reset Password'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Enter your email to receive reset instructions:'),
//             SizedBox(height: 15),
//             TextFormField(
//               controller: TextEditingController(),
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // TODO: Implement forgot password
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Password reset feature coming soon'),
//                   backgroundColor: Colors.blue,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFFf7418c),
//             ),
//             child: Text('Send Instructions'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.only(left: 20, right: 20, top: 35, bottom: 30),
//           width: double.infinity,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 // CLOSE ICON
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: InkWell(
//                     child: Icon(Icons.close),
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),

//                 SizedBox(height: 40),

//                 // LOGO
//                 Image.asset(
//                   "assets/images/menus/image.png",
//                   width: 230,
//                   height: 100,
//                 ),

//                 SizedBox(height: 20),

//                 // EMAIL
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Color(0xFFF2F3F5),
//                     prefixIcon: Icon(
//                       Icons.email,
//                       size: defaultIconSize,
//                       color: Color(0xFF666666),
//                     ),
//                     hintText: "Email Address",
//                     hintStyle: TextStyle(
//                       color: Color(0xFF666666),
//                       fontFamily: defaultFontFamily,
//                       fontSize: defaultFontSize,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: 15),

//                 // PASSWORD
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Color(0xFFF2F3F5),
//                     prefixIcon: Icon(
//                       Icons.lock_outline,
//                       size: defaultIconSize,
//                       color: Color(0xFF666666),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         size: defaultIconSize,
//                         color: Color(0xFF666666),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                     hintText: "Password",
//                     hintStyle: TextStyle(
//                       color: Color(0xFF666666),
//                       fontFamily: defaultFontFamily,
//                       fontSize: defaultFontSize,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: 15),

//                 // REMEMBER ME & FORGOT PASSWORD
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // REMEMBER ME CHECKBOX
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _rememberMe,
//                           onChanged: (value) {
//                             setState(() {
//                               _rememberMe = value!;
//                             });
//                           },
//                           activeColor: Color(0xFFf7418c),
//                           checkColor: Colors.white,
//                         ),
//                         Text(
//                           "Remember me",
//                           style: TextStyle(
//                             color: Color(0xFF666666),
//                             fontFamily: defaultFontFamily,
//                             fontSize: defaultFontSize,
//                           ),
//                         ),
//                       ],
//                     ),

//                     // FORGOT PASSWORD
//                     InkWell(
//                       onTap: _handleForgotPassword,
//                       child: Text(
//                         "Forgot password?",
//                         style: TextStyle(
//                           color: Color(0xFFf7418c),
//                           fontFamily: defaultFontFamily,
//                           fontSize: defaultFontSize,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 20),

//                 // SIGN IN BUTTON
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     gradient: LinearGradient(
//                       colors: [Color(0xFFf7418c), Color(0xFFfbab66)],
//                     ),
//                   ),
//                   child: MaterialButton(
//                     highlightColor: Colors.transparent,
//                     splashColor: Color(0xFFf7418c),
//                     onPressed: _isLoading ? null : _submitForm,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       child: _isLoading
//                           ? SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : Text(
//                               "SIGN IN",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 25,
//                                 fontFamily: "WorkSansBold",
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 10),

//                 // FACEBOOK / GOOGLE LOGIN
//                 FacebookGoogleLogin(),

//                 SizedBox(height: 30),

//                 // SIGN UP TEXT
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Text(
//                       "Don't have an account? ",
//                       style: TextStyle(
//                         color: Color(0xFF666666),
//                         fontFamily: defaultFontFamily,
//                         fontSize: defaultFontSize,
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           ScaleRoute(page: SignUpPage()),
//                         );
//                       },
//                       child: Text(
//                         "Sign Up",
//                         style: TextStyle(
//                           color: Color(0xFFf7418c),
//                           fontFamily: defaultFontFamily,
//                           fontSize: defaultFontSize,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FacebookGoogleLogin extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.only(top: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Container(width: 100, height: 1, color: Colors.black26),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15),
//                 child: Text("Or"),
//               ),
//               Container(width: 100, height: 1, color: Colors.black26),
//             ],
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.only(top: 10, right: 40),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xFFf7418c),
//                 child: Icon(FontAwesomeIcons.facebookF, color: Colors.white),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: 10),
//               child: CircleAvatar(
//                 backgroundColor: Color(0xFFf7418c),
//                 child: Icon(FontAwesomeIcons.google, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/SignUpPage.dart';
import 'package:flutter_app/pages/ResetPasswordPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/favorite_service.dart';
import '../services/review_service.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPasswordController =
      TextEditingController();

  String defaultFontFamily = 'Roboto-Light.ttf';
  double defaultFontSize = 14;
  double defaultIconSize = 17;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isForgotPasswordLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        final result = await authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login successful!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Get updated auth data
          final updatedAuthService =
              Provider.of<AuthService>(context, listen: false);

          // Check if we have valid user data
          if (updatedAuthService.userId != null &&
              updatedAuthService.token != null &&
              updatedAuthService.userName != null) {
            final String userId = updatedAuthService.userId!;
            final String token = updatedAuthService.token!;
            final String userName = updatedAuthService.userName!;

            // Initialize cart service
            final cartService =
                Provider.of<CartService>(context, listen: false);
            cartService.setUserData(userId, token);

            // Initialize favorite service
            try {
              final favoriteService =
                  Provider.of<FavoriteService>(context, listen: false);
              favoriteService.setUserData(userId, token);
              print('✅ FavoriteService initialized for user: $userId');
            } catch (e) {
              print('⚠️ Error initializing FavoriteService: $e');
            }

            // Initialize review service
            try {
              final reviewService =
                  Provider.of<ReviewService>(context, listen: false);
              reviewService.setUserData(token, userId, userName);
              print('✅ ReviewService initialized for user: $userName');
            } catch (e) {
              print('⚠️ Error initializing ReviewService: $e');
            }

            // Navigate to home page
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          } else {
            print('❌ Missing user data after login:');
            print('   userId: ${updatedAuthService.userId}');
            print('   token: ${updatedAuthService.token}');
            print('   userName: ${updatedAuthService.userName}');
            throw Exception('User data is incomplete after login');
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Invalid email or password'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        print('💥 Login error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Reset Password',
              style: TextStyle(
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your registered email address:'),
                SizedBox(height: 15),
                TextFormField(
                  controller: _forgotPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                if (_isForgotPasswordLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFfb3132),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isForgotPasswordLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        _forgotPasswordController.clear();
                      },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: _isForgotPasswordLoading
                    ? null
                    : () async {
                        final email = _forgotPasswordController.text.trim();
                        if (email.isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a valid email'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isForgotPasswordLoading = true;
                        });

                        try {
                          final authService =
                              Provider.of<AuthService>(context, listen: false);
                          final result =
                              await authService.forgotPassword(email);

                          Navigator.pop(context);
                          _forgotPasswordController.clear();

                          if (result['status'] == 'success') {
                            // Show success dialog with token info
                            _showResetTokenDialog(context, result);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ??
                                    'Failed to send reset email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (error) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isForgotPasswordLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFfb3132),
                ),
                child: Text('Send Reset Link'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetTokenDialog(
      BuildContext context, Map<String, dynamic> result) {
    final String token = result['token'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Token Generated',
          style: TextStyle(
            color: Color(0xFF3a3a3b),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.vpn_key,
              color: Colors.blue,
              size: 50,
            ),
            SizedBox(height: 15),
            Text(
              'Use this token to reset your password:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              // child: SelectableText(
              //   token,
              //   style: TextStyle(
              //     fontFamily: 'monospace',
              //     fontSize: 12,
              //     color: Colors.blue[800],
              //   ),
              // ),
            ),
            SizedBox(height: 10),
            Text(
              'You will be taken to the reset password page.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to reset password page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(resetToken: token),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfb3132),
            ),
            child: Text('Reset Password'),
          ),
        ],
      ),
    );
  }
  // void _showResetTokenDialog(
  //     BuildContext context, Map<String, dynamic> result) {
  //   final bool isDevelopment = result['token'] != null;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         isDevelopment ? 'Password Reset Token' : 'Reset Email Sent',
  //         style: TextStyle(
  //           color: Color(0xFF3a3a3b),
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           if (isDevelopment) ...[
  //             Text(
  //               'For development/testing, here is your reset token:',
  //               style: TextStyle(fontSize: 14),
  //             ),
  //             SizedBox(height: 10),
  //             Container(
  //               padding: EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: Colors.grey[300]!),
  //               ),
  //               child: SelectableText(
  //                 result['token'],
  //                 style: TextStyle(
  //                   fontFamily: 'monospace',
  //                   fontSize: 12,
  //                   color: Colors.blue[800],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               'Reset URL:',
  //               style: TextStyle(fontSize: 14),
  //             ),
  //             SizedBox(height: 5),
  //             SelectableText(
  //               result['resetURL'] ?? '',
  //               style: TextStyle(
  //                 color: Colors.blue,
  //                 fontSize: 12,
  //               ),
  //             ),
  //             SizedBox(height: 15),
  //             Text(
  //               'Note: In production, this token would be sent via email.',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontStyle: FontStyle.italic,
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //           ] else ...[
  //             Icon(
  //               Icons.check_circle,
  //               color: Colors.green,
  //               size: 50,
  //             ),
  //             SizedBox(height: 15),
  //             Text(
  //               'Password reset instructions have been sent to your email!',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               'Please check your inbox (and spam folder) for further instructions.',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //       actions: [
  //         if (isDevelopment)
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               // Optionally open reset password page
  //               // Navigator.pushNamed(context, '/reset-password');
  //             },
  //             child: Text('Open Reset Page'),
  //           ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Color(0xFFfb3132),
  //           ),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 35, bottom: 30),
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // CLOSE ICON
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    child: Icon(Icons.close),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                SizedBox(height: 40),

                // LOGO
                Image.asset(
                  "assets/images/menus/ic_food_express.png",
                  width: 230,
                  height: 100,
                ),

                SizedBox(height: 20),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F3F5),
                    prefixIcon: Icon(
                      Icons.email,
                      size: defaultIconSize,
                      color: Color(0xFF666666),
                    ),
                    hintText: "Email Address",
                    hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F3F5),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: defaultIconSize,
                      color: Color(0xFF666666),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: defaultIconSize,
                        color: Color(0xFF666666),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

                // REMEMBER ME & FORGOT PASSWORD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // REMEMBER ME CHECKBOX
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          activeColor: Color(0xFFf7418c),
                          checkColor: Colors.white,
                        ),
                        Text(
                          "Remember me",
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontFamily: defaultFontFamily,
                            fontSize: defaultFontSize,
                          ),
                        ),
                      ],
                    ),

                    // FORGOT PASSWORD
                    InkWell(
                      onTap: _handleForgotPassword,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Color(0xFFf7418c),
                          fontFamily: defaultFontFamily,
                          fontSize: defaultFontSize,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // SIGN IN BUTTON
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: [Color(0xFFf7418c), Color(0xFFfbab66)],
                    ),
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Color(0xFFf7418c),
                    onPressed: _isLoading ? null : _submitForm,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "SIGN IN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: "WorkSansBold",
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // FACEBOOK / GOOGLE LOGIN
                FacebookGoogleLogin(),

                SizedBox(height: 30),

                // SIGN UP TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontFamily: defaultFontFamily,
                        fontSize: defaultFontSize,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ScaleRoute(page: SignUpPage()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFFf7418c),
                          fontFamily: defaultFontFamily,
                          fontSize: defaultFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FacebookGoogleLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 100, height: 1, color: Colors.black26),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text("Or"),
              ),
              Container(width: 100, height: 1, color: Colors.black26),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, right: 40),
              child: CircleAvatar(
                backgroundColor: Color(0xFFf7418c),
                child: Icon(FontAwesomeIcons.facebookF, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: CircleAvatar(
                backgroundColor: Color(0xFFf7418c),
                child: Icon(FontAwesomeIcons.google, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
