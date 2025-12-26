import 'package:flutter/material.dart';
import 'package:flutter_app/pages/category_page.dart';

class TopMenus extends StatefulWidget {
  @override
  _TopMenusState createState() => _TopMenusState();
}

class _TopMenusState extends State<TopMenus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const <Widget>[
          TopMenuTiles(
              name: "Burger", imageUrl: "ic_burger", category: "burger"),
          TopMenuTiles(name: "Pizza", imageUrl: "ic_pizza", category: "pizza"),
          TopMenuTiles(name: "Cake", imageUrl: "ic_cake", category: "cake"),
          TopMenuTiles(
              name: "Ice Cream",
              imageUrl: "ic_ice_cream",
              category: "icecream"),
          TopMenuTiles(
              name: "Burrito", imageUrl: "ic_burrito", category: "burrito"),
          TopMenuTiles(
              name: "Soft Drink",
              imageUrl: "ic_soft_drink",
              category: "softdrink"),
        ],
      ),
    );
  }
}

class TopMenuTiles extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String category;

  const TopMenuTiles({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to category page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: category,
              categoryTitle: name,
            ),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 25.0,
                offset: Offset(0.0, 0.75),
              ),
            ]),
            child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Image.asset(
                    'assets/images/topmenu/' + imageUrl + ".png",
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.fastfood,
                        color: Color(0xFFfb3132),
                        size: 24,
                      );
                    },
                  )),
                )),
          ),
          Text(name,
              style: TextStyle(
                  color: Color(0xFF6e6e71),
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
