const express = require('express');
const router = express.Router();
const { createPromptPayCharge } = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');

router.post('/promptpay', protect, createPromptPayCharge);

module.exports = router;