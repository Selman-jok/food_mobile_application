import 'package:flutter/material.dart';
import 'package:flutter_app/pages/favorite_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:flutter_app/animation/scaleroute.dart';
import 'package:flutter_app/pages/foodorderpage.dart';
import 'package:flutter_app/pages/favorite_page.dart';

class BottomNavBarWidget extends StatefulWidget {
  @override
  _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 3) {
      // Account tab clicked

      Navigator.push(
        context,
        ScaleRoute(page: SignInPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        ScaleRoute(page: FoodOrderPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        ScaleRoute(page: FavoritePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.user),
          label: 'Account',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Color(0xFFfd5352),
      unselectedItemColor: Color(0xFF2c2b2b),
      onTap: _onItemTapped,
    );
  }
}
