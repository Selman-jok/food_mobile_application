class Food {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double? originalPrice;
  final double? discountPercent;
  final String image;
  final bool isPopular;
  final bool isSpecialOffer;
  final double rating;
  final int totalReviews;
  final List<String> ingredients;
  final bool available;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.image,
    this.isPopular = false,
    this.isSpecialOffer = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.ingredients = const [],
    this.available = true,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      discountPercent: json['discountPercent']?.toDouble(),
      image: json['image'] ?? '',
      isPopular: json['isPopular'] ?? false,
      isSpecialOffer: json['isSpecialOffer'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      available: json['available'] ?? true,
    );
  }

  bool get isLocalImage {
    return image.startsWith('assets/');
  }

  String get displayImage {
    return image;
  }
}
