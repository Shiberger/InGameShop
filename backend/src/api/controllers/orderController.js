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
        ...item,
        product: item.id, // สมมติว่า frontend ส่ง id ของ product มา
        _id: undefined // ป้องกันไม่ให้ client กำหนด _id เอง
    })),
    totalPrice,
  });

  const createdOrder = await order.save();

  res.status(201).json(createdOrder);
});

module.exports = { createOrder };