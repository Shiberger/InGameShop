require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
// Import Routes
const authRoutes = require('./api/routes/authRoutes');
const productRoutes = require('./api/routes/productRoutes'); // เพิ่มบรรทัดนี้

// Connect to Database
connectDB();

const app = express();
app.use(cors());
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
app.use('/api/products', productRoutes); // เพิ่มบรรทัดนี้

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});