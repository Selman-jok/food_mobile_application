class Review {
  final String id;
  final String foodId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.foodId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // In lib/models/review.dart - Update fromJson method
  factory Review.fromJson(Map<String, dynamic> json) {
    print('📝 Parsing review JSON: $json'); // Debug line

    // Handle different possible JSON structures
    String id;
    if (json['_id'] != null) {
      id = json['_id'].toString();
    } else if (json['id'] != null) {
      id = json['id'].toString();
    } else {
      id = '';
    }

    // Handle user data - check multiple possible formats
    String userId;
    String? userName;
    String? userEmail;

    // Case 1: user is an object with _id, name, email
    if (json['user'] is Map<String, dynamic>) {
      userId = json['user']['_id']?.toString() ?? '';
      userName = json['user']['name']?.toString();
      userEmail = json['user']['email']?.toString();
    }
    // Case 2: user fields are directly in JSON (flattened)
    else if (json['userId'] != null || json['userName'] != null) {
      userId = json['userId']?.toString() ?? '';
      userName = json['userName']?.toString();
      userEmail = json['userEmail']?.toString();
    }
    // Case 3: user is just an ID string
    else if (json['user'] is String) {
      userId = json['user'];
      userName = null; // Will be set later from AuthService
      userEmail = null;
    }
    // Case 4: No user data found
    else {
      userId = '';
      userName = null; // Will be set later from AuthService
      userEmail = null;
    }

    // If no name found, try to get it from alternative fields
    if (userName == null || userName.isEmpty) {
      userName = json['author']?.toString() ??
          json['username']?.toString() ??
          'User'; // Default to 'User' instead of 'Anonymous'
    }

    // Parse rating
    int rating;
    if (json['rating'] is int) {
      rating = json['rating'];
    } else if (json['rating'] is double) {
      rating = (json['rating'] as double).toInt();
    } else if (json['rating'] is String) {
      rating = int.tryParse(json['rating']) ?? 0;
    } else {
      rating = 0;
    }

    // Parse date
    DateTime createdAt;
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
    } else if (json['createdAt'] != null) {
      // Try to parse any other format
      try {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    return Review(
      id: id,
      foodId: json['food']?.toString() ?? json['foodId']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      rating: rating,
      comment: json['comment']?.toString() ?? '',
      createdAt: createdAt,
    );
  }
}
