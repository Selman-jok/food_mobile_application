import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
import '../services/favorite_service.dart';
import '../services/cart_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String defaultFontFamily = 'Roboto-Light.ttf';
  double defaultFontSize = 14;
  double defaultIconSize = 17;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Ethiopian phone number validation
  bool _isValidEthiopianPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    RegExp ethiopianPhoneRegex = RegExp(r'^(\+251|251|0)9\d{8}$');
    return ethiopianPhoneRegex.hasMatch(cleanedPhone);
  }

  // Normalize phone number
  String _normalizePhoneNumber(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanedPhone.startsWith('0')) {
      return '+251${cleanedPhone.substring(1)}';
    } else if (cleanedPhone.startsWith('251') &&
        !cleanedPhone.startsWith('+251')) {
      return '+$cleanedPhone';
    }
    return cleanedPhone;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Normalize phone number
      final normalizedPhone = _normalizePhoneNumber(_phoneController.text);

      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        // Call signUp instead of signIn!
        final result = await authService.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          phoneNumber: normalizedPhone,
        );

        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration successful!'),
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
            // If auth data is incomplete, just show success message
            print('ℹ️ Auth data incomplete but signup succeeded');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration successful! Please sign in.'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
            // Navigate back to sign in page
            Navigator.pop(context);
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        print('💥 Signup error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${error.toString()}'),
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

                // FULL NAME
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F3F5),
                    prefixIcon: Icon(
                      Icons.person,
                      size: defaultIconSize,
                      color: Color(0xFF666666),
                    ),
                    hintText: "Full Name",
                    hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

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

                // PHONE NUMBER
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F3F5),
                    prefixIcon: Icon(
                      Icons.phone,
                      size: defaultIconSize,
                      color: Color(0xFF666666),
                    ),
                    hintText: "Phone Number (09xxxxxxxx)",
                    hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!_isValidEthiopianPhone(value)) {
                      return 'Please enter a valid Ethiopian phone number\nFormats: 09xxxxxxxx, +2519xxxxxxxx, 2519xxxxxxxx';
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 15),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
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
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: defaultIconSize,
                        color: Color(0xFF666666),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(
                      color: Color(0xFF666666),
                      fontFamily: defaultFontFamily,
                      fontSize: defaultFontSize,
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

                SizedBox(height: 20),

                // SIGN UP BUTTON
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
                              "SIGN UP",
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

                // SIGN IN TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Already have an account? ",
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
                          ScaleRoute(page: SignInPage()),
                        );
                      },
                      child: Text(
                        "Sign In",
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
