import 'package:flutter/material.dart';
import 'package:flutter_app/models/food.dart';
import 'package:flutter_app/pages/favorite_page.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/HomePage.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:flutter_app/pages/SignUpPage.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';
import 'services/review_service.dart'; // ADD THIS IMPORT

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => FavoriteService()),
        ChangeNotifierProvider(
            create: (context) => ReviewService()), // ADD THIS
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          hintColor: Color(0xFFd0cece),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/sign-in',
        routes: {
          '/': (context) => HomePage(),
          '/favorites': (context) => FavoritePage(),
          '/food-details': (context) {
            final food = ModalRoute.of(context)!.settings.arguments as Food?;
            return FoodDetailsPage(
              food: food ?? _createDefaultFood(),
            );
          },
          '/food-order': (context) => FoodOrderPage(),
          '/sign-in': (context) => SignInPage(),
          '/sign-up': (context) => SignUpPage(),
        },
      ),
    );
  }

  Food _createDefaultFood() {
    return Food(
      id: 'default',
      name: 'Food Item',
      category: 'burger',
      description: 'Delicious food item',
      price: 0.0,
      image: '',
    );
  }
}
