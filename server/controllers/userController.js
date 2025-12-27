// const User = require('../models/User');
// const catchAsync = require('../utils/catchAsync');
// const AppError = require('../utils/appError');

// // Helper function to filter object
// const filterObj = (obj, ...allowedFields) => {
//   const newObj = {};
//   Object.keys(obj).forEach(el => {
//     if (allowedFields.includes(el)) newObj[el] = obj[el];
//   });
//   return newObj;
// };

// // GET ME (Get current user)
// exports.getMe = (req, res, next) => {
//   req.params.id = req.user.id;
//   next();
// };

// // GET ALL USERS (Admin only)
// exports.getAllUsers = catchAsync(async (req, res, next) => {
//   const users = await User.find();
  
//   res.status(200).json({
//     status: 'success',
//     results: users.length,
//     data: { users }
//   });
// });

// // GET USER
// exports.getUser = catchAsync(async (req, res, next) => {
//   const user = await User.findById(req.params.id);
  
//   if (!user) {
//     return next(new AppError('No user found with that ID', 404));
//   }
  
//   res.status(200).json({
//     status: 'success',
//     data: { user }
//   });
// });

// // UPDATE ME
// exports.updateMe = catchAsync(async (req, res, next) => {
//   // Create error if user tries to update password
//   if (req.body.password || req.body.confirmPassword) {
//     return next(new AppError('This route is not for password updates. Please use /update-my-password.', 400));
//   }
  
//   // Filter allowed fields
//   const filteredBody = filterObj(req.body, 'name', 'email', 'phoneNumber');
  
//   // Update user document
//   const updatedUser = await User.findByIdAndUpdate(req.user.id, filteredBody, {
//     new: true,
//     runValidators: true
//   });
  
//   res.status(200).json({
//     status: 'success',
//     data: { user: updatedUser }
//   });
// });

// // DELETE ME
// exports.deleteMe = catchAsync(async (req, res, next) => {
//   await User.findByIdAndUpdate(req.user.id, { active: false });
  
//   res.status(204).json({
//     status: 'success',
//     data: null
//   });
// });

// // UPDATE USER (Admin only)
// exports.updateUser = catchAsync(async (req, res, next) => {
//   const user = await User.findByIdAndUpdate(req.params.id, req.body, {
//     new: true,
//     runValidators: true
//   });
  
//   if (!user) {
//     return next(new AppError('No user found with that ID', 404));
//   }
  
//   res.status(200).json({
//     status: 'success',
//     data: { user }
//   });
// });

// // DELETE USER (Admin only)
// exports.deleteUser = catchAsync(async (req, res, next) => {
//   const user = await User.findByIdAndDelete(req.params.id);
  
//   if (!user) {
//     return next(new AppError('No user found with that ID', 404));
//   }
  
//   res.status(204).json({
//     status: 'success',
//     data: null
//   });
// // });
// // server/controllers/cartController.js
// const CartFirebase = require('../models/CartFirebase');
// const FoodFirebase = require('../models/FoodFirebase');

// // Get user's cart
// const getCart = async (req, res) => {
//     try {
//         // Get cart for logged-in user
//         let cart = await CartFirebase.findByUserId(req.user.id);
        
//         if (!cart) {
//             // Create cart if doesn't exist for this user
//             cart = new CartFirebase({ 
//                 userId: req.user.id,
//                 items: [] 
//             });
//             await cart.save();
//         }
        
//         res.json({
//             success: true,
//             data: cart
//         });
//     } catch (error) {
//         res.status(500).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// // Add item to user's cart
// const addToCart = async (req, res) => {
//     try {
//         const { foodId, quantity = 1 } = req.body;
//         const userId = req.user.id;
        
//         console.log('Adding to cart - userId:', userId, 'foodId:', foodId, 'quantity:', quantity);
        
//         // Validate input
//         if (!foodId) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'foodId is required'
//             });
//         }
        
//         // Find the food item
//         const food = await FoodFirebase.findById(foodId);
//         if (!food) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Food item not found'
//             });
//         }
        
//         // Get or create cart for this specific user
//         let cart = await CartFirebase.findByUserId(userId);
//         if (!cart) {
//             cart = new CartFirebase({ 
//                 userId: userId,
//                 items: [] 
//             });
//             console.log('Created new cart for user:', userId);
//         }
        
//         // Check if item already exists in cart
//         const existingItemIndex = cart.items.findIndex(item => 
//             item.foodId === foodId
//         );
        
//         if (existingItemIndex > -1) {
//             // Update quantity if item exists
//             cart.items[existingItemIndex].quantity += quantity;
//             console.log('Updated existing item quantity for user:', userId);
//         } else {
//             // Add new item to cart
//             cart.items.push({
//                 foodId: foodId,
//                 name: food.name,
//                 quantity,
//                 price: food.price,
//                 finalPrice: food.price,
//                 image: food.image
//             });
//             console.log('Added new item to cart for user:', userId);
//         }
        
//         await cart.save();
        
//         res.status(201).json({
//             success: true,
//             message: 'Item added to cart',
//             data: cart
//         });
//     } catch (error) {
//         console.error('Error in addToCart:', error);
//         res.status(400).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// // Update item quantity in user's cart
// const updateCartItem = async (req, res) => {
//     try {
//         const { quantity } = req.body;
//         const { itemId } = req.params;
//         const userId = req.user.id;
        
//         console.log('Updating cart item - userId:', userId, 'itemId:', itemId, 'quantity:', quantity);
        
//         const cart = await CartFirebase.findByUserId(userId);
        
//         if (!cart) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Cart not found'
//             });
//         }
        
//         // In Firebase, itemId is the index or foodId
//         const success = cart.updateItemQuantity(itemId, quantity);
        
//         if (!success) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Item not found in cart'
//             });
//         }
        
//         await cart.save();
        
//         res.json({
//             success: true,
//             message: 'Cart updated successfully',
//             data: cart
//         });
//     } catch (error) {
//         console.error('Error in updateCartItem:', error);
//         res.status(400).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// // Remove item from user's cart
// const removeFromCart = async (req, res) => {
//     try {
//         const { itemId } = req.params;
//         const userId = req.user.id;
        
//         console.log('Removing from cart - userId:', userId, 'itemId:', itemId);
        
//         const cart = await CartFirebase.findByUserId(userId);
        
//         if (!cart) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Cart not found'
//             });
//         }
        
//         const success = cart.removeItem(itemId);
        
//         if (!success) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Item not found in cart'
//             });
//         }
        
//         await cart.save();
        
//         console.log('Item removed successfully for user:', userId);
        
//         res.json({
//             success: true,
//             message: 'Item removed from cart',
//             data: cart
//         });
//     } catch (error) {
//         console.error('Error in removeFromCart:', error);
//         res.status(400).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// // Clear user's cart
// const clearCart = async (req, res) => {
//     try {
//         const userId = req.user.id;
//         console.log('Clearing entire cart for user:', userId);
        
//         const cart = await CartFirebase.findByUserId(userId);
        
//         if (!cart) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'Cart not found'
//             });
//         }
        
//         cart.clear();
//         await cart.save();
        
//         console.log('Cart cleared successfully for user:', userId);
        
//         res.json({
//             success: true,
//             message: 'Cart cleared successfully',
//             data: cart
//         });
//     } catch (error) {
//         console.error('Error in clearCart:', error);
//         res.status(500).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// // Get user's cart summary
// const getCartSummary = async (req, res) => {
//     try {
//         const userId = req.user.id;
//         console.log('Getting cart summary for user:', userId);
        
//         const cart = await CartFirebase.findByUserId(userId);
        
//         if (!cart) {
//             return res.json({
//                 success: true,
//                 data: {
//                     totalQuantity: 0,
//                     subtotal: 0,
//                     deliveryFee: 50,
//                     totalAmount: 50
//                 }
//             });
//         }
        
//         res.json({
//             success: true,
//             data: {
//                 totalQuantity: cart.totalQuantity,
//                 subtotal: cart.subtotal,
//                 deliveryFee: cart.deliveryFee,
//                 totalAmount: cart.totalAmount
//             }
//         });
//     } catch (error) {
//         console.error('Error in getCartSummary:', error);
//         res.status(500).json({
//             success: false,
//             message: error.message
//         });
//     }
// };

// module.exports = {
//     getCart,
//     addToCart,
//     updateCartItem,
//     removeFromCart,
//     clearCart,
//     getCartSummary
// };

// server/controllers/userController.js - Firebase version
const UserFirebase = require('../models/UserFirebase');
const catchAsync = require('../utils/catchAsync');
const AppError = require('../utils/appError');

// Helper function to filter object
const filterObj = (obj, ...allowedFields) => {
  const newObj = {};
  Object.keys(obj).forEach(el => {
    if (allowedFields.includes(el)) newObj[el] = obj[el];
  });
  return newObj;
};

// GET ME (Get current user)
exports.getMe = (req, res, next) => {
  req.params.id = req.user.id;
  next();
};

// GET ALL USERS (Admin only)
exports.getAllUsers = catchAsync(async (req, res, next) => {
  // For Firebase, we'll need a different approach
  // Since we don't have a findAll method yet, we'll create one
  
  const users = []; // Placeholder - we need to implement this
  
  res.status(200).json({
    status: 'success',
    results: users.length,
    data: { users }
  });
});

// GET USER
exports.getUser = catchAsync(async (req, res, next) => {
  const user = await UserFirebase.findById(req.params.id);
  
  if (!user) {
    return next(new AppError('No user found with that ID', 404));
  }
  
  // Remove sensitive data
  const userObj = { ...user };
  delete userObj.password;
  
  res.status(200).json({
    status: 'success',
    data: { user: userObj }
  });
});

// UPDATE ME
exports.updateMe = catchAsync(async (req, res, next) => {
  // Create error if user tries to update password
  if (req.body.password || req.body.confirmPassword) {
    return next(new AppError('This route is not for password updates. Please use /update-my-password.', 400));
  }
  
  // Filter allowed fields
  const filteredBody = filterObj(req.body, 'name', 'email', 'phoneNumber');
  
  // Get current user
  const user = await UserFirebase.findById(req.user.id);
  
  if (!user) {
    return next(new AppError('User not found', 404));
  }
  
  // Update user fields
  Object.assign(user, filteredBody);
  await user.save();
  
  res.status(200).json({
    status: 'success',
    data: { user }
  });
});

// DELETE ME
exports.deleteMe = catchAsync(async (req, res, next) => {
  const user = await UserFirebase.findById(req.user.id);
  
  if (!user) {
    return next(new AppError('User not found', 404));
  }
  
  // Soft delete - set active to false
  user.active = false;
  await user.save();
  
  res.status(204).json({
    status: 'success',
    data: null
  });
});

// UPDATE USER (Admin only)
exports.updateUser = catchAsync(async (req, res, next) => {
  const user = await UserFirebase.findById(req.params.id);
  
  if (!user) {
    return next(new AppError('No user found with that ID', 404));
  }
  
  // Update user fields
  Object.assign(user, req.body);
  await user.save();
  
  res.status(200).json({
    status: 'success',
    data: { user }
  });
});

// DELETE USER (Admin only)
exports.deleteUser = catchAsync(async (req, res, next) => {
  const user = await UserFirebase.findById(req.params.id);
  
  if (!user) {
    return next(new AppError('No user found with that ID', 404));
  }
  
  await user.delete();
  
  res.status(204).json({
    status: 'success',
    data: null
  });
});