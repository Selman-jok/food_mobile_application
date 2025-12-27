
// // server/controllers/reviewController.js - Update addReview function
// const Review = require('../models/Review');
// const Food = require('../models/Food');
// const User = require('../models/User'); // Add this import

// // Add a review
// exports.addReview = async (req, res) => {
//   try {
//     console.log('📝 Add review request body:', req.body);
//     console.log('👤 User from request:', req.user); // Check if user exists
    
//     const { foodId, rating, comment } = req.body;
    
//     // IMPORTANT: Use the authenticated user from req.user
//     if (!req.user || !req.user._id) {
//       return res.status(401).json({
//         success: false,
//         message: 'Please login to add a review'
//       });
//     }
    
//     const userId = req.user._id;

//     // Validate rating
//     if (!rating || rating < 1 || rating > 5) {
//       return res.status(400).json({
//         success: false,
//         message: 'Rating must be between 1 and 5'
//       });
//     }

//     // Check if food exists
//     const food = await Food.findById(foodId);
//     if (!food) {
//       return res.status(404).json({
//         success: false,
//         message: 'Food item not found'
//       });
//     }

//     // Check if user already reviewed this food
//     const existingReview = await Review.findOne({ 
//       food: foodId, 
//       user: userId 
//     });
    
//     if (existingReview) {
//       return res.status(400).json({
//         success: false,
//         message: 'You have already reviewed this food'
//       });
//     }

//     // Create review
//     const review = new Review({
//       food: foodId,
//       user: userId,
//       rating,
//       comment: comment || ''
//     });

//     await review.save();

//     // Populate user details
//     const populatedReview = await Review.findById(review._id)
//       .populate('user', 'name email')
//       .lean();

//     // Update food rating
//     const reviews = await Review.find({ food: foodId });
//     const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
//     const averageRating = totalRating / reviews.length;

//     food.rating = parseFloat(averageRating.toFixed(1));
//     food.totalReviews = reviews.length;
//     await food.save();

//     res.status(201).json({
//       success: true,
//       message: 'Review added successfully',
//       data: {
//         ...populatedReview,
//         userName: populatedReview.user.name,
//         userEmail: populatedReview.user.email,
//         user: {
//           _id: populatedReview.user._id,
//           name: populatedReview.user.name,
//           email: populatedReview.user.email
//         }
//       }
//     });

//   } catch (error) {
//     console.error('Add review error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message
//     });
//   }
// };

// // Get reviews for a food item
// // In reviewController.js - Update getFoodReviews function
// exports.getFoodReviews = async (req, res) => {
//   try {
//     const { foodId } = req.params;
//     console.log('📝 Fetching reviews for food:', foodId);

//     const reviews = await Review.find({ food: foodId })
//       .populate({
//         path: 'user',
//         select: 'name email', // Make sure to select name
//         model: 'User' // Specify the model
//       })
//       .sort({ createdAt: -1 });

//     console.log('👤 First review user data:', reviews[0]?.user);

//     res.status(200).json({
//       success: true,
//       count: reviews.length,
//       data: reviews
//     });

//   } catch (error) {
//     console.error('Get reviews error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message
//     });
//   }
// };

// server/controllers/reviewController.js - Firebase version
const ReviewFirebase = require('../models/ReviewFirebase');
const FoodFirebase = require('../models/FoodFirebase');
const UserFirebase = require('../models/UserFirebase');

// Add a review
exports.addReview = async (req, res) => {
  try {
    console.log('📝 Add review request body:', req.body);
    console.log('👤 User from request:', req.user);
    
    const { foodId, rating, comment } = req.body;
    
    // IMPORTANT: Use the authenticated user from req.user
    if (!req.user || !req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Please login to add a review'
      });
    }
    
    const userId = req.user.id;

    // Validate rating
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    // Check if food exists
    const food = await FoodFirebase.findById(foodId);
    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Check if user already reviewed this food
    const existingReview = await ReviewFirebase.findByUserAndFood(userId, foodId);
    
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this food'
      });
    }

    // Create review
    const review = new ReviewFirebase({
      foodId: foodId,
      userId: userId,
      rating: parseInt(rating),
      comment: comment || ''
    });

    await review.save();

    // Get user details
    const user = await UserFirebase.findById(userId);
    
    // Update food rating
    const ratingData = await ReviewFirebase.calculateFoodRating(foodId);
    food.rating = ratingData.averageRating;
    food.totalReviews = ratingData.totalReviews;
    await food.save();

    res.status(201).json({
      success: true,
      message: 'Review added successfully',
      data: {
        id: review.id,
        foodId: review.foodId,
        userId: review.userId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        user: user ? {
          id: user.id,
          name: user.name,
          email: user.email
        } : null
      }
    });

  } catch (error) {
    console.error('Add review error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Get reviews for a food item
exports.getFoodReviews = async (req, res) => {
  try {
    const { foodId } = req.params;
    console.log('📝 Fetching reviews for food:', foodId);

    const reviewsWithUsers = await ReviewFirebase.getReviewsWithUserDetails(foodId);

    res.status(200).json({
      success: true,
      count: reviewsWithUsers.length,
      data: reviewsWithUsers.map(review => ({
        id: review.id,
        foodId: review.foodId,
        userId: review.userId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
        user: review.user
      }))
    });

  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Delete a review (optional)
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.id;

    const review = await ReviewFirebase.findById(reviewId);
    
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check if user owns the review or is admin
    if (review.userId !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this review'
      });
    }

    // Update food rating before deleting
    const foodId = review.foodId;
    await review.delete();
    
    const food = await FoodFirebase.findById(foodId);
    if (food) {
      const ratingData = await ReviewFirebase.calculateFoodRating(foodId);
      food.rating = ratingData.averageRating;
      food.totalReviews = ratingData.totalReviews;
      await food.save();
    }

    res.status(200).json({
      success: true,
      message: 'Review deleted successfully'
    });

  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Update a review (optional)
exports.updateReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;

    // Validate rating
    if (rating && (rating < 1 || rating > 5)) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    const review = await ReviewFirebase.findById(reviewId);
    
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    // Check if user owns the review
    if (review.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this review'
      });
    }

    // Update review
    if (rating !== undefined) review.rating = parseInt(rating);
    if (comment !== undefined) review.comment = comment;
    
    await review.save();

    // Update food rating
    const foodId = review.foodId;
    const food = await FoodFirebase.findById(foodId);
    if (food) {
      const ratingData = await ReviewFirebase.calculateFoodRating(foodId);
      food.rating = ratingData.averageRating;
      food.totalReviews = ratingData.totalReviews;
      await food.save();
    }

    res.status(200).json({
      success: true,
      message: 'Review updated successfully',
      data: review.toObject()
    });

  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};