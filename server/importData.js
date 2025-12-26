
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const Food = require('./models/Food');

dotenv.config();

const MONGODB_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/food_ordering_db';

mongoose.connect(MONGODB_URI)
  .then(() => console.log('MongoDB connected for data import'))
  .catch(err => {
    console.error('MongoDB connection error for import:', err);
    process.exit(1);
  });

const importData = async () => {
  try {
    // --- Food Import ---
    console.log('Deleting existing foods...');
    await Food.deleteMany();

    // Read food data from JSON file
    const foodDataPath = path.resolve(__dirname, './data/foodData.json');
    const rawFoodData = fs.readFileSync(foodDataPath, 'utf-8');
    const foodsFromFile = JSON.parse(rawFoodData);

    console.log(`Found ${foodsFromFile.length} food items to import...`);
    
    // Calculate totalReviews from reviews array
    const formattedFoods = foodsFromFile.map(food => {
      const foodItem = {
        ...food,
        // Ensure all required fields have defaults
        rating: food.rating || 0,
        totalReviews: food.reviews ? food.reviews.length : 0,
        available: food.available !== undefined ? food.available : true,
        // Parse numeric fields to ensure they're numbers
        price: typeof food.price === 'string' ? parseFloat(food.price) : food.price,
        originalPrice: food.originalPrice ? 
          (typeof food.originalPrice === 'string' ? parseFloat(food.originalPrice) : food.originalPrice) : 
          undefined,
        discountPercent: food.discountPercent ? 
          (typeof food.discountPercent === 'string' ? parseFloat(food.discountPercent) : food.discountPercent) : 
          undefined
      };
      
      // Add current date to reviews if not present
      if (foodItem.reviews) {
        foodItem.reviews = foodItem.reviews.map(review => ({
          ...review,
          date: new Date()
        }));
      }
      
      return foodItem;
    });

    console.log('Importing foods...');
    await Food.insertMany(formattedFoods);
    console.log('Foods imported successfully!');

    // Get import statistics
    const totalFoods = await Food.countDocuments();
    const categories = await Food.aggregate([
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);

    const popularCount = await Food.countDocuments({ isPopular: true });
    const specialCount = await Food.countDocuments({ isSpecialOffer: true });

    console.log('\n=== IMPORT SUMMARY ===');
    console.log(`Total foods imported: ${totalFoods}`);
    console.log(`Popular items: ${popularCount}`);
    console.log(`Special offers: ${specialCount}`);
    console.log('\nBy category:');
    categories.forEach(cat => {
      console.log(`  ${cat._id}: ${cat.count} items`);
    });

    process.exit();
  } catch (error) {
    console.error('Error importing data:', error);
    process.exit(1);
  }
};

const destroyData = async () => {
  try {
    console.log('Destroying all foods...');
    await Food.deleteMany();
    console.log('All foods destroyed!');
    process.exit();
  } catch (error) {
    console.error('Error destroying data:', error);
    process.exit(1);
  }
};

if (process.argv[2] === '--import') {
  importData();
} else if (process.argv[2] === '--delete') {
  destroyData();
} else {
  console.log('Usage: node importData.js --import (to import data) or node importData.js --delete (to delete all data)');
  console.log('Example:');
  console.log('  npm run import  (if you have script in package.json)');
  console.log('  OR');
  console.log('  node importData.js --import');
  process.exit(1);
}