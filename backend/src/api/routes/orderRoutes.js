const express = require('express');
const router = express.Router();
const { createOrder } = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');

router.route('/').post(protect, createOrder);

module.exports = router;