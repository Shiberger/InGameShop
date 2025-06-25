const asyncHandler = require('express-async-handler');
const axios = require('axios');
const sharp = require('sharp'); // 1. Import sharp

const omise = require('omise')({
  publicKey: process.env.OMISE_PUBLIC_KEY,
  secretKey: process.env.OMISE_SECRET_KEY,
});

const createPromptPayCharge = asyncHandler(async (req, res) => {
  const { orderId, amount } = req.body;
  const amountInSatang = Math.round(amount * 100);

  try {
    // Step 1: สร้าง Charge กับ Omise เหมือนเดิม
    const charge = await omise.charges.create({
      amount: amountInSatang,
      currency: 'thb',
      source: { type: 'promptpay' },
      metadata: { order_id: orderId },
    });

    if (!charge.source?.scannable_code?.image?.download_uri) {
      throw new Error('Failed to retrieve QR code URL from Omise');
    }

    const qrCodeSvgUrl = charge.source.scannable_code.image.download_uri;

    // Step 2: ให้ Server ไปดาวน์โหลดข้อมูล SVG จาก URL นั้น
    console.log(`--- Downloading SVG from: ${qrCodeSvgUrl} ---`);
    const svgResponse = await axios.get(qrCodeSvgUrl, {
      responseType: 'arraybuffer' // รับข้อมูลเป็น Binary Buffer
    });

    // --- Step 3: (ใหม่) ใช้ sharp แปลง Buffer ของ SVG ให้เป็นรูปภาพ PNG ---
    console.log('--- Converting SVG to PNG using sharp... ---');
    const pngBuffer = await sharp(svgResponse.data).png().toBuffer();

    // Step 4: แปลง Buffer ของ PNG ให้เป็น Base64 String
    const base64Png = pngBuffer.toString('base64');
    console.log('--- PNG image converted to Base64 successfully ---');

    // Step 5: ส่ง Base64 String ของ "รูป PNG" กลับไปให้แอป
    res.json({
      qrCodeBase64: base64Png, // ส่ง Key ที่มีข้อมูล PNG Base64
    });

  } catch (error) {
    console.error('--- ❌ Payment processing failed ---', error);
    res.status(500).json({ message: 'Payment processing failed', error: error.message });
  }
});

module.exports = { createPromptPayCharge };
