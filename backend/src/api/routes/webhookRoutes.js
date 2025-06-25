const express = require('express');
const router = express.Router();
const { omiseWebhookHandler } = require('../controllers/webhookController');

// Webhook ไม่ต้องใช้ middleware `protect` เพราะ Omise เป็นคนเรียกเข้ามา
router.post('/omise', omiseWebhookHandler);

module.exports = router;