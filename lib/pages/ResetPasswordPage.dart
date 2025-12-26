// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   final String resetToken;

//   const ResetPasswordPage({Key? key, required this.resetToken})
//       : super(key: key);

//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _showSuccess = false;

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _resetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       if (_passwordController.text != _confirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Passwords do not match'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final authService = Provider.of<AuthService>(context, listen: false);

//         final result = await authService.resetPassword(
//           token: widget.resetToken,
//           password: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//         );

//         if (result['success'] == true) {
//           setState(() {
//             _showSuccess = true;
//           });

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Password reset successful!'),
//               backgroundColor: Colors.green,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(result['message'] ?? 'Password reset failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${error.toString()}'),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reset Password'),
//         backgroundColor: Color(0xFFfb3132),
//       ),
//       body: _showSuccess
//           ? _buildSuccessView()
//           : SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 30),
//                     Text(
//                       'Set New Password',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF3a3a3b),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Enter your new password below',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         'Reset token: ${widget.resetToken.substring(0, 20)}...',
//                         style: TextStyle(
//                           fontFamily: 'monospace',
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // New Password
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       decoration: InputDecoration(
//                         labelText: 'New Password',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter new password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 20),

//                     // Confirm Password
//                     TextFormField(
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         labelText: 'Confirm Password',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.lock_outline),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureConfirmPassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscureConfirmPassword =
//                                   !_obscureConfirmPassword;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please confirm your password';
//                         }
//                         if (value != _passwordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 30),

//                     // Reset Button
//                     Container(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _resetPassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFFfb3132),
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(
//                                 'RESET PASSWORD',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildSuccessView() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.check_circle,
//               color: Colors.green,
//               size: 80,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Password Reset Successful!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF3a3a3b),
//               ),
//             ),
//             SizedBox(height: 15),
//             Text(
//               'Your password has been successfully updated in the database.',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/signin',
//                   (route) => false,
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFFfb3132),
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               child: Text('Go to Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;

  const ResetPasswordPage({Key? key, required this.resetToken})
      : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        final result = await authService.resetPassword(
          token: widget.resetToken,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        if (result['success'] == true) {
          setState(() {
            _showSuccess = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Password reset failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Color(0xFFfb3132),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _showSuccess
          ? _buildSuccessView()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Set New Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3a3a3b),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Enter your new password below',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),

                    // New Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    // Reset Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFfb3132),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                                'RESET PASSWORD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Password Reset Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3a3a3b),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Your password has been successfully updated.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen (which should be login)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFfb3132),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
