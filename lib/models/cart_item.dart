// lib/models/cart_item.dart
import 'dart:convert';

class CartItem {
  final String id; // MongoDB _id from server
  final String foodId; // Food ID reference
  final String name;
  final int quantity;
  final double price;
  final double finalPrice;
  final String image;
  final double? originalPrice;
  final double? discountPercent;

  CartItem({
    required this.id,
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.finalPrice,
    required this.image,
    this.originalPrice,
    this.discountPercent,
  });

  // Calculate total for this item
  double get totalPrice => finalPrice * quantity;

  // Parse from server JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id']?.toString() ?? '',
      foodId: json['food']?.toString() ?? json['foodId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Item',
      quantity: json['quantity']?.toInt() ?? 1,
      price: (json['price'] ?? json['finalPrice'])?.toDouble() ?? 0.0,
      finalPrice:
          json['finalPrice']?.toDouble() ?? json['price']?.toDouble() ?? 0.0,
      image: json['image']?.toString() ?? '',
      originalPrice: json['originalPrice']?.toDouble(),
      discountPercent: json['discountPercent']?.toDouble(),
    );
  }

  // Convert to JSON for server
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'food': foodId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'finalPrice': finalPrice,
      'image': image,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (discountPercent != null) 'discountPercent': discountPercent,
    };
  }
}
