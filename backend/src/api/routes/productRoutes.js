const express = require('express');
const router = express.Router();
const { getProducts, createProduct } = require('../controllers/productController');
const { protect, admin } = require('../middleware/authMiddleware');

// Public route - ทุกคนสามารถดูรายการสินค้าได้
router.route('/').get(getProducts);

// Admin only route - เฉพาะ Admin ที่สามารถสร้างสินค้าได้
router.route('/create').post(protect, admin, createProduct);

module.exports = router;