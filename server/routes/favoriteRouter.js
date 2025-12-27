// const express = require('express');
// const router = express.Router();
// const {
//     getFavorites,
//     addToFavorites,
//     removeFromFavorites,
//     checkIsFavorite
// } = require('../controllers/favoriteController');

// // Import auth middleware
// const authController = require('../controllers/authController');

// // Protect all favorite routes
// router.use(authController.protect);

// // User's favorite routes
// router.get('/', getFavorites); // Get user's favorites
// router.post('/add', addToFavorites); // Add to favorites
// router.delete('/remove/:foodId', removeFromFavorites); // Remove from favorites
// router.get('/check/:foodId', checkIsFavorite); // Check if food is favorite

// module.exports = router;

// No changes needed
const express = require('express');
const router = express.Router();
const {
    getFavorites,
    addToFavorites,
    removeFromFavorites,
    checkIsFavorite
} = require('../controllers/favoriteController'); // Uses updated favoriteController.js

const authController = require('../controllers/authController');

router.use(authController.protect); // ✅ Firebase auth

router.get('/', getFavorites);
router.post('/add', addToFavorites);
router.delete('/remove/:foodId', removeFromFavorites);
router.get('/check/:foodId', checkIsFavorite);

module.exports = router;