// class Review {
//   final String id;
//   final String foodId;
//   final String userId;
//   final String? userName;
//   final String? userEmail;
//   final int rating;
//   final String comment;
//   final DateTime createdAt;

//   Review({
//     required this.id,
//     required this.foodId,
//     required this.userId,
//     this.userName,
//     this.userEmail,
//     required this.rating,
//     required this.comment,
//     required this.createdAt,
//   });

//   // In lib/models/review.dart - Update fromJson method
//   factory Review.fromJson(Map<String, dynamic> json) {
//     print('📝 Parsing review JSON: $json'); // Debug line

//     // Handle different possible JSON structures
//     String id;
//     if (json['_id'] != null) {
//       id = json['_id'].toString();
//     } else if (json['id'] != null) {
//       id = json['id'].toString();
//     } else {
//       id = '';
//     }

//     // Handle user data - check multiple possible formats
//     String userId;
//     String? userName;
//     String? userEmail;

//     // Case 1: user is an object with _id, name, email
//     if (json['user'] is Map<String, dynamic>) {
//       userId = json['user']['_id']?.toString() ?? '';
//       userName = json['user']['name']?.toString();
//       userEmail = json['user']['email']?.toString();
//     }
//     // Case 2: user fields are directly in JSON (flattened)
//     else if (json['userId'] != null || json['userName'] != null) {
//       userId = json['userId']?.toString() ?? '';
//       userName = json['userName']?.toString();
//       userEmail = json['userEmail']?.toString();
//     }
//     // Case 3: user is just an ID string
//     else if (json['user'] is String) {
//       userId = json['user'];
//       userName = null; // Will be set later from AuthService
//       userEmail = null;
//     }
//     // Case 4: No user data found
//     else {
//       userId = '';
//       userName = null; // Will be set later from AuthService
//       userEmail = null;
//     }

//     // If no name found, try to get it from alternative fields
//     if (userName == null || userName.isEmpty) {
//       userName = json['author']?.toString() ??
//           json['username']?.toString() ??
//           'User'; // Default to 'User' instead of 'Anonymous'
//     }

//     // Parse rating
//     int rating;
//     if (json['rating'] is int) {
//       rating = json['rating'];
//     } else if (json['rating'] is double) {
//       rating = (json['rating'] as double).toInt();
//     } else if (json['rating'] is String) {
//       rating = int.tryParse(json['rating']) ?? 0;
//     } else {
//       rating = 0;
//     }

//     // Parse date
//     DateTime createdAt;
//     if (json['createdAt'] is String) {
//       createdAt = DateTime.parse(json['createdAt']);
//     } else if (json['createdAt'] is int) {
//       createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
//     } else if (json['createdAt'] != null) {
//       // Try to parse any other format
//       try {
//         createdAt = DateTime.parse(json['createdAt'].toString());
//       } catch (e) {
//         createdAt = DateTime.now();
//       }
//     } else {
//       createdAt = DateTime.now();
//     }

//     return Review(
//       id: id,
//       foodId: json['food']?.toString() ?? json['foodId']?.toString() ?? '',
//       userId: userId,
//       userName: userName,
//       userEmail: userEmail,
//       rating: rating,
//       comment: json['comment']?.toString() ?? '',
//       createdAt: createdAt,
//     );
//   }
// // }
// class Review {
//   final String id;
//   final String foodId;
//   final String userId;
//   final String? userName;
//   final String? userEmail;
//   final int rating;
//   final String comment;
//   final DateTime createdAt;

//   Review({
//     required this.id,
//     required this.foodId,
//     required this.userId,
//     this.userName,
//     this.userEmail,
//     required this.rating,
//     required this.comment,
//     required this.createdAt,
//   });

//   factory Review.fromJson(Map<String, dynamic> json) {
//     print('📝 Parsing review JSON: $json');

//     // Handle Firebase ID (could be 'id' or '_id')
//     String id;
//     if (json['id'] != null) {
//       id = json['id'].toString();
//     } else if (json['_id'] != null) {
//       id = json['_id'].toString();
//     } else {
//       id = '';
//     }

//     // Handle user data - Firebase structure
//     String userId;
//     String? userName;
//     String? userEmail;

//     // Case 1: user is an object with id, name, email (Firebase)
//     if (json['user'] is Map<String, dynamic>) {
//       userId = json['user']['id']?.toString() ??
//           json['user']['_id']?.toString() ??
//           '';
//       userName = json['user']['name']?.toString();
//       userEmail = json['user']['email']?.toString();
//     }
//     // Case 2: user fields are directly in JSON
//     else if (json['userId'] != null) {
//       userId = json['userId'].toString();
//       userName = json['userName']?.toString();
//       userEmail = json['userEmail']?.toString();
//     }
//     // Case 3: No user data found
//     else {
//       userId = '';
//       userName = null;
//       userEmail = null;
//     }

//     // Parse rating
//     int rating;
//     if (json['rating'] is int) {
//       rating = json['rating'];
//     } else if (json['rating'] is double) {
//       rating = (json['rating'] as double).toInt();
//     } else if (json['rating'] is String) {
//       rating = int.tryParse(json['rating']) ?? 0;
//     } else {
//       rating = 0;
//     }

//     // Parse date
//     DateTime createdAt;
//     if (json['createdAt'] is String) {
//       try {
//         createdAt = DateTime.parse(json['createdAt']);
//       } catch (e) {
//         createdAt = DateTime.now();
//       }
//     } else if (json['createdAt'] is int) {
//       createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
//     } else if (json['createdAt'] != null) {
//       try {
//         createdAt = DateTime.parse(json['createdAt'].toString());
//       } catch (e) {
//         createdAt = DateTime.now();
//       }
//     } else {
//       createdAt = DateTime.now();
//     }

//     return Review(
//       id: id,
//       foodId: json['foodId']?.toString() ?? '',
//       userId: userId,
//       userName: userName ?? 'User',
//       userEmail: userEmail,
//       rating: rating,
//       comment: json['comment']?.toString() ?? '',
//       createdAt: createdAt,
//     );
//   }

//   // Convert to JSON for server
//   Map<String, dynamic> toJson() {
//     return {
//       'foodId': foodId,
//       'rating': rating,
//       'comment': comment,
//     };
//   }
// }
// lib/models/review.dart
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

  factory Review.fromJson(Map<String, dynamic> json) {
    print('📝 Parsing review JSON: $json');

    // Handle ID - Firebase might use 'id' instead of '_id'
    String id;
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    } else {
      id = '';
    }

    // Handle foodId - Firebase might use 'foodId'
    String foodId;
    if (json['foodId'] != null) {
      foodId = json['foodId'].toString();
    } else if (json['food'] != null) {
      foodId = json['food'].toString();
    } else {
      foodId = '';
    }

    // Handle user data
    String userId;
    String? userName;
    String? userEmail;

    // Check if 'user' field exists and is an object
    if (json['user'] is Map<String, dynamic>) {
      final userData = json['user'];
      userId = userData['id']?.toString() ??
          userData['_id']?.toString() ??
          userData['userId']?.toString() ??
          '';
      userName = userData['name']?.toString();
      userEmail = userData['email']?.toString();
    }
    // Check for direct userId field
    else if (json['userId'] != null) {
      userId = json['userId'].toString();
      userName = json['userName']?.toString();
      userEmail = json['userEmail']?.toString();
    }
    // If user is just a string ID
    else if (json['user'] is String) {
      userId = json['user'];
      userName = null;
      userEmail = null;
    } else {
      userId = '';
      userName = null;
      userEmail = null;
    }

    // Set default values if userName is null
    if (userName == null || userName.isEmpty) {
      userName =
          json['author']?.toString() ?? json['username']?.toString() ?? 'User';
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

    // Parse comment
    String comment = json['comment']?.toString() ?? '';

    // Parse createdAt
    DateTime createdAt;
    try {
      if (json['createdAt'] is String) {
        // Try to parse ISO string
        createdAt = DateTime.parse(json['createdAt']);
      } else if (json['createdAt'] is int) {
        // Parse from timestamp
        createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
      } else if (json['createdAt'] is Map) {
        // Firebase timestamp object
        final timestamp = json['createdAt'];
        if (timestamp['_seconds'] != null) {
          final seconds = timestamp['_seconds'] as int;
          final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
          createdAt = DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
          );
        } else {
          createdAt = DateTime.now();
        }
      } else if (json['createdAt'] != null) {
        // Try to parse any other format
        createdAt = DateTime.parse(json['createdAt'].toString());
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      print('⚠️ Error parsing date: $e');
      createdAt = DateTime.now();
    }

    return Review(
      id: id,
      foodId: foodId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }

  // Convert to JSON for sending to server
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get rating as stars
  String get ratingStars {
    return '⭐' * rating;
  }
}
