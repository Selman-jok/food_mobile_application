// const express = require('express');
// const router = express.Router();
// const {
//     getAllFoods,
//     getFoodById,
//     createFood,
//     updateFood,
//     deleteFood,
//     addReview,
//     getFoodsByCategory,
//     getPopularFoods,
//     getSpecialOffers
// } = require('../controllers/foodController');

// // Public routes
// router.get('/', getAllFoods);
// router.get('/popular', getPopularFoods);
// router.get('/special-offers', getSpecialOffers);
// router.get('/category/:category', getFoodsByCategory);
// router.get('/:id', getFoodById);

// // Protected/Admin routes (you can add authentication middleware)
// router.post('/', createFood);
// router.put('/:id', updateFood);
// router.delete('/:id', deleteFood);

// // Review routes
// router.post('/:id/reviews', addReview);

// module.exports = router;

const express = require('express');
const router = express.Router();
const {
    getAllFoods,
    getFoodById,
    createFood,
    updateFood,
    deleteFood,
    addReview,
    getFoodsByCategory,
    getPopularFoods,
    getSpecialOffers
} = require('../controllers/foodController'); // Uses updated foodController.js

// Public routes
router.get('/', getAllFoods);
router.get('/popular', getPopularFoods);
router.get('/special-offers', getSpecialOffers);
router.get('/category/:category', getFoodsByCategory);
router.get('/:id', getFoodById);

// Protected/Admin routes - ADD authController
const authController = require('../controllers/authController'); // Add this
const { restrictTo } = require('../controllers/authController'); // Add this

// Update these to protected routes:
router.post('/', authController.protect, authController.restrictTo('admin'), createFood);
router.put('/:id', authController.protect, authController.restrictTo('admin'), updateFood);
router.delete('/:id', authController.protect, authController.restrictTo('admin'), deleteFood);

// Review routes - Remove from here (moved to reviewRoutes.js)
// router.post('/:id/reviews', addReview); // Remove this line

module.exports = router;