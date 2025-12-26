import 'dart:convert';

class Food {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String image;
  final double rating;
  final int totalReviews;
  final List<String> ingredients;
  final bool isSpecialOffer;
  final double? discountPercent;
  final double? originalPrice;
  final bool available;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.rating = 4.5,
    this.totalReviews = 100,
    this.ingredients = const [],
    this.isSpecialOffer = false,
    this.discountPercent,
    this.originalPrice,
    this.available = true,
  });

  bool get isLocalImage => !image.startsWith('http');

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Food',
      category: json['category']?.toString() ?? 'burger',
      description: json['description']?.toString() ?? 'Delicious food item',
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image']?.toString() ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      totalReviews: (json['totalReviews'] ?? 100).toInt(),
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : [],
      isSpecialOffer: json['isSpecialOffer'] ?? false,
      discountPercent: json['discountPercent']?.toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      available: json['available'] ?? true,
    );
  }

  // ADD THIS METHOD
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'image': image,
      'rating': rating,
      'totalReviews': totalReviews,
      'ingredients': ingredients,
      'isSpecialOffer': isSpecialOffer,
      'discountPercent': discountPercent,
      'originalPrice': originalPrice,
      'available': available,
    };
  }
}
