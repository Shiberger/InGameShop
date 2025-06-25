require('dotenv').config();

// Import necessary modules
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// Import Routes
const authRoutes = require('./api/routes/authRoutes');
const productRoutes = require('./api/routes/productRoutes')
const orderRoutes = require('./api/routes/orderRoutes');

// Import Payment and Webhook Routes
const paymentRoutes = require('./api/routes/paymentRoutes');
const webhookRoutes = require('./api/routes/webhookRoutes');

// Connect to Database
connectDB();

const app = express();
app.use(cors());

// สำคัญ: Webhook ต้องใช้ raw body parser ก่อน json parser
app.use('/api/webhooks', express.raw({ type: 'application/json' }), webhookRoutes); 

app.use(express.json());

// Debug middleware - ADD THIS FIRST
app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.url}`);
  console.log('Headers:', req.headers);
  next();
});

// More debugging after JSON parsing
app.use((req, res, next) => {
  console.log('Body after JSON parsing:', req.body);
  next();
});

// Routes with debugging
app.use('/api/auth', (req, res, next) => {
  console.log('🔄 Auth route middleware hit');
  next();
}, authRoutes);

// Basic Route
app.get('/', (req, res) => {
  res.send('Welcome to In-Game Shop API!');
});

// Use the imported routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes); 
app.use('/api/orders', orderRoutes);
app.use('/api/payment', paymentRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});