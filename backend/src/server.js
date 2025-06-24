require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// Connect to Database
connectDB();

const app = express();

// Debug middleware - ADD THIS FIRST
app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.url}`);
  console.log('Headers:', req.headers);
  next();
});

// Middlewares
app.use(cors());
app.use(express.json());

// More debugging after JSON parsing
app.use((req, res, next) => {
  console.log('Body after JSON parsing:', req.body);
  next();
});

// Import Routes
const authRoutes = require('./api/routes/authRoutes');

// Routes with debugging
app.use('/api/auth', (req, res, next) => {
  console.log('🔄 Auth route middleware hit');
  next();
}, authRoutes);

// Basic Route
app.get('/', (req, res) => {
  res.send('Welcome to In-Game Shop API!');
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});