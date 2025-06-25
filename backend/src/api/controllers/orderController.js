const asyncHandler = require('express-async-handler');
const Order = require('../models/OrderModel');

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
const createOrder = asyncHandler(async (req, res) => {
  const { orderItems, totalPrice } = req.body;

  if (!orderItems || orderItems.length === 0) {
    res.status(400);
    throw new Error('No order items');
  }

  const order = new Order({
    user: req.user._id, // ได้มาจาก authMiddleware
    orderItems: orderItems.map(item => ({
      name: item.name,
      qty: item.qty,
      image: item.image,
      price: item.price,
      // --- จุดแก้ไข ---
      // เปลี่ยนจาก item.id เป็น item.product เพื่อให้ตรงกับที่ Frontend ส่งมา
      product: item.product, 
    })),
    totalPrice,
  });

  const createdOrder = await order.save();

  res.status(201).json(createdOrder);
});

module.exports = { createOrder };
