const asyncHandler = require('express-async-handler');
const Order = require('../models/OrderModel');

// @desc    Omise webhook handler
// @route   POST /api/webhooks/omise
// @access  Public
const omiseWebhookHandler = asyncHandler(async (req, res) => {
  const event = req.body;

  // ตรวจสอบว่าเป็น event 'charge.complete' หรือไม่
  if (event.object === 'event' && event.key === 'charge.complete') {
    const charge = event.data;

    // ตรวจสอบว่าการชำระเงินสำเร็จ (successful)
    if (charge.status === 'successful' && charge.paid) {
      const orderId = charge.metadata.order_id;

      // ค้นหา Order ในฐานข้อมูล
      const order = await Order.findById(orderId);

      if (order) {
        // อัปเดตสถานะ Order
        order.isPaid = true;
        order.paidAt = new Date();
        order.status = 'processing'; // หรือ 'completed' ถ้าไม่ต้องมีขั้นตอนอื่น
        await order.save();
        console.log(`Order ${orderId} has been paid.`);
      } else {
        console.error(`Webhook Error: Order not found with ID ${orderId}`);
      }
    }
  }

  // ต้องตอบกลับ status 200 OK ให้ Omise ทราบเสมอ
  res.sendStatus(200);
});

module.exports = { omiseWebhookHandler };